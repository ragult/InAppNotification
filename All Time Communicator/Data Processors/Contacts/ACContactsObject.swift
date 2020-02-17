//
//  ACContactsObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 26/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class ACContactsObject: EVNetworkingObject {
    var phoneNumber: String = ""
    var fullName: String = ""
    var globalId: String = ""
    var syncStatus: ContactSyncStatus = ContactSyncStatus.NO_Action

    convenience init(phoneNumber: String, name: String, status: ContactSyncStatus, globalId _: String) {
        self.init()
        self.phoneNumber = phoneNumber
        fullName = name
        globalId = name

        syncStatus = status
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("name", "fullName")]
    }
}
