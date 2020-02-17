//
//  DefaultDataProcessor.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 09/05/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class DefaultDataProcessor: NSObject {
    func getAuthDetails() -> GlobalAuth {
        let authDetails = GlobalAuth()
        authDetails.globalUserId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
        authDetails.securityCode = UserDefaults.standard.string(forKey: UserKeys.serverSecurityCode)
        authDetails.deviceId = UserDefaults.standard.string(forKey: UserKeys.serverDeviceId)
        return authDetails
    }

    func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
}
