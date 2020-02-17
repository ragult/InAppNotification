//
//  DayViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 26/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class DayViewCell: UITableViewCell {
    @IBOutlet var dayButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        dayButton.setTitle("Today", for: .normal)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
