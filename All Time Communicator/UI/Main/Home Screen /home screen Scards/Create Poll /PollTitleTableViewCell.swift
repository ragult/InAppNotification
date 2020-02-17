//
//  PollTitleTableViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 28/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class PollTitleTableViewCell: UITableViewCell {
    @IBOutlet var questionTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func getQuestion() -> String {
        return questionTextField.text ?? ""
    }
}
