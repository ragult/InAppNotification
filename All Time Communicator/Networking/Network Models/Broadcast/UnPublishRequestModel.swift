//
//  UnPublishRequestModel.swift
//  alltimecommunicator
//
//  Created by Ragul kts on 31/01/20.
//  Copyright © 2020 Droid5. All rights reserved.
//

import EVReflection
import Foundation
class UnPublishRequestModel : EVNetworkingObject {
    var auth = GlobalAuth()
    var groupId: String?
    var globalMessageId: String?
   

    convenience init(auth: GlobalAuth, groupId: String, globalMessageId _: String) {
        self.init()
        self.auth = auth
        self.groupId = groupId
        self.globalMessageId = globalMessageId
    }

}
