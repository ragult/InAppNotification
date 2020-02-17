//
//  ACMediaDisplayObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 25/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACMediaDisplayObject: NSObject {
    var imageName: String?
    var msgType: messagetype = messagetype.IMAGE

    init(name: String, type: messagetype) {
        super.init()
        imageName = name
        msgType = type
    }
}
