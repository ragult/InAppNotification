//
//  EventsTable.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 07/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class EventsTable: EVNetworkingObject, Codable, PersistableRecord, TableRecord, FetchableRecord {
    var messageId: String?
    var eventId: Int?
    var eventTitle: String = ""
    var eventDescription: String = ""
    var eventLocation: String = ""
    var eventTimeAndDate: String = ""
    var eventCreatedBy: String = ""
    var eventCreatedOn: String = ""
    var isGoingtoEvent = false

    static let messageIdForeignKey = ForeignKey(["messageId"])
    static let event = belongsTo(MessageBaseTable.self, using: EventsTable.messageIdForeignKey)
    var event: QueryInterfaceRequest<MessageBaseTable> {
        return request(for: EventsTable.event)
    }

    func loadValues(result: EventsTable) {
        eventId = result.eventId
        messageId = result.messageId
        eventTitle = result.eventTitle
        eventDescription = result.eventDescription
        eventLocation = result.eventLocation
        eventCreatedBy = result.eventCreatedBy
        eventCreatedOn = result.eventCreatedOn
    }

    internal enum Columns: String, ColumnExpression {
        case messageId
        case eventId
        case eventTitle
        case eventDescription
        case eventLocation
        case eventTimeAndDate
        case eventCreatedBy
        case eventCreatedOn
        case eventMessageTag
        case isGoingtoEvent
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.eventId.name, .integer)
        tableDefinition.column(Columns.messageId.name, .text).primaryKey()
        tableDefinition.column(Columns.eventTitle.name, .text)
        tableDefinition.column(Columns.eventLocation.name, .text)
        tableDefinition.column(Columns.eventCreatedBy.name, .text)
        tableDefinition.column(Columns.eventCreatedOn.name, .text)
        tableDefinition.column(Columns.eventDescription.name, .text)
        tableDefinition.column(Columns.eventTimeAndDate.name, .text)
        tableDefinition.column(Columns.isGoingtoEvent.name, .boolean)
    }
}
