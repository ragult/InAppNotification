//
//  ImageCollectionTable.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 07/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

// Photos collection card Model
class PhotosCollectionTable: EVNetworkingObject, Codable, PersistableRecord, TableRecord, FetchableRecord {
    var photosId: Int?
    var messageId: String?
    var photos: [String] = [""]
    var photosCreatedBy: String = ""
    var photosCreatedOn: String = ""
    var isIncoming: Bool = false

    static let messageIdForeignKey = ForeignKey(["messageId"])
    static let photosCollection = belongsTo(MessageBaseTable.self, using: PhotosCollectionTable.messageIdForeignKey)
    var photosCollection: QueryInterfaceRequest<MessageBaseTable> {
        return request(for: PhotosCollectionTable.photosCollection)
    }

    func loadValues(result: PhotosCollectionTable) {
        photos = result.photos
        photosId = result.photosId
        photosCreatedBy = result.photosCreatedBy
        photosCreatedOn = result.photosCreatedOn
        messageId = result.messageId
    }

    internal enum Columns: String, ColumnExpression {
        case photosId
        case messageId
        case photos
        case photosCreatedBy
        case photosCreatedOn
        case isIncoming
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.photosId.name, .integer)
        tableDefinition.column(Columns.photos.name, .text)
        tableDefinition.column(Columns.messageId.name, .text).primaryKey()
        tableDefinition.column(Columns.photosCreatedBy.name, .text)
        tableDefinition.column(Columns.photosCreatedOn.name, .text)
        tableDefinition.column(Columns.isIncoming.name, .boolean)
    }
}
