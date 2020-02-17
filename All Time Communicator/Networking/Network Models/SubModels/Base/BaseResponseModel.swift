//
//  DefaultResponseModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 03/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import AnyCodable
import EVReflection

class BaseResponseModel: EVNetworkingObject {
    var status: String?
    var fault: String?
    var successMsg: [String] = []
    var errorMsg: [String] = []

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("successMsg", "sucMsg"), ("errorMsg", "errMsg")]
    }
}

class EncryptedBaseResponseModel: EVNetworkingObject {
    var status: String?
    var fault: String?
    var successMsg: [String] = []
    var errorMsg: [String] = []
    var encryptedData: NSString?

    func decryptData(_: String) {
        assert(true, "This needs to be overridden")
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("successMsg", "sucMsg"), ("errorMsg", "errMsg"), ("encryptedData", "data")]
    }
}

class UpdateBroadCastGroupEncryptedBaseModel: EVNetworkingObject {
    var status: String?
    var fault: String?
    var successMsg: [String] = []
    var errorMsg: [Any] = []
    var encryptedData: NSString?
    
    func decryptData(_: String) {
        assert(true, "This needs to be overridden")
    }
    
    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("successMsg", "sucMsg"), ("errorMsg", "errMsg"), ("encryptedData", "data")]
    }
}
