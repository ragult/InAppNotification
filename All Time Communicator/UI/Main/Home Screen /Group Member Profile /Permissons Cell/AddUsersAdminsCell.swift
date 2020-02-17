//
//  AddUsersAdminsCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 02/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class AddUsersAdminsCell: UITableViewCell {
    @IBOutlet var addUsersLabel: UILabel!
    @IBOutlet var addUsersImage: UIImageView!
    @IBOutlet var addUsersStack: UIStackView!
    @IBOutlet var postEventsLabel: UILabel!
    @IBOutlet var postEventsImage: UIImageView!
    @IBOutlet var postEventsStack: UIStackView!
    @IBOutlet var postAlbumsLabel: UILabel!
    @IBOutlet var postAlbumsImage: UIImageView!
    @IBOutlet var postAlbumsStack: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        postAlbumsStack.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
