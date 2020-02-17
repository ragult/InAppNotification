//
//  eventObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 14/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import UIKit

class eventObject: EVNetworkingObject {
    var channelObject: ChannelTable?
    var messages: MessagesTable?

    convenience init(chnlObj: ChannelTable, msg: MessagesTable) {
        self.init()
        channelObject = chnlObj
        messages = msg
    }
}
