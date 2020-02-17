//
//  MessageItemText.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 07/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class MessageItemText: NSObject {
    private var messageString: String?
    private var messageType: messagetype?

    init(msgText: String) {
        messageType = messagetype.TEXT
        messageString = msgText
    }

    func getMessageType() -> messagetype {
        return messageType!
    }

    func getMessageText() -> String {
        return messageString!
    }

    func setMessageText(msgText: String) {
        messageString = msgText
    }
}
