SnapOperationQueue is made to resemble NSOperationQueue and has options to quickly rearrange the queued priorities

In Snapsale we make A LOT of network requests to our backend. At the same time, it is easy to navigate from screen to screen. When we go from one screen to another, we do not want the currently visible screen to have its data arrive late because we were executing network requests for a screen that is no longer visible. The information on the screen that is no longer visible is still relevant: the user will probably go back. But it should be deprioritized to what the currently visible screen needs. Similarly, when scrolling a scroll view, what is visible on screen should take priority of what has been scrolled off screen.

Of course, there are situations where an operation that has not yet been performed yet is no longer needed, and should be cancled. Also, there are situations where an operation should have the highest priority no matter what is visible on screen.

SnapOperationQueue wraps four queues with the following priorities:
  .Highest
  .High
  .Normal
  .Low
  
.Highest and .Low don't rearrange. When operations with dependent operations rearrange, they are put in the queue that matches the highest priority in its set of dependencies.

An operation is added with an identifier, a priority (defaults to .High) and a group identifier. The group identifier would typically be your view controller identifier. Then, on viewDidDisappear, it would call queue.setGroupPriorityTo(.Low, forId: groupId). Remember to wrap groupIds in a StringRepresentable enum. When the view controller reappears, it would call queue.setGroupPriorityTo(.High, forId: groupId)

Uses [PSNotification][0], a maintained version of Apple's WWDC'15 sample code

[0]: https://github.com/pluralsight/PSOperations