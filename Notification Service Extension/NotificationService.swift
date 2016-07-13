//
//  NotificationService.swift
//  Notification Service Extension
//
//  Created by yorkepb on 7/12/16.
//  Copyright © 2016 iYorke. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler:(UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            guard let contentIdentifier = bestAttemptContent.userInfo["content_id"] as? Int else { contentHandler(bestAttemptContent); return }
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
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

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
