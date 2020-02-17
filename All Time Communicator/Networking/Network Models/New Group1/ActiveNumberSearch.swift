//
//  ActiveNumberSearch.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 23/05/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection

class ActiveNumberSearch: EVNetworkingObject {
    var auth = GlobalAuth()
    var globalUserId = NSArray()
}

class ActiveNumberSearchResponse: EncryptedBaseResponseModel {
    var data: [CustomData]?

    override func decryptData(_ decryptedData: String) {
        data = [CustomData(json: decryptedData)]
    }

    class CustomData: EVNetworkingObject {
        var globalUserId: String?
        var status: String?
        var phoneNumber: String?
    }
}
