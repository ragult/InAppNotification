//
//  ImagePollCardView.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ImagePollCardView: UIView {
    @IBOutlet var votesBG: UIView!
    @IBOutlet var voteTextLabel: UILabel!
    @IBOutlet var numberOfVotes: UILabel!
    @IBOutlet var pollOptionOne: UIImageView!
    @IBOutlet var pollOptionTwo: UIImageView!
    @IBOutlet var pollOptionThree: UIImageView!
    @IBOutlet var pollOptionFour: UIImageView!
    @IBOutlet var pollExpiresOn: UILabel!
    @IBOutlet var pollTitle: UILabel!
    @IBOutlet var select1: UIButton!
    @IBOutlet var select2: UIButton!
    @IBOutlet var select3: UIButton!
    @IBOutlet var select4: UIButton!

    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!

    @IBOutlet var rightConstaint: NSLayoutConstraint!
    @IBOutlet var leftConstaint: NSLayoutConstraint!

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
         // Drawing code
     }
     */
}
