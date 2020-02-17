//
//  ConfidentialGroupCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/10/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class ConfidentialGroupCell: UITableViewCell {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileBadge: UIImageView!
    @IBOutlet var confGroupName: UILabel!
    @IBOutlet var confCreatedBy: UILabel!
    @IBOutlet var confCreatedDate: UILabel!
    @IBOutlet var confNumberOfContacts: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
