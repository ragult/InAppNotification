//
//  KeyManager.swift
//  alltimecommunicator
//
//  Created by Kamal Wadhwa on 30/11/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Foundation

class KeyManager {
    static func getKey() -> String? {
        return UserDefaults.standard.string(forKey: SharedSecret.key)
    }

    static func getIV() -> String? {
        return UserDefaults.standard.string(forKey: SharedSecret.iv)
    }

    static func setSharedSecretKey(key: String, iv: String) {
        UserDefaults.standard.setValue(key, forKey: SharedSecret.key)
        UserDefaults.standard.setValue(iv, forKey: SharedSecret.iv)
//        UserDefaults.standard.synchronize()
    }

    static func clear() {
        UserDefaults.standard.setValue("", forKey: SharedSecret.key)
        UserDefaults.standard.setValue("", forKey: SharedSecret.iv)
        UserDefaults.standard.synchronize()
    }
}
