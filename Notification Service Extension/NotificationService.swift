//
//  NotificationService.swift
//  Notification Service Extension
//
//  Created by iYrke on 7/12/16.
//  Copyright © 2016 iYorke. All rights reserved.
//

import UserNotifications

/**
 This class is automatically provided with the service extension upon adding it to your project. This file must override the `didReceive` function and should override the `serviceExtensionTimeWillExpire` function. The service extension runs indepdently from your main application so you will not be able to talk to the application at all as part of the process of handling notifications. You also should not plan on doing any lengthy transactions or you will loose your opportunity to modify the payload. This extensions primary responsibility to is modify the payload in anyway necessary to present data to the user. Use this opportunity to download and prepare additional content, download images or other media and add them to notification. In this example I am adding everything I need to the notification content for the Content Extension to present the notifiation to the user through a custom view.
 
 While your main app will not run in the background upon receiving a background call if the user manually force quits the app, this extension will. So you can count on this extension always running as part of your process as long as you tell it to.
 To get this extension to run simply include in the `aps` dictionary of the payload the key/value pair: `"mutable-content":1`
 
 Upon completing the work here you must call the completionHandler to present the notification to the user. If you fail to call the completionHandler within a reasonable amount of time, the system will call through to `serviceExtensionTimeWillExpire` which is your last opportunity to modify the payload. If you fail to call that completion on time, then the original payload will be presented to the user.
 */
class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    /**
     This func is where you'll handle all the processing, use the payload to infer data that should be processed, images to download, content to download and do all your work in a timely manner and then call through to the completionHandler with the finished payload.
     */
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler:(UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            /**
             If you do any guard statements, be sure to call the completionHandler. You can also do this along the way so that if one part in particular fails, other content is successfully added before calling the completionHandler
             */
            guard let contentIdentifier = bestAttemptContent.userInfo["content_id"] as? Int else { contentHandler(bestAttemptContent); return }
            /**
             Here I am setting up the payload with all the content necessary for the Notification Content extension.
             */
            downloadFeed(byIdentifier: contentIdentifier) { jsonData in
                guard let jsonData = jsonData,
                    summary = jsonData["summary"] as? String,
                    headline = jsonData["headline"] as? String,
                    imageURLString = jsonData["image"] as? String,
                    imageURL = URL(string: imageURLString) else { contentHandler(bestAttemptContent); return }

                bestAttemptContent.userInfo["summary"] = summary
                bestAttemptContent.userInfo["headline"] = headline
                bestAttemptContent.threadIdentifier = "\(contentIdentifier)"

                self.download(fromURL: imageURL) { location in
                    guard let location = location else { contentHandler(bestAttemptContent); return }

                    do {
                        let attachment = try UNNotificationAttachment(identifier: imageURL.absoluteString ?? "", url: location, options: [UNNotificationAttachmentOptionsTypeHintKey: "public.jpeg"])
                        bestAttemptContent.attachments.append(attachment)
                    } catch {
                        //
                    }

                    contentHandler(bestAttemptContent)
                }
            }
        }
    }

    /**
     This method should be implemented just in case something goes wrong to ensure your modified payload can be presented to the user.
     */
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // MARK: Helper Methods for Downloading Content
    
    private func downloadFeed(byIdentifier identifier: Int, completion: ([String:AnyObject]?) -> () ) {
        guard let url = url(forIdentifier: identifier) else { completion(nil); return }

        download(fromURL: url) { location in
            guard let location = location else { completion(nil); return }

            do {
                let downloadedData = try Data(contentsOf: location)
                let jsonContent = try JSONSerialization.jsonObject(with: downloadedData, options: []) as? [String:AnyObject]
                completion(jsonContent)
            } catch {
                completion(nil)
            }
        }
    }

    private func download(fromURL url: URL, completion: (URL?) -> () ) {
        let urlSession = URLSession.shared
        let downloadTask = urlSession.downloadTask(with: url) { (location, urlResponse, error) in
            completion(location)
        }

        downloadTask.resume()
    }

    private func url(forIdentifier identifier: Int) -> URL? {
        let urlString = "https://s1-stg-nyt-com.s3.amazonaws.com/ios-newsreader/internal/feeds/notifications/\(identifier).json"
        return URL(string: urlString)
    }

}
