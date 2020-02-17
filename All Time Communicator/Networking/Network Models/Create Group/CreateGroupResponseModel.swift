//
//  CreateGroupResponse.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 09/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class createGroupResponseModel: EncryptedBaseResponseModel {
    var data: [CustomData]?

    class CustomData: EVNetworkingObject {
        var groupId: String?
        var channelName: String?
        var qrCode: String?
        var webUrl: String?
        var publicGroupId: String?
        var publicGroupCode: String?
        
    }

    override func decryptData(_ decryptedData: String) {
        data = [CustomData(json: decryptedData)]
    }
}
