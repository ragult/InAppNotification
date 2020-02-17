//
//  SigninResponseProfileData.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 21/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection

class SigninResponseProfileData: EVNetworkingObject {
    var name: String?
    var monthYearOfBirth: String?
    var gender: String?
    var dateOfBirth: String?
    var picture: String?
    var globalUserId: String?
    var userQrcode: String?
}
