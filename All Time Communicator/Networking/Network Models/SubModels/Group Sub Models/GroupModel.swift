//
//  GetGroupModel.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 13/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class GroupModel: EVNetworkingObject {
    var groupId: String?
    var groupGlobalId: String?

    var groupName: String?
    var groupType: String?
    var groupDescription: String?
    var confidentialFlag: String?
    var fullImageUrl: String?
    var thumnailIUrl: String?
    var groupStatus: String?
    var createdOn: String?
    var createdBy: String?
    var createdByThumbnailUrl: String?
    var createdByMobileNumber: String?
    var mapLocationId: String?
    var mapServiceProvider: String?
    var latitude: String?
    var longitude: String?
    var address: String?
    
    var qrCode: String?
    var webUrl: String?
    var publicGroupCode: String?
    var groupPublicId: String?
    var groupCode: String?
    var qrurl: String?
    var groupMembers = [GroupMemberModel]()
    
    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupGlobalId", "groupId"), ("groupName", "name"), ("groupType", "type"), ("memberName", "name"), ("phoneNumber", "mobileNo"), ("groupStatus", "status"), ("groupDescription", "description"), ("createdByThumbnailUrl", "createdByThumbUrl"), ("createdByMobileNumber", "createdByMobileNo"), ("groupMembers", "members"), ("mapLocationId", "mapLocationId"), ("mapServiceProvider", "mapServiceProvider"), ("longitude", "longitude"), ("latitude", "latitude"),("groupPublicId","publicGroupId")]
    }
}
