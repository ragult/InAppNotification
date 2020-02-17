//
//  UpdateGroupResponse.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 09/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class UpdateGroupResponse: EncryptedBaseResponseModel {
//    var data:customData?
//    class customData:EVNetworkingObject {}
}

class UpdateBroadcastGroupResponse: EncryptedBaseResponseModel {
    var data: [CustomData]?

    class CustomData: EVNetworkingObject {
        var globalMessageId: String?
//        var globalGroupId: String?
        var targetCount: Int?
        var remCount: String?
    }

    override func decryptData(_ decryptedData: String) {
        data = [CustomData(json: decryptedData)]
    }
}

class UpdateBroadcastSyncResponse: EncryptedBaseResponseModel {
    var data: [CustomData]?

    class CustomData : MessageModel {}
    
    override func decryptData(_ decryptedData: String) {
        data = CustomData.arrayFromJson(decryptedData)
    }
}

class MessageModel: EVNetworkingObject {
        var globalMessageId: String?
        var globalGroupId: String?
        var messageType: String?
        var submittedTime: String?
        var attachmentUrl: String?
        var message: NSDictionary?
    }
