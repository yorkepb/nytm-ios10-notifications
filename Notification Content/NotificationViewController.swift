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

    @IBOutlet var headlineLabel: UILabel?
    @IBOutlet var summaryLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        guard let headline = notification.request.content.userInfo["headline"] as? String,
            summary = notification.request.content.userInfo["summary"] as? String else { return }

        self.headlineLabel?.text = headline
        self.summaryLabel?.text = summary
        if let attachment = notification.request.content.attachments.first {
            if attachment.url.startAccessingSecurityScopedResource() {
                do {
                    guard let image = UIImage(data: try Data(contentsOf: attachment.url)) else { return }
                    topImage?.bounds.size = scaledImageSize(fromSize: image.size)
                    topImage?.image = image
                } catch {
                    print(error)
                }

                attachment.url.stopAccessingSecurityScopedResource()
            }
        }
    }

    private func scaledImageSize(fromSize size: CGSize) -> CGSize {
        guard let viewWidth = mainView?.bounds.size.width else { return size }

        let currentWidth = size.width
        let scaleFactor = viewWidth / currentWidth

        let newWidth = currentWidth * scaleFactor
        let newHeight = size.height * scaleFactor

        return CGSize(width: newWidth, height: newHeight)
    }

}
