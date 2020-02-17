//
//  SignIndataModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 21/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//
import EVReflection

class SignIndataModel: EVNetworkingObject {
    var securityCode: String?
    var phoneNoChallengeId: String?
    var doRegister: String?
    var totalRecords: String?
    var pubnubSubscriberKey: String?
    var pubnubPublisherKey: String?
    var pubnubaccessKey: String?
    var globalUserId: String?
    var profileData: CustomData?
    var activeGroupModel: [CustomGroupData]?
    var awsAccessKey: String?
    var defaultGroupAdminTitle: String?
    var awsSecretKey: String?
    var gooApiKey : String?
    
    class CustomGroupData: ActiveGroupModelResponse {}

    class CustomData: SigninResponseProfileData {}

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [
            ("pubnubSubscriberKey", "sKey"),
            ("pubnubPublisherKey", "pKey"),
            ("awsAccessKey", "AWS_Access_Key"),
            ("awsSecretKey", "AWS_Secret_Key"),
            ("defaultGroupAdminTitle", "defaultGroupAdminTitle"),
            ("pubnubaccessKey", "accessKey"),
        ]
    }
}
             
