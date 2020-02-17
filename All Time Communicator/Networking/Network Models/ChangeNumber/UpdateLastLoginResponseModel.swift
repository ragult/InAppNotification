//
//  UpdateLastLoginResponseModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 31/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class UpdateLastLoginResponseModel: EncryptedBaseResponseModel {
    var data: CustomData?

    class CustomData {}

//    override func decryptData(_ decryptedData: String) {
//        self.data = CustomData(json: decryptedData)
//    }
}
