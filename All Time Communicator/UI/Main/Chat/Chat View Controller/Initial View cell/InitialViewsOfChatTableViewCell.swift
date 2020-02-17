//
//  InitialViewsOfChatTableViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 22/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class InitialViewsOfChatTableViewCell: UITableViewCell {
    @IBOutlet var customView: UIStackView!

    var JoinGroupView: JoinGroupView?
    var ChatAlert: ChatAlert?
    override func awakeFromNib() {
        super.awakeFromNib()
        customView.setNeedsLayout()
        customView.layoutIfNeeded()
        if let CustomView = Bundle.main.loadNibNamed("JoinGroupView", owner: self, options: nil)?.first as? JoinGroupView {
            JoinGroupView = CustomView
            JoinGroupView?.dropLightShadow(scale: true)
        }
        if let CustomView = Bundle.main.loadNibNamed("ChatAlert", owner: self, options: nil)?.first as? ChatAlert {
            ChatAlert = CustomView
            ChatAlert?.dropLightShadow(scale: true)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
