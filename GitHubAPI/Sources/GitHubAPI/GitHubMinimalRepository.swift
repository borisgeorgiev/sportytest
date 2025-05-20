/// A minimal set of information returned by the the GitHub API.
public struct GitHubMinimalRepository: Sendable, Codable {
    /// The unique identifier for the repository.
    public let id: Int

    /// The name of the repository.
    public let name: String

    /// The full name of the repository, including the owner.
    public let fullName: String

    /// A description of the repository.
    public let description: String?

    /// The number of stars the repository has received.
    public let stargazersCount: Int
}
