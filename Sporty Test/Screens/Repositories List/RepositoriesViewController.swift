import Combine
import GitHubAPI
import MockLiveServer
import SwiftUI
import UIKit

/// A view controller that displays a list of GitHub repositories for the "swiftlang" organization.
final class RepositoriesViewController: UITableViewController {
    
    private enum RepositoryMode: Codable {
        case user(String)
        case organization(String)
        
        var name: String {
            switch self {
            case .user(let name):
                return name
            case .organization(let name):
                return name
            }
        }
    }
    
    private enum Constants {
        static let mode = "mode"
    }
    
    private let gitHubAPI: GitHubAPI
    private let mockLiveServer: MockLiveServer
    private var repositories: [GitHubMinimalRepository] = []
    private var currentLoadingTask: Task<Void, Never>?
    private var subscriptionsByRepoId: [Int: AnyCancellable] = [:]
    
    private var mode: RepositoryMode {
        get {
            if let data = UserDefaults.standard.data(forKey: Constants.mode),
               let mode = try? JSONDecoder().decode(RepositoryMode.self, from: data) {
                return mode
            }
            
            return .organization("swiftlang")
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: Constants.mode)
            }
        }
    }

    init(gitHubAPI: GitHubAPI, mockLiveServer: MockLiveServer) {
        self.gitHubAPI = gitHubAPI
        self.mockLiveServer = mockLiveServer

        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: "RepositoryCell")
        
        let openRepositoryButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass.circle.fill"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(openRepositoryTapped))
        
        let setTokenButton = UIBarButtonItem(image: UIImage(systemName: "key.icloud.fill"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(setTokenTapped))
        
        navigationItem.rightBarButtonItems = [setTokenButton, openRepositoryButton]
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshRepositories), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        self.refreshControl = refreshControl

        refreshRepositories()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repositories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repository = repositories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: indexPath) as! RepositoryTableViewCell

        cell.name = repository.name
        cell.descriptionText = repository.description
        cell.starCountText = repository.stargazersCount.formatted()
        
        startStarCountUpdates(for: cell, repository: repository)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let repoId = (cell as? RepositoryTableViewCell)?.repoId {
            cancelStarCountUpdates(for: repoId)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        let viewController = RepositoryViewController(
            minimalRepository: repository,
            gitHubAPI: gitHubAPI
        )
        show(viewController, sender: self)
    }
    
    @objc private func refreshRepositories() {
        currentLoadingTask?.cancel()
        
        refreshControl?.beginRefreshing()
        
        currentLoadingTask = Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            
            let repositories: [GitHubMinimalRepository]
            // TODO: show loading indicator
            do {
                switch mode {
                case .user(let username):
                    repositories = try await gitHubAPI.repositoriesForUser(username)
                case .organization(let org):
                    repositories = try await gitHubAPI.repositoriesForOrganisation(org)
                }
                
                if Task.isCancelled {
                    return
                }
            } catch {
                // TODO: Error handling and empty state (alert, empty data view)
                print("Error loading repositories: \(error)")
                repositories = []
            }
            
            // Cancel all update subscriptions
            for repoId in subscriptionsByRepoId.keys {
                cancelStarCountUpdates(for: repoId)
            }
            
            // TODO: hide loading indicator
            self.repositories = repositories
            
            title = mode.name
            tableView.reloadData()
            
            refreshControl?.endRefreshing()
        }
    }
    
    @objc private func setTokenTapped() {
        let alert = UIAlertController(title: "Set authorization token",
                                      message: "Enter token.",
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }

        let setAction = UIAlertAction(title: "Set", style: .default) { [weak self, weak alert] _ in
            if let textField = alert?.textFields?.first {
                self?.updateToken(textField.text)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(setAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
    
    private func updateToken(_ value: String?) {
        do {
            // Clear the token when field is empty
            let token = value?.isEmpty == false ? value! : nil
            if token != nil {
                try KeychainHelper.shared.set(token!, forKey: KeychainHelper.Keys.authToken)
            } else {
                try KeychainHelper.shared.delete(forKey: KeychainHelper.Keys.authToken)
            }
            print("token set")
            
            // Refresh the UI
            Task { @MainActor in
                await gitHubAPI.updateAuthorisationToken(token)
                refreshRepositories()
            }
        } catch {
            // TODO: Error handling
            print("error setting token: \(error.localizedDescription)")
        }
    }
    
    @objc private func openRepositoryTapped() {
        let alert = UIAlertController(title: "Open Repositories",
                                      message: "Enter name.",
                                      preferredStyle: .alert)

        alert.addTextField { textField in
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }

        let openUserRepoAction = UIAlertAction(title: "User Repositories", style: .default) { [weak self, weak alert] _ in
            if let textField = alert?.textFields?.first,
               let user = textField.text {
                self?.updateMode(.user(user))
            }
        }
        
        let openOrgRepoAction = UIAlertAction(title: "Organization Repositories", style: .default) { [weak self, weak alert] _ in
            if let textField = alert?.textFields?.first,
               let org = textField.text {
                self?.updateMode(.organization(org))
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(openUserRepoAction)
        alert.addAction(openOrgRepoAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
    
    private func updateMode(_ mode: RepositoryMode) {
        self.mode = mode
        refreshRepositories()
    }
    
    private func startStarCountUpdates(for cell: RepositoryTableViewCell, repository: GitHubMinimalRepository) {
        cell.repoId = repository.id // So we can check & update the value once it is delivered
        
        subscriptionsByRepoId[repository.id]?.cancel()
        subscriptionsByRepoId[repository.id] = nil
        
        // Start/replace a live subscription for star updates for this repo
        Task { @MainActor [weak cell] in
            if let cancellable = try? await mockLiveServer.subscribeToRepo(
                repoId: repository.id,
                currentStars: repository.stargazersCount,
                subscriber: { [weak cell] newStars in
                    Task { @MainActor [weak cell] in
                        // Check if cell has been reused
                        if cell?.repoId == repository.id {
                            cell?.starCountText = newStars.formatted()
                        }
                    }
                }) {
                subscriptionsByRepoId[repository.id] = cancellable
            }
        }
    }
    
    private func cancelStarCountUpdates(for repoId: Int) {
        subscriptionsByRepoId[repoId]?.cancel()
        subscriptionsByRepoId[repoId] = nil
    }
}
