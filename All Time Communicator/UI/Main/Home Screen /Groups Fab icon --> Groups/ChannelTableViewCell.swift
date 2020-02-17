//
//  ChannelTableViewCell.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 06/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {
    @IBOutlet var channelImageView: UIImageView!
    @IBOutlet var channelNameLabel: UILabel!

    @IBOutlet var channelMessageLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!

    @IBOutlet var unreadCountLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    @IBOutlet var confidentialImage: UIImageView!

    @IBOutlet var attachIcon: UIImageView!
    @IBOutlet var sentStatus: UIImageView!

    //    @IBOutlet weak var channelImageView: UIImageView!
//
//    @IBOutlet weak var channelNameLabel: UILabel!
//
//    @IBOutlet weak var channelMessageLabel: UILabel!
//
//    @IBOutlet weak var unreadCountLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
