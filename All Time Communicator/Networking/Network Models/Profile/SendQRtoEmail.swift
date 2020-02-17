//
//  SendQRtoEmail.swift
//  alltimecommunicator
//
//  Created by Ragul kts on 29/01/20.
//  Copyright © 2020 Droid5. All rights reserved.
//

import Foundation
import EVReflection

class SendQRtoEmail : EVNetworkingObject {
    var auth = GlobalAuth()
    var email: String = ""
    
    convenience init(auth: GlobalAuth, email: String) {
        self.init()
        self.auth = auth
        self.email = email
    }
}
