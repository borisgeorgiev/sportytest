# Sporty Coding Challenge

Welcome to the Sporty coding challenge for iOS. This project contains a basic app that queries the GitHub API for the repositories owned by an organisation.

The GitHub API does not require authentication to access, but does have a [limit of 60 requests per hour](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28#primary-rate-limit-for-unauthenticated-users). If you hit this limit you can provide a authorisation token in the initialiser of the `AppCoordinator`. See https://docs.github.com/en/rest/authentication/authenticating-to-the-rest-api?apiVersion=2022-11-28#authenticating-with-a-personal-access-token for more information.

## Guidelines

- Spend around 1.5 - 2 hours on the challenge.
- Create git commits at appropriate times.
- Do not add any external dependencies.
- You may use whichever technologies you are most comfortable with, for example UIKit and SwiftUI and both ok, as are `UITableView` and `UICollectionView`, and XCTest and Swift Testing.
- Please document any decision you make. This could in the form of a separate document you include as part of your submission or inline in the codebase.
- Note that this challenge will be discussed as part of the technical interview stage. You should be prepared to discuss the reasoning behind the technical decisions you made, what you would improve, and what your next steps would be.
- When you are finished please zip the full directory, including the `.git` directory. You can use the `archive-test.sh` script to do this.
- Feel free to use AI to help with the challenge. For example Xcode's Predictive code completion, Copilot, or a tool of your choice. Please document areas you used AI.

## Tasks

You may choose from any of the tasks below. **You are not expected to complete all of these tasks**; complete the tasks that you feel best demonstrate your skills.

A. Add UI to store the authorisation token used to access the GitHub API.
B. Add UI to request the repos for a different user.
C. Refactor the `ReposViewController` to use an architecture of your choosing.
D. Implement deep links to a specific repo.
E. Implement pull-to-refresh.
F. Modify `RepositoryTableViewCell` to modify its layout when the title and star count cannot fit on a single line.
G. Implement real-time updates of the star count using the provided `MockLiveServer`.
