//
//  AudioCardView.swift
//  alltimecommunicator
//
//  Created by new1 on 18/03/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class AudioCardView: UIView {
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var BtnPlay: UIButton!
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
         // Drawing code
     }
     */

    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!

    @IBOutlet var rightConstaint: NSLayoutConstraint!
    @IBOutlet var leftConstaint: NSLayoutConstraint!
}
