//
//  RoleOfUserCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 02/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class RoleOfUserCell: UITableViewCell {
    @IBOutlet var makeAdminSwitch: UISwitch!
    @IBOutlet var makeAdminLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        makeAdminSwitch.transform = CGAffineTransform(scaleX: 0.72, y: 0.72)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
