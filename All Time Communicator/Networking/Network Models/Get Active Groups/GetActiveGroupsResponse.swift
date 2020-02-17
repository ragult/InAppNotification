//
//  GetActiveGroupsResponse.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 09/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class GetActiveGroupResponse: EncryptedBaseResponseModel {
    var data: CustomData?

    class CustomData: EVNetworkingObject {
        var totalRecords = ""
        var activeGroups = [GroupModel]()
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("activeGroups", "activeGroupModel")]
    }

    override func decryptData(_ decryptedData: String) {
        data = CustomData(json: decryptedData)
    }
}
