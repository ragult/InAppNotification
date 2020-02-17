//
//  CreateGroupRequest.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 09/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class CreateGroupRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var name: String = ""
    var type: String = ""
    var groupDescription: String = ""
    var fullImageUrl: String = ""
    var thumbnailUrl: String = ""
    var confidentialFlag: String = ""
    var createdBy: String = ""
    var groupStatus: String = ""
    var groupLocationId: String = ""
    var address: String = ""

    var groupMembers: [String] = []

    convenience init(auth: GlobalAuth, name: String, type: String, groupDescription: String, fullImageUrl: String, thumbnailUrl: String, confidentialFlag: String, createdBy: String, groupStatus: String, groupMembers: [String]) {
        self.init()
        self.auth = auth
        self.name = name
        self.type = type
        self.groupDescription = groupDescription
        self.fullImageUrl = fullImageUrl
        self.thumbnailUrl = thumbnailUrl
        self.confidentialFlag = confidentialFlag
        self.createdBy = createdBy
        self.groupStatus = groupStatus
        self.groupMembers = groupMembers
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupDescription", "description"), ("groupStatus", "status"), ("groupMembers", "members")]
    }
}
