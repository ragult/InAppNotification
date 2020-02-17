//
//  GetGroupResponseModel.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 13/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class GetGroupResponseModel: EncryptedBaseResponseModel {
    var data = GroupModel()

    override func decryptData(_ decryptedData: String) {
        data = GroupModel(json: decryptedData)
    }
}

class GetPublicGroupResponseModel: EncryptedBaseResponseModel {
    var data: PublicGroupModel?

    override func decryptData(_ decryptedData: String) {
        data = PublicGroupModel(json: decryptedData)
    }
}

class PublicGroupModel: EVNetworkingObject {
    var name: String?
    var groupPublicId: String?
    var mapLocationId: String?

    var mapServiceProvider: String?
    var latitude: String?
    var longitude: String?

    var groupdescription: String?
    var fullImageUrl: String?
    var thumbnailUrl: String?

    var createdOn: String?
    var qrCode: String?
    var totalMembers: String?

    var members: [publicMember]?

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupdescription", "description")]
    }
}

class publicMember: EVNetworkingObject {
    var groupMemberPublicId: String?
    var memberTitle: String?
    var name: String?
    var thumbUrl: String?
    var isPublic: String?

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("isPublic", "public")]
    }
}
