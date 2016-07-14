//
//  InteractiveNotifications.swift
//  NYTimes
//
//  Created by iYrke on 7/14/16.
//  Copyright © 2016 iYorke. All rights reserved.
//

import Foundation
import UserNotifications

/**
 An enum provided to contain information relative to the notification actions. This is provided as a means of easily identifying action strings in other locations of the app (for handling notification action responses from users)
 */
enum InteractiveNotifications: String {
    case Follow = "follow"
    case Read = "read"
    case Save = "save"

    private func title() -> String {
        switch self {
        case .Follow:
            return "Follow for Updates"
        case .Read:
            return "Read Story"
        case .Save:
            return "Save for Later"
        }
    }

    /**
     Three notification actions used for interactive notifications here just as examples. This is functionality introduced in iOS 8, not new to iOS 10 however the object types have changed from `UIUserNotificationAction` to the new `UNNotificationAction`. Everything else about how this functions is the same.
     */
    func action() -> UNNotificationAction {
        var options: UNNotificationActionOptions = []

        switch self {
        case .Read:
            options = [.foreground]
        default:
            break
        }

        return UNNotificationAction(identifier: self.rawValue, title: self.title(), options: options)
    }
}
