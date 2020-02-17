//
//  UpdateUserProfile.swift
//  alltimecommunicator
//
//  Created by Lokesh on 12/20/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Foundation
import EVReflection

class UpdateUserProfile: EVNetworkingObject {
    var auth = GlobalAuth()
    var picture: String = ""
    var fullName: String = ""
    var quote: String = ""

    convenience init(auth: GlobalAuth, picture: String,fullName: String, quote: String) {
        self.init()
        self.auth = auth
        self.picture = picture
        self.fullName = fullName
        self.quote = quote
    }
}
