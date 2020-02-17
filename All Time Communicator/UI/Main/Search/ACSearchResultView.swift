//
//  ACSearchResultView.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 22/06/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACSearchResultView: UIView {
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupSmallImage: UIImageView!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var groupDescription: UILabel!
    @IBOutlet weak var descripStack: UIStackView!
    @IBAction func connectClicked(_ sender: Any) {
        
    }
    
    @IBAction func closedButtonTapped(_ sender: Any) {
        
    }
    @IBOutlet weak var addressStack: UIStackView!
}
