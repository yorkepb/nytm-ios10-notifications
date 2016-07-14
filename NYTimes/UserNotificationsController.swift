//
//  UserNotificationsController.swift
//  NYTimes
//
//  Created by yorkepb on 7/12/16.
//  Copyright © 2016 iYorke. All rights reserved.
//

import UIKit
import UserNotifications

/**
  A controller class specifically responsible for handling UNUserNotificationCenterDelegate functionality.
  
  In iOS 10 fewer responsibilities lie with the app delegate and a new delegate object is available for setup and managing notifications. This delegate object is responsible for handling the receipt of notifications. However for the purpose of this prototype I have also included notification authorization and registration. 
 */ 
class UserNotificationController: NSObject, UNUserNotificationCenterDelegate {

	// MARK: Interactive Notifications (ancillary to the prototype)
	
	/**
	  An enum provided to contain information relative to the notification actions. This is provided as a means of easily identifying action strings in other locations of the app (for handling notification action responses from users)
	 */
	enum NotificationActions: String {
		case .Follow = "follow"
		case .Read = "read"
		
		/**
		  TODO: determine if this can be a var instead of a func
		 */
		private func title() -> String {
			switch self {
				case .Follow:
					return "Follow for Updates"
				case .Read:
					return "Read Story"
			}
		}
	}

	/**
	  Two notification actions used for interactive notifications but here just as examples. This is functionality introduced in iOS 8, not new to iOS 10 however the object types have changed from `UIUserNotificationAction` to the new `UNNotificationAction`. Everything else about how this functions is the same. 
	 */
    private static var followAction = UNNotificationAction(identifier: NotificationActions.Follow.rawValue, title: NotificationActions.Follow.title(), options: [])
    private static var readAction = UNNotificationAction(identifier: NotificationActions.Read.rawValue, title: NotificationActions.Read.title(), options: [.foreground])
    
    /**
      This is also not new and provided simply for functionality in notifications. This is functionality introduced in iOS 8, not new to iOS 10 however the object types have changed from `UIUserNotificationCategoru` to the new `UNNotificationCategory`. Everything else about how this functions is the same. 
     */
    private var followCategory -> UNNotificationCategory = {
        return UNNotificationCategory(identifier: NotificationActions.Follow.rawValue, actions: [UserNotificationController.readAction, UserNotificationController.followAction], minimalActions: [UserNotificationController.readAction, UserNotificationController.followAction], intentIdentifiers: [], options: [])
    }()

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

        UNUserNotificationCenter.current().setNotificationCategories(Set([followCategory]))
    }
    
    // MARK: UNUserNotificationCenterDelegate Functions

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print(response.notification.request.content.userInfo)
        completionHandler()
    }
}
