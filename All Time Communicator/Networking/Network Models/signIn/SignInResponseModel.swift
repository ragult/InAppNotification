//
//  SignInResponseModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 21/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection

class SignInResponseModel: EncryptedBaseResponseModel {
    var data: CustomData?

    class CustomData: SignIndataModel {}

    override func decryptData(_ decryptedData: String) {
        data = CustomData(json: decryptedData)
        updateSharedSecretKeys()
    }

    func updateSharedSecretKeys() {
        guard let isRequiredRegisteration = data?.doRegister,
            isRequiredRegisteration != "true" else { return }

        if let code = data?.securityCode,
            let deviceID = UserDefaults.standard.string(forKey: UserKeys.serverDeviceId) {
            KeyManager.setSharedSecretKey(key: deviceID, iv: code)
        }

        if let pubnubaccessKey = data?.pubnubaccessKey {
            UserDefaults.standard.set(pubnubaccessKey, forKey: UserKeys.pubnubAccessKey)
        }
    }
}
