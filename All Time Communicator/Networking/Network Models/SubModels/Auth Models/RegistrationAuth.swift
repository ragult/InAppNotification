//
//  File.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 03/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation
class RegistrationAuth: EVNetworkingObject {
    var fg: String?
    var jq: String?
    var phoneNumber: String?
    var isoCode: String?

    convenience init(fg: String, phoneNumber: String, isoCode: String, jq: String) {
        self.init()
        self.fg = fg
        self.phoneNumber = phoneNumber
        self.isoCode = isoCode
        self.jq = jq
    }
}
