//
//  outGoingMessageHelperView.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 21/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class outGoingMessageHelperView: UIView {
    var isLastMessage: Bool = true {
        didSet(newValue) {
            if newValue {
                self.draw(self.bounds)
            }
        }
    }

    convenience override init(frame: CGRect) {
        self.init(frame: frame)
    }

    override func draw(_: CGRect) {
        if isLastMessage == false {
            ChatBubbleDesignHelper.drawOutGoingMessageChatBubbleNL(mainFrame: bounds)
        } else {
            ChatBubbleDesignHelper.drawOutGoingMessageChatBubble(mainFrame: bounds)
        }
    }
}