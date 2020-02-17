//
//  UpdatelastLoginModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 31/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class UpdatelastLoginModel: EVNetworkingObject {
    var securityCode: String = ""
    var globalUserId: String = ""

    convenience init(securityCode: String, globalId: String) {
        self.init()
        self.securityCode = securityCode
        globalUserId = globalId
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("globalUserId", "globalId")]
    }
}
