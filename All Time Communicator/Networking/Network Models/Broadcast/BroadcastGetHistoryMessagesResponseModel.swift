//
//  BroadcastGetHistoryMessagesResponseModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 30/03/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection

class BroadcastGetHistoryMessagesResponseModel: BaseResponseModel {
    var data: CustomData?

    class CustomData: SignIndataModel {}
}