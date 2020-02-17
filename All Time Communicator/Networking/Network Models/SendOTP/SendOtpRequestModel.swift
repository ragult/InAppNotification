//
//  OtpRequestModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 03/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class SendOtpRequestModel: EVNetworkingObject {
    var countryIsoCode: String = ""
    var phoneNumber: String = ""

    convenience init(countryIsoCode: String, phoneNumber: String) {
        self.init()
        self.countryIsoCode = countryIsoCode
        self.phoneNumber = phoneNumber
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("countryIsoCode", "isoCode")]
    }
}
