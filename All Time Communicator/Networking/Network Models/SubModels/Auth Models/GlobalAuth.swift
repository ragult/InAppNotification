//
//  GlobalAuth.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 03/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class GlobalAuth: EVNetworkingObject {
    var globalUserId: String?
    var securityCode: String?
    var deviceId: String?

    convenience init(globalUserId: String, securityCode: String, deviceId: String) {
        self.init()
        self.globalUserId = globalUserId
        self.securityCode = securityCode
        self.deviceId = deviceId
    }
}
