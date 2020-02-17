//
//  incomingMessageHelperVIew.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 21/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class incomingMessageHelperVIew: UIView {
    var isLastMessage: Bool = true {
        didSet(newValue) {
            if newValue { self.draw(self.bounds)
            }
        }
    }

    override func draw(_: CGRect) {
        if isLastMessage == false {
            ChatBubbleDesignHelper.drawIncomingMessageChatBubbleNL(mainFrame: bounds)
        } else {
            ChatBubbleDesignHelper.drawIncomingMessageChatBubble(mainFrame: bounds)
        }
    }
}
