//
//  GetMessagesResponseModel.swift
//  alltimecommunicator
//
//  Created by Nandha on 20/01/20.
//  Copyright © 2020 Droid5. All rights reserved.
//
import EVReflection
import Foundation


import Foundation
import EVReflection

class GetMessagesResponseModel: EncryptedBaseResponseModel {
    var data : [CustomData]?
    
    class CustomData : GetMessagesModel {}

    override func decryptData(_ decryptedData: String) {
        data = CustomData.arrayFromJson(decryptedData)
    }
}

class GetMessagesModel: EVNetworkingObject {
    var globalMessageId: String?
    var globalGroupId: String?
    var mesgSource: String?

}
