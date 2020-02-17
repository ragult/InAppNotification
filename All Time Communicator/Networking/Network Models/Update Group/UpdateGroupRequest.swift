//
//  UpdateGroupRequest.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 09/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class UpdateGroupRequest: EVNetworkingObject {
    var groupName: String?
    var groupType: String?
    var groupDescription: String?
    var fullImageUrl: String?
    var thumbnailUrl: String?
    var confidentialFlag: String?
    var groupStatus: String?

    convenience init(groupName: String, groupType: String, groupDescription: String, fullImageUrl: String, thumbnailUrl: String, confidentialFlag: String, groupStatus: String) {
        self.init()
        self.groupName = groupName
        self.groupType = groupType
        self.groupDescription = groupDescription
        self.fullImageUrl = fullImageUrl
        self.thumbnailUrl = thumbnailUrl
        self.confidentialFlag = confidentialFlag
        self.groupStatus = groupStatus
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupName", "name"), ("groupDescription", "description"), ("groupStatus", "status"), ("groupType", "type")]
    }
}
