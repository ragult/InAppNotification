//
//  ACDirectMsgObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 31/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import UIKit

class ACCommunicationMsgObject: EVNetworkingObject {
    var action: String?
    var channelType: String?
    var contSource: String?
    var globalMsgId: String?
    var globalTopicId: String?
    var text: String?
    var media: String?
    var other: Any?
    var otherType: String?
    var msgType: String?
    var receiver: String?
    var senderUUID: String?
    var senderPhone: String?
    var sent_utc: String?
    var replyToId: String?
    var refGroupId: String?
    var isForward: Bool = false

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("action", "action"), ("channelType", "channeltype"), ("contSource", "cont_src"), ("globalMsgId", "gl_mesg_id"), ("globalTopicId", "gl_topic_id"), ("text", "txt"), ("msgType", "mesgtype"), ("receiver", "receiver"), ("senderUUID", "senderUUID"), ("senderPhone", "senderPhone"), ("sent_utc", "sent_utc"), ("replyToId", "reply_to"), ("refGroupId", "refGroupId"), ("isForward", "isForward")]
    }

    func mapDataValues(dataDict: NSDictionary) -> ACCommunicationMsgObject {
        let directMsgObj = ACCommunicationMsgObject()

        directMsgObj.action = dataDict.value(forKey: "action") as? String ?? ""
        directMsgObj.channelType = dataDict.value(forKey: "channeltype") as? String ?? ""
        directMsgObj.contSource = dataDict.value(forKey: "cont_src") as? String ?? ""
        directMsgObj.globalMsgId = dataDict.value(forKey: "gl_mesg_id") as? String ?? ""
        directMsgObj.globalTopicId = dataDict.value(forKey: "gl_topic_id") as? String ?? ""
        directMsgObj.text = dataDict.value(forKey: "txt") as? String ?? ""
        directMsgObj.media = dataDict.value(forKey: "media") as? String ?? ""
        directMsgObj.other = dataDict.value(forKey: "other") as? String ?? ""
        directMsgObj.otherType = dataDict.value(forKey: "otherType") as? String ?? ""
        directMsgObj.msgType = dataDict.value(forKey: "mesgtype") as? String ?? ""
        directMsgObj.receiver = dataDict.value(forKey: "receiver") as? String ?? ""
        directMsgObj.senderUUID = dataDict.value(forKey: "senderUUID") as? String ?? ""
        directMsgObj.senderPhone = dataDict.value(forKey: "senderPhone") as? String ?? ""
        directMsgObj.sent_utc = dataDict.value(forKey: "sent_utc") as? String ?? ""
        directMsgObj.replyToId = dataDict.value(forKey: "reply_to") as? String ?? ""
        directMsgObj.refGroupId = dataDict.value(forKey: "refGroupId") as? String ?? ""
        directMsgObj.isForward = dataDict.value(forKey: "isForward") as? Bool ?? false

        return directMsgObj
    }

    func getLocalReplyMsgId(globalMsgId: String) -> String {
        return globalMsgId
    }

    func getMsgType(typeValue: String) -> String {
        switch typeValue {
        case messagetype.TEXT.rawValue:
            return messagetype.TEXT.rawValue
        case messagetype.IMAGE.rawValue:
            return messagetype.IMAGE.rawValue
        case messagetype.VIDEO.rawValue:
            return messagetype.VIDEO.rawValue
        case messagetype.AUDIO.rawValue:
            return messagetype.AUDIO.rawValue
        case messagetype.OTHER.rawValue:
            return messagetype.OTHER.rawValue

        default:
            print("nothing to be done")
            return "0"
        }
    }

    func getUnseenCount(unseenCount: String) -> String {
        var count = Double(unseenCount)
        if count == nil {
            count = 0
        }
        count = count! + 1
        let str = String(format: "%.0f", count!)
        return str
    }
}
