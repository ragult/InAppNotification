//
//  twilioApi.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 29/04/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
class TwilioRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var phone: String = ""
    var country: String = ""
    var state: String = ""
    var area: String = ""
    var city: String = ""
    var address: String = ""
    var zip: String = ""
    var latitude: String = ""
    var mapLocationId: String = ""
    var longitude: String = ""
    var phoneType: String = "0"
    var mapServiceProvider: String = "1"
    var verifyMethod: String = "1"
    var stateShortName: String = ""
    var cityId: String = ""
    var locality: String = ""
    var subLocality: String = ""
    var postalTown: String = ""
}

class TwilioVerifyRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var mapLocationId: String?
    var pin: String?
}

class UpdateOtpResponse: EncryptedBaseResponseModel {
    //    var data:customData?
    //    class customData:EVNetworkingObject {}
}

class verifyMapOtpResponse: EncryptedBaseResponseModel {
    var data: [CustomData]?

    override func decryptData(_ decryptedData: String) {
        data = [CustomData(json: decryptedData)]
    }

    class CustomData: EVNetworkingObject {
        var groupLocId: String?
    }
}

class mapSearchRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var lat: String?
    var lon: String?
    var keyword: String?
    var type: String = "address"
    var radius: String = "50000"
}

class mapSearchresponseModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var lat: String?
    var lon: String?
    var keyword: String?
    var type: String = "address"
    var radius: String = "50000"
}
