//
//  CreateAdhocChatRequestModel.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 11/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import EVReflection
import UIKit

class CreateAdhocChatRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var title: String = ""
    var members: NSDictionary = [:]

    convenience init(auth: GlobalAuth, name: String, groupMembers: NSDictionary) {
        self.init()
        self.auth = auth
        title = name
        members = groupMembers
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("title", "title")]
    }
}

class AddMembersAdhocChatRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var title: String = ""
    var members: NSArray = []
    var newjoiners: NSArray = []
    var channelName: String = ""

    convenience init(auth: GlobalAuth, name: String, groupMembers: NSArray, newMembers: NSArray) {
        self.init()
        self.auth = auth
        title = name
        members = groupMembers
        newjoiners = newMembers
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("title", "title")]
    }
}

class ExitMembersAdhocChatRequestModel: EVNetworkingObject {
    var auth = GlobalAuth()
    var deleteGroup: String = ""
    var channelName: String = ""
}
