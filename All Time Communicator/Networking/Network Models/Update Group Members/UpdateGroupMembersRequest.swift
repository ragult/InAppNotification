//
//  UpdateGroupMembers.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 09/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class UpdateGroupMembersRequest: EVNetworkingObject {
    var auth = GlobalAuth()
    var groupId: String?
    var globalUserId: String?
    var groupMembers = [GroupMemberTable]()
    convenience init(auth: GlobalAuth, groupId: String, globalUserId: String, groupMembers: [GroupMemberTable]) {
        self.init()
        self.auth = auth
        self.globalUserId = globalUserId
        self.groupId = groupId
        self.groupMembers = groupMembers
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupMembers", "members")]
    }
}
