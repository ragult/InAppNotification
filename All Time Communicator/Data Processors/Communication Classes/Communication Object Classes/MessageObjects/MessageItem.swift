//
//  MessageItem.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 07/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class MessageItem: NSObject {
    var messageType: messagetype?
    var message: Any?
    var otherMessageType: otherMessageType?
    var cloudReference: String = ""
    var messageTextString: String = ""
    var thumbnail: String = ""
    var cloudThumbail: String = ""
    var localMediaPaths: String = ""
}
