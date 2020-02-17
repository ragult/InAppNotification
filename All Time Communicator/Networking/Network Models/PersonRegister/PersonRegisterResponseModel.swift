//
//  PersonRegisterResponseModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 03/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class PersonRegisterResponseModel: EncryptedBaseResponseModel {
    var data: [CustomData]?

    override func decryptData(_ decryptedData: String) {
        data = [CustomData(json: decryptedData)]
    }

    class CustomData: EVNetworkingObject {
        var globalId: String?
        var securityCode: String?
        var pubnubSubscriberKey: String?
        var pubnubPublisherKey: String?
        var pubnubaccessKey: String?
        var userQRCode: String?
        var awsAccessKey: String?
        var awsSecretKey: String?
        var defaultGroupAdminTitle: String?
        var googleApiKey: String?

        override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
            return [("globalId", "global_id"),
                    ("pubnubSubscriberKey", "sKey"),
                    ("pubnubPublisherKey", "pKey"),
                    ("pubnubaccessKey", "accessKey"),
                    ("userQRCode", "userQrcode"),
                    ("awsAccessKey", "AWS_Access_Key"),
                    ("awsSecretKey", "AWS_Secret_Key"),
                    ("defaultGroupAdminTitle", "defaultGroupAdminTitle"),
                    ("googleApiKey", "gooApiKey")]
        }
    }

    func updateSharedSecretKeys() {
        if let code = data?.first?.securityCode,
            let deviceID = UserDefaults.standard.string(forKey: UserKeys.serverDeviceId) {
            KeyManager.setSharedSecretKey(key: deviceID, iv: code)
        }

        if let pubnubaccessKey = data?.first?.pubnubaccessKey {
            UserDefaults.standard.set(pubnubaccessKey, forKey: UserKeys.pubnubAccessKey)
        }
    }
}
