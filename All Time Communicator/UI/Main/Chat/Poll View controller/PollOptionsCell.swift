//
//  PollOptionsCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 21/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class PollOptionsCell: UITableViewCell {
    @IBOutlet var pollOptionTitle: UILabel!
    @IBOutlet var optionSelectionCheckMark: UIImageView!
    @IBOutlet var pollProgressBar: UIProgressView!
    @IBOutlet var numberOfVotes: UILabel!
    @IBOutlet var pollPercentage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
