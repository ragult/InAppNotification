//
//  File.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 09/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class GetActiveGroupsRequest: EVNetworkingObject {
    var auth = GlobalAuth()
    convenience init(auth: GlobalAuth) {
        self.init()
        self.auth = auth
    }
}
