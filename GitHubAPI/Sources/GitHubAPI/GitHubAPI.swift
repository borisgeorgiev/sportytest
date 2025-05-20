import Foundation

/// A very basic type used to interact with the GitHub API.
///
/// You may choose to add new functions here if you would like to access new endpoints. Don't worry
/// about improving this type (e.g. removing duplication); just add what you need.
public struct GitHubAPI: Sendable {
    private let baseURL: URL
    private let authorisationToken: String?
    private let urlSession: URLSession

    /// Creates a new object for interacting with the GitHub API.
    ///
    /// - parameter baseURL: The base URL for the GitHub API. Defaults to `https://api.github.com`.
    /// - parameter authorisationToken: An optional authorisation token to use when authenticating.
    /// - parameter urlSession: The URL session to use for network requests. Defaults to `.shared`.
    public init(
        baseURL: URL = URL(string: "https://api.github.com")!,
        authorisationToken: String? = nil,
        urlSession: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.authorisationToken = authorisationToken
        self.urlSession = urlSession
    }

    /// Retrieves the repositories for a given organisation.
    ///
    /// - parameter organisation: The name of the organisation to retrieve repositories for.
    /// - returns: An array of `GitHubMinimalRepository` objects representing the repositories for
    ///   the provided organisation.
    public func repositoriesForOrganisation(_ organisation: String) async throws -> [GitHubMinimalRepository] {
        let url = baseURL.appendingPathComponent("orgs/\(organisation)/repos")
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        if let authorisationToken {
            request.setValue("Bearer \(authorisationToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, _) = try await urlSession.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([GitHubMinimalRepository].self, from: data)
    }

    /// Retrieves a specific repository by its full name. The full name should be a value returned
    /// by the GitHub API and is in the form `<owner>/<repository>`.
    ///
    /// - parameter fullName: The full name of the repository to retrieve.
    /// - returns: A `GitHubFullRepository` object representing the repository.
    public func repository(_ fullName: String) async throws -> GitHubFullRepository {
        let url = baseURL.appendingPathComponent("repos/\(fullName)")
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        if let authorisationToken {
            request.setValue("Bearer \(authorisationToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, _) = try await urlSession.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GitHubFullRepository.self, from: data)
    }
}
