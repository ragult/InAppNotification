//
//  PollCardView.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class PollCardView: UIView {
    @IBOutlet var votesTextLabel: UILabel!
    @IBOutlet var pollTitle: UILabel!
    @IBOutlet var pollExpireOnLabel: UILabel!
    @IBOutlet var pollOptionOne: UILabel!

    @IBOutlet var numberOfVotes: UILabel!
    @IBOutlet var pollOptionTwo: UILabel!
    @IBOutlet var votesBG: UIStackView!
    @IBOutlet var moreOptions: UILabel!
    @IBOutlet var select1: UIImageView!
    @IBOutlet var select2: UIImageView!

    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!

    @IBOutlet var rightConstaint: NSLayoutConstraint!
    @IBOutlet var leftConstaint: NSLayoutConstraint!
}
