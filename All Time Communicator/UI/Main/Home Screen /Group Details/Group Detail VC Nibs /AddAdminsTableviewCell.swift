//
//  AddAdminsTableviewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 01/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class AddAdminsTableviewCell: UITableViewCell {
    @IBOutlet var groupMemberProfileImage: UIImageView!
    @IBOutlet var groupMemName: UILabel!
    @IBOutlet var adminLabel: UILabel!
    @IBOutlet var leftArrow: UIImageView!
    @IBOutlet var memberTitle: UILabel!
    @IBOutlet var crownStack: UIStackView!
    @IBOutlet var lbltit2: UILabel!

    @IBOutlet var imgCrown: UIImageView!
    @IBOutlet var lblAdminSet: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
