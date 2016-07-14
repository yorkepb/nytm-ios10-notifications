# nytm-ios10-notifications
An iOS 10 Prototype Implementation of Notifications for NYTMobile

Author: iYrke - <paul.yorke@nytimes.com>

This application is meant as a prototype of an implementation of Push Notifications for iOS 10. It leverages a lot of the new functionality including service extensions, rich media attachments and custom views. None of the code is production code and is only meant as an example of implementation and a prototype of the features for exploration.

Documentation and a sample app from Apple is not readily available. This app provides the sample as well as documentation of everything I've found along the way. Documentation will be provided inline with as much detail as I have been able to figure out. 

To run this application you must use xcode 8 running on iOS 10+. To test, send a push or location notification with content similar to this:

```
{"aps":{"alert":{"title":"Breaking News", "subtitle": "developing", "body": "Two years after Eric Garner died in a police chokehold, the case has stalled. “How much investigation do you need?” his widow said."}, "sound":"default", "category":"follow", "mutable-content": 1}, "content_id":12345}
```

To debug the app, be sure to run the appropriate scheme based on which binary you are working with, service extension, content extension and main app. 
