//
//  ContactModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 10/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class ContactModel: EVNetworkingObject, Codable, FetchableRecord, TableRecord, PersistableRecord {
    var phoneNumber: String?
    var id: String?

    convenience init(phoneNumber: String, contactId: String) {
        self.init()
        self.phoneNumber = phoneNumber
        id = contactId
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("phoneNumber", "ph_no"), ("id", "contact_id")]
    }
}
