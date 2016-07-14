//
//  AppDelegate.swift
//  NYTimes
//
//  Created by yorkepb on 7/12/16.
//  Copyright © 2016 iYorke. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationController = UserNotificationController()

    /**
     Prior to returning from this function, the UNUserNotificationControllerDelegate must be set. In this case I am setting it as a property on this object and in the initializer of that property I am setting the delegate. This ensures that it is setup before `init` finishes.
    */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    /**
     This method was introduced in iOS 3 and has not changed. The gist of it is the same with it being the call back upon successfully registering the device for push notifications. That registration should happen each fresh launch of the app as this is how you will get any updates to the device token should it change and since it is not guaranteed to stay the same you should plan on the possibility that it can change. Once this call back is received you will take the deviceToken (usually converted to string format as seen below) and pass it to your push notification service for registration.
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: ""))
    }

    /**
     Also not new, this function will inform your application should registration fail.
     */
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Remote Notification Registration Failed: \(error)")
    }

    /**
     Introduced in iOS 7, this function replaced the `didReceiveRemoteNotification` function which did not contain a completion handler. This function use to be used for capturing remote notifications which either were received while the app was foregrounded or that the user interacted with. Now this function is much more specific to handling background fetch calls made through push notifications by including the `"content-available":1` key/value pair in your payload. Doing so will pass the notification and payload through to this API the moment that the push notification is received rather than having to wait for your user to interact with it. This will give you the opportunity to log an analytic about the push notification being received as well as prepare your application for the updated content. Be aware though that if the user manually force quits the app by swiping up in the app switcher or if your app crashes, this API will not receive any call backs until the next time the app is launched. Additionally if you do not call the completionHandler within a timely manner, your app will crash.
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("did receive remote notification (background) with userInfo: \(userInfo)")
        completionHandler(.noData)
    }
}

