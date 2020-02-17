//
//  OtpResponseModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 03/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//
import EVReflection

class SendOtpResponseModel: BaseResponseModel {
    var data: CustomData?

    class CustomData: EVNetworkingObject {
        var otp: NSNumber?
        var deviceId: String?

        override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
            return [("otp", "OTP"), ("deviceId", "deviceId")]
        }
    }

    func saveDeviceData() {
        if let deviceID = data?.deviceId {
            UserDefaults.standard.setValue(deviceID, forKey: UserKeys.serverDeviceId)
        }
    }
}
