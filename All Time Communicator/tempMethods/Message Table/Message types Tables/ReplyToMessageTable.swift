//
//  ReplyToMessageTable.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 07/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class ReplyToMessageTable: EVNetworkingObject, Codable, PersistableRecord, TableRecord, FetchableRecord {
    var messageId: String?
    var replyMessage: String = ""
    var replyMessageId: Int?
    var replyToMessage: String = ""
    var replyTomessageSender: String = ""

    static let messageIdForeignKey = ForeignKey(["messageId"])
    static let replyToMsg = belongsTo(MessageBaseTable.self, using: ReplyToMessageTable.messageIdForeignKey)
    var replyToMsg: QueryInterfaceRequest<MessageBaseTable> {
        return request(for: ReplyToMessageTable.replyToMsg)
    }

    func loadData(result: ReplyToMessageTable) {
        messageId = result.messageId
        replyToMessage = result.replyToMessage
        replyMessage = result.replyMessage
        replyMessageId = result.replyMessageId
        replyTomessageSender = result.replyTomessageSender
    }

    internal enum Columns: String, ColumnExpression {
        case messageId
        case replyToMessage
        case replyMessage
        case replyToMessageSender
        case replyMessageId
    }

    internal static func defineTableDefinition(tabledefinition: TableDefinition) {
        tabledefinition.column(Columns.messageId.name, .text).primaryKey()
        tabledefinition.column(Columns.replyMessage.name, .text)
        tabledefinition.column(Columns.replyToMessage.name, .text)
        tabledefinition.column(Columns.replyToMessageSender.name, .text)
        tabledefinition.column(Columns.replyMessageId.name, .integer)
    }
}
