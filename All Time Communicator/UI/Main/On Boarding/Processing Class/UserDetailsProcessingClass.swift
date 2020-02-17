
//
//  UserDetailsProcessingClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 21/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Foundation

class UserDetailsProcessingClass {
    static func insertContactToDB(user: UserModel) -> String {
        let index = DatabaseManager.storeSelfConatct(profileTable: user)
        return String(index)
    }

    static func saveToUserDefaults(pUser: UserModel) {
        let userIndex = insertContactToDB(user: pUser)

        UserDefaults.standard.set(userIndex, forKey: UserKeys.userContactIndex)
        UserDefaults.standard.set(pUser.globalUserId, forKey: UserKeys.userGlobalId)
        UserDefaults.standard.set(pUser.phoneNumber, forKey: UserKeys.userPhoneNumber)
        UserDefaults.standard.set(pUser.fullName, forKey: UserKeys.userName)
        UserDefaults.standard.set(pUser.securityCode, forKey: UserKeys.userSecurityCode)
        UserDefaults.standard.set(pUser.registerType, forKey: UserKeys.userRegistrationType)
    }

    static func createChannelForSystemNotifications() {
        let channel = ACDatabaseMethods.createChannelTable(conatctId: "-99", channelType: channelType.NOTIFICATIONS.rawValue, globalChannelName: GlobalStrings.systemChannelName)

        let channelIndex = DatabaseManager.storeChannelData(channelTable: channel)
        let id = String(channelIndex)
        UserDefaults.standard.set(id, forKey: UserKeys.userSystemChannelId)
    }
}
