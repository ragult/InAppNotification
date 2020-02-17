//
//  ACEventBusManager.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 09/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import SwiftEventBus
import UIKit

class ACEventBusManager {
    static func postToEventBusWithMessageObject(eventBusObject: ACEventBusObject, notificationName: String) {
        SwiftEventBus.post(notificationName, sender: eventBusObject)
    }

    static func postNotificationWithoutObject(notificationName: String) {
        SwiftEventBus.post(notificationName)
    }

    static func postToEventBusWithReadReceiptObject(eventBusObject: ACReadReceiptEventBusObject, notificationName: String) {
        SwiftEventBus.post(notificationName, sender: eventBusObject)
    }

    static func postToEventBusforInternet(isInternetAvailable: Bool, notificationName: String) {
        SwiftEventBus.post(notificationName, sender: isInternetAvailable)
    }

    static func postToEventBusWithChannelObject(eventBusChannelObject: eventObject, notificationName: String) {
        SwiftEventBus.post(notificationName, sender: eventBusChannelObject)
    }

    static func postToEventBusWithTypingObject(eventBusChannelObject: ACTypingStatusObject, notificationName: String) {
        SwiftEventBus.post(notificationName, sender: eventBusChannelObject)
    }
}
