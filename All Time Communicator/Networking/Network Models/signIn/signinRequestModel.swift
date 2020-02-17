//
//  signinRequestModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 21/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection

class signinRequestModel: EVNetworkingObject {
    var countryIsoCode: String = ""
    var phoneNumber: String = ""
    var loginSessionId: String = ""
    var socialType: String = ""
    var socialAccessToken: String = ""
    var deviceId: String = ""
    var deviceType: String = ""
    var deviceToken: String = ""

    convenience init(countryIsoCode: String, phoneNumber: String) {
        self.init()
        self.countryIsoCode = countryIsoCode
        self.phoneNumber = phoneNumber
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("countryIsoCode", "isoCode"), ("deviceId", "ab"), ("loginSessionId", "cd"), ("socialType", "pq"), ("socialAccessToken", "accessToken"), ("deviceType", "dt"), ("deviceToken", "dtk")]
    }
}
