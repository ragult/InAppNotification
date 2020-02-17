//
//  ProfileModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 12/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class FindProfileModel: EVNetworkingObject {
    var nickName: String?
    var fullName: String?
    var dateOfBirth: String?
    var picture: String?
    var phoneNumber: String?
    var emailId: String?
    var deviceApn: String?
    var deviceApnType: String?
    var city: String?
    var zipCode: String?
    var isoCode: String?
    var longitude: String?
    var countryCode: String?
    var countryIsoCode: String?
    var globalUserId: String?
    var userStatus: String?
    var contactId: String?

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [
            ("nickName", "nick_name"),
            ("fullName", "name"),
            ("dateOfBirth", "dateOfBirth"),
            ("phoneNumber", "phoneNumber"),
            ("emailId", "email_id"),
            ("zipCode", "zip_code"),
            ("globalUserId", "globalUserId"),
            ("countryCode", "country_code"),
            ("isoCode", "iso_code"),
            ("deviceApn", "device_apn"),
            ("deviceApnType", "device_apn_type"),
            ("contactId", "contactId"),
            ("userStatus", "status"),
        ]
    }
}
