//
//  verifyOTPRequestModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 03/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//
import EVReflection

class VerifyOtpRequestModel: EVNetworkingObject {
    var userOtp: String = ""
    var securityCode: String = ""
    var countryCode: String = ""
    var phoneNumber: String = ""

    convenience init(userOtp: String, securityCode: String, phoneNumber: String, countryCode: String) {
        self.init()
        self.userOtp = userOtp
        self.securityCode = securityCode
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("userOtp", "varUserOtp"), ("countryCode", "isoCode"), ("securityCode", "deviceId")]
    }
}
