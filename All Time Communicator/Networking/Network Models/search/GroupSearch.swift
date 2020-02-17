//
//  GroupSearch.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 19/06/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class GroupSearch: EVNetworkingObject {
    var auth = GlobalAuth()
    var keyword: String = ""
    var cityId: String = ""
}

class GroupCodeSearch: EVNetworkingObject {
    var auth = GlobalAuth()
    var groupCode: String = ""
}

class GroupCodeSearchResponse: EncryptedBaseResponseModel {
    var data: [CustomData]?

    override func decryptData(_ decryptedData: String) {
        data = [CustomData(json: decryptedData)]
    }

    class CustomData: EVNetworkingObject {
        var groupId: String?
        var groupPublicId: String?
        var groupName: String?
        var groupType: String?
        var groupDescription: String?
        var fullImageUrl: String?

        override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
            return [("groupDescription", "description")]
        }
    }
}

class GroupNameSearchResponse: EncryptedBaseResponseModel {
    var data: [CustomData]?

    override func decryptData(_ decryptedData: String) {
        data = CustomData.arrayFromJson(decryptedData)
//        data = [CustomData(json: decryptedData)]
    }

    class CustomData: EVNetworkingObject {
        var groupId: String?
        var groupPublicId: String?
        var groupName: String?
        var address: String?
        var desc:  String?
        var fullImageUrl: String?


        override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
            return [("desc", "description")]
        }
    }
    
}
