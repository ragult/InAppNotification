//
//  BroadcastGetMessageLastTimeStampRequestModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 30/03/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class BroadcastGetMessageLastTimeStampRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var sinceTimeStamp: String?
    var globalGroupId = [String]()
}

class BroadcastSyncModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var received = [String]()
    var required = [String]()
}
