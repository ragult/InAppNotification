//
//  SigninChallengeRequestModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 21/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//
import EVReflection

class SigninChallengeRequestModel: EVNetworkingObject {
    var countryIsoCode: String = ""
    var phoneNumber: String = ""
    var loginSessionId: String = ""
    var oldIsoCode: String = ""
    var phoneNoChallengeId: String = ""
    var deviceId: String = ""
    var oldPhoneNumber: String = ""
    var registerType: String = ""
    var socialId: String = ""
    var deviceType: String = ""
    var deviceToken: String = ""

    convenience init(countryIsoCode: String, phoneNumber: String) {
        self.init()
        self.countryIsoCode = countryIsoCode
        self.phoneNumber = phoneNumber
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("countryIsoCode", "isoCode"), ("loginSessionId", "sd"), ("phoneNoChallengeId", "er"), ("deviceId", "yu"), ("registerType", "pq"), ("socialId", "st"), ("deviceType", "dt"), ("deviceToken", "dtk")]
    }
}
