//
//  ACReadReceiptEventBusObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 09/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import UIKit

class ACReadReceiptEventBusObject: EVNetworkingObject {
    var firstMsgId: String = ""
    var lastMsgId: String = ""
    var channelName: String? = ""
    var isMine: Bool = false
    var messageState: messageState?
    var messageDate: String = ""

    convenience init(firstMsgId: String, lastMsgId: String, channelName: String?, messageState: messageState, isMine: Bool, date: String) {
        self.init()
        self.firstMsgId = firstMsgId
        self.lastMsgId = lastMsgId
        self.channelName = channelName
        self.messageState = messageState
        self.isMine = isMine
        messageDate = date
    }
}
