//
//  ACDatabaseMethods.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 03/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACDatabaseMethods {
    static func saveMessageToDb(_ msgObject: ACCommunicationMsgObject, _ channelId: String, _ senderLocalId: String, _ chnlType: channelType, _ isMine: Bool, _ msgState: String) -> String {
        let msgObj = ACCommunicationMsgObject()
        let msgData = MessagesTable()
        msgData.messageType = msgObj.getMsgType(typeValue: msgObject.msgType!)
        msgData.chanelId = channelId
        msgData.senderId = senderLocalId
        msgData.channelType = chnlType.rawValue
        msgData.globalMsgId = msgObject.globalMsgId!
        msgData.action = msgObject.action!
        msgData.topicId = msgObject.globalTopicId!
        msgData.replyToId = msgObj.getLocalReplyMsgId(globalMsgId: msgObject.replyToId!)
        if msgData.messageType == messagetype.TEXT.rawValue {
            msgData.text = msgObject.text!
            msgData.other = msgObject.other as! String

        } else if msgData.messageType == messagetype.IMAGE.rawValue || msgData.messageType == messagetype.VIDEO.rawValue || msgData.messageType == messagetype.AUDIO.rawValue {
            msgData.media = msgObject.media!
            msgData.text = msgObject.text!
            msgData.other = msgObject.other! as! String

        } else {
            if (msgData.messageType == messagetype.OTHER.rawValue && msgObject.otherType == otherMessageType.TEXT_POLL.rawValue) || (msgData.messageType == messagetype.OTHER.rawValue && msgObject.otherType == otherMessageType.IMAGE_POLL.rawValue) {
                msgData.media = msgObject.media!
            }

            msgData.other = msgObject.other! as! String
            msgData.otherType = msgObject.otherType!
            msgData.text = msgObject.text!
        }
        msgData.msgTimeStamp = msgObject.sent_utc!
        msgData.isMine = isMine
        msgData.messageState = msgState
        msgData.isForwarded = msgObject.isForward ?? false
        
        if chnlType != channelType.ONE_ON_ONE_CHAT || chnlType != channelType.GROUP_MEMBER_ONE_ON_ONE {
            if let groupTable = DatabaseManager.getGroupIndex(groupGlobalId: msgObject.receiver!) {
                let groupMembersList = DatabaseManager.getGroupMembers(globalGroupId: groupTable.id)
                msgData.targetCount = String(groupMembersList.count)
            }
        }

        let messageIndex = DatabaseManager.storeIntoMsgTable(messageTable: msgData)

//        let message = DatabaseManager.getMessageIndex(globalMsgId: msgObject.globalMsgId!)

        let channelIndex = ChannelTable()

        //to update channel table
        channelIndex.id = channelId
        channelIndex.unseenCount = "0"
        channelIndex.lastSavedMsgid = String(messageIndex)
        channelIndex.lastSenderPhone = msgObject.senderPhone!
        channelIndex.lastSenderContactId = senderLocalId
        channelIndex.lastMsgTime = msgObject.sent_utc!
        DatabaseManager.updateChannelTable(channelTable: channelIndex)

        return String(messageIndex)
    }

    static func saveMessageToDbWithOldMsg(_ msgObject: ACCommunicationMsgObject, _ msg: MessagesTable, _ channelId: String, _ senderLocalId: String, _ chnlType: channelType, _ isMine: Bool, _ msgState: String) -> String {
        let msgObj = ACCommunicationMsgObject()
        let msgData = MessagesTable()
        msgData.messageType = msgObj.getMsgType(typeValue: msgObject.msgType!)
        msgData.chanelId = channelId
        msgData.senderId = senderLocalId
        msgData.channelType = chnlType.rawValue
        msgData.globalMsgId = msgObject.globalMsgId!
        msgData.action = msgObject.action!
        msgData.topicId = msgObject.globalTopicId!
        msgData.replyToId = msgObj.getLocalReplyMsgId(globalMsgId: msgObject.replyToId!)
        msgData.isForwarded = msgObject.isForward ?? false
        
        msgData.other = msg.other
        msgData.otherType = msg.otherType
        msgData.text = msg.text
        msgData.media = msg.media
        msgData.attachmentsExtra = msg.attachmentsExtra

        msgData.msgTimeStamp = msgObject.sent_utc!
        msgData.isMine = isMine
        msgData.messageState = msgState
        msgData.isForwarded = msgObject.isForward ?? false
        
        if chnlType != channelType.ONE_ON_ONE_CHAT || chnlType != channelType.GROUP_MEMBER_ONE_ON_ONE {
            if let groupTable = DatabaseManager.getGroupIndex(groupGlobalId: msgObject.receiver!) {
                let groupMembersList = DatabaseManager.getGroupMembers(globalGroupId: groupTable.id)
                msgData.targetCount = String(groupMembersList.count)
            }
        }

        let messageIndex = DatabaseManager.storeIntoMsgTable(messageTable: msgData)

        //        let message = DatabaseManager.getMessageIndex(globalMsgId: msgObject.globalMsgId!)

        let channelIndex = ChannelTable()

        //to update channel table
        channelIndex.id = channelId
        channelIndex.unseenCount = "0"
        channelIndex.lastSavedMsgid = String(messageIndex)
        channelIndex.lastSenderPhone = msgObject.senderPhone!
        channelIndex.lastSenderContactId = senderLocalId
        channelIndex.lastMsgTime = msgObject.sent_utc!
        DatabaseManager.updateChannelTable(channelTable: channelIndex)

        return String(messageIndex)
    }

    static func saveIncomingMessageToDb(_ msgObject: ACCommunicationMsgObject, _ channelId: String, _ senderLocalId: String, _ channelType: channelType, _ isMine: Bool, _ msgState: String) -> String {
        let commObj = ACCommunicationMsgObject()
        let msgData = MessagesTable()
        msgData.messageType = commObj.getMsgType(typeValue: msgObject.msgType!)
        msgData.chanelId = channelId
        msgData.senderId = senderLocalId
        msgData.channelType = channelType.rawValue
        msgData.globalMsgId = msgObject.globalMsgId!
        msgData.action = msgObject.action!
        msgData.replyToId = commObj.getLocalReplyMsgId(globalMsgId: msgObject.replyToId!)
        if msgData.messageType == messagetype.TEXT.rawValue {
            msgData.text = msgObject.text!
            msgData.other = msgObject.other! as! String

        } else if msgData.messageType == messagetype.IMAGE.rawValue || msgData.messageType == messagetype.VIDEO.rawValue || msgData.messageType == messagetype.AUDIO.rawValue {
            msgData.attachmentsExtra = msgObject.media!
            msgData.text = msgObject.text!

        } else {
            msgData.attachmentsExtra = msgObject.other! as! String
            msgData.otherType = msgObject.otherType!
            msgData.text = msgObject.text!
        }
        if channelType == .PUBLIC_GROUP || channelType == .PRIVATE_GROUP {
            msgData.topicId = msgObject.globalMsgId!
        } else {
            msgData.topicId = msgObject.globalTopicId!
        }
        msgData.msgTimeStamp = msgObject.sent_utc!
        msgData.isMine = isMine
        msgData.messageState = msgState
        msgData.isForwarded = msgObject.isForward ?? false
        let messageIndex = DatabaseManager.storeIntoMsgTable(messageTable: msgData)

        return String(messageIndex)
    }

//    func saveMessageToDb(_ msgType: messagetype,_ globalMsgId: String,_ replyToId: String,_ messageText: String,_ messageTime: String, _ action: useractionType, _ channelId: String, _ senderLocalId: String, _ channelType: channelType, _ isMine: Bool, _ msgState: String) {
//        let msgData = MessagesTable()
//        msgData.messageType = msgType.rawValue
//        msgData.chanelId = channelId
//        msgData.senderId = senderLocalId
//        msgData.channelType = channelType.rawValue
//        msgData.globalMsgId = globalMsgId
//        msgData.action = action.rawValue
//        msgData.replyToId = getLocalReplyMsgId(globalMsgId: replyToId)
//        msgData.text = messageText
//        msgData.msgTimeStamp = messageTime
//        msgData.isMine = isMine
//        msgData.messageState = msgState
//        DatabaseManager.storeIntoMsgTable(messageTable: msgData)
//    }

    static func createChannelTable(conatctId: String, channelType: String, globalChannelName: String) -> ChannelTable {
        let channel = ChannelTable()
        channel.contactId = conatctId
        channel.channelType = channelType
        channel.globalChannelName = globalChannelName
        return channel
    }
}
