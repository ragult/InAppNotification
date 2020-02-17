//
//  AddGroupMember.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 09/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class AddGroupMemberRequest: EVNetworkingObject {
    var auth = GlobalAuth()
    var groupId: String?
    var joinType: String?

    var groupMembers: [String] = []

    convenience init(auth: GlobalAuth, groupId: String, groupUserId _: String, groupMembers: [String], jointype: String) {
        self.init()
        self.auth = auth
        self.groupId = groupId
        joinType = jointype

        self.groupMembers = groupMembers
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupMembers", "members")]
    }
}

class JoinGroupMemberRequest: EVNetworkingObject {
    var auth = GlobalAuth()
    var publicGroupId: String?

    convenience init(auth: GlobalAuth, groupId: String, groupUserId _: String, groupMembers _: [String], jointype _: String) {
        self.init()
        self.auth = auth
        publicGroupId = groupId
    }
}

class RemoveGroupMemberRequest: EVNetworkingObject {
    var auth = GlobalAuth()
    var groupId: String?

    var groupMembers: [String] = []

    convenience init(auth: GlobalAuth, groupId: String, groupUserId _: String, groupMembers: [String]) {
        self.init()
        self.auth = auth
        self.groupId = groupId

        self.groupMembers = groupMembers
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupMembers", "members")]
    }
}

class deleteGroupRequest: EVNetworkingObject {
    var auth = GlobalAuth()
    var groupId: String?

    convenience init(auth: GlobalAuth, groupId: String) {
        self.init()
        self.auth = auth
        self.groupId = groupId
    }
}
