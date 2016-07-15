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

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet private weak var webView: UIWebView!
    
    func didReceive(_ notification: UNNotification) {
        guard let interactiveURLString = notification.request.content.userInfo["interactiveURLString"] as? String, interactiveURL = URL(string: interactiveURLString) else { return }

        let urlRequest = URLRequest(url: interactiveURL)
        webView.loadRequest(urlRequest)
    }

}
