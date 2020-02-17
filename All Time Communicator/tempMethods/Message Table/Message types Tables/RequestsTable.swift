//
//  RequestsTable.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 07/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class RequestTable: EVNetworkingObject, Codable, PersistableRecord, TableRecord, FetchableRecord {
    var requestId: Int?
    var messageId: String?
    var requestTitle: String = ""
    var requestTimeandDate: String = ""
    var requestPurpose: Bool = false
    var requestDescription: String = ""
    var requestThumbnail: String = ""
    var requestCreatedBy: String = ""
    var requestCreatedOn: String = ""
    var isAccepted: Bool = false

    static let messageIdForeignKey = ForeignKey(["messageId"])
    static let request = belongsTo(MessageBaseTable.self, using: RequestTable.messageIdForeignKey)
    var request: QueryInterfaceRequest<MessageBaseTable> {
        return request(for: RequestTable.request)
    }

    private func loadValues(result: RequestTable) {
        requestId = result.requestId
        messageId = result.messageId
        requestTitle = result.requestTitle
        requestTimeandDate = result.requestTimeandDate
        requestPurpose = result.requestPurpose
        requestCreatedBy = result.requestCreatedBy
        requestThumbnail = result.requestThumbnail
        requestCreatedOn = result.requestCreatedOn
    }

    internal enum Columns: String, ColumnExpression {
        case requestId
        case requestTitle
        case requestTimeandDate
        case requestPurpose
        case requestDescription
        case requestCreatedBy
        case requestCreatedon
        case requestThumbnail
        case isAccepted
        case messageId
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.requestId.name, .integer)
        tableDefinition.column(Columns.requestTitle.name, .text)
        tableDefinition.column(Columns.messageId.name, .text).primaryKey()
        tableDefinition.column(Columns.requestDescription.name, .text)
        tableDefinition.column(Columns.requestTimeandDate.name, .text)
        tableDefinition.column(Columns.requestPurpose.name, .text)
        tableDefinition.column(Columns.requestCreatedBy.name, .text)
        tableDefinition.column(Columns.requestCreatedon.name, .text)
        tableDefinition.column(Columns.isAccepted.name, .boolean)
        tableDefinition.column(Columns.requestThumbnail.name, .text)
    }
}
