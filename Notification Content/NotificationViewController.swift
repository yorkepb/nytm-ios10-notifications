//
//  NotificationViewController.swift
//  Notification Content
//
//  Created by iYrke on 7/13/16.
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
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var summaryLabel: UILabel!
    @IBOutlet private weak var topImage: UIImageView!
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var HUDView: UIView!

    /**
     An Enum just for providing styling to the textual content.
     */
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
                paragraphStyle.lineHeightMultiple = 1.29
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

    /**
     This function must be implemented in order to receive the notification content.
     */
    func didReceive(_ notification: UNNotification) {
        guard let headline = notification.request.content.userInfo["headline"] as? String,
            summary = notification.request.content.userInfo["summary"] as? String else { return }

        /**
         You'll have full access to anything in the notification including the userInfo for retrieving content stored by the service extension or passed originally through the payload.
         */
        headlineLabel.attributedText = Styling.Headline.apply(toString: headline)
        summaryLabel.attributedText = Styling.Summary.apply(toString: summary)

        /**
         The attachment URL is security scoped. So to access it you must `startAccessingSecurityScopedResource()` and you must end it.
         */
        if let attachment = notification.request.content.attachments.first {
            if attachment.url.startAccessingSecurityScopedResource() {
                do {
                    guard let image = UIImage(data: try Data(contentsOf: attachment.url)) else { return }
                    topImage.bounds.size = scaledImageSize(fromSize: image.size)
                    topImage.image = image
                } catch {
                    print(error)
                }

                attachment.url.stopAccessingSecurityScopedResource()
            }
        }
    }

    /**
     This optional function may be implemented if you wish to intercept interactive notification actions as they are used. When a user taps on a particular interactive notification action, implementing this method will first send the action here allowing for the update of the UI or for action to be taken here before continuing. Once you are done you must call the completion with one of three options:
     
         .doNotDismiss: Finishes with the action but does nothing more. The user must then dismiss the notification manually.
         .dismiss: Dismisses the notification and completes the action and does not send _anything_ to the main application.
         .dismissAndForwardAction: Dismisses the notification and sends the action to be handled by the main application.
     
      In WWDC they stated that doing this would cause a delay in the dismissal, giving you a chance to updat ethe UI for the user before the alert is dismissed. However because I am not seeing any delay, I added the Dispatch After as a means of faking that delay. In the case below, if the user tapped the "Save for Later" interactive action, I am displaying a HUD indicating the article was saved and then dismissing and forwarding to the main application to actually handle the save.
     */
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: (UNNotificationContentExtensionResponseOption) -> Void) {
        
        if response.actionIdentifier == InteractiveNotifications.Save.rawValue {
            DispatchQueue.main.after(when:  DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.HUDView.isHidden = false
            }

            DispatchQueue.main.after(when:  DispatchTime.now() + Double(Int64(1.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                completion(.dismissAndForwardAction)
            }
        } else {
            completion(.dismissAndForwardAction)
        }
    }

    /**
     Convienence func provided to help create the correct scale of image.
     */
    private func scaledImageSize(fromSize size: CGSize) -> CGSize {
        let scaleFactor = mainView.bounds.size.width / size.width
        return CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
    }

}
