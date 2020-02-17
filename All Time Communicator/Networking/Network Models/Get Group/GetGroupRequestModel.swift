//
//  GetGroupRequestModel.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 13/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation
class GetGroupRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var groupId: String?
    var groupType: String?

    convenience init(auth: GlobalAuth, groupId: String, groupType: String) {
        self.init()
        self.auth = auth
        self.groupId = groupId
        self.groupType = groupType
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupType", "type")]
    }
}

class GetPublicGroupRequestModel: EVNetworkingObject {
    var publicGroupId: String?
    var auth = GlobalAuth()
}
