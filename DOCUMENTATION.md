# Documentation:

## I was able to do:

A. Add UI to store the authorisation token used to access the GitHub API.
B. Add UI to request the repos for a different user.
E. Implement pull-to-refresh.
G. Implement real-time updates of the star count using the provided `MockLiveServer`.

Please review the commit history, I did not add much inline documentation as I hope the changes are gradual and self-explanatory.


### AI: 

I used AI to generate the intial implementation of KeychainHelper.

I used AI to suggest a simple implementation for the real-time updates and to help me figure out whether I am missing something after I did the implementation (I missed clearing the subscribers on reload).


### TIME: 

I took a look at the task the day before and saw it was using UIKit (have not written UIKit code in more than a year so I needed a refresh) so I had an idea on how to add auth key, the open repo button and how to implement the refresh control for example. I would not have had time for the the real-time updates otherwise. But I did all the coding and functionality verification in less than 2 hours.

I chose to do the real-time updates as it seemed a more interesting problem than wiring the Deep Linking logic.


### UNFINISHED:

- C: I would have not been able to do the refactoring in 2 hours for sure. I would change a lot of components. Make the code testable (new services, interfaces), move the business logic to AppCoordinator and the ViewControllers would be View-only, rewrite the streaming of updates as it took me some time to figure out how it worked.

- D: After the 2 hour mark I wanted to implement the deep linking logic. Surprisingly it took me 30 more minutes as I needed to test the parser, then to update the structure and allow AppCoordinator to update the view controller's mode and handle edge cases.

- G: I did not have time to add streaming updates to the RepositoryViewController. After running out of time I asked the AI to do it, it did it in less than 1 minute. But it is not my code so I did not add it.

Also I probably should have done some throttling of updates to improve frame rates while scrolling for example.

- F: The cell layout would probably take me some time, but I would just use a UIStackView (vertical) in case the title was too long. So I would put the title on the top and the star and the count on the bottom, right aligned.
