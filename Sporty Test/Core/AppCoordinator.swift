import GitHubAPI
import MockLiveServer
import UIKit

@MainActor
final class AppCoordinator {
    private let window: UIWindow
    private let gitHubAPI: GitHubAPI
    private let mockLiveServer: MockLiveServer

    init(window: UIWindow) {
        self.window = window
        let tokenValue = KeychainHelper.authToken
        let token = tokenValue?.isEmpty == false ? tokenValue! : nil
        gitHubAPI = GitHubAPI(authorisationToken: token)
        mockLiveServer = MockLiveServer()
    }

    func start() {
        window.rootViewController = UINavigationController(
            rootViewController: RepositoriesViewController(
                gitHubAPI: gitHubAPI,
                mockLiveServer: mockLiveServer
            )
        )
        window.makeKeyAndVisible()
    }
}
