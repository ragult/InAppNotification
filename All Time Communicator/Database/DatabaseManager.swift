//
//  DatabaseManager.swift
//  alltimecommunicator
//
//  Created by Droid5 on 06/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import GRDB
import UIKit

class DatabaseManager {
    private(set) static var dbQueue: DatabaseQueue?

    static func initDatabase(application: UIApplication) {
        do {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
            let databasePath = documentsPath.appendingPathComponent("db.sqlite")
            dbQueue = try DatabaseQueue(path: databasePath)
            dbQueue?.setupMemoryManagement(in: application)
            createTables(tableNames: [UserModel.databaseTableName, ProfileTable.databaseTableName, GroupTable.databaseTableName, GroupMemberTable.databaseTableName, ChannelTable.databaseTableName, MessagesTable.databaseTableName, PollTable.databaseTableName, UniqueRefTable.databaseTableName])
            print("database path is \(databasePath)")
        } catch {
            print("dbError initDatabase(): \(error.localizedDescription)")
        }
    }

    private static func createTables(tableNames: [String]) {
        do {
            try dbQueue?.write { db in
                try db.inSavepoint { () -> Database.TransactionCompletion in
                    for tableName in tableNames {
                        switch tableName {
                        case UserModel.databaseTableName:
                            try db.create(table: tableName, ifNotExists: true, body: { tableDefinition in
                                UserModel.defineTableDefinition(tableDefinition: tableDefinition)
                            })
                        case ProfileTable.databaseTableName:
                            try db.create(table: tableName, ifNotExists: true, body: { tableDefinition in
                                ProfileTable.defineTableDefinition(tableDefinition: tableDefinition)
                            })
                        case GroupTable.databaseTableName:
                            try db.create(table: tableName, ifNotExists: true, body: { tableDefinition in
                                GroupTable.defineTableDefinition(tableDefinition: tableDefinition)
                            })
                        case GroupMemberTable.databaseTableName:
                            try db.create(table: tableName, ifNotExists: true, body: { tableDefinition in
                                GroupMemberTable.defineTableDefinition(tableDefinition: tableDefinition)
                            })
                        case ChannelTable.databaseTableName:
                            try db.create(table: tableName, ifNotExists: true, body: { tableDefinition in
                                ChannelTable.defineTableDefinition(tableDefinition: tableDefinition)
                            })
                        case MessagesTable.databaseTableName:
                            try db.create(table: tableName, ifNotExists: true, body: { tableDefinition in
                                MessagesTable.defineTableDefinition(tableDefinition: tableDefinition)
                            })

                        case PollTable.databaseTableName:
                            try db.create(table: tableName, ifNotExists: true, body: { tableDefinition in
                                PollTable.defineTableDefinition(tableDefinition: tableDefinition)
                            })

                        case UniqueRefTable.databaseTableName:
                            try db.create(table: tableName, ifNotExists: true, body: { tableDefinition in
                                UniqueRefTable.defineTableDefinition(tableDefinition: tableDefinition)
                            })
                        default:
                            print("Error in switching create Tables")
                        }
                    }
                    return .commit
                }
            }
        } catch {
            print("dbError createTables(): \(error.localizedDescription)")
        }
    }

    // MARK: UserTable

    static func storeUserInfo(userModel: UserModel) {
        do {
            try dbQueue?.write { db in
                try db.inSavepoint { () -> Database.TransactionCompletion in
                    //try UserTable.deleteAll(db)
                    try userModel.save(db)
                    print()
                    return .commit
                }
            }
        } catch {
            print("dbError storeUserInfo: \(error.localizedDescription)")
        }
    }

    // Get tables
    static func getUser() -> UserModel? {
        do {
            let user = try dbQueue?.read { db in
                try UserModel.fetchOne(db)
            }
            return user
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: Profile

    static func storeProfile(profileTable: ProfileTable) {
        do {
            try dbQueue?.write { db in
                try db.inSavepoint { () -> Database.TransactionCompletion in
                    //try ContactTable.deleteAll(db)
                    try profileTable.save(db)
                    //                    let profiles = try ProfileTable.fetchAll(db)

                    return .commit
                }
            }
        } catch {
            print("dbError storeProfile: \(error.localizedDescription)")
        }
    }

    static func storeContacts(profileTables: [ACContactsObject]) {
        for profileTable in profileTables {
            do {
                try dbQueue?.write { db in

                    try db.execute(
                        sql: "INSERT INTO ProfileTable (phoneNumber, contactId, fullName, nickName, dateOfBirth, picture, emailId, isMember, selected, globalUserId, countryCode, deviceApn, deviceApnType, isoCode, localImageFilePath, userstatus, isAnonymus, userQrcode, localQrcode) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )",
                        arguments: [profileTable.phoneNumber, "", profileTable.fullName, "", "", "", "", "", "", "", "", "", "", "", "", "0", false, "", ""]
                    )
                }
            } catch {
                print("dbError storeContacts: \(error.localizedDescription)")
            }
        }
    }

    static func UpdateContactsName(contacts: [ACContactsObject]) {
        for contact in contacts {
            do {
                try dbQueue?.write { db in
                    try db.execute(
                        sql: "UPDATE ProfileTable SET fullName = :fullName  WHERE phoneNumber = :phoneNumber",
                        arguments: ["fullName": contact.fullName, "phoneNumber": contact.phoneNumber]
                    )
                }
            } catch {
                print("dbError storeContacts: \(error.localizedDescription)")
            }
        }
    }

    static func storeSelfConatct(profileTable: UserModel) -> Int {
        do {
            let lastRowid = try dbQueue?.write { (db) -> Int in
                try db.execute(
                    sql: "INSERT INTO ProfileTable (phoneNumber, contactId, fullName, nickName, dateOfBirth, picture, emailId, isMember, selected, globalUserId, countryCode, deviceApn, deviceApnType, isoCode, localImageFilePath, userstatus, isAnonymus, userQrcode, localQrcode) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    arguments: [profileTable.phoneNumber, "-99", profileTable.fullName, profileTable.nickName, profileTable.dateofBirth, profileTable.picture, profileTable.emailId, true, "", profileTable.globalUserId, profileTable.countryCode, profileTable.deviceApn, profileTable.deviceApnType, "91", "", "1", false, profileTable.userQrcode, profileTable.localQrcode]
                )
                let insertId = Int(db.lastInsertedRowID)
                return insertId
            }
            return lastRowid!
        } catch {
            print("dbError storeContacts: \(error.localizedDescription)")
            return 0
        }
    }

    static func storeSingleConatct(profileTable: ProfileTable) -> Int {
        do {
            let lastRowid = try dbQueue?.write { (db) -> Int in
                try db.execute(
                    sql: "INSERT INTO ProfileTable (phoneNumber, contactId, fullName, nickName, dateOfBirth, picture, emailId, isMember, selected, globalUserId, countryCode, deviceApn, deviceApnType, isoCode, localImageFilePath, userstatus, isAnonymus, userQrcode, localQrcode) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,?)",
                    arguments: [profileTable.phoneNumber, "", profileTable.fullName, "", "", profileTable.picture, "", true, "", profileTable.globalUserId, "", "", "", "91", "", profileTable.userstatus, profileTable.isAnonymus,
                                profileTable.userQrcode, profileTable.localQrcode]
                )
                let insertId = Int(db.lastInsertedRowID)
                return insertId
            }
            return lastRowid!
        } catch {
            print("dbError storeContacts: \(error.localizedDescription)")
            return 0
        }
    }

    static func updateContactsFromServerToDb(profileTables: [ProfileTable]) {
        for profileTable in profileTables {
            do {
                try dbQueue?.write { db in

                    try db.execute(
                        sql: "UPDATE ProfileTable SET globalUserId = :globalUserId, picture = :picture, isMember = :isMember, phoneNumber = :phoneNumber, isoCode = :isoCode, isAnonymus= :isAnonymus WHERE id = :id",
                        arguments: ["globalUserId": profileTable.globalUserId, "picture": profileTable.picture, "isMember": profileTable.isMember, "phoneNumber": profileTable.phoneNumber, "isoCode": profileTable.isoCode, "isAnonymus": profileTable.isAnonymus, "id": profileTable.id]
                    )
                }
            } catch {
                print("dbError storeContacts: \(error.localizedDescription)")
            }
        }
    }

    static func updateProfileMember(profile: ProfileTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ProfileTable SET globalUserId = :globalUserId, picture = :picture, isMember = :isMember  WHERE phoneNumber = :phoneNumber",
                    arguments: ["globalUserId": profile.globalUserId, "picture": profile.picture, "isMember": profile.isMember, "phoneNumber": profile.phoneNumber]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateUserDatailsFromIntro(profile: ProfileTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ProfileTable SET picture = :picture, phoneNumber = :phoneNumber, isAnonymus= :isAnonymus, fullName= :fullName, userstatus= :userstatus WHERE globalUserId = :globalUserId",
                    arguments: ["picture": profile.picture, "phoneNumber": profile.phoneNumber, "isAnonymus": profile.isAnonymus, "fullName": profile.fullName, "userstatus": profile.userstatus, "globalUserId": profile.globalUserId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateProfileUserStatus(profile: ProfileTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ProfileTable SET userstatus = :userstatus, WHERE id = :id",
                    arguments: ["userstatus": profile.userstatus, "id": profile.id]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMemberQrForId(qr: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ProfileTable SET localQrcode = :localQrcode WHERE contactId = -99",
                    arguments: ["localQrcode": qr]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMemberPhotoForId(picture: String, userId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ProfileTable SET localImageFilePath = :localImageFilePath WHERE id = :id",
                    arguments: ["localImageFilePath": picture, "id": userId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    
    static func updateUserPhotoForId(picture: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ProfileTable SET localImageFilePath = :localImageFilePath WHERE contactId = -99",
                    arguments: ["localImageFilePath": picture]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    
    static func updateMemberPhoneNumber(phoneNumber: String, globalUserId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ProfileTable SET phoneNumber = :phoneNumber WHERE globalUserId = :globalUserId",
                    arguments: ["phoneNumber": phoneNumber, "globalUserId": globalUserId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func getContacts() -> [ProfileTable]? {
        do {
            let profiles = try dbQueue?.read { db in
                try ProfileTable.fetchAll(db, sql: "SELECT * FROM ProfileTable WHERE contactId != ? ORDER BY fullName ASC", arguments: ["-99"])
            }
            return profiles
        } catch {
            print("dbError getContacts: \(error.localizedDescription)")
            return nil
        }
    }

    static func getContactsForSync() -> [ProfileTable]? {
        do {
            let profiles = try dbQueue?.read { db in
                try ProfileTable.fetchAll(db, sql: "SELECT * FROM ProfileTable WHERE contactId != ?", arguments: ["-99"])
            }
            return profiles
        } catch {
            print("dbError getContacts: \(error.localizedDescription)")
            return nil
        }
    }

    static func getContactsForUpload() -> [ContactModel]? {
        do {
            let profiles = try dbQueue?.read { db in
                try ContactModel.fetchAll(db, sql: "SELECT id, phoneNumber FROM ProfileTable WHERE contactId != ?", arguments: ["-99"])
            }
            return profiles
        } catch {
            print("dbError getContacts: \(error.localizedDescription)")
            return nil
        }
    }

    static func getAppContacts() -> [ProfileTable]? {
        do {
            let profiles = try dbQueue?.read { db in
                try ProfileTable.fetchAll(db, sql: "SELECT * FROM ProfileTable WHERE contactId != ? AND isMember = ? ORDER BY fullName ASC", arguments: ["-99", "1"])
            }
            return profiles
        } catch {
            print("dbError getContacts: \(error.localizedDescription)")
            return nil
        }
    }

    static func getSelfContactDetails() -> ProfileTable? {
        do {
            let profiles = try dbQueue?.read { db in
                try ProfileTable.fetchOne(db, sql: "SELECT * FROM ProfileTable WHERE contactId = ?", arguments: ["-99"])
            }
            return profiles
        } catch {
            print("dbError getContacts: \(error.localizedDescription)")
            return nil
        }
    }

    static func getContactDetails(phoneNumber: String) -> ProfileTable? {
        do {
            let profile = try dbQueue?.read { db in

                try ProfileTable.fetchOne(db, sql: "SELECT * FROM ProfileTable WHERE id = ?", arguments: [phoneNumber])
            }
            return profile
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getContactIndex(globalUserId: String) -> ProfileTable? {
        do {
            let profile = try dbQueue?.read { db in

                try ProfileTable.fetchOne(db, sql: "SELECT * FROM ProfileTable WHERE globalUserId = ?", arguments: [globalUserId])
            }
            return profile
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getContactIndexforTable(tableIndex: String) -> ProfileTable? {
        do {
            let profile = try dbQueue?.read { db in

                try ProfileTable.fetchOne(db, sql: "SELECT * FROM ProfileTable WHERE id = ?", arguments: [tableIndex])
            }
            return profile
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: Channels

    static func storeChannelData(channelTable: ChannelTable) -> Int {
        do {
            let lastRowId = try dbQueue?.write { (db) -> Int in
                if try channelTable.exists(db) {
                    print("data already exists")
                    return 0
                } else {
                    try db.execute(
                        sql: "INSERT INTO ChannelTable (contactId, channelType, globalChannelName, lastSenderPhone, lastSenderContactId, lastSavedMsgid, lastSeenMsgId, lastMsgTime, unseenCount, channelStatus, channelSyncTime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        arguments: [channelTable.contactId, channelTable.channelType, channelTable.globalChannelName, channelTable.lastSenderPhone, channelTable.lastSenderContactId, channelTable.lastSavedMsgid, channelTable.lastSeenMsgId, channelTable.lastMsgTime, channelTable.unseenCount, channelTable.channelStatus, channelTable.channelSyncTime]
                    )
                    let insertId = Int(db.lastInsertedRowID)
                    return insertId
                }
            }
            return lastRowId!
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
            return 0
        }
    }

    static func updateChannelTable(channelTable: ChannelTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ChannelTable SET lastSenderPhone = :lastSenderPhone, lastSenderContactId = :lastSenderContactId, lastSavedMsgid = :lastSavedMsgid, lastMsgTime = :lastMsgTime, unseenCount = :unseenCount WHERE id = :id",
                    arguments: ["lastSenderPhone": channelTable.lastSenderPhone, "lastSenderContactId": channelTable.lastSenderContactId, "lastSavedMsgid": channelTable.lastSavedMsgid, "lastMsgTime": channelTable.lastMsgTime, "unseenCount": channelTable.unseenCount, "id": channelTable.id]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateChannelTableForChannelId(channelId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ChannelTable SET unseenCount = :unseenCount WHERE id = :id",
                    arguments: ["unseenCount": "0", "id": channelId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateChannelStatusForContactId(status: String, contactId: String, channelTyp: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ChannelTable SET channelStatus = :channelStatus WHERE contactId = :contactId AND  channelType = :channelType",
                    arguments: ["channelStatus": status, "contactId": contactId, "channelType": channelTyp]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateChannelSyncTimeForChannelId(channelId: String, time: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE ChannelTable SET channelSyncTime = :channelSyncTime WHERE id = :id",
                    arguments: ["channelSyncTime": time, "id": channelId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func fetchAllChannelGroup() -> [ChannelTable]? {
        let channelTypes = "\(channelType.TOPIC_GROUP.rawValue),\(channelType.PUBLIC_GROUP.rawValue),\(channelType.PRIVATE_GROUP.rawValue),\(channelType.GROUP_CHAT.rawValue)"

        do {
            let group = try dbQueue?.read { db in
                try ChannelTable.fetchAll(db, sql: "SELECT * FROM ChannelTable WHERE channelType in(\(channelTypes))", arguments: [])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getChannelIndex(contactId: String, channelType: String) -> ChannelTable? {
        do {
            let group = try dbQueue?.read { db in

                try ChannelTable.fetchOne(db, sql: "SELECT * FROM ChannelTable WHERE contactId = ? AND channelType = ?", arguments: [contactId, channelType])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getChannelIndexbyMessage(contactId: String, channelType: String) -> ChannelTable? {
        do {
            let group = try dbQueue?.read { db in

                try ChannelTable.fetchOne(db, sql: "SELECT * FROM ChannelTable WHERE id = ? AND channelType = ?", arguments: [contactId, channelType])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getgroupCreatedTimeStamp(contactId: String) -> String? {
        do {
            let group = try dbQueue?.read { db in

                try String.fetchOne(db, sql: "SELECT createdOn FROM GroupTable WHERE id = ?", arguments: [contactId])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func

        fetchChannel() -> [ChannelTable]? {
        let channelTypes = "\(channelType.ONE_ON_ONE_CHAT.rawValue),\(channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue)"

        let grpType = "\(channelType.GROUP_CHAT.rawValue),\(channelType.ADHOC_CHAT.rawValue)"

        do {
            let group = try dbQueue?.read { db in

                try ChannelTable.fetchAll(db, sql: "SELECT * FROM ChannelTable WHERE ((channelType in(\(channelTypes)) AND lastSavedMsgid != ?) OR (channelType in(\(grpType)))) AND channelStatus != ?", arguments: ["", "-1"])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func fetchChannelForHome() -> [ChannelTable]? {
        let channelTypes = "\(channelType.ONE_ON_ONE_CHAT.rawValue),\(channelType.GROUP_CHAT.rawValue),\(channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue),\(channelType.ADHOC_CHAT.rawValue)"

        do {
            let group = try dbQueue?.read { db in
                try ChannelTable.fetchAll(db, sql: "SELECT * FROM ChannelTable WHERE channelType in(\(channelTypes)) AND lastSavedMsgid != ? AND channelStatus != ? ORDER BY lastMsgTime DESC LIMIT 10", arguments: ["", "-1"])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: groups

    static func storeGroup(groupTable: GroupTable) -> Int {
        do {
            let lastRowId = try dbQueue?.write { (db) -> Int in
                try db.execute(
                    sql: "INSERT INTO GroupTable (groupGlobalId, groupType, groupName, groupDescription, confidentialFlag, fullImageUrl, thumbnailUrl, createdOn, createdBy, groupStatus, createdByThumbnailUrl, createdByMobileNumber,localImagePath, uniqueRef, lastConfirmId, coordinates, mapServiceProvider, mapLocationId, qrURL, address, qrCode, webUrl, publicGroupCode, groupCode, localQrcode, groupPublicId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    arguments: [groupTable.groupGlobalId, groupTable.groupType, groupTable.groupName, groupTable.groupDescription, groupTable.confidentialFlag, groupTable.fullImageUrl, groupTable.thumbnailUrl, groupTable.createdOn, groupTable.createdBy, groupTable.groupStatus, groupTable.createdByThumbnailUrl, groupTable.createdByMobileNumber, groupTable.localImagePath, groupTable.uniqueRef, groupTable.lastConfirmId, groupTable.coordinates, groupTable.mapServiceProvider, groupTable.mapLocationId, groupTable.qrURL, groupTable.address, groupTable.qrCode, groupTable.webUrl, groupTable.publicGroupCode, groupTable.groupCode, groupTable.localQrcode, groupTable.groupPublicId]
                )
                let insertId = Int(db.lastInsertedRowID)
                return insertId
            }
            return lastRowId!

        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
            return 0
        }
    }

    static func checkIfGroupExistsOrUpdate(groupTable: GroupTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupTable SET groupType = :groupType, groupName = :groupName, groupDescription = :groupDescription, confidentialFlag =:confidentialFlag, fullImageUrl = :fullImageUrl, thumbnailUrl = :thumbnailUrl, createdOn = :createdOn, createdBy = :createdBy, groupStatus = :groupStatus, createdByThumbnailUrl = :createdByThumbnailUrl, createdByMobileNumber = :createdByMobileNumber, coordinates = :coordinates, mapServiceProvider =:mapServiceProvider, mapLocationId = :mapLocationId, qrURL = :qrURL, address = :address, qrCode = :qrCode, webUrl = :webUrl, publicGroupCode = :publicGroupCode, groupCode = :groupCode, localQrcode = :localQrcode, groupPublicId = :groupPublicId WHERE id = :id ",
                    arguments: ["groupType": groupTable.groupType, "groupName": groupTable.groupName, "groupDescription": groupTable.groupDescription, "confidentialFlag": groupTable.confidentialFlag, "fullImageUrl": groupTable.fullImageUrl, "thumbnailUrl": groupTable.thumbnailUrl, "createdOn": groupTable.createdOn, "createdBy": groupTable.createdBy, "groupStatus": groupTable.groupStatus, "createdByThumbnailUrl": groupTable.createdByThumbnailUrl, "createdByMobileNumber": groupTable.createdByMobileNumber, "coordinates": groupTable.coordinates, "mapServiceProvider": groupTable.mapServiceProvider, "mapLocationId": groupTable.mapLocationId, "qrURL": groupTable.qrURL, "id": groupTable.id, "address": groupTable.address, "qrCode": groupTable.qrCode, "webUrl": groupTable.webUrl, "publicGroupCode": groupTable.publicGroupCode, "groupCode": groupTable.groupCode, "localQrcode": groupTable.localQrcode, "groupPublicId": groupTable.groupPublicId]
                )

                let count = db.changesCount
                if count == 0 {
                    try db.execute(
                        sql: "INSERT INTO GroupTable (groupGlobalId, groupType, groupName, groupDescription, confidentialFlag, fullImageUrl, thumbnailUrl, createdOn, createdBy, groupStatus, createdByThumbnailUrl, createdByMobileNumber, localImagePath, uniqueRef, lastConfirmId, coordinates, mapServiceProvider, mapLocationId, qrURL, address, qrCode, webUrl, publicGroupCode, groupCode, localQrcode, groupPublicId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ?, ?, ?, ?, ?)",
                        arguments: [groupTable.groupGlobalId, groupTable.groupType, groupTable.groupName, groupTable.groupDescription, groupTable.confidentialFlag, groupTable.fullImageUrl, groupTable.thumbnailUrl, groupTable.createdOn, groupTable.createdBy, groupTable.groupStatus, groupTable.createdByThumbnailUrl, groupTable.createdByMobileNumber, groupTable.localImagePath, groupTable.uniqueRef, groupTable.lastConfirmId, groupTable.coordinates, groupTable.mapServiceProvider, groupTable.mapLocationId, groupTable.qrURL, groupTable.address, groupTable.qrCode, groupTable.webUrl, groupTable.publicGroupCode, groupTable.groupCode, groupTable.localQrcode, groupTable.groupPublicId]
                    )
                }
            }
        } catch {
            do {
                try dbQueue?.write { db in
                    try db.execute(
                        sql: "INSERT INTO GroupTable (groupGlobalId, groupType, groupName, groupDescription, confidentialFlag, fullImageUrl, thumbnailUrl, createdOn, createdBy, groupStatus, createdByThumbnailUrl, createdByMobileNumber, localImagePath, uniqueRef, lastConfirmId, coordinates, mapServiceProvider, mapLocationId, qrURL, address, qrCode, webUrl, publicGroupCode, groupCode, localQrcode, groupPublicId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ?, ?, ?, ?, ?)",
                        arguments: [groupTable.groupGlobalId, groupTable.groupType, groupTable.groupName, groupTable.groupDescription, groupTable.confidentialFlag, groupTable.fullImageUrl, groupTable.thumbnailUrl, groupTable.createdOn, groupTable.createdBy, groupTable.groupStatus, groupTable.createdByThumbnailUrl, groupTable.createdByMobileNumber, groupTable.localImagePath, groupTable.uniqueRef, groupTable.lastConfirmId, groupTable.coordinates, groupTable.mapServiceProvider, groupTable.mapLocationId, groupTable.qrURL, groupTable.address, groupTable.qrCode, groupTable.webUrl, groupTable.publicGroupCode, groupTable.groupCode, groupTable.localQrcode, groupTable.groupPublicId]
                    )
                }
            } catch {
                
            }
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func checkIfGroupExistsOrUpdateTheSummary(groupTable: GroupTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupTable SET groupName = :groupName, fullImageUrl = :fullImageUrl, groupStatus = :groupStatus WHERE id = :id ",
                    arguments: ["groupName": groupTable.groupName, "fullImageUrl": groupTable.fullImageUrl, "groupStatus": groupTable.groupStatus, "id": groupTable.id]
                )

                let count = db.changesCount
                if count == 0 {
                    try db.execute(
                        sql: "INSERT INTO GroupTable (groupGlobalId, groupType, groupName, groupDescription, confidentialFlag, fullImageUrl, thumbnailUrl, createdOn, createdBy, groupStatus, createdByThumbnailUrl, createdByMobileNumber, localImagePath, uniqueRef, lastConfirmId, coordinates, mapServiceProvider, mapLocationId, qrURL, address, qrCode, webUrl, publicGroupCode, groupCode, localQrcode, groupPublicId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? , ?, ?, ?, ?, ?)",
                        arguments: [groupTable.groupGlobalId, groupTable.groupType, groupTable.groupName, groupTable.groupDescription, groupTable.confidentialFlag, groupTable.fullImageUrl, groupTable.thumbnailUrl, groupTable.createdOn, groupTable.createdBy, groupTable.groupStatus, groupTable.createdByThumbnailUrl, groupTable.createdByMobileNumber, groupTable.localImagePath, groupTable.uniqueRef, groupTable.lastConfirmId, groupTable.coordinates, groupTable.mapServiceProvider, groupTable.mapLocationId, groupTable.qrURL, groupTable.address, groupTable.qrCode, groupTable.webUrl, groupTable.publicGroupCode, groupTable.groupCode, groupTable.localQrcode,
                                    groupTable.groupPublicId]
                    )
                }
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func fetchAllBroadcastGroup() -> [GroupTable]? {
        let groupTypes = "\(groupType.PUBLIC_GROUP.rawValue),\(groupType.PRIVATE_GROUP.rawValue)"

        do {
            let group = try dbQueue?.read { db in
                try GroupTable.fetchAll(db, sql: "SELECT * FROM GroupTable WHERE groupType in(\(groupTypes))", arguments: [])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func fetchAllPublicGroup() -> [GroupTable]? {
        let groupTypes = "\(groupType.PUBLIC_GROUP.rawValue)"

        do {
            let group = try dbQueue?.read { db in
                try GroupTable.fetchAll(db, sql: "SELECT * FROM GroupTable WHERE groupType in(\(groupTypes))", arguments: [])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func checkGroupExsists(publicGroupId : String ) -> Bool {
        let groups = fetchAllPublicGroup()
        let filteredGroup = groups?.filter{$0.groupPublicId == publicGroupId}
        if (filteredGroup?.count ?? 0) > 0 {
            return true
        } else {
            return false
        }
    }
    static func getGroupTableWith(publicGroupId : String ) -> GroupTable? {
        let groups = fetchAllPublicGroup()
        let filteredGroup = groups?.filter{$0.groupPublicId == publicGroupId}
        if (filteredGroup?.count ?? 0) > 0 {
            return filteredGroup![0]
        } else {
            return nil
        }
    }
    
    static func UpdategroupTable(groupTable: GroupTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupTable SET groupName = :groupName, groupDescription = :groupDescription  WHERE id = :id ",
                    arguments: ["groupName": groupTable.groupName, "groupDescription": groupTable.groupDescription, "id": groupTable.id]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func UpdateGroupStatus(groupStatus: String, groupId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupTable SET groupStatus = :groupStatus  WHERE id = :id ",
                    arguments: ["groupStatus": groupStatus, "id": groupId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateCloudImageInGroupTable(groupTable: GroupTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupTable SET fullImageUrl = :fullImageUrl  WHERE id = :id ",
                    arguments: ["fullImageUrl": groupTable.fullImageUrl, "id": groupTable.id]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateGroupLocalImagePath(localImagePath: String, localId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupTable SET localImagePath = :localImagePath WHERE id = :id",
                    arguments: ["localImagePath": localImagePath, "id": localId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateGroupLocalQrPath(localImagePath: String, localId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupTable SET localQrcode = :localQrcode WHERE id = :id",
                    arguments: ["localQrcode": localImagePath, "id": localId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updatelastConfirmId(msgTimeSyamp: String, globalGroupId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupTable SET lastConfirmId = :lastConfirmId WHERE groupGlobalId = :groupGlobalId",
                    arguments: ["lastConfirmId": msgTimeSyamp, "groupGlobalId": globalGroupId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func getGroupWithPublicId(groupPublicId: String) -> GroupTable? {
        do {
            let group = try dbQueue?.read { db in
                try GroupTable.fetchOne(db, sql: "SELECT * FROM GroupTable WHERE groupPublicId = ?", arguments: [groupPublicId])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getGroups() -> [GroupTable] {
        let groupTypes = "\(groupType.GROUP_CHAT.rawValue),\(groupType.TOPIC_GROUP.rawValue),\(groupType.PUBLIC_GROUP.rawValue),\(groupType.PRIVATE_GROUP.rawValue)"

        do {
            let groups = try dbQueue?.read { db -> [GroupTable] in
                try GroupTable.fetchAll(db, sql: "SELECT * FROM GroupTable WHERE groupType in(\(groupTypes)) ORDER BY createdOn ASC", arguments: []).reversed()
            }
            return groups ?? []
        } catch {
            print("dbError getGroup: \(error.localizedDescription)")
            return []
        }
    }

//    static func fetchGroup(groupId:String) -> GroupTable? {
//        do {
//            let group = try dbQueue?.read { db in
//                return try GroupTable.fetchOne(db, "SELECT * FROM GroupTable WHERE groupId = ?", arguments: [groupId])
//            }
//            return group
//        } catch {
//            print("dbError getUser: \(error.localizedDescription)")
//            return nil
//        }
//    }

    static func getGroupIndex(groupGlobalId: String) -> GroupTable? {
        do {
            let group = try dbQueue?.read { db in

                try GroupTable.fetchOne(db, sql: "SELECT * FROM GroupTable WHERE groupGlobalId = ?", arguments: [groupGlobalId])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getGroupDetail(groupGlobalId: String) -> GroupTable? {
        do {
            let group = try dbQueue?.read { db in

                try GroupTable.fetchOne(db, sql: "SELECT * FROM GroupTable WHERE id = ?", arguments: [groupGlobalId])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getGroupWith(groupPublicId: String) -> GroupTable? {
        do {
            let group = try dbQueue?.read { db in

                try GroupTable.fetchOne(db, sql: "SELECT * FROM GroupTable WHERE id = ?", arguments: [groupPublicId])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: groupMembers

    static func storeGroupMembers(groupMemebrsTable: GroupMemberTable) -> Int {
        do {
            let lastRowId = try dbQueue?.write { (db) -> Int in
                try db.execute(
                    sql: "INSERT INTO GroupMemberTable (memberName, memberTitle, phoneNumber, thumbUrl, memberStatus, createdOn, createdBy, superAdmin, publish, events, album, addMember, globalUserId, groupId, localImagePath, groupMemberContactId, publicView) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    arguments: [groupMemebrsTable.memberName, groupMemebrsTable.memberTitle, groupMemebrsTable.phoneNumber, groupMemebrsTable.thumbUrl, groupMemebrsTable.memberStatus, groupMemebrsTable.createdOn, groupMemebrsTable.createdBy, groupMemebrsTable.superAdmin, groupMemebrsTable.publish, groupMemebrsTable.events, groupMemebrsTable.album, groupMemebrsTable.addMember, groupMemebrsTable.globalUserId, groupMemebrsTable.groupId, groupMemebrsTable.localImagePath, groupMemebrsTable.groupMemberContactId, groupMemebrsTable.publicView]
                )
                let insertId = Int(db.lastInsertedRowID)
                return insertId
            }
            return lastRowId!
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
            return 0
        }
    }

    static func updateGroupMmembers(groupMemebrsTable: GroupMemberTable) -> Int {
        do {
            let lastRowid = try dbQueue?.write { (db) -> Int in
                try db.execute(
                    sql: "UPDATE GroupMemberTable SET memberName = :memberName, memberTitle = :memberTitle, phoneNumber =:phoneNumber, thumbUrl = :thumbUrl, memberStatus = :memberStatus, createdOn = :createdOn, createdBy = :createdBy, superAdmin = :superAdmin, publish = :publish, events = :events, album = :album, addMember = :addMember, groupMemberContactId = :groupMemberContactId, localImagePath = :localImagePath, publicView = :publicView WHERE globalUserId = :globalUserId AND groupId = :groupId",
                    arguments: ["memberName": groupMemebrsTable.memberName, "memberTitle": groupMemebrsTable.memberTitle, "phoneNumber": groupMemebrsTable.phoneNumber, "thumbUrl": groupMemebrsTable.thumbUrl, "memberStatus": groupMemebrsTable.memberStatus, "createdOn": groupMemebrsTable.createdOn, "createdBy": groupMemebrsTable.createdBy, "superAdmin": groupMemebrsTable.superAdmin, "publish": groupMemebrsTable.publish, "events": groupMemebrsTable.events, "album": groupMemebrsTable.album, "addMember": groupMemebrsTable.addMember, "groupMemberContactId": groupMemebrsTable.groupMemberContactId, "localImagePath": groupMemebrsTable.localImagePath, "publicView": groupMemebrsTable.publicView, "globalUserId": groupMemebrsTable.globalUserId, "groupId": groupMemebrsTable.groupId]
                )
                let count = db.changesCount
                if count == 0 {
                    try db.execute(
                        sql: "INSERT OR REPLACE INTO GroupMemberTable (memberName, memberTitle, phoneNumber, thumbUrl, memberStatus, createdOn, createdBy, superAdmin, publish, events, album, addMember, globalUserId, groupId, localImagePath, groupMemberContactId, publicView) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        arguments: [groupMemebrsTable.memberName, groupMemebrsTable.memberTitle, groupMemebrsTable.phoneNumber, groupMemebrsTable.thumbUrl, groupMemebrsTable.memberStatus, groupMemebrsTable.createdOn, groupMemebrsTable.createdBy, groupMemebrsTable.superAdmin, groupMemebrsTable.publish, groupMemebrsTable.events, groupMemebrsTable.album, groupMemebrsTable.addMember, groupMemebrsTable.globalUserId, groupMemebrsTable.groupId, groupMemebrsTable.localImagePath, groupMemebrsTable.groupMemberContactId, groupMemebrsTable.publicView]
                    )
                }
                let insertId = Int(db.lastInsertedRowID)
                return insertId
            }
            return lastRowid!

        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
            return 0
        }
    }

    static func updateGroupMembersStatus(groupMemebrsTable: GroupMemberTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupMemberTable SET memberStatus = :memberStatus WHERE globalUserId = :globalUserId AND groupId = :groupId",
                    arguments: ["memberStatus": groupMemebrsTable.memberStatus, "globalUserId": groupMemebrsTable.globalUserId, "groupId": groupMemebrsTable.groupId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateGroupMembersContactId(groupMemebrsTable: GroupMemberTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupMemberTable SET groupMemberContactId = :groupMemberContactId WHERE globalUserId = :globalUserId AND groupId = :groupId",
                    arguments: ["groupMemberContactId": groupMemebrsTable.groupMemberContactId, "globalUserId": groupMemebrsTable.globalUserId, "groupId": groupMemebrsTable.groupId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateGroupMembersforNewValue(groupMemebrsTable: GroupMemberTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupMemberTable SET memberName = :memberName, memberTitle = :memberTitle, phoneNumber =:phoneNumber, thumbUrl = :thumbUrl, memberStatus = :memberStatus, createdOn = :createdOn, createdBy = :createdBy, superAdmin = :superAdmin, publish = :publish, events = :events, album = :album, addMember = :addMember, groupMemberContactId = :groupMemberContactId, localImagePath = :localImagePath, publicView = :publicView  WHERE globalUserId = :globalUserId AND groupId = :groupId",
                    arguments: ["memberName": groupMemebrsTable.memberName, "memberTitle": groupMemebrsTable.memberTitle, "phoneNumber": groupMemebrsTable.phoneNumber, "thumbUrl": groupMemebrsTable.thumbUrl, "memberStatus": groupMemebrsTable.memberStatus, "createdOn": groupMemebrsTable.createdOn, "createdBy": groupMemebrsTable.createdBy, "superAdmin": groupMemebrsTable.superAdmin, "publish": groupMemebrsTable.publish, "events": groupMemebrsTable.events, "album": groupMemebrsTable.album, "addMember": groupMemebrsTable.addMember, "groupMemberContactId": groupMemebrsTable.groupMemberContactId, "localImagePath": groupMemebrsTable.localImagePath, "publicView": groupMemebrsTable.publicView, "globalUserId": groupMemebrsTable.globalUserId, "groupId": groupMemebrsTable.groupId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateGroupMembersStatusNewValue(groupMemebrsTable: GroupMemberTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupMemberTable SET memberTitle = :memberTitle, superAdmin = :superAdmin, publish = :publish, events = :events, album = :album, addMember = :addMember, publicView = :publicView  WHERE globalUserId = :globalUserId AND groupId = :groupId",
                    arguments: ["memberTitle": groupMemebrsTable.memberTitle, "superAdmin": groupMemebrsTable.superAdmin, "publish": groupMemebrsTable.publish, "events": groupMemebrsTable.events, "album": groupMemebrsTable.album, "addMember": groupMemebrsTable.addMember, "publicView": groupMemebrsTable.publicView, "globalUserId": groupMemebrsTable.globalUserId, "groupId": groupMemebrsTable.groupId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateGroupMembersPicture(globalUserId: String, image: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupMemberTable SET localImagePath = :localImagePath WHERE globalUserId = :globalUserId",
                    arguments: ["localImagePath": image, "globalUserId": globalUserId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateGroupMembersPhoneNumber(groupMemebrsTable: GroupMemberTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupMemberTable SET phoneNumber = :phoneNumber WHERE globalUserId = :globalUserId",
                    arguments: ["phoneNumber": groupMemebrsTable.phoneNumber, "globalUserId": groupMemebrsTable.globalUserId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateGroupMembersLocalImagePath(localImagePath: String, localId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE GroupMemberTable SET localImagePath = :localImagePath WHERE groupMemberId = :groupMemberId",
                    arguments: ["localImagePath": localImagePath, "groupMemberId": localId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func getGroupMemberIndex(groupId: String, globalUserId: String) -> GroupMemberTable? {
        do {
            let group = try dbQueue?.read { db in

                try GroupMemberTable.fetchOne(db, sql: "SELECT * FROM GroupMemberTable WHERE groupId = ? AND globalUserId = ?", arguments: [groupId, globalUserId])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getGroupMemberIndexForMemberId(groupId: String) -> GroupMemberTable? {
        do {
            let group = try dbQueue?.read { db in

                try GroupMemberTable.fetchOne(db, sql: "SELECT * FROM GroupMemberTable WHERE groupMemberId = ?", arguments: [groupId])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getGroupMembers(globalGroupId: String) -> [GroupMemberTable] {
        do {
            let group = try dbQueue?.read { db -> [GroupMemberTable] in

                try GroupMemberTable.fetchAll(db, sql: "SELECT * FROM GroupMemberTable WHERE groupId = \(globalGroupId) AND memberStatus != 2 ORDER BY superAdmin = 1, addMember = 1", arguments: []).reversed()
            }
            return group ?? []
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return []
        }
    }

    static func getPublicGroupMembers(globalGroupId: String) -> [GroupMemberTable] {
        do {
            let group = try dbQueue?.read { db -> [GroupMemberTable] in

                try GroupMemberTable.fetchAll(db, sql: "SELECT * FROM GroupMemberTable WHERE groupId = \(globalGroupId) AND memberTitle != ?", arguments: [""]).reversed()
            }
            return group ?? []
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: Messages

    static func storeIntoMsgTable(messageTable: MessagesTable) -> Int {
        do {
//            let group = try dbQueue?.read { db in
//
//                return try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE globalMsgId = ?", arguments: [messageTable.globalMsgId])
//                }
//            if group == nil {
            let lastRowid = try dbQueue?.write { (db) -> Int in
                try db.execute(
                    sql: "INSERT INTO MessagesTable (isMine, senderId, messageType, text, media, other, otherType, topicId, messageState, mesgSource, chanelId, channelType, globalMsgId, action, replyToId, msgTimeStamp, readCount,seenCount,readMembers,seenMembers,targetCount,seenRecept, attachmentsExtra, visibilityStatus, isForwarded) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    arguments: [messageTable.isMine, messageTable.senderId, messageTable.messageType, messageTable.text, messageTable.media, messageTable.other, messageTable.otherType, messageTable.topicId, messageTable.messageState, messageTable.mesgSource, messageTable.chanelId, messageTable.channelType, messageTable.globalMsgId, messageTable.action, messageTable.replyToId, messageTable.msgTimeStamp, messageTable.readCount, messageTable.seenCount, messageTable.readMembers, messageTable.seenMembers, messageTable.targetCount, messageTable.seenRecept, messageTable.attachmentsExtra, messageTable.visibilityStatus, messageTable.isForwarded]
                )
                let insertId = Int(db.lastInsertedRowID)
                return insertId
            }
            return lastRowid!
//            } else {
//                return 0
//            }
        } catch {
            print("dbError storeContacts: \(error.localizedDescription)")
            return 0
        }
    }

    static func checkIfMsgExists(msgId: String) -> Bool {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE globalMsgId = ?", arguments: [msgId])
            }
            if group == nil {
                return false
            } else {
                return true
            }

        } catch {
            print("dbError storeContacts: \(error.localizedDescription)")
            return false
        }
    }

    static func storeMultipleMessagesIntoMsgTable(messageTable: MessagesTable) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "INSERT INTO MessagesTable (isMine, senderId, messageType, text, media, other, otherType, topicId, messageState, mesgSource, chanelId, channelType, globalMsgId, action, replyToId, msgTimeStamp, readCount,seenCount,readMembers,seenMembers,targetCount,seenRecept) SELECT  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, id, channelType, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?   from channelTable where channelType in (1,2)",
                    arguments: [messageTable.isMine, messageTable.senderId, messageTable.messageType, messageTable.text, messageTable.media, messageTable.other, messageTable.otherType, messageTable.topicId, messageTable.messageState, messageTable.mesgSource, messageTable.chanelId, messageTable.channelType, messageTable.globalMsgId, messageTable.action, messageTable.replyToId, messageTable.msgTimeStamp, messageTable.readCount, messageTable.seenCount, messageTable.readMembers, messageTable.seenMembers, messageTable.targetCount, messageTable.seenRecept, messageTable.isForwarded]
                )
            }
        } catch {
            print("dbError storeContacts: \(error.localizedDescription)")
        }
    }

    static func updateMessageTableForDirectChatReadReceipt(messageState: String, globalMessageId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET messageState = :messageState WHERE globalMsgId = :globalMsgId",
                    arguments: ["messageState": messageState, "globalMsgId": globalMessageId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMessageTableForattachMentUrl(attachmentUrl: String, globalMessageId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET attachmentsExtra = :attachmentsExtra WHERE globalMsgId = :globalMsgId",
                    arguments: ["attachmentsExtra": attachmentUrl, "globalMsgId": globalMessageId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMessageTableForLocalImage(localImagePath: String, localId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET media = :media WHERE id = :id",
                    arguments: ["media": localImagePath, "id": localId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMessageTableForOtherColoumn(imageData: String, localId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET other = :other WHERE id = :id",
                    arguments: ["other": imageData, "id": localId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMessageTableforColoumnAndValue(coloumnName: String, Value: String, localId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET \(coloumnName) = ? WHERE id = ?",
                    arguments: [Value, localId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMessageTableForMultipleDirectChatReadReceipt(messagState: String, firstMsgId: String, lastMsgId: String, channelId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET messageState = ? WHERE id >= ? AND id <= ? AND chanelId = ? AND messageState != ?",
                    arguments: [messagState, firstMsgId, lastMsgId, channelId, messageState.RECEIVER_SEEN.rawValue]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func getUnreadMessagesForChannelId(channelId: String) -> [MessagesTable] {
        do {
            let group = try dbQueue?.read { db -> [MessagesTable] in

                try MessagesTable.fetchAll(db, sql: "SELECT * FROM MessagesTable WHERE chanelId = ? AND visibilityStatus < ? AND messageState = ? ORDER BY id ASC", arguments: [channelId, visibilityStatus.deleted.rawValue, messageState.RECEIVER_RECEIVED.rawValue]).reversed()
            }
            return group ?? []
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return []
        }
    }

    static func updateMessageTableToSeenForChannelId(channelId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET messageState = ? WHERE chanelId = ? AND (messageState = ?)",
                    arguments: [messageState.RECEIVER_SEEN.rawValue, channelId, messageState.RECEIVER_RECEIVED.rawValue]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMessageTableToSeenForChannelIdandTopic(channelId: String, topicId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET messageState = ? WHERE chanelId = ? AND topicId = ? AND (messageState = ?)",
                    arguments: [messageState.RECEIVER_SEEN.rawValue, channelId, topicId, messageState.RECEIVER_RECEIVED.rawValue]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMessageTableForgroupReadReceipt(readMembers: String, readCount: Int, lastMsgId: String, channelId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET readMembers = :readMembers, readCount = :readCount  WHERE id = :id AND chanelId = :chanelId",
                    arguments: ["readMembers": readMembers, "readCount": readCount, "id": lastMsgId, "chanelId": channelId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMessageTableForgroupSeenReceipt(seenMembers: String, seenCount: Int, lastMsgId: String, channelId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET seenMembers = :seenMembers, seenCount = :seenCount  WHERE id = :id AND chanelId = :chanelId",
                    arguments: ["seenMembers": seenMembers, "seenCount": seenCount, "id": lastMsgId, "chanelId": channelId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updateMessageTableForRangeOfGroup(ColoumnName: String, countColoumnName: String, seenMembers: String, firstMsgId: String, lastMsgId: String, channelId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE MessagesTable SET \(ColoumnName) = \(ColoumnName) || ','|| \(seenMembers), \(countColoumnName) =  \(countColoumnName) + 1  WHERE id >= ? AND id <= ? AND chanelId = ?",
                    arguments: [firstMsgId, lastMsgId, channelId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func getMessageIndex(globalMsgId: String) -> MessagesTable? {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE globalMsgId = ?", arguments: [globalMsgId])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getMessage(messageId: String) -> MessagesTable? {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE id = ?", arguments: [messageId])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getLatestMessage(channelId: String, channelType: String) -> MessagesTable? {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE chanelId = ? AND channelType = ?  AND visibilityStatus < ? ORDER BY id DESC LIMIT 1", arguments: [channelId, channelType, visibilityStatus.deleted.rawValue])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getMessagesForChannelId(channelId: String) -> [MessagesTable] {
        do {
            let group = try dbQueue?.read { db -> [MessagesTable] in

                try MessagesTable.fetchAll(db, sql: "SELECT * FROM MessagesTable WHERE chanelId = ? AND visibilityStatus < ?", arguments: [channelId, visibilityStatus.deleted.rawValue]).reversed()
            }
            return group ?? []
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return []
        }
    }

    static func getLastUnseenMessageChannelId(channelId: String) -> MessagesTable? {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE chanelId = ? AND visibilityStatus < ? AND messageState = ? ORDER BY id ASC LIMIT 1 ", arguments: [channelId, visibilityStatus.deleted.rawValue, messageState.RECEIVER_RECEIVED.rawValue])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getFirstUnseenMessageChannelId(channelId: String) -> MessagesTable? {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE chanelId = ? AND visibilityStatus < ? AND messageState = ? ORDER BY id ASC LIMIT 1 ", arguments: [channelId, visibilityStatus.deleted.rawValue, messageState.RECEIVER_RECEIVED.rawValue])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getMessagesFormessageIdOfspeakerGroup(channelId: String, replyMessageId: String) -> [MessagesTable] {
        do {
            let group = try dbQueue?.read { db -> [MessagesTable] in

                try MessagesTable.fetchAll(db, sql: "SELECT * FROM MessagesTable WHERE chanelId = ? AND visibilityStatus < ? AND topicId = ?", arguments: [channelId, visibilityStatus.deleted.rawValue, replyMessageId]).reversed()
            }
            return group ?? []
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return []
        }
    }

    static func getUnreadMessagesFormessageIdOfspeakerGroup(channelId: String, replyMessageId: String) -> [MessagesTable] {
        do {
            let group = try dbQueue?.read { db -> [MessagesTable] in

                try MessagesTable.fetchAll(db, sql: "SELECT * FROM MessagesTable WHERE chanelId = ? AND visibilityStatus < ? AND topicId = ? AND messageState = ?", arguments: [channelId, visibilityStatus.deleted.rawValue, replyMessageId, messageState.RECEIVER_RECEIVED.rawValue]).reversed()
            }
            return group ?? []
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return []
        }
    }

    static func getMessagesForChannelIdForSpeakerGroup(channelId: String) -> [MessagesTable] {
        do {
            let group = try dbQueue?.read { db -> [MessagesTable] in
                try MessagesTable.fetchAll(db, sql: "SELECT * FROM MessagesTable WHERE chanelId = ? AND visibilityStatus < ? AND globalMsgId = topicId", arguments: [channelId, visibilityStatus.deleted.rawValue]).reversed()
            }
            return group ?? []
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return []
        }
    }

    static func getMessagesForHomeScreenNotifications(timestamp: String) -> [MessagesTable]? {
        let channelTypes = "\(channelType.TOPIC_GROUP.rawValue),\(channelType.PUBLIC_GROUP.rawValue),\(channelType.PRIVATE_GROUP.rawValue),\(channelType.NOTIFICATIONS.rawValue)"
        do {
            let group = try dbQueue?.read { db -> [MessagesTable] in
                try MessagesTable.fetchAll(db, sql: "SELECT * FROM MessagesTable WHERE channelType in(\(channelTypes)) AND visibilityStatus < ? AND msgTimeStamp > ? AND globalMsgId = topicId AND (messageState != ? AND messageState != ?) ORDER BY id DESC", arguments: [visibilityStatus.deleted.rawValue, timestamp, messageState.SENDER_UNSENT.rawValue, messageState.MESSAGE_INFO.rawValue])
            }
            return group ?? []
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return []
        }
    }

    static func getRecentMessagesForHomeScreenNotifications() -> [MessagesTable]? {
        let channelTypes = "\(channelType.TOPIC_GROUP.rawValue),\(channelType.PUBLIC_GROUP.rawValue),\(channelType.PRIVATE_GROUP.rawValue)"

        do {
            let group = try dbQueue?.read { db -> [MessagesTable] in
                try MessagesTable.fetchAll(db, sql: "SELECT * FROM MessagesTable WHERE channelType in(\(channelTypes)) AND visibilityStatus < ? AND globalMsgId = topicId AND (messageState != ? AND messageState != ?) ORDER BY id DESC LIMIT 12", arguments: [visibilityStatus.deleted.rawValue, messageState.SENDER_UNSENT.rawValue, messageState.MESSAGE_INFO.rawValue])
            }
            return group ?? []
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return []
        }
    }

    static func getTimeStampOfLastMessage() -> MessagesTable? {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE messageState > ? AND visibilityStatus < ? ORDER BY id DESC LIMIT 1", arguments: [messageState.SENDER_UNSENT.rawValue, visibilityStatus.deleted.rawValue])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getTimeStampOfLastMessageForSelf() -> MessagesTable? {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE channelType = ? AND isMine = ? ORDER BY id DESC LIMIT 1", arguments: [channelType.ONE_ON_ONE_CHAT.rawValue, false])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getTimeStampOfLastMessageForchannel(channelId: String, channelType: String) -> MessagesTable? {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE chanelId = ? AND channelType = ? AND messageState > ? ORDER BY id DESC LIMIT 1", arguments: [channelId, channelType, messageState.SENDER_UNSENT.rawValue])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getAllMessages() -> [MessagesTable]? {
        do {
            let group = try dbQueue?.read { db in
                try MessagesTable.fetchAll(db, sql: "SELECT * FROM MessagesTable")
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getUnsentMessages() -> [MessagesTable]? {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchAll(db, sql: "SELECT * FROM MessagesTable WHERE messageState = ? AND visibilityStatus < ?", arguments: [messageState.SENDER_UNSENT.rawValue, visibilityStatus.deleted.rawValue])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: POLL

    static func storePollData(pollTable: PollTable) -> Int {
        do {
            let lastRowId = try dbQueue?.write { (db) -> Int in

                try db.execute(
                    sql: "UPDATE PollTable SET pollCreatedBy = ?, pollCreatedOn = ?, pollExpireOn = ?, pollTitle = ?, pollOPtions =?, pollType = ?, numberOfOptions = ?,selectedChoice = ? WHERE pollId = ?",
                    arguments: [pollTable.pollCreatedBy, pollTable.pollCreatedOn, pollTable.pollExpireOn, pollTable.pollTitle, pollTable.pollOPtions, pollTable.pollType, pollTable.numberOfOptions, pollTable.selectedChoice, pollTable.pollId]
                )
                let count = db.changesCount
                if count == 0 {
                    try db.execute(
                        sql: "INSERT INTO PollTable (pollId, messageId, pollCreatedBy, pollCreatedOn, pollExpireOn, pollTitle, pollOPtions, pollType,numberOfOptions,selectedChoice, localData) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        arguments: [pollTable.pollId, pollTable.messageId, pollTable.pollCreatedBy, pollTable.pollCreatedOn, pollTable.pollExpireOn, pollTable.pollTitle, pollTable.pollOPtions, pollTable.pollType, pollTable.numberOfOptions, pollTable.selectedChoice, pollTable.localData]
                    )
                    let insertId = Int(db.lastInsertedRowID)
                    return insertId
                } else {
                    return 0
                }
            }
            return lastRowId!
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
            return 0
        }
    }

    static func updateSelectedPoll(selectedChoice: String, pollId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE PollTable SET selectedChoice = :selectedChoice WHERE pollId = :pollId",
                    arguments: ["selectedChoice": selectedChoice, "pollId": pollId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updatePollOptions(pollOptions: String, pollId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE PollTable SET pollOPtions = :pollOPtions WHERE pollId = :pollId",
                    arguments: ["pollOPtions": pollOptions, "pollId": pollId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func updatePollLocalDataOptions(localData: String, pollId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(
                    sql: "UPDATE PollTable SET localData = :localData WHERE pollId = :pollId",
                    arguments: ["localData": localData, "pollId": pollId]
                )
            }
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
        }
    }

    static func getPollDataForId(localPollId: String) -> PollTable? {
        do {
            let group = try dbQueue?.read { db in

                try PollTable.fetchOne(db, sql: "SELECT * FROM PollTable WHERE id = ?", arguments: [localPollId])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: Unique Ref

    // MARK: POLL

    static func SaveUniqueRef(ref: String) -> Int {
        do {
            let lastRowId = try dbQueue?.write { (db) -> Int in
                try db.execute(
                    sql: "INSERT INTO UniqueRefTable (uniqueId) VALUES (?)",
                    arguments: [ref]
                )
                let insertId = Int(db.lastInsertedRowID)
                return insertId
            }
            return lastRowId!
        } catch {
            print("dbError storeGroup: \(error.localizedDescription)")
            return 0
        }
    }

    static func getUniqueRef(ref: String) -> UniqueRefTable? {
        do {
            let group = try dbQueue?.read { db in

                try UniqueRefTable.fetchOne(db, sql: "SELECT * FROM UniqueRefTable WHERE uniqueId = ?", arguments: [ref])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    static func getGlobalMsgId(ref: String) -> MessagesTable? {
        do {
            let group = try dbQueue?.read { db in

                try MessagesTable.fetchOne(db, sql: "SELECT * FROM MessagesTable WHERE globalMsgId = ?", arguments: [ref])
            }
            return group
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: delete

    static func deleteFromMembersTable(globalGroupId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(sql: "DELETE FROM GroupMemberTable WHERE groupId = \(globalGroupId)")
            }
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
        }
    }

    // MARK: delete

    static func deleteFromGroupsTable(groupId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(sql: "DELETE FROM GroupTable WHERE id = \(groupId)")
            }
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
        }
    }

    // MARK: delete

    static func deleteMessagesForChannelId(channelId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(sql: "DELETE FROM MessagesTable WHERE chanelId = \(channelId)")
            }
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
        }
    }

    // MARK: delete

    static func deleteFromChannelTable(channelId: String) {
        do {
            try dbQueue?.write { db in
                try db.execute(sql: "DELETE FROM ChannelTable WHERE id = \(channelId)")
            }
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
        }
    }

    static func deleteGroupTable() {
        do {
            try dbQueue?.write { db in
                try GroupTable.deleteAll(db)
            }
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
        }
    }

    static func deleteChannelTable() {
        do {
            try dbQueue?.write { db in
                try ChannelTable.deleteAll(db)
            }
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
        }
    }

    static func deleteGroupMembersTable() {
        do {
            try dbQueue?.write { db in
                try GroupMemberTable.deleteAll(db)
            }
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
        }
    }

    static func deleteContactsTable() {
        do {
            try dbQueue?.write { db in
                try ProfileTable.deleteAll(db)
            }
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
        }
    }

    static func deleteMessagesTable() {
        do {
            try dbQueue?.write { db in
                try MessagesTable.deleteAll(db)
            }
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
        }
    }

    static func deleteUserTable() {
        do {
            try dbQueue?.write { db in
                try UserModel.deleteAll(db)
            }
        } catch {
            print("dbError getUser: \(error.localizedDescription)")
        }
    }

    //to be deleted

    // FETCH MESSAGE TYPE
    static func dBRead<T>(_ block: (Database) throws -> T) -> T? {
        do {
            return try dbQueue?.read(block)
        } catch {
            print("dbError getGroup: \(error.localizedDescription)")
        }
        return nil as T?
    }
}
