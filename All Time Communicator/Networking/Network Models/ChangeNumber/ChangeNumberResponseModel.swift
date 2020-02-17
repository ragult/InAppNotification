//
//  ChangeNumberResponseModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 18/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class ChangeNumberResponseModel: EncryptedBaseResponseModel {
    var data: CustomData?

    class CustomData {}

//    override func decryptData(_ decryptedData: String) {
//        self.data = CustomData(json: decryptedData)
//    }
}
