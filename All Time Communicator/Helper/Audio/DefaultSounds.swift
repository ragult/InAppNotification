//
//  DefaultSounds.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 30/05/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import AudioToolbox
import Foundation

class DefaultSound {
    static func eventBusNewMessage() {
        AudioServicesPlaySystemSound(1114)
    }

    static func newBroadcastMessage() {
        AudioServicesPlaySystemSound(1114)
    }

    static func sendNewMessage() {
        AudioServicesPlaySystemSound(1004)
    }

    static func inappNotification() {
        AudioServicesPlaySystemSound(1022)
    }

    static func PushNotification() {
        AudioServicesPlaySystemSound(4162)
        // alert_voicemail_haptic.caf
    }
}
