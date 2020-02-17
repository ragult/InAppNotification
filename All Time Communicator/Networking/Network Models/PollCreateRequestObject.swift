//
//  PollCreateRequestObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 01/04/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import Foundation
class PollCreateRequestObject: EVNetworkingObject {
    var auth = GlobalAuth()
    var question: String = ""
    var pollEndDate: String = ""
    var pollChoicetyp: String = ""
    var choices: NSMutableArray = []
}

class createPollResponseModel: EncryptedBaseResponseModel {
    var data: [CustomData]?

    class CustomData: EVNetworkingObject {
        var pollId: String?
        var pollQuestion: String = ""
        var pollType: String = ""
        var pollEndDate: String = ""
        var createdBy: String = ""
        var choices = [GetPollDataChoices]()
    }

    override func decryptData(_ decryptedData: String) {
        data = [CustomData(json: decryptedData)]
    }
}

class GetPollDataRequestObject: EVNetworkingObject {
    var auth = GlobalAuth()
    var pollId: String = ""
    var groupType: Int = 0
}

class GetPollDataResponseObject: EncryptedBaseResponseModel {
    var data: [CustomData]?

    class CustomData: EVNetworkingObject {
        var pollQuestion: String = ""
        var pollType: String = ""
        var pollEndDate: String = ""
        var createdBy: String = ""
        var choices = [GetPollDataChoices]()
    }

    override func decryptData(_ decryptedData: String) {
        data = [CustomData(json: decryptedData)]
    }
}

class GetPollDataChoices: EVNetworkingObject {
    var choiceId: String = ""
    var choiceText: String = ""
    var choiceImage: String = ""
}

class submitPollIdRequestObject: EVNetworkingObject {
    var auth = GlobalAuth()
    var pollId: String = ""
    var pollChoiceId: String = ""
    var groupType: Int = 0
}

class SubmitPollDataResponseObject: EncryptedBaseResponseModel {
    var data: [CustomData]?

    class CustomData: EVNetworkingObject {}

    override func decryptData(_ decryptedData: String) {
        data = [CustomData(json: decryptedData)]
    }
}

class PollStatusResponseObject: EncryptedBaseResponseModel {
    var data: CustomData?

    class CustomData: EVNetworkingObject {
        var pollstats = [GetPollDataVoteCount]()
    }

    override func decryptData(_ decryptedData: String) {
        data = CustomData(json: decryptedData)
    }
}

class GetPollDataVoteCount: EVNetworkingObject {
    var choiceId: String = ""
    var count: String = ""
}
