//
//  TextMessageTable.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 08/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class TextMessageTable: EVNetworkingObject, Codable, FetchableRecord, PersistableRecord, TableRecord {
    var messageId: String?
    var textMessageId: Int?
    var text: String = "Hello there"

    // Relation
    static let messageIdForeignKey = ForeignKey(["messageId"])
    static let textMessage = belongsTo(MessageBaseTable.self, using: TextMessageTable.messageIdForeignKey)
    var textMessage: QueryInterfaceRequest<MessageBaseTable> {
        return request(for: TextMessageTable.textMessage)
    }

    // loading values from server
    func loadValues(result: TextMessageTable) {
        messageId = result.messageId
        textMessageId = result.textMessageId
    }

    internal enum Columns: String, ColumnExpression {
        case messageId
        case textMessageId
        case text
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.messageId.name, .text).primaryKey()
        tableDefinition.column(Columns.textMessageId.name, .integer)
        tableDefinition.column(Columns.text.name, .text)
    }
}
