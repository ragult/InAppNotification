//
//  VideoTable.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 07/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class VideoTable: EVNetworkingObject, Codable, PersistableRecord, TableRecord, FetchableRecord {
    var messageId: String?
    var videoId: Int?
    var videoTitle: String = ""
    var videoUrl: String = ""
    var createdBy: String = ""
    var createdOn: String = ""
    var videoThumbnail: String = ""

    static let messageIdForeignKey = ForeignKey(["messageId"])
    static let video = belongsTo(MessageBaseTable.self, using: VideoTable.messageIdForeignKey)
    var video: QueryInterfaceRequest<MessageBaseTable> {
        return request(for: VideoTable.video)
    }

    func loadValues(result: VideoTable) {
        messageId = result.messageId
        videoId = result.videoId
        videoTitle = result.videoTitle
        videoUrl = result.videoUrl
        createdBy = result.createdBy
        createdOn = result.createdOn
        videoThumbnail = result.videoThumbnail
    }

    internal enum Columns: String, ColumnExpression {
        case messageId
        case videoId
        case videoTitle
        case videoUrl
        case createdBy
        case createdOn
        case videoThumbnail
    }

    internal static func defineTabledefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.messageId.name, .text).primaryKey()
        tableDefinition.column(Columns.videoTitle.name, .text)
        tableDefinition.column(Columns.videoUrl.name, .text)
        tableDefinition.column(Columns.videoThumbnail.name, .text)
        tableDefinition.column(Columns.videoId.name, .integer)
        tableDefinition.column(Columns.createdBy.name, .text)
        tableDefinition.column(Columns.createdOn.name, .text)
    }
}
