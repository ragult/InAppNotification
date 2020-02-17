//
//  PollwithImages.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 18/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class PollwithImages: UIView {
    @IBOutlet var numberOfMembersInPoll: UILabel!

    @IBOutlet var timeForPollLabel: UILabel!
    @IBOutlet var pollQuestion: UILabel!
    @IBOutlet var pollImage1: UIImageView!
    @IBOutlet var pollOptionOneVotes: UILabel!
    @IBOutlet var pollOptionTwo: UIImageView!
    @IBOutlet var pollOptionViewVotes: UILabel!
    @IBOutlet var pollOptionThree: UIImageView!
    @IBOutlet var pollOptionThreeVotes: UILabel!
    @IBOutlet var pollOptionFour: UIImageView!
    @IBOutlet var pollOptionFourVotes: UILabel!
    @IBOutlet var image1Selected: UIButton!

    @IBOutlet var image2Selected: UIButton!
    @IBOutlet var image3Selected: UIButton!
    @IBOutlet var image4Selected: UIButton!

    @IBOutlet var BottomImageHeightConstraint: NSLayoutConstraint!

    @IBOutlet var pollSubmit: UIButton!

    @IBOutlet var POLLTITLELABEL: UILabel!

    @IBOutlet var expIcon: UIImageView!

    @IBOutlet var pollIcon: UIImageView!

    @IBOutlet var lineLabel: UILabel!

    func setTextToWhite() {
        pollSubmit.extBorderColor = .white
        pollSubmit.setTitleColor(.white, for: .normal)
        lineLabel.backgroundColor = .white
        pollQuestion.textColor = .white
        POLLTITLELABEL.textColor = .white
        timeForPollLabel.textColor = .white
        pollIcon.image = UIImage(named: "poll-1")
        expIcon.image = UIImage(named: "clock-1")
        backgroundColor = .clear
    }

    func setTextToDefault() {
        pollSubmit.extBorderColor = COLOURS.APP_MEDIUM_GREEN_COLOR
        pollSubmit.setTitleColor(COLOURS.APP_MEDIUM_GREEN_COLOR, for: .normal)
        lineLabel.backgroundColor = COLOURS.APP_MEDIUM_GREEN_COLOR

        pollQuestion.textColor = COLOURS.textDarkGrey
        POLLTITLELABEL.textColor = COLOURS.APP_MEDIUM_GREEN_COLOR
        timeForPollLabel.textColor = COLOURS.APP_MEDIUM_GREEN_COLOR
        pollIcon.image = UIImage(named: "poll")
        expIcon.image = UIImage(named: "clockSmall")
        backgroundColor = .white
    }
}
