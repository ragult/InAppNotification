//
//  SendBroadcastRequestModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 16/03/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
class SendBroadcastRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var groupId: String?
    var mesgtype: String?
    var otherType: String?
    var attachment: String?
    var data: NSMutableDictionary?

    convenience init(auth: GlobalAuth, groupId: String, groupType _: String) {
        self.init()
        self.auth = auth
        self.groupId = groupId
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("attachment", "attachment-url")]
    }
}
