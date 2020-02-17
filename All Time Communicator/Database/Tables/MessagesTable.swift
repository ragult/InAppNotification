//
//  MessagesTable.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 31/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import GRDB
import UIKit

class MessagesTable: EVNetworkingObject, Codable, PersistableRecord, TableRecord, FetchableRecord {
    var id: String = ""
    var isMine: Bool = false
    var senderId: String = ""
    var messageType: String = ""
    var text: String = ""
    var media: String = ""
    var other: String = ""
    var otherType: String = ""
    var topicId: String = ""
    var messageState: String = ""
    var mesgSource: String = ""
    var chanelId: String = ""
    var channelType: String = ""
    var globalMsgId: String = ""
    var action: String = ""
    var replyToId: String = ""
    var msgTimeStamp: String = ""
    var readCount: Int = 0
    var seenCount: Int = 0
    var readMembers: String = ""
    var seenMembers: String = ""
    var targetCount: String = ""
    var seenRecept: String = ""
    var attachmentsExtra: String = ""
    var visibilityStatus: String = "1"
    var isForwarded: Bool = false

    func loadValues(result: MessagesTable) {
        isMine = result.isMine
        senderId = result.senderId
        messageType = result.messageType
        text = result.text
        media = result.media
        other = result.other
        otherType = result.otherType
        topicId = result.topicId
        messageState = result.messageState
        mesgSource = result.mesgSource
        chanelId = result.chanelId
        channelType = result.channelType
        globalMsgId = result.globalMsgId
        action = result.action
        replyToId = result.replyToId
        msgTimeStamp = result.msgTimeStamp
        readCount = result.readCount
        seenCount = result.seenCount
        readMembers = result.readMembers
        seenMembers = result.seenMembers
        targetCount = result.targetCount
        seenRecept = result.seenRecept
    }

    internal enum Columns: String, ColumnExpression {
        case id
        case isMine
        case senderId
        case messageType
        case text
        case media
        case other
        case otherType
        case topicId
        case messageState
        case mesgSource
        case chanelId
        case channelType
        case globalMsgId
        case action
        case replyToId
        case msgTimeStamp
        case readCount
        case seenCount
        case readMembers
        case seenMembers
        case targetCount
        case seenRecept
        case attachmentsExtra
        case visibilityStatus
        case isForwarded
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.id.name, .integer).primaryKey(onConflict: .ignore, autoincrement: true)
        tableDefinition.column(Columns.isMine.name, .boolean)
        tableDefinition.column(Columns.senderId.name, .text)
        tableDefinition.column(Columns.messageType.name, .text)
        tableDefinition.column(Columns.text.name, .text)
        tableDefinition.column(Columns.media.name, .text)
        tableDefinition.column(Columns.other.name, .text)
        tableDefinition.column(Columns.otherType.name, .text)
        tableDefinition.column(Columns.topicId.name, .text)
        tableDefinition.column(Columns.messageState.name, .text)
        tableDefinition.column(Columns.mesgSource.name, .text)
        tableDefinition.column(Columns.chanelId.name, .text)
        tableDefinition.column(Columns.channelType.name, .text)
        tableDefinition.column(Columns.globalMsgId.name, .text)
        tableDefinition.column(Columns.action.name, .text)
        tableDefinition.column(Columns.replyToId.name, .text)
        tableDefinition.column(Columns.msgTimeStamp.name, .text)
        tableDefinition.column(Columns.readCount.name, .integer)
        tableDefinition.column(Columns.seenCount.name, .integer)
        tableDefinition.column(Columns.readMembers.name, .text)
        tableDefinition.column(Columns.seenMembers.name, .text)
        tableDefinition.column(Columns.targetCount.name, .text)
        tableDefinition.column(Columns.seenRecept.name, .text)
        tableDefinition.column(Columns.attachmentsExtra.name, .text)
        tableDefinition.column(Columns.visibilityStatus.name, .text)
        tableDefinition.column(Columns.isForwarded.name, .boolean   )
    }
}
