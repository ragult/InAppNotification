//
//  Constant.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 09/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Foundation

struct GlobalStrings {
    static let systemChannelName = "SYSTEM_CHANNEL"
    static let friendJoined = " has joined"
    static let phoneNumberChnange = "[0] has changed the number to [1]"
    static let memberAddedToGroup = "[0] has been added to group"
    static let memberRemovedFromGroup = "[0] has been removed by admin"
    static let memberleftFromGroup = "[0] has left the group"
    static let groupPhotoChanged = "The group photo has been changed"

    static let accessConfidentialMessages = "To access your confidential messages"
    static let groupDelete = "The group has been closed"
}

struct InternetStrings {
    static let internetAvailable = "isInternetAvailable"
}

struct labelStrings {
    static let verify = "VERIFY"
    static let setPin = "Set PIN"
    static let enterPin = "Enter PIN"
    static let enterPinDesc = "Enter your app PIN"
    static let setPinDesc = "Set your app PIN"

    static let allowNotification = "Please enable access to Notifications in the Settings app."
    static let copyOnlyText = "Only text can be copied"

    static let groupAlert = "Make another member admin before existing the group or you may close the group before exiting"

    static let groupAlertClose = "Are you sure to close the group?"
    static let groupClearChatClose = "Are you sure to clear the chat?"
    static let groupRemoveChatClose = "Are you sure to remove the group and its data?"
    static let groupmemberRemoveAlert = "Do you want to remove?"
    static let groupmemberExitAlert = "Are you sure to exit?"
}

struct errorStrings {
//    static let invalidISO            =   "Please select "
    static let invalidPhone = "Please Enter a valid Phonr Number"
    static let unKnownAlert = "Whoops! Something doesn't seem right"
    static let noInterent = "Internet is required"
}
