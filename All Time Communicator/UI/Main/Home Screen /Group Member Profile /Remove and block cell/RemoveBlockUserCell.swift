//
//  RemoveBlockUserCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 02/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class RemoveBlockUserCell: UITableViewCell {
    @IBOutlet var blockImage: UIImageView!
    @IBOutlet var blockLabel: UILabel!
    @IBOutlet var removeImage: UIImageView!
    @IBOutlet var removeLabel: UILabel!
    @IBOutlet var removeFromGroupStack: UIStackView!
    @IBOutlet var blockStack: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
