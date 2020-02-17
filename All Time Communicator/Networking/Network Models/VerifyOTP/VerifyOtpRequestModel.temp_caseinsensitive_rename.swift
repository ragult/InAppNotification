//
//  verifyOTPRequestModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 03/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//
import EVReflection

class VerifyOtpRequestModel: EVNetworkingObject {
    var userOtp: String?
    var securityCode: String?
    var countryIsoCode: String?
    var phoneNumber: String?

    convenience init(userOtp: String, securityCode: String, countryIsoCode: String, phoneNumber: String) {
        self.init()
        self.userOtp = userOtp
        self.securityCode = securityCode
        self.countryIsoCode = countryIsoCode
        self.phoneNumber = phoneNumber
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("userOtp", "varUserOtp"), ("countryIsoCode", "isoCode")]
    }
}
