//
//  ChannelTable.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 27/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import GRDB
import UIKit

class ChannelTable: EVNetworkingObject, Codable, FetchableRecord, TableRecord, PersistableRecord {
    var id: String = ""
    var contactId: String = ""
    var channelType: String = ""
    var globalChannelName: String = ""
    var lastSenderPhone: String = ""
    var lastSenderContactId: String = ""
    var lastSavedMsgid: String = ""
    var lastSeenMsgId: String = ""
    var lastMsgTime: String = ""
    var unseenCount: String = ""
    var channelStatus: String = ""
    var channelSyncTime: String = ""

    internal enum Columns: String, ColumnExpression {
        case id
        case contactId
        case channelType
        case globalChannelName
        case lastSenderPhone
        case lastSenderContactId
        case lastSavedMsgid
        case lastSeenMsgId
        case lastMsgTime
        case unseenCount
        case channelStatus
        case channelSyncTime
    }

    func loadValues(result: ChannelTable) {
        id = result.id
        contactId = result.contactId
        channelType = result.channelType
        globalChannelName = result.globalChannelName
        lastSenderPhone = result.lastSenderPhone
        lastSenderContactId = result.lastSenderContactId
        lastSavedMsgid = result.lastSavedMsgid
        lastSeenMsgId = result.lastSeenMsgId
        lastMsgTime = result.lastMsgTime
        unseenCount = result.unseenCount
        channelStatus = result.channelStatus
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.id.name, .integer).primaryKey(onConflict: .ignore, autoincrement: true)
        tableDefinition.column(Columns.contactId.name, .text)
        tableDefinition.column(Columns.channelType.name, .text)
        tableDefinition.column(Columns.globalChannelName.name, .text)
        tableDefinition.column(Columns.lastSenderPhone.name, .text)
        tableDefinition.column(Columns.lastSenderContactId.name, .text)
        tableDefinition.column(Columns.lastSavedMsgid.name, .text)
        tableDefinition.column(Columns.lastSeenMsgId.name, .text)
        tableDefinition.column(Columns.lastMsgTime.name, .text)
        tableDefinition.column(Columns.unseenCount.name, .text)
        tableDefinition.column(Columns.channelStatus.name, .text)
        tableDefinition.column(Columns.channelSyncTime.name, .text)
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        //        ("propertyName", nil) for ignoring
        return [("contactId", "contact_id"), ("nickName", nil), ("fullName", nil), ("dateOfBirth", nil), ("picture", nil), ("emailId", nil), ("city", nil), ("zipCode", nil), ("latitude", nil), ("countryCode", nil), ("globalUserId", nil), ("phoneNumber2", nil), ("existingUser", nil), ("selected", nil), ("deviceApn", nil), ("deviceApnType", nil)]
    }
}
