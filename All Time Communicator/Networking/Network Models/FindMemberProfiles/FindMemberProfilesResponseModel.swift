//
//  FindMemberProfilesResponseModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 10/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class FindMemberProfilesResponseModel: EncryptedBaseResponseModel {
    var data: [CustomData]?

    class CustomData: FindProfileModel {}

    override func decryptData(_ decryptedData: String) {
        data = CustomData.arrayFromJson(decryptedData)
    }
}
