//
//  PollView.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 18/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class PollView: UIView {
    @IBOutlet var optionStack1: UIStackView!
    @IBOutlet var optionStack2: UIStackView!
    @IBOutlet var optionStack3: UIStackView!
    @IBOutlet var optionStack4: UIStackView!

    @IBOutlet var pollBtn: TableViewButton!

    @IBOutlet var numberOfGroupMembers: UILabel!
    @IBOutlet var pollTime: UILabel!
    @IBOutlet var pollTitle: UILabel!
    @IBOutlet var pollOptionOneLabel: UILabel!
    @IBOutlet var numberOfVotesForOptionOne: UILabel!
    @IBOutlet var pollOptionOneCheckMark: UIImageView!
    @IBOutlet var pollOptionTwoLabel: UILabel!
    @IBOutlet var pollOptionTwoCheckMark: UIImageView!
    @IBOutlet var numberOfVotesForOptionThree: UILabel!
    @IBOutlet var numberOfVotesForOptionTwo: UILabel!
    @IBOutlet var numberOfVotesForOptionFour: UILabel!
    @IBOutlet var pollOptionLabelFour: UILabel!
    @IBOutlet var pollOptionLabelThree: UILabel!
    @IBOutlet var pollOptionourCheckMark: UIImageView!
    @IBOutlet var pollOptionThreeCheckMark: UIImageView!
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
         // Drawing code
     }
     */

    @IBOutlet var POLLTITLELABEL: UILabel!

    @IBOutlet var expIcon: UIImageView!

    @IBOutlet var pollIcon: UIImageView!

    func setTextToWhite() {
        pollBtn.extBorderColor = .white
        pollBtn.setTitleColor(.white, for: .normal)
        pollTitle.textColor = .white
        POLLTITLELABEL.textColor = .white
        pollTime.textColor = .white
        pollIcon.image = UIImage(named: "poll-1")
        expIcon.image = UIImage(named: "clock-1")
        backgroundColor = .clear
    }

    func setTextToDefault() {
        pollBtn.extBorderColor = COLOURS.APP_MEDIUM_GREEN_COLOR
        pollBtn.setTitleColor(COLOURS.APP_MEDIUM_GREEN_COLOR, for: .normal)

        pollTitle.textColor = COLOURS.textDarkGrey
        POLLTITLELABEL.textColor = COLOURS.APP_MEDIUM_GREEN_COLOR
        pollTime.textColor = COLOURS.APP_MEDIUM_GREEN_COLOR
        pollIcon.image = UIImage(named: "poll")
        expIcon.image = UIImage(named: "clockSmall")
        backgroundColor = .white
    }
}
