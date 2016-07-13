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

    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var summaryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.headlineLabel.text = "could not find headline"
        self.summaryLabel.text = "could not find summary"

        if let headline = notification.request.content.userInfo["headline"] as? String {
            self.headlineLabel.text = headline
        }

        if let summary = notification.request.content.userInfo["summary"] as? String {
            self.summaryLabel.text = summary
        }
    }
}
