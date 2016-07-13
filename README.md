# nytm-ios10-notifications
an iOS 10 Implementation of Notifications for NYTM

This application is meant as a prototype of an implementation of Push Notifications for iOS 10. It leverages a lot of the new functionality including service extensions, rich media attachments and custom views. None of the code is production code and is only meant as an example of implementation and a prototype of the features for exploration.

To run this application you must use xcode 8 running on iOS 10+. To test, send a push or location notification with content similar to this:

```
{"aps":{"alert":{"title":"Breaking News", "body": "Two years after Eric Garner died in a police chokehold, the case has stalled. “How much investigation do you need?” his widow said."}, "sound":"default", "category":"follow", "mutable-content": 1}, "content_id":12345}
```

Author: iYrke <paul.yorke@nytimes.com>
