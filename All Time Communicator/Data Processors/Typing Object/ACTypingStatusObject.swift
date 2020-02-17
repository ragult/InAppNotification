//
//  ACTypingStatusObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 21/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import UIKit

class ACTypingStatusObject: EVNetworkingObject {
    var uuid: String = ""
    var status: Bool = true
    var channelName: String = ""
    var topic: String = ""
    var time: String = ""
    convenience init(uuid: String, channelName: String, time: String, status: Bool, topic: String) {
        self.init()
        self.uuid = uuid
        self.channelName = channelName
        self.time = time
        self.status = status
        self.topic = topic
    }
}
