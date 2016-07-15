//
//  NotificationViewController.swift
//  Notification Content Interactive
//
//  Created by yorkepb on 7/15/16.
//  Copyright © 2016 iYorke. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

/**
 This class is auto generated when a Notification Content Extension is created. It is necessary to configure the storyboard scene which will be loaded as the custom view for a given notification. When the extension is created it is done so with a `MainInterface.storyboard` as well as an `info.plist`. There are a few `info.plist` attributes that come preconfigured and some you must configure on your own to get this to work:

 Under they key: `NSExtension`:
 Under the Key: `NSExtensionAttributes`:
 `UNNotificationExtensionCategory`: Set this to the category used when sending the push notification
 `UNNotificationExtensionInitialContentSizeRatio`: Set this as a ratio of height to width of the initial View Controller
 `UNNotificationExtensionDefaultContentHidden`: Set this to true if you do not want the notification details (title, subtitle, body) appended to your view. Default is false if not configured.

 You must define a category for each extension you include in your app. You may have as many extensions as you would like and an extension may have multiple categories assigned to it, however each category may only be assigned to a single extension.
 */
class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    /**
     IBOutlets linked to storyboard assets. Currently there is a bug wherein if you link the objects to the outlets, the view will fail to setup, instead link the outlets to the object by selection `Notification View Controller` in the storyboards and setting them on the view controller.
     */
    @IBOutlet private weak var webView: UIWebView!
    
    /**
     This function must be implemented in order to receive the notification content.
     */
    func didReceive(_ notification: UNNotification) {
        guard let interactiveURLString = notification.request.content.userInfo["interactiveURLString"] as? String, interactiveURL = URL(string: interactiveURLString) else { return }

        let urlRequest = URLRequest(url: interactiveURL)
        webView.loadRequest(urlRequest)
    }

}
