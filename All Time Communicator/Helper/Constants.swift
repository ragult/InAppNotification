//
//  Constants.swift
//  alltimecommunicator
//
//  Created by Droid5 on 06/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//
import UIKit

struct RegisterType {
    static let NEVER_REGISTERED = ""
    static let FACEBOOK = "1"
    static let MANUAL = "4"
    // TODO: just kept the value without checking, so after testing please check the value
    static let GOOGLE = "2"
}

struct TextFieldMaxLength {
    static let MOBILE = 10
}

struct SharedSecret {
    static let key = "shared-secret-key"
    static let iv = "shared-secret-iv"
}

struct eventBusHandler {
    static let channelUpdated = "channelUpdated"
    static let groupAdded = "groupAdded"
    static let typingStatus = "typingStatus"
    static let systemMessage = "systemMessage"
    static let groupinactive = "groupinactive"
    static let groupactive = "groupactive"

    static let publishrights = "publishActive"
    static let messageSent = "messageSent"
    static let apiFailure = "apiFailure"
}

struct COLOURS {
    static let TABLE_BACKGROUND_COLOUR: UIColor = UIColor(r: 237, g: 237, b: 237)
    static let DESCRIPTION_COLOUR: UIColor = UIColor(r: 119, g: 119, b: 119)
    static let APP_MEDIUM_GREEN_COLOR: UIColor = UIColor(red: 0.137, green: 0.6235, blue: 0.6078, alpha: 1)
    // Add this in InAppNotificationBanner
    static let NOTIFICATION_COLOUR = UIColor(r: 15, g: 122, b: 119)
    static let textDarkGrey: UIColor = UIColor(r: 74, g: 74, b: 74)
    static let chatSelectedColor: UIColor = UIColor(red: 26.0 / 255.0, green: 118.0 / 255.0, blue: 186.0 / 255.0, alpha: 0.11)
}
