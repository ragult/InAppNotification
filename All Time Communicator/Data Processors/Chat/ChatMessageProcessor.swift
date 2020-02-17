//
//  ChatMessageProcessor.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 12/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Foundation

class ChatMessageProcessor {
    static func processMessage(messageObjectArray: [MessagesTable]) -> NSMutableDictionary {
        let chatobjectsDictionary = NSMutableDictionary()
        for message in messageObjectArray {
            let msgContext = ACMessageContextObject()
            msgContext.messageType = messagetype(rawValue: message.messageType)
            msgContext.contentSource = source(rawValue: message.mesgSource)
            msgContext.localChanelId = message.chanelId
            msgContext.localSenderId = message.senderId
            msgContext.localMessageId = message.id

            msgContext.channelType = channelType(rawValue: message.channelType)
            msgContext.globalMsgId = message.globalMsgId
            msgContext.action = useractionType(rawValue: message.action)
            msgContext.replyToId = message.replyToId
            msgContext.isMine = message.isMine
            msgContext.msgTimeStamp = message.msgTimeStamp
            msgContext.messageState = messageState(rawValue: message.messageState)
            msgContext.targetCount = message.targetCount
            msgContext.seenMembers = message.seenMembers
            msgContext.readMembers = message.readMembers
            msgContext.isForward = message.isForwarded

            let msgItem = MessageItem()
            msgItem.messageType = messagetype(rawValue: message.messageType)
            if msgItem.messageType == messagetype.TEXT {
                msgItem.messageTextString = message.text
                msgItem.message = message.other

            } else if msgItem.messageType == messagetype.IMAGE || msgItem.messageType == messagetype.VIDEO || msgItem.messageType == messagetype.AUDIO {
                msgItem.message = message.media
                msgItem.cloudReference = message.attachmentsExtra
                msgItem.messageTextString = message.text
                msgItem.thumbnail = message.other

            } else {
                if (msgItem.messageType == messagetype.OTHER && otherMessageType(rawValue: message.otherType) == otherMessageType.TEXT_POLL) || (msgItem.messageType == messagetype.OTHER && otherMessageType(rawValue: message.otherType) == otherMessageType.IMAGE_POLL) {
                    msgItem.message = message.other
                    msgItem.otherMessageType = otherMessageType(rawValue: message.otherType)
                    msgItem.cloudReference = message.attachmentsExtra
                    msgItem.messageTextString = message.text
                    msgItem.localMediaPaths = message.media

                } else {
                    msgItem.message = message.other
                    msgItem.otherMessageType = otherMessageType(rawValue: message.otherType)
                    msgItem.cloudReference = message.attachmentsExtra
                    msgItem.messageTextString = message.text
                }
            }

            let chatListItem = chatListObject()
            chatListItem.messageContext = msgContext
            chatListItem.messageItem = msgItem

            // to set based on timestamp
            let time = Double(message.msgTimeStamp)! / 10_000_000
            let finalDate = time.getDateFromUTC()

            let allDates = chatobjectsDictionary.allKeys as NSArray

            if allDates.contains(finalDate) {
                let dateChatMsgs = chatobjectsDictionary.value(forKey: finalDate) as! NSMutableArray
                dateChatMsgs.add(chatListItem)

                chatobjectsDictionary.removeObject(forKey: finalDate)
                chatobjectsDictionary.setValue(dateChatMsgs, forKey: finalDate)

            } else {
                let dateChatMsgs = NSMutableArray()
                dateChatMsgs.add(chatListItem)
                chatobjectsDictionary.setValue(dateChatMsgs, forKey: finalDate)
            }
        }
        return chatobjectsDictionary
    }

    static func processSingleMessage(message: MessagesTable, chatobjectsDictionary: NSMutableDictionary) -> NSMutableDictionary {
        let msgContext = ACMessageContextObject()
        msgContext.messageType = messagetype(rawValue: message.messageType)
        msgContext.contentSource = source(rawValue: message.mesgSource)
        msgContext.localChanelId = message.chanelId
        msgContext.localSenderId = message.senderId
        msgContext.localMessageId = message.id

        msgContext.channelType = channelType(rawValue: message.channelType)
        msgContext.globalMsgId = message.globalMsgId
        msgContext.action = useractionType(rawValue: message.action)
        msgContext.replyToId = message.replyToId
        msgContext.isMine = message.isMine
        msgContext.msgTimeStamp = message.msgTimeStamp
        msgContext.messageState = messageState(rawValue: message.messageState)
        msgContext.targetCount = message.targetCount
        msgContext.seenMembers = message.seenMembers
        msgContext.readMembers = message.readMembers
        msgContext.isForward = message.isForwarded

        let msgItem = MessageItem()
        msgItem.messageType = messagetype(rawValue: message.messageType)
        if msgItem.messageType == messagetype.TEXT {
            msgItem.messageTextString = message.text
            msgItem.message = message.other

        } else if msgItem.messageType == messagetype.IMAGE || msgItem.messageType == messagetype.VIDEO || msgItem.messageType == messagetype.AUDIO {
            msgItem.message = message.media
            msgItem.cloudReference = message.attachmentsExtra
            msgItem.messageTextString = message.text
            msgItem.thumbnail = message.other

        } else {
            if (msgItem.messageType == messagetype.OTHER && otherMessageType(rawValue: message.otherType) == otherMessageType.TEXT_POLL) || (msgItem.messageType == messagetype.OTHER && otherMessageType(rawValue: message.otherType) == otherMessageType.IMAGE_POLL) {
                msgItem.message = message.other
                msgItem.otherMessageType = otherMessageType(rawValue: message.otherType)
                msgItem.cloudReference = message.attachmentsExtra
                msgItem.messageTextString = message.text
                msgItem.localMediaPaths = message.media

            } else {
                msgItem.message = message.other
                msgItem.otherMessageType = otherMessageType(rawValue: message.otherType)
                msgItem.cloudReference = message.attachmentsExtra
                msgItem.messageTextString = message.text
            }
        }

        let chatListItem = chatListObject()
        chatListItem.messageContext = msgContext
        chatListItem.messageItem = msgItem

        // to set based on timestamp
        let time = Double(message.msgTimeStamp)! / 10_000_000
        let finalDate = time.getDateFromUTC()

        let allDates = chatobjectsDictionary.allKeys as NSArray

        if allDates.contains(finalDate) {
            let dateChatMsgs = chatobjectsDictionary.value(forKey: finalDate) as! NSMutableArray
            dateChatMsgs.insert(chatListItem, at: 0)

            chatobjectsDictionary.removeObject(forKey: finalDate)
            chatobjectsDictionary.setValue(dateChatMsgs, forKey: finalDate)

        } else {
            let dateChatMsgs = NSMutableArray()
            dateChatMsgs.insert(chatListItem, at: 0)
            chatobjectsDictionary.setValue(dateChatMsgs, forKey: finalDate)
        }

        return chatobjectsDictionary
    }

    static func processSingleMessageContext(message: MessagesTable) -> chatListObject {
        let msgContext = ACMessageContextObject()
        msgContext.messageType = messagetype(rawValue: message.messageType)
        msgContext.contentSource = source(rawValue: message.mesgSource)
        msgContext.localChanelId = message.chanelId
        msgContext.localSenderId = message.senderId
        msgContext.localMessageId = message.id
        msgContext.channelType = channelType(rawValue: message.channelType)
        msgContext.globalMsgId = message.globalMsgId
        msgContext.action = useractionType(rawValue: message.action)
        msgContext.replyToId = message.replyToId
        msgContext.isMine = message.isMine
        msgContext.msgTimeStamp = message.msgTimeStamp
        msgContext.messageState = messageState(rawValue: message.messageState)
        msgContext.targetCount = message.targetCount
        msgContext.seenMembers = message.seenMembers
        msgContext.readMembers = message.readMembers
        msgContext.isForward = message.isForwarded
        
        let msgItem = MessageItem()
        msgItem.messageType = messagetype(rawValue: message.messageType)
        if msgItem.messageType == messagetype.TEXT {
            msgItem.messageTextString = message.text
            msgItem.message = message.other

        } else if msgItem.messageType == messagetype.IMAGE || msgItem.messageType == messagetype.VIDEO || msgItem.messageType == messagetype.AUDIO {
            msgItem.message = message.media
            msgItem.cloudReference = message.attachmentsExtra
            msgItem.messageTextString = message.text
            msgItem.thumbnail = message.other

        } else {
            msgItem.message = message.other
            msgItem.otherMessageType = otherMessageType(rawValue: message.otherType)
            msgItem.cloudReference = message.attachmentsExtra
            msgItem.messageTextString = message.text
        }

        let chatListItem = chatListObject()
        chatListItem.messageContext = msgContext
        chatListItem.messageItem = msgItem

        return chatListItem
    }

    static func createMessageContextObject(groupType: String, text: String, channel: String, chanlType: channelType, localSenderId: String, localChannelId: String, globalChatId: String, replyId: String, title: String = "") -> chatListObject {
        let ChatList = chatListObject()
        let message = ACMessageContextObject()
        let messageItem = MessageItem()
        let timestamp = NSDate().timeIntervalSince1970 * 1000 * 10000
        let finalTS = String(format: "%.0f", timestamp)

        message.senderGlobalId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
        message.senderPhoneNo = UserDefaults.standard.value(forKey: UserKeys.userPhoneNumber) as? String
        message.channelType = chanlType
        message.localChanelId = localChannelId
        message.messageType = messagetype.TEXT
        message.messageState = messageState.SENDER_UNSENT
        message.isMine = true
        if replyId == "" {
            message.action = useractionType.NEW
        } else {
            message.action = useractionType.REPLY
        }
        message.groupType = groupType
        message.replyToId = replyId
        message.msgTimeStamp = finalTS
        message.globalMsgId = message.senderGlobalId! + message.msgTimeStamp
        message.localSenderId = localSenderId
        message.globalChannelName = channel
        message.receiverGlobalId = globalChatId
        ChatList.messageContext = message
        messageItem.messageType = messagetype.TEXT
        messageItem.messageTextString = text
        messageItem.message = title

        ChatList.messageItem = messageItem

        return ChatList
    }

    static func createImageContextObject(text: String, channel: String, chanlType: channelType, localSenderId: String, localChannelId: String, globalChatId: String, mediaType: messagetype, mediaObject: Any, thumbnail: String) -> chatListObject {
        let ChatList = chatListObject()
        let message = ACMessageContextObject()
        let messageItem = MessageItem()
        let timestamp = NSDate().timeIntervalSince1970 * 1000 * 10000
        let finalTS = String(format: "%.0f", timestamp)

        message.senderGlobalId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
        message.senderPhoneNo = UserDefaults.standard.value(forKey: UserKeys.userPhoneNumber) as? String
        message.channelType = chanlType
        message.localChanelId = localChannelId
        message.messageType = mediaType
        message.messageState = messageState.SENDER_UNSENT
        message.isMine = true
        message.action = useractionType.NEW
        message.replyToId = ""
        message.msgTimeStamp = finalTS
        message.globalMsgId = message.senderGlobalId! + message.msgTimeStamp
        message.localSenderId = localSenderId
        message.globalChannelName = channel
        message.receiverGlobalId = globalChatId
        ChatList.messageContext = message
        messageItem.messageType = mediaType
        messageItem.messageTextString = text
        messageItem.thumbnail = thumbnail
        messageItem.message = mediaObject

        ChatList.messageItem = messageItem

        return ChatList
    }

    static func createOtherContextObject(text: String, channel: String, chanlType: channelType, localSenderId: String, localChannelId: String, globalChatId: String, mediaType: messagetype, otherType: otherMessageType, mediaObject: Any) -> chatListObject {
        let ChatList = chatListObject()
        let message = ACMessageContextObject()
        let messageItem = MessageItem()

        let timestamp = NSDate().timeIntervalSince1970 * 1000 * 10000
        let finalTS = String(format: "%.0f", timestamp)

        message.senderGlobalId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
        message.senderPhoneNo = UserDefaults.standard.value(forKey: UserKeys.userPhoneNumber) as? String
        message.channelType = chanlType
        message.localChanelId = localChannelId
        message.messageType = mediaType
        message.messageState = messageState.SENDER_UNSENT
        message.isMine = true
        message.action = useractionType.NEW
        message.replyToId = ""
        message.msgTimeStamp = finalTS
        message.globalMsgId = message.senderGlobalId! + message.msgTimeStamp
        message.localSenderId = localSenderId
        message.globalChannelName = channel
        message.receiverGlobalId = globalChatId
        ChatList.messageContext = message
        messageItem.messageType = mediaType
        messageItem.messageTextString = text
        messageItem.message = mediaObject
        messageItem.otherMessageType = otherType

        ChatList.messageItem = messageItem

        return ChatList
    }

    static func createPollContextObject(text: String, channel: String, chanlType: channelType, localSenderId: String, localChannelId: String, globalChatId: String, mediaType: messagetype, otherType: otherMessageType, mediaObject: Any, localMediaData: String, cloudData: String) -> chatListObject {
        let ChatList = chatListObject()
        let message = ACMessageContextObject()
        let messageItem = MessageItem()

        let timestamp = NSDate().timeIntervalSince1970 * 1000 * 10000
        let finalTS = String(format: "%.0f", timestamp)

        message.senderGlobalId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
        message.senderPhoneNo = UserDefaults.standard.value(forKey: UserKeys.userPhoneNumber) as? String
        message.channelType = chanlType
        message.localChanelId = localChannelId
        message.messageType = mediaType
        message.messageState = messageState.SENDER_UNSENT
        message.isMine = true
        message.action = useractionType.NEW
        message.replyToId = ""
        message.msgTimeStamp = finalTS
        message.globalMsgId = message.senderGlobalId! + message.msgTimeStamp
        message.localSenderId = localSenderId
        message.globalChannelName = channel
        message.receiverGlobalId = globalChatId
        ChatList.messageContext = message

        messageItem.messageType = mediaType
        messageItem.messageTextString = text
        let ptable = mediaObject as! PollTable
        messageItem.message = ptable.toJsonString()
        messageItem.otherMessageType = otherType
        messageItem.localMediaPaths = localMediaData
        messageItem.cloudReference = cloudData

        ChatList.messageItem = messageItem

        return ChatList
    }
}

extension NSArray {
    // sorting- ascending
    func ascendingArrayWithKeyValue(key: String) -> NSArray {
        let ns = NSSortDescriptor(key: key, ascending: true)
        let aa = NSArray(object: ns)
        let arrResult = sortedArray(using: aa as! [NSSortDescriptor])
        return arrResult as NSArray
    }

    func ascendingArrayWithData() -> NSMutableArray {
        var convertedArray: [Date] = []
        let finalArray = NSMutableArray()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd, MMM yyyy" // yyyy-MM-dd"

        for dat in self {
            let date = dateFormatter.date(from: dat as! String)
            if let date = date {
                convertedArray.append(date)
            }
        }

        let filArray = convertedArray.sorted(by: { ($0 as AnyObject).compare($1) == .orderedAscending })

        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd, MMMM yyyy" // yyyy-MM-dd"

        for date in filArray {
            let sdate = dateFormatter.string(from: date)
            finalArray.add(sdate)
        }
        return finalArray
    }

    func descendingArrayWithData() -> NSMutableArray {
        var convertedArray: [Date] = []
        let finalArray = NSMutableArray()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd, MMM yyyy" // yyyy-MM-dd"

        for dat in self {
            let date = dateFormatter.date(from: dat as! String)
            if let date = date {
                convertedArray.append(date)
            }
        }

        let filArray = convertedArray.sorted(by: { ($0 as AnyObject).compare($1) == .orderedDescending })

        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd, MMMM yyyy" // yyyy-MM-dd"

        for date in filArray {
            let sdate = dateFormatter.string(from: date)
            finalArray.add(sdate)
        }
        return finalArray
    }

    // sorting - descending
    func discendingArrayWithKeyValue(key: String) -> NSArray {
        let ns = NSSortDescriptor(key: key, ascending: false)
        let aa = NSArray(object: ns)
        let arrResult = sortedArray(using: aa as! [NSSortDescriptor])
        return arrResult as NSArray
    }
}
