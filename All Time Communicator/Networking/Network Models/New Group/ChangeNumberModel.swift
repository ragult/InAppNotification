//
//  ChangeNumber.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 23/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection

class ChangeNumberModel: EVNetworkingObject {
    var otp: String = ""
    var newDeviceId: String = ""
    var newIsoCode: String = ""
    var newPhoneNumber: String = ""
    var auth = GlobalAuth()

    convenience init(userOtp: String, securityCode: String, phoneNumber: String, countryCode: String) {
        self.init()
        otp = userOtp
        newDeviceId = securityCode
        newIsoCode = countryCode
        newPhoneNumber = phoneNumber
    }
}
