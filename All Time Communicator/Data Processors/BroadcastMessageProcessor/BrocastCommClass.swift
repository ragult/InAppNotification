//
//  BrocastCommClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 25/05/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class BrocastCommClass: EVNetworkingObject {
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

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("action", "action"), ("channelType", "channeltype"), ("contSource", "cont_src"), ("globalMsgId", "gl_mesg_id"), ("globalTopicId", "gl_topic_id"), ("text", "txt"), ("msgType", "mesgtype"), ("receiver", "receiver"), ("senderUUID", "senderUUID"), ("senderPhone", "senderPhone"), ("sent_utc", "sent_utc"), ("replyToId", "reply_to"), ("refGroupId", "refGroupId")]
    }

    func mapDataValues(dataDict: ACCommunicationMsgObject) -> BrocastCommClass {
        let directMsgObj = BrocastCommClass()

        directMsgObj.action = dataDict.action
        directMsgObj.channelType = dataDict.channelType
        directMsgObj.contSource = dataDict.contSource
        directMsgObj.globalMsgId = dataDict.globalMsgId
        directMsgObj.globalTopicId = dataDict.globalTopicId
        directMsgObj.text = dataDict.text
        directMsgObj.media = dataDict.media
        directMsgObj.other = dataDict.other
        directMsgObj.otherType = dataDict.otherType
        directMsgObj.msgType = dataDict.msgType
        directMsgObj.receiver = dataDict.receiver
        directMsgObj.senderUUID = dataDict.senderUUID
        directMsgObj.senderPhone = dataDict.senderPhone
        directMsgObj.sent_utc = dataDict.sent_utc
        directMsgObj.replyToId = dataDict.replyToId
        directMsgObj.refGroupId = dataDict.refGroupId

        return directMsgObj
    }
}
