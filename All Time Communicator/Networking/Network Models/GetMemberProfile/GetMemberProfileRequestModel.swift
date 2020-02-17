//
//  GetMemberProfileRequestModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 12/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class GetMemberProfileRequestModel: EVNetworkingObject {
    var auth = RegistrationAuth()
//    var globalUserId: String?
//    var phoneNumber: String?
    var registrationReference: String?
    var registerType: String?
    convenience init(auth: RegistrationAuth, globalUserId _: String, phoneNumber _: String, registrationReference: String, registerType: String) {
        self.init()
        self.auth = auth
//        self.globalUserId = globalUserId
//        self.phoneNumber = phoneNumber
        self.registrationReference = registrationReference
        self.registerType = registerType
    }
}
