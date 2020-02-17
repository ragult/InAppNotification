//
//  activeGroupMembersResponse.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 07/03/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
class activeGroupMembersResponse: EVNetworkingObject {
    var groupMemberId: String?
    var groupId: String?
    var memberTitle: String?
    var name: String?
    var globalUserId: String?
    var mobileNo: String?
    var thumbUrl: String?
    var publish: String?
    var events: String?
    var album: String?
    var addMember: String?
    var memberStatus: String?
    var createdOn: String?
    var createdBy: String?
    var superAdmin: String?
    var groupMemberPublicId: String?
    var isPublic: String?
    var publicProfileQrCode: String?
    var displayName: String?
    var quote: String?
    var groupMemberProfileUrl: String?

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupId", "groupId"), ("name", "name"), ("globalUserId", "globalUserId"), ("mobileNo", "mobileNo"), ("memberTitle", "memberTitle"), ("addMember", "addMember"), ("groupMemberPublicId", "groupMemberPublicId"), ("isPublic", "public"), ("groupMemberProfileUrl", "groupMemberProfileUrl"), ("quote", "quote"), ("displayName", "displayName"), ("publicProfileQrCode", "publicProfileQrCode")]
    }
}
