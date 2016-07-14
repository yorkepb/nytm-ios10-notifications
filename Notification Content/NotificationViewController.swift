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
    @IBOutlet var topImage: UIImageView?
    @IBOutlet var mainView: UIView?

    enum Styling {
        case Headline
        case Summary

        func apply(toString string: String) -> AttributedString {
            var attributes = [String: AnyObject]()

            let paragraphStyle = NSMutableParagraphStyle()
            var font: UIFont?
            let fontSize: CGFloat
            let textColor: UIColor

            switch self {
            case .Headline:
                paragraphStyle.lineHeightMultiple = 1.20
                fontSize = CGFloat(20.0)
                font = UIFont(name: "NYTCheltenham-Bold", size: fontSize)
                textColor = UIColor(white: 51.0 / 255.0, alpha: 1.0)
            case .Summary:
                paragraphStyle.lineHeightMultiple = 1.10
                fontSize = CGFloat(14.0)
                font = UIFont(name: "NYTCheltenhamSH-Regular", size: fontSize)
                textColor = UIColor(white: 102.0 / 255.0, alpha: 1.0)
            }

            attributes[NSParagraphStyleAttributeName] = paragraphStyle
            attributes[NSFontAttributeName] = font ?? UIFont.preferredFont(forTextStyle: UIFontTextStyleBody)
            attributes[NSForegroundColorAttributeName] = textColor
            return AttributedString(string: string, attributes: attributes)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        guard let headline = notification.request.content.userInfo["headline"] as? String,
            summary = notification.request.content.userInfo["summary"] as? String else { return }

        headlineLabel?.attributedText = Styling.Headline.apply(toString: headline)
        summaryLabel?.attributedText = Styling.Summary.apply(toString: summary)

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
