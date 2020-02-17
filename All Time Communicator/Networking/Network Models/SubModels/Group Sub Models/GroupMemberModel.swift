//
//  GroupMemberModel.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 09/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
class GroupMemberModel: EVNetworkingObject {
    var groupMemberId: String?
    var groupId: String?
    var memberTitle: String?
    var memberName: String?
    var globalUserId: String?
    var phoneNumber: String?
    var thumbUrl: String?
    var publish: String?
    var events: String?
    var album: String?
    var addMember: String?
    var memberStatus: String?
    var createdOn: String?
    var createdBy: String?
    var superAdmin: String?
    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("memberName", "name"), ("phoneNumber", "mobileNo"), ("memberStatus", "status")]
    }
}
