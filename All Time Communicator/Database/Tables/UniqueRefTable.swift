//
//  UniqueRefTable.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 20/05/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class UniqueRefTable: EVNetworkingObject, Codable, FetchableRecord, TableRecord, PersistableRecord {
    var uniqueId: String?

    internal enum Columns: String, ColumnExpression {
        case uniqueId
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.uniqueId.name, .integer).primaryKey()
    }
}
