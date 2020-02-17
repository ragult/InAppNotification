//
//  File.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 03/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class PersonRegistrationRequestModel: EVNetworkingObject {
    var auth: RegistrationAuth?
    var fullName: String?
    var dateofBirth: String?
    var monthYearOfBirth: String?
    var gender: String?
    var picture: String?
    var deviceApn: String?
    var deviceApnType: String?
    var registerType: String?
    var socialId: String?
    var deviceMake: String?
    var mobileServiceProvider: String?
    var socialAccessToken: String = ""

    convenience init(auth: RegistrationAuth, monthYearOfBirth: String, picture: String, deviceApn: String, deviceApnType: String, registerType: String, socialId: String, mobileServiceProvider: String, fullName: String, dateofBirth: String, gender: String, deviceMake: String) {
        self.init()
        self.auth = auth

        self.monthYearOfBirth = monthYearOfBirth
        self.picture = picture
        self.deviceApn = deviceApn
        self.deviceApnType = deviceApnType
        self.registerType = registerType
        self.socialId = socialId
        self.deviceMake = deviceMake
        self.mobileServiceProvider = mobileServiceProvider
        self.fullName = fullName
        self.dateofBirth = dateofBirth
        self.gender = gender
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("socialAccessToken", "accessToken")]
    }
}
