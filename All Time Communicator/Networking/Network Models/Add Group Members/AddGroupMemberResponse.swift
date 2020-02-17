//
//  AddGroupMemberResponse.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 09/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class AddGroupMemberResponse: EncryptedBaseResponseModel {
    var data: CustomData?

    class CustomData: EVNetworkingObject {
        var sys : NSDictionary?
        var chnl : String?
        var src : String?
    }

    override func decryptData(_ decryptedData: String) {
//        data = CustomData.arrayFromJson(decryptedData)

        data = CustomData(json: decryptedData)
    }
}
