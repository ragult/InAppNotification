//
//  GroupDescription.swift
//  alltimecommunicator
//
//  Created by Lokesh on 12/29/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Foundation
import UIKit

class GroupDescription: UIView {
    @IBOutlet weak var groupDescription: UILabel!
    
    
    static func initWith() -> GroupDescription {
        return Bundle.main.loadNibNamed("GroupDescription", owner: self, options: nil)?.first as! GroupDescription
    }
    
    func setDescription(desc: String) {
        self.groupDescription.text = desc
    }
}
