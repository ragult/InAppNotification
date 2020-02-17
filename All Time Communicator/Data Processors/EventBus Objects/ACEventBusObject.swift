//
//  ACEventBusObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 02/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACEventBusObject: NSObject {
    var messageId: String = ""
    var receivingChannelName: String = ""
    var postedTime: String = ""
    var messageOrigin: MessageOrigin?
    var senderPhone: String = ""
    var ChannelType: channelType?
    var messageState: messageState?
}
