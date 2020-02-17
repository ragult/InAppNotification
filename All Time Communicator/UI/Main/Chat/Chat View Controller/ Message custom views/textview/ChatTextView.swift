//
//  ChatTextView.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 30/04/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ChatTextView: UIView {
    @IBOutlet var textLabel: UILabel!
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
         // Drawing code
     }
     */
    @IBOutlet var textViewWidth: NSLayoutConstraint!

    @IBOutlet var textViewHeight: NSLayoutConstraint!
}
