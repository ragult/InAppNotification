//
//  verifyOTPResponseModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 03/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//
import EVReflection

class VerifyOtpResponseModel: BaseResponseModel {
    var data: CustomData?

    class CustomData: EVNetworkingObject {
        var phoneNumberLength: String?
        var registerType: String?
        var loginSessionId: String?
        var deviceId: String?
        var mailRef: String?

        override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
            return [("phoneNumberLength", "varPhoneLength"), ("deviceId", "deviceId"), ("mailRef", "mailRef")]
        }
    }

    func saveDeviceData() {
        if let deviceID = data?.deviceId {
            UserDefaults.standard.setValue(deviceID, forKey: UserKeys.serverDeviceId)
        }
    }
}
