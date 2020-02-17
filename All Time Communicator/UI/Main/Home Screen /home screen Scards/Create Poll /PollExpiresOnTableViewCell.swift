//
//  PollExpiresOnTableViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 28/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class PollExpiresOnTableViewCell: UITableViewCell {
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var BtnClose: UIButton!
    @IBOutlet var BtnDone: UIButton!
    @IBOutlet var containView: UIView!

    @IBOutlet var lblDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
