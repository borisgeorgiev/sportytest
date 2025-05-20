import GitHubAPI
import SwiftUI
import UIKit

/// A view controller that displays the details of a GitHub repository.
final class RepositoryViewController: UIViewController {
    private let minimalRepository: GitHubMinimalRepository
    private let gitHubAPI: GitHubAPI

    init(minimalRepository: GitHubMinimalRepository, gitHubAPI: GitHubAPI) {
        self.minimalRepository = minimalRepository
        self.gitHubAPI = gitHubAPI

        super.init(nibName: nil, bundle: nil)

        title = minimalRepository.name
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let hostingViewController = UIHostingController(
            rootView: RepositoryView(minimalRepository: minimalRepository, gitHubAPI: gitHubAPI)
        )
        addChild(hostingViewController)
        view.addSubview(hostingViewController.view)
        hostingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingViewController.didMove(toParent: self)
    }
}

/// A view displaying the details of a GitHub repository.
private struct RepositoryView: View {
    let minimalRepository: GitHubMinimalRepository
    let gitHubAPI: GitHubAPI

    @State private var fullRepository: GitHubFullRepository?

    var body: some View {
        List {
            Group {
                RepositoryValueView(key: "Name") {
                    Text(minimalRepository.name)
                        .foregroundColor(.secondary)
                }

                RepositoryValueView(key: "Description") {
                    if let description = minimalRepository.description {
                        Text(description)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No description")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }

                RepositoryValueView(key: "Stars") {
                    Text("\(minimalRepository.stargazersCount)")
                        .foregroundColor(.secondary)
                }

                RepositoryValueView(key: "Forks") {
                    if let fullRepository {
                        Text("\(fullRepository.networkCount)")
                            .foregroundColor(.secondary)
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .task {
            do  {
                fullRepository = try await gitHubAPI.repository(minimalRepository.fullName)
            } catch {
                print("Error loading full repository: \(error)")
            }
        }
    }
}

private struct RepositoryValueView<Value: View>: View {
    let key: String
    let value: Value

    var body: some View {
        VStack(alignment: .leading) {
            Text(key)
                .font(.headline)
            value
        }
    }

    init(key: String, @ViewBuilder value: () -> Value) {
        self.key = key
        self.value = value()
    }
}
