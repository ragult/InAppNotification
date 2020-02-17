//
//  SearchTableViewCell.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 19/06/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    @IBOutlet var groupProfileImage: UIImageView!
    @IBOutlet var groupName: UILabel!
    @IBOutlet var typeOfChatIcon: UIImageView!
    @IBOutlet var numberOfContacts: UILabel!
    @IBOutlet var createdByAndDate: UILabel!
    @IBOutlet var confidentialImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
