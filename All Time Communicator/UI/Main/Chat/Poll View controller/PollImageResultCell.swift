//
//  PollImageResultCell.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 03/06/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class PollImageResultCell: UITableViewCell {
    @IBOutlet var imgBtn: UIButton!
    @IBOutlet var pollOptionTitle: UILabel!
    @IBOutlet var optionSelectionCheckMark: UIImageView!
    @IBOutlet var pollProgressBar: UIProgressView!
    @IBOutlet var numberOfVotes: UILabel!
    @IBOutlet var pollPercentage: UILabel!
    @IBOutlet var checkMark: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
