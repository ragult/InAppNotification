//
//  ReplyToMessageView.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 17/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class ReplyToMessageView: UIView {
    @IBOutlet var messageSender: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var previewButton: UIButton!
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_: CGRect) {
        // Drawing code

        dropLightShadow()
    }
}
