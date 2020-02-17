//
//  GroupTableviewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/10/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class GroupTableviewCell: UITableViewCell {
    @IBOutlet var groupProfileImage: UIImageView!
    @IBOutlet var groupName: UILabel!
    @IBOutlet var typeOfChatIcon: UIImageView!
    @IBOutlet var numberOfContacts: UILabel!
    @IBOutlet var createdByAndDate: UILabel!
    @IBOutlet var confidentialImage: UIImageView!

    @IBOutlet var messageStatus: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
//    groupProfileImage.backgroundColor = UIColor(r: 0, g: 198, b: 168)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
