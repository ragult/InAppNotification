//
//  ChangeNumberRequestModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 18/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class ChangeNumberRequestModel: EVNetworkingObject {
    var securityCode: String = ""
    var globalUserId: String = ""
    var oldNumber: PhoneNumber = PhoneNumber(countryIsoCode: "", phoneNumber: "")
    var newNumber: PhoneNumber = PhoneNumber(countryIsoCode: "", phoneNumber: "")
    var deviceApn: String = ""
    var deviceApnType: String = ""

    convenience init(securityCode: String, globalId: String, oldNumber: PhoneNumber, newNumber: PhoneNumber, deviceApn: String, deviceApnType: String) {
        self.init()
        self.securityCode = securityCode
        globalUserId = globalId
        self.oldNumber = oldNumber
        self.newNumber = newNumber
        self.deviceApn = deviceApn
        self.deviceApnType = deviceApnType
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("oldNumber", "oldnumber"), ("newNumber", "newnumber"), ("globalUserId", "globalId")]
    }
}
