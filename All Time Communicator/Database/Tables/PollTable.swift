//
//  PollTable.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 01/04/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class PollTable: EVNetworkingObject, Codable, PersistableRecord, TableRecord, FetchableRecord {
    var id: Int?
    var messageId: String?
    var pollId: String = ""
    var pollTitle: String = ""
    var pollOPtions: String = ""
    var pollCreatedBy: String = ""
    var pollCreatedOn: String = ""
    var pollExpireOn: String = ""
    var pollType: String = ""
    var numberOfOptions: Int = 2
    var selectedChoice: String = ""
    var localData: String = ""

    private func loadValues(result: PollTable) {
        id = result.id
        messageId = result.messageId
        pollId = result.pollId
        pollTitle = result.pollTitle
        pollOPtions = result.pollOPtions
        pollCreatedOn = result.pollCreatedOn
        pollCreatedBy = result.pollCreatedBy
        pollExpireOn = result.pollExpireOn
        pollType = result.pollType
        localData = result.localData
    }

    internal enum Columns: String, ColumnExpression {
        case id
        case messageId
        case pollId
        case pollTitle
        case pollCreatedBy
        case pollCreatedOn
        case pollExpireOn
        case pollOptions
        case pollType
        case numberOfOptions
        case selectedChoice
        case localData
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.id.name, .integer).primaryKey(onConflict: .ignore, autoincrement: true)
        tableDefinition.column(Columns.pollId.name, .integer)
        tableDefinition.column(Columns.messageId.name, .text)
        tableDefinition.column(Columns.pollTitle.name, .text)
        tableDefinition.column(Columns.pollCreatedBy.name, .text)
        tableDefinition.column(Columns.pollCreatedOn.name, .text)
        tableDefinition.column(Columns.pollExpireOn.name, .text)
        tableDefinition.column(Columns.pollOptions.name, .text)
        tableDefinition.column(Columns.pollType.name, .text)
        tableDefinition.column(Columns.numberOfOptions.name, .integer)
        tableDefinition.column(Columns.selectedChoice.name, .text)
        tableDefinition.column(Columns.localData.name, .text)
    }

    // POLL OPTION WITH DATA
    class PollOptions: EVNetworkingObject, Codable {
        var choiceId: String = ""
        var choiceText: String = ""
        var choiceImage: String = ""

        var localData: String = ""
        var numberOfVotes: String = ""
    }
}
