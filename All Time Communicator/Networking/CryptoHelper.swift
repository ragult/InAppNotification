//
//  CryptoHelper.swift
//  alltimecommunicator
//
//  Created by Kamal Wadhwa on 30/11/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import CryptoSwift
import Foundation

class CryptoHelper {
    static func encrypt(input: String) -> String? {
        do {
            guard let key = KeyManager.getKey(),
                let iv = KeyManager.getIV() else { return nil }

            let validatedKey = validateKey(key: key)
            let validatedIV = validateKey(key: iv)

            let encrypted: [UInt8] = try AES(key: validatedKey, iv: validatedIV, padding: .pkcs5).encrypt(Array(input.utf8))

            return encrypted.toBase64()
        } catch {}
        return nil
    }

    static func decrypt(input: String) -> String? {
        do {
            guard let key = KeyManager.getKey(),
                let iv = KeyManager.getIV() else { return nil }

            let validatedKey = validateKey(key: key)
            let validatedIV = validateKey(key: iv)

            let d = Data(base64Encoded: input)
            let decrypted = try AES(key: validatedKey, iv: validatedIV, padding: .pkcs5).decrypt(
                d!.bytes)
            return String(data: Data(decrypted), encoding: .utf8)
        } catch {}
        return nil
    }

    private static func validateKey(key: String) -> String {
        if key.count < 16 {
            return key.padding(toLength: 16, withPad: "0", startingAt: 0)
        }

        return key.truncated(limit: 16, position: .head, leader: "")
    }
}
