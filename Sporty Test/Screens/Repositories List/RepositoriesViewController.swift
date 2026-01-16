import Combine
import GitHubAPI
import MockLiveServer
import SwiftUI
import UIKit

/// A view controller that displays a list of GitHub repositories for the "swiftlang" organization.
final class RepositoriesViewController: UITableViewController {
    private let gitHubAPI: GitHubAPI
    private let mockLiveServer: MockLiveServer
    private var repositories: [GitHubMinimalRepository] = []

    init(gitHubAPI: GitHubAPI, mockLiveServer: MockLiveServer) {
        self.gitHubAPI = gitHubAPI
        self.mockLiveServer = mockLiveServer

        super.init(style: .insetGrouped)

        title = "swiftlang"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: "RepositoryCell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "key.icloud.fill"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(setTokenTapped))

        Task {
            await loadRepositories()
        }
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

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        let viewController = RepositoryViewController(
            minimalRepository: repository,
            gitHubAPI: gitHubAPI
        )
        show(viewController, sender: self)
    }

    private func loadRepositories() async {
        do {
            let api = GitHubAPI()
            repositories = try await api.repositoriesForOrganisation("swiftlang")
            tableView.reloadData()
        } catch {
            print("Error loading repositories: \(error)")
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
                await loadRepositories()
            }
        } catch {
            // TODO: Error handling
            print("error setting token: \(error.localizedDescription)")
        }
    }
}
