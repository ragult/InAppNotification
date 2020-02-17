//
//  MessageItemMedia.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 07/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class MessageItemMedia: NSObject {
    private var mediaUrl: String?
    private var messageType: messagetype?

    init(url: String, msgType: messagetype) {
        messageType = msgType
        mediaUrl = url
    }

    func getMessageType() -> messagetype {
        return messageType!
    }

    func getMediaUrl() -> String {
        return mediaUrl!
    }

    func setMediaUrl(url: String) {
        mediaUrl = url
    }
}
