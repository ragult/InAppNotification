//
//  ContactsTableCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 23/10/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class ContactsTableCell: UITableViewCell {
    @IBOutlet var memberProfielImage: UIImageView!
    @IBOutlet var memberName: UILabel!
    @IBOutlet var memberPhonNumber: UILabel!
    @IBOutlet var chatButtonInSectionOne: UIButton!
    @IBOutlet var inviteButtonInSectionTwo: UIButton!
    @IBOutlet var profileTickMark: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func chatButtonActionInSectionOne(_: Any) {
        print("chat Button clicked")
    }
}
