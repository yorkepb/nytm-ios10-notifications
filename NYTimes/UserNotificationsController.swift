//
//  UserNotificationsController.swift
//  NYTimes
//
//  Created by iYrke on 7/12/16.
//  Copyright © 2016 iYorke. All rights reserved.
//

import UIKit
import UserNotifications

/**
 A controller class specifically responsible for handling UNUserNotificationCenterDelegate functionality.
  
 In iOS 10, fewer responsibilities lie with the app delegate and a new delegate object is available for setup and managing notifications. This delegate object is responsible for handling the receipt of notifications. However for the purpose of this prototype I have also included notification authorization and registration.
 */ 
class UserNotificationController: NSObject, UNUserNotificationCenterDelegate {

    /**
     This is also not new and provided simply for functionality in notifications. This is functionality introduced in iOS 8, not new to iOS 10 however the object types have changed from `UIUserNotificationCategoru` to the new `UNNotificationCategory`. Everything else about how this functions is the same. 
     */
    private var followCategory: UNNotificationCategory = {
        return UNNotificationCategory(identifier: "follow", actions: [InteractiveNotifications.Read.action(), InteractiveNotifications.Follow.action()], minimalActions: [InteractiveNotifications.Read.action(), InteractiveNotifications.Follow.action()], intentIdentifiers: [], options: [])
    }()

    private var saveCategory: UNNotificationCategory = {
        return UNNotificationCategory(identifier: "save", actions: [InteractiveNotifications.Read.action(), InteractiveNotifications.Save.action()], minimalActions: [InteractiveNotifications.Read.action(), InteractiveNotifications.Save.action()], intentIdentifiers: [], options: [])
    }()

    override init() {
        super.init()
        
        /**
         Setting the delegate allows for notification call backs to this class. This delegate _must_ be set prior to the app returning from `application(_:didFinishLaunchingWithOptions:)`. So if done from a secondary delegate controller make sure that controller is instantiated and the delegate is set prior to returning.
         */
        UNUserNotificationCenter.current().delegate = self

        /**
         In iOS 9 and below, getting information about user settings around notifications were heavily limited. There was no way to tell the difference between a user with alerts, badges and sounds off and a user with notifications off. In iOS 10 there is now a way to retrieve information about everything around notification settings. Upon calling the api to get notification settings, the closure is run with a full set of settings including alerts, badges, sounds, lock screen, notification center and alert style. But also Authorization Status is included which will be one of the following:
 
         .notDetermined: indicates that the user has never been prompted to authorize the app to send notifications. This status is useful to figure out if a previous authorization has been done and if the user has seen and responded to the push permission prompt.
         .authorized: indicates that at present the user has notifications turned on for the app regardless of the other individual settings.
         .denied: indicates that at present the user has notifications turned off for the app.
 
         Here I am getting the notification settings before requesting authorization. This allows me to determine whether or not I have previously requested authorization and whether or not I should bother aetting up the rest of the notification stuff. If the authorization status is `NotDetermined` then I will know this is the first time I am requesting authorization and can log an analytic for the users' response. 
         */
        UNUserNotificationCenter.current().getNotificationSettings { settings in self.register(withAuthorizationStatus: settings.authorizationStatus) }

    }

    private func register(withAuthorizationStatus authorizationStatus: UNAuthorizationStatus) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (authorized, error) in
            /**
             At this point I have authorizationStatus which I will use to log an analytic if it is `.notDetermined`. This allows me to ensure that the analytic is only logged the first time when the user is prompted to authorize the app. The `authorized` bool informs me how the user reacted to the push permission prompt.
            */
            if authorizationStatus == .notDetermined {
                print("we just logged that the user selected: \(authorized)")
            }

            /**
             If the user denied my request to send push notifications or has at any point turned them off in settings then there is no point in going any further. So I am only going to do this is `authorized` is `true`.
             */
            if authorized {
                UIApplication.shared().registerForRemoteNotifications()

                /**
                 This again hasn't changed and is all about setting up the categorie created above. There can be many categories, each category corresponds to a given set of Interactive Notifications, but will also be used to select a Notification Content Extension if you choose to have a custom view for your notifications. Each extension may have multiple categories however each category may only be assigned to a single extension. Additionally the category will influence the storyboard scene used for the Watch App when presenting a notification.
                 */
                UNUserNotificationCenter.current().setNotificationCategories(Set([self.followCategory, self.saveCategory]))
            }
        }
    }
    
    // MARK: UNUserNotificationCenterDelegate Functions

    /**
     This function is a call back which is made when a push notification is received while the app is in the foreground. This will give you the opportunity to prepare for the push notification and decide whether or not the notification should be presented to the user by the system. This function is optional and if it is not implemented OR if the completionHandler is not called within a set time limit the notification will not be presented to the user. Use this method to determine how to present the notification to the user.
     
     If this function is not implemented then push notifications received while the app is int he foreground will be sent through the old `didReceiveRemoteNotifications` API of the AppDelegate.
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    /**
     This function is a call back made when a push notification has been interacted with by the user for example, either tapping the notification to launch the app or tapping one of the interactive notification actions. This will be your opportunity to respond to the actions and/or present additional information based on the notification. Be sure to call the completionHandler within a reasonable amount of time.
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print(response.notification.request.content)
        completionHandler()
    }
}
