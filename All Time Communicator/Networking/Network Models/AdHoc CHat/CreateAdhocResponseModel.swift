//
//  CreateAdhocResponseModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 12/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import UIKit

class CreateAdhocResponseModel: EncryptedBaseResponseModel {
    var data: CustomData?

    class CustomData: EVNetworkingObject {
        var channel: String?
    }
    
    override func decryptData(_ decryptedData: String) {
        data = CustomData(json: decryptedData)
    }
}
