//
//  UserNotificationsController.swift
//  NYTimes
//
//  Created by yorkepb on 7/12/16.
//  Copyright © 2016 iYorke. All rights reserved.
//

import UIKit
import UserNotifications

class UserNotificationController: NSObject, UNUserNotificationCenterDelegate {

    var followAction = UNNotificationAction(identifier: "follow", title: "Follow for Updates", options: [])
    var readAction = UNNotificationAction(identifier: "read", title: "Read Story", options: [.foreground])

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().getNotificationSettings { settings in self.register(withAuthorizationStatus: settings.authorizationStatus) }

    }

    private func register(withAuthorizationStatus authorizationStatus: UNAuthorizationStatus) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (authorized, error) in
            //Note: Here is where we can do things specific to the authorization. For example if the user has revoked authorization here we would change our behavior.

            if authorizationStatus == .notDetermined {
                print("we just logged that the user selected: \(authorized)")
            }

            if authorized {
                UIApplication.shared().registerForRemoteNotifications()
            }
        }

        UNUserNotificationCenter.current().setNotificationCategories(Set([followCategory()]))
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print(response.notification.request.content.userInfo)

        completionHandler()
    }

    func followCategory() -> UNNotificationCategory {
        return UNNotificationCategory(identifier: "follow", actions: [readAction, followAction], minimalActions: [readAction, followAction], intentIdentifiers: [], options: [])
    }
}
