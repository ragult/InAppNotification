//
//  PollOptionsTableViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 28/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class PollOptionsTableViewCell: UITableViewCell {
    @IBOutlet var pollOptionTextField: UITextField!
    @IBOutlet var optionImageView: UIImageView!
    @IBOutlet var deleteOptionImageBtn: UIButton!
    @IBOutlet var uploadImageBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
