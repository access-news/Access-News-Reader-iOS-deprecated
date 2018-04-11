p FileManager.default.contentsOfDirectory(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0], includingPropertiesForKeys: nil, options: [])
UI TODO
=======

"Settings" goes to a table view where "Logout" is on the bottom
  + Strive for an adaptive interface such as the iOS "Settings"
    (i.e., on iPhone, it is a tableview, on iPad it is a split view)

"Recordings" goes to a sectioned table view. Sections:
  + "Current status" 
     Shows whether a recording is in progress (u.i., is there an unqueued audio).
  + "Queued"
  + "Submitted"

"Help!" menu(?) to call, email or message Access News.

Show reader statistics -> Settings?

"Submit" uploads all queued recordings, including the current one that is stopped.
It behaves the same way if there are many queued recordings or none: a modal view
pops up, asks for how much time they spent recording and then it sends the file(s)
to firebase.

Tooltips section on each audio control status. For example, when recording is stopped,
it will say that "To resume recording, press Record. To start recording another article,
press Queue and tap Record after that. Or to upload the article right now, hit Submit."
And so on.

On "Submit" and "Queue" -> popup dialog to confirm publication (and optionally, the
title). For example, "Saving Sacramento Bee article (titled blabla). Confirm ChangePublication"

Notes
=====

`GoogleInfo.plist` is added to the repo, because the final
service will run on another account and anyone finding
this app useful should set up their own Firebase project.
https://stackoverflow.com/questions/44937175/firebase-should-i-add-googleservice-info-plist-to-gitignore

TODO
====

* Extend this README with potential use cases (e.g., with trivial
  modification, this could be used as a personal app to upload files/content
  to Google Storage via Firebase)

* Add a license (currently exclusive copyright applies)

Resources found useful during developing this app
=================================================

+ http://www.talkmobiledev.com/2017/01/22/create-a-custom-share-extension-in-swift/

+ https://www.makeschool.com/online-courses/tutorials/build-a-photo-sharing-app-9f153781-8df0-4909-8162-bb3b3a2f7a81/getting-started

+ https://hackernoon.com/how-to-build-an-ios-share-extension-in-swift-4a2019935b2e

+ Matt Neuburg books (iOS Programming Fundamentals with Swift + Programming iOS 11)

+ Cocoapods and Podfiles: https://stackoverflow.com/questions/41114967/how-to-add-firebase-to-today-extension-ios/48213902#48213902

+ This helped deciphering `init`s in Firebase-iOS-SDK's undocumented classes: http://joemburgess.com/2014/10/13/why-the-underscores-in-init/

+ [How to load view controllers (navigation controller included) with their xib/nib views without a storyboard](https://www.weheartswift.com/remove-storyboard-from-project/)

+ [Set NSExtensionActivationRule to accept audio only](https://stackoverflow.com/questions/29546283/ios-share-extension-how-to-support-wav-files/30536743#30536743)
