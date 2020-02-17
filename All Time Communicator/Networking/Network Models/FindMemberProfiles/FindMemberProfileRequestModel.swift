//
//  FindMemberProfileRequestModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 10/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class FindMemberProfileRequestModel: EVNetworkingObject {
    var phoneNumbers: [ContactModel] = []
    var notifyFriend: Bool = false
    var auth = GlobalAuth()

    convenience init(auth: GlobalAuth, phoneNumbers: [ContactModel]?) {
        self.init()
        self.auth = auth
        self.phoneNumbers = phoneNumbers ?? []
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("phoneNumbers", "phone_numbers"), ("id", "contact_id")]
    }
}
