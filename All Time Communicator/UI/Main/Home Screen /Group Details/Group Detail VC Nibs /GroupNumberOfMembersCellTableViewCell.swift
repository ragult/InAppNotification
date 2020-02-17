//
//  GroupNumberOfMembersCellTableViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 27/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class GroupNumberOfMembersCellTableViewCell: UITableViewCell {
    @IBOutlet var remainingMembersInGroup: UILabel!

    @IBOutlet var exitImage: UIImageView!
    @IBOutlet var exitGroup: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
