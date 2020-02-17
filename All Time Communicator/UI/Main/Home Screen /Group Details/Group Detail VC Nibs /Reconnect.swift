//
//  Reconnect.swift
//  alltimecommunicator
//
//  Created by Ragul kts on 31/01/20.
//  Copyright © 2020 Droid5. All rights reserved.
//


import UIKit

class Reconnect: UIView {
    
    @IBOutlet weak var reconnectBtn: UIButton!
    
    static func initWith() -> Reconnect {
        return Bundle.main.loadNibNamed("Reconnect", owner: self, options: nil)?.first as! Reconnect
    }
    
}
