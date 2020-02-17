
//
//  ACReadReceiptsClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 04/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACReadReceiptsProcessorClass: NSObject {
    func processDataForDeliveredMessage(dataDictionary: NSDictionary, actionType: String) {
        let msgObject = mapDataValues(objectDict: dataDictionary)

//        switch msgObject.chnl_typ {

        if channelType.GROUP_CHAT.rawValue == msgObject.chnl_typ || channelType.ADHOC_CHAT.rawValue == msgObject.chnl_typ || channelType.TOPIC_GROUP.rawValue == msgObject.chnl_typ {
            if msgObject.id_first == "" {
                msgObject.id_first = msgObject.id_last
            }

            if let lastmessage = DatabaseManager.getMessageIndex(globalMsgId: msgObject.id_last!) {
                if let firstMessage = DatabaseManager.getMessageIndex(globalMsgId: msgObject.id_first!) {
                    if let groupIndex = DatabaseManager.getGroupIndex(groupGlobalId: msgObject.receiver!) {
                        if let GroupMemebrIndex = DatabaseManager.getGroupMemberIndex(groupId: groupIndex.id, globalUserId: msgObject.senderUUID!) {
                            switch actionType {
                            case readReceipts.messageDelivered.rawValue:

                                DatabaseManager.updateMessageTableForRangeOfGroup(ColoumnName: "readMembers", countColoumnName: "readCount", seenMembers: GroupMemebrIndex.groupMemberId, firstMsgId: firstMessage.id, lastMsgId: lastmessage.id, channelId: lastmessage.chanelId)

                                let time = Double(lastmessage.msgTimeStamp)! / 10_000_000
                                let finalDate = time.getDateFromUTC()

                                //to communicate with eventbus
                                let eventBusObj = ACReadReceiptEventBusObject(firstMsgId: firstMessage.id, lastMsgId: lastmessage.globalMsgId, channelName: msgObject.chnl_name ?? "", messageState: messageState.RECEIVER_RECEIVED, isMine: true, date: finalDate)

                                ACEventBusManager.postToEventBusWithReadReceiptObject(eventBusObject: eventBusObj, notificationName: "readReceiptsMessage")

                            case readReceipts.messageSeen.rawValue:
                                DatabaseManager.updateMessageTableForRangeOfGroup(ColoumnName: "seenMembers", countColoumnName: "seenCount", seenMembers: GroupMemebrIndex.groupMemberId, firstMsgId: firstMessage.id, lastMsgId: lastmessage.id, channelId: lastmessage.chanelId)

                                let time = Double(lastmessage.msgTimeStamp)! / 10_000_000
                                let finalDate = time.getDateFromUTC()
                                //to communicate with eventbus
                                let eventBusObj = ACReadReceiptEventBusObject(firstMsgId: firstMessage.globalMsgId, lastMsgId: lastmessage.globalMsgId, channelName: msgObject.chnl_name ?? "", messageState: messageState.RECEIVER_SEEN, isMine: true, date: finalDate)

                                ACEventBusManager.postToEventBusWithReadReceiptObject(eventBusObject: eventBusObj, notificationName: "readReceiptsMessage")

                            default:
                                print("nothing to be done")
                            }
                        }
                    }
                }
            }
        } else if channelType.ONE_ON_ONE_CHAT.rawValue == msgObject.chnl_typ {
            if msgObject.id_first == "" {
                msgObject.id_first = msgObject.id_last
            }

            if let lastmessage = DatabaseManager.getMessageIndex(globalMsgId: msgObject.id_last!) {
                if let firstMessage = DatabaseManager.getMessageIndex(globalMsgId: msgObject.id_first!) {
                    switch actionType {
                    case readReceipts.messageDelivered.rawValue:

                        DatabaseManager.updateMessageTableForMultipleDirectChatReadReceipt(messagState: messageState.RECEIVER_RECEIVED.rawValue, firstMsgId: firstMessage.id, lastMsgId: lastmessage.id, channelId: lastmessage.chanelId)
                        let time = Double(lastmessage.msgTimeStamp)! / 10_000_000
                        let finalDate = time.getDateFromUTC()
                        //to communicate with eventbus
                        let eventBusObj = ACReadReceiptEventBusObject(firstMsgId: firstMessage.globalMsgId, lastMsgId: lastmessage.globalMsgId, channelName: msgObject.chnl_name ?? "", messageState: messageState.RECEIVER_RECEIVED, isMine: true, date: finalDate)

                        ACEventBusManager.postToEventBusWithReadReceiptObject(eventBusObject: eventBusObj, notificationName: "readReceiptsMessage")

                    case readReceipts.messageSeen.rawValue:
                        DatabaseManager.updateMessageTableForMultipleDirectChatReadReceipt(messagState: messageState.RECEIVER_SEEN.rawValue, firstMsgId: firstMessage.id, lastMsgId: lastmessage.id, channelId: lastmessage.chanelId)
                        let time = Double(lastmessage.msgTimeStamp)! / 10_000_000
                        let finalDate = time.getDateFromUTC()
                        //to communicate with eventbus
                        let eventBusObj = ACReadReceiptEventBusObject(firstMsgId: firstMessage.globalMsgId, lastMsgId: lastmessage.globalMsgId, channelName: msgObject.chnl_name ?? "", messageState: messageState.RECEIVER_SEEN, isMine: true, date: finalDate)

                        ACEventBusManager.postToEventBusWithReadReceiptObject(eventBusObject: eventBusObj, notificationName: "readReceiptsMessage")

                    default:
                        print("nothing to be done")
                    }
                }
            }
        }
    }

    func mapDataValues(objectDict: NSDictionary) -> ACreadReceiptObjectClass {
        let msgObject = ACreadReceiptObjectClass()
        let dataDict = objectDict.value(forKey: "data") as! NSDictionary
        msgObject.chnl_name = dataDict.value(forKey: "chnl_name") as? String ?? ""
        msgObject.chnl_typ = dataDict.value(forKey: "chnl_typ") as? String ?? ""
        msgObject.id_first = dataDict.value(forKey: "id_first") as? String ?? ""
        msgObject.id_last = dataDict.value(forKey: "id_last") as? String ?? ""
        msgObject.mesg_state = dataDict.value(forKey: "mesg_state") as? String ?? ""
        msgObject.receiver = dataDict.value(forKey: "receiver") as? String ?? ""
        msgObject.senderPhone = dataDict.value(forKey: "senderPhone") as? String ?? ""
        msgObject.senderUUID = dataDict.value(forKey: "senderUUID") as? String ?? ""

        return msgObject
    }
}
