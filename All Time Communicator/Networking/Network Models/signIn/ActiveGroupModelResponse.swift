//
//  ActiveGroupModelResponse.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 07/03/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
class ActiveGroupModelResponse: EVNetworkingObject {
    var groupId: String?
    var channelName: String?
    var name: String?
    var type: String?
    var desc: String?
    var confidentialFlag: String?
    var fullImageUrl: String?
    var thumbnailUrl: String?
    var groupStatus: String?
    var createdOn: String?
    var createdBy: String?
    var createdByThumbUrl: String?
    var createdByMobileNo: String?
    var mapLocationId: String?
    var mapServiceProvider: String?
    var latitude: String?
    var longitude: String?
    var groupLocation: String?
    var groupPublicId: String?
    var address: String?
    var groupCode: String?
    var qrCode: String?
    var webUrl: String?
    var publicGroupCode: String?
    var totalMembers: String?

    var groupMembers = [activeGroupMembersResponse]()
    var albums = [albumModel]()

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupId", "groupId"), ("name", "name"), ("type", "type"), ("desc", "description"), ("createdByThumbUrl", "createdByThumbUrl"), ("createdByMobileNo", "createdByMobileNo"), ("groupMembers", "groupMembers"), ("channelName", "channelName"), ("address", "address")]
    }
}

class albumModel: EVNetworkingObject {
    var albumId: Int?
    var albumName: String?
    var albumCoverUrl: String?
    var createdOn: Int?

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("albumId", "albumId"), ("albumName", "albumName"), ("albumCoverUrl", "albumCoverUrl"), ("createdOn", "createdOn")]
    }
}
