//
//  ACPubnubReferenceObjectClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 16/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACPubnubReferenceObjectClass: NSObject {
    var messageId: String = ""
    var timeStamp: String = ""
    var channel: String = ""

    var msgState: String = messageState.RECEIVER_RECEIVED.rawValue

    init(messageId: String, timeStamp: String, msgState: String, chnl: String) {
        self.messageId = messageId
        self.msgState = msgState
        self.timeStamp = timeStamp
        channel = chnl
    }
}
