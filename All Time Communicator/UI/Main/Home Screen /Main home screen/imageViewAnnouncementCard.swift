//
//  imageViewAnnouncementCard.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class imageViewAnnouncementCard: UIView {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageTitle: UILabel!
    @IBOutlet var imageComment: UILabel!
    @IBOutlet var onClickOfPlayBtn: UIButton!

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
