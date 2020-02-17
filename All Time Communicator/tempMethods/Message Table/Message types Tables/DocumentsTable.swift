//
//  DocumentsTable.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 07/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

// Doument card Model
class DocumentTable: EVNetworkingObject, Codable, PersistableRecord, TableRecord, FetchableRecord {
    var messageId: String?
    var documentId: Int?
    var documentTitle: String = ""
    var documentThumbnail: String = ""
    // TODO: Need to change the DocumentData datatype
    var documentData: String = ""
    var documentCreatedBy: String = ""
    var documentCreatedOn: String = ""

    static let messageIdForeignKey = ForeignKey(["messageId"])
    static let document = belongsTo(MessageBaseTable.self, using: DocumentTable.messageIdForeignKey)
    var document: QueryInterfaceRequest<MessageBaseTable> {
        return request(for: DocumentTable.document)
    }

    internal enum Columns: String, ColumnExpression {
        case documentId
        case messageId
        case documentTitle
        case documentCreatedBy
        case documentCreatedOn
        case documentData
        case documentThumbnail
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.documentId.name, .integer)
        tableDefinition.column(Columns.messageId.name, .text).primaryKey()
        tableDefinition.column(Columns.documentThumbnail.name, .text)
        tableDefinition.column(Columns.documentData.name, .text)
        tableDefinition.column(Columns.documentTitle.name, .text)
        tableDefinition.column(Columns.documentCreatedBy.name, .text)
        tableDefinition.column(Columns.documentCreatedOn.name, .text)
    }
}
