//
//  GroupUserProfileCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 01/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class GroupUserProfileCell: UITableViewCell {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var groupMemName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
