//
//  InviteTItleDescrptionTableViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 01/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class InviteTItleDescrptionTableViewCell: UITableViewCell {
    @IBOutlet var textFieldTrailingAnchor: NSLayoutConstraint!
    @IBOutlet var titleImage: UIImageView!
    @IBOutlet var openGalleryBtn: UIButton!
    @IBOutlet var deleteImageBtn: UIButton!
    @IBOutlet var inviteTF: UITextField!

    @IBOutlet var inviteTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
