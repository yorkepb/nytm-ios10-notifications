//
//  NotificationViewController.swift
//  Notification Content
//
//  Created by yorkepb on 7/13/16.
//  Copyright © 2016 iYorke. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet var secondLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        guard let headline = notification.request.content.userInfo["headline"] as? String,
            summary = notification.request.content.userInfo["summary"] as? String else { return }

        self.label?.text = headline
        self.secondLabel?.text = summary
    }

}
