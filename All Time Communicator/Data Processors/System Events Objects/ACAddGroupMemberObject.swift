//
//  ACAddGroupMemberObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 29/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class ACAddGroupMemberObject: NSObject {
    var groupMemberId: String = ""
    var groupId: String = ""
    var memberTitle: String = ""
    var memberName: String = ""
    var globalUserId: String = ""
    var phoneNumber: String = ""
    var thumbUrl: String = ""
    var memberStatus: String = ""
    var createdOn: String = ""
    var createdBy: String = ""
    var superAdmin: Bool = false
    var publish: Bool = false
    var events: Bool = false
    var album: Bool = false
    var addMember: Bool = false
}
