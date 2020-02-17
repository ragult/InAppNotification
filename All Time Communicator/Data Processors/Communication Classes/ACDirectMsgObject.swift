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
    var msgType: String?
    var receiver: String?
    var senderUUID: String?
    var senderPhone: String?
    var sent_utc: String?
    var replyToId: String?

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("action", "action"), ("channelType", "channeltype"), ("contSource", "cont_src"), ("globalMsgId", "gl_mesg_id"), ("globalTopicId", "gl_topic_id"), ("text", "txt"), ("msgType", "mesgtype"), ("receiver", "receiver"), ("senderUUID", "senderUUID"), ("senderPhone", "senderPhone"), ("sent_utc", "sent_utc"), ("replyToId", "reply_data")]
    }
}
