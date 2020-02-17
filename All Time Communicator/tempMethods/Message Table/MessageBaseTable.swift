//
//  TypesOfMessages.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 04/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB
class MessageBaseTable: EVNetworkingObject, Codable, PersistableRecord, TableRecord, FetchableRecord {
    var channel: String = ""
    var src = ""
    var comm = Comm()
    var typeOfMessage: String = ""
    var groupId: String = "1"
    var messageId: String?
    var replyToMessage: String = ""
    var isIncoming: Bool = false
    var fromName: String?

    // To fetch messages by group id
    static let groupIdForeignKey = ForeignKey(["groupId"])
    //  GET TYPE OF MESSAGE
//    static let getPollMessage = hasOne(PollTable.self, using: (PollTable.messageIdForeignKey))
    static let getDocumentMessage = hasOne(DocumentTable.self, using: DocumentTable.messageIdForeignKey)
    static let getEventsMessage = hasOne(EventsTable.self, using: EventsTable.messageIdForeignKey)
    static let getPhotosColletionMessage = hasOne(PhotosCollectionTable.self, using: PhotosCollectionTable.messageIdForeignKey)
    static let getRequestMessage = hasOne(RequestTable.self, using: RequestTable.messageIdForeignKey)
    static let getVideoMessage = hasOne(VideoTable.self, using: VideoTable.messageIdForeignKey)
    static let getReplyToMessage = hasOne(ReplyToMessageTable.self, using: ReplyToMessageTable.messageIdForeignKey)
    static let getTextMessage = hasOne(TextMessageTable.self, using: TextMessageTable.messageIdForeignKey)

//    var getPollMessage: QueryInterfaceRequest<PollTable> {
//        return request(for: MessageBaseTable.getPollMessage)
//    }
    var getDocumentMessage: QueryInterfaceRequest<DocumentTable> {
        return request(for: MessageBaseTable.getDocumentMessage)
    }

    var getEventsMessage: QueryInterfaceRequest<EventsTable> {
        return request(for: MessageBaseTable.getEventsMessage)
    }

    var getPhotosColletionMessage: QueryInterfaceRequest<PhotosCollectionTable> {
        return request(for: MessageBaseTable.getPhotosColletionMessage)
    }

    var getRequestMessage: QueryInterfaceRequest<RequestTable> {
        return request(for: MessageBaseTable.getRequestMessage)
    }

    var getVideoMessage: QueryInterfaceRequest<VideoTable> {
        return request(for: MessageBaseTable.getVideoMessage)
    }

    var getReplyToMessage: QueryInterfaceRequest<ReplyToMessageTable> {
        return request(for: MessageBaseTable.getReplyToMessage)
    }

    var getTextMessage: QueryInterfaceRequest<TextMessageTable> {
        return request(for: MessageBaseTable.getTextMessage)
    }

    internal enum BaseColumns: String, ColumnExpression {
        case messageId
        case isIncoming
        case typeOfMessage
        case groupId
        case messageComment
        case channel
        case src
        case comm
        case fromName
        case replyToMessage
    }

    internal static func baseDefineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(BaseColumns.messageId.name, .text).primaryKey()
        tableDefinition.column(BaseColumns.isIncoming.name, .boolean)
        tableDefinition.column(BaseColumns.typeOfMessage.name, .text)
        tableDefinition.column(BaseColumns.groupId.name, .text)
        tableDefinition.column(BaseColumns.messageComment.name, .text)
        tableDefinition.column(BaseColumns.src.name, .text)
        tableDefinition.column(BaseColumns.channel.name, .text)
        tableDefinition.column(BaseColumns.comm.name, .text)
        tableDefinition.column(BaseColumns.fromName.name, .text)
        tableDefinition.column(BaseColumns.replyToMessage.name, .text)
    }

    // Comm
    class Comm: EVNetworkingObject, Codable {
        var action: String = ""
        var channelType: String = ""
        var cont_src = ""
        // var globalMessageId:String = ""
        var globalTopicId: String = ""
        var reply_to: String = ""
        var text: String = ""
        var receiver: String = ""
        var senderUUID: String = ""
        var senderPhone: String = ""
        var sent_UTC: String = ""
    }

    // GET  MESSAGE DATA BY MESSAGE TYPE VARIABLE

//    func getMessageData<TYPE: TableRecord>(type: TYPE.Type) -> TYPE? {
//        switch typeOfMessage {
//
//        case TYPE_OF_MESSAGE.TEXT_MESSAGE:
//            return DatabaseManager.dBRead({ (db) -> TextMessageTable in return try getTextMessage.fetchOne(db) ?? TextMessageTable()}) as? TYPE
//        case TYPE_OF_MESSAGE.POLL_MESSAGE:
//            return DatabaseManager.dBRead({ (db) -> PollTable in return try getPollMessage.fetchOne(db) ?? PollTable()}) as? TYPE
//        case TYPE_OF_MESSAGE.POLL_MESSAGE_WITH_IMAGES:
//            return DatabaseManager.dBRead({ (db) -> PollTable in return try getPollMessage.fetchOne(db) ?? PollTable()}) as? TYPE
//        case TYPE_OF_MESSAGE.VIDEO_MESSAGE:
//            return DatabaseManager.dBRead({ (db) -> VideoTable in return try getVideoMessage.fetchOne(db) ?? VideoTable()}) as? TYPE
//        case TYPE_OF_MESSAGE.PHOTO_MESSAGE:
//            return DatabaseManager.dBRead({ (db) -> PhotosCollectionTable in return try getPhotosColletionMessage.fetchOne(db) ?? PhotosCollectionTable()}) as? TYPE
//        case TYPE_OF_MESSAGE.PHOTO_COLLECTION_MESSAGE:
//            return DatabaseManager.dBRead({ (db) -> PhotosCollectionTable in return try getPhotosColletionMessage.fetchOne(db) ?? PhotosCollectionTable()}) as? TYPE
//        case TYPE_OF_MESSAGE.EVENT_MESSAGE:
//            return DatabaseManager.dBRead({ (db) -> EventsTable in return try getEventsMessage.fetchOne(db) ?? EventsTable()}) as? TYPE
//        case TYPE_OF_MESSAGE.REQUEST_MESSAGE:
//            return DatabaseManager.dBRead({ (db) -> RequestTable in return try getRequestMessage.fetchOne(db) ?? RequestTable()}) as? TYPE
//        case TYPE_OF_MESSAGE.DOCUMENT_MESSAGE:
//            return DatabaseManager.dBRead({ (db) -> DocumentTable in return try getDocumentMessage.fetchOne(db) ?? DocumentTable()}) as? TYPE
//        case TYPE_OF_MESSAGE.REPLY_TO_MESSAGE:
//            return DatabaseManager.dBRead({ (db) -> ReplyToMessageTable in return try getReplyToMessage.fetchOne(db) ?? ReplyToMessageTable()}) as? TYPE
//        default:
//            return nil
//        }
//    }
}
