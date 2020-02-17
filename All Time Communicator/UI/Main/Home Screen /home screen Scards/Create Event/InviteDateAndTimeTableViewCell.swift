//
//  InviteDateAndTimeTableViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 01/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class InviteDateAndTimeTableViewCell: UITableViewCell {
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var timePicker: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
