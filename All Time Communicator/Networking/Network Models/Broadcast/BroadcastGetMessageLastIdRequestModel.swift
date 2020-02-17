
//
//  BroadcastGetMessageLastIdRequestModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 30/03/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation

class BroadcastGetMessageLastIdRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var fetchFor = [BroadcastGetMessagesLastConfirmId]()
}
