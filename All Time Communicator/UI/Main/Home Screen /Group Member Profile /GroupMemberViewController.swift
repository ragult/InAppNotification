//
//  GroupMemberViewController.swift
//  alltimecommunicator
//
//  Created by Lokesh on 12/29/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Foundation
import UIKit

class GroupMemberViewController: UIViewController {
    @IBOutlet var saveButton: UIButton!
    var groupId = ""
    var globalUserId = ""
    var group = GroupTable()
    var groupMembersList = [GroupMemberTable]()
    var profile = GroupMemberTable()
    var showPublicView = false
    var isMemberAdmin = false
    var tableViewController: GroupMemberProfileTableViewController?

    override func viewDidLoad() {
        tableViewController = children[0] as? GroupMemberProfileTableViewController
        tableViewController?.groupId = self.groupId
        tableViewController?.globalUserId = self.globalUserId
        tableViewController?.group = group
        tableViewController?.groupMembersList = groupMembersList
        tableViewController?.profile = profile
        tableViewController?.showPublicView = showPublicView
        tableViewController?.isMemberAdmin = isMemberAdmin
        tableViewController?.viewDidLoad()
        tableViewController?.viewWillAppear(true)
        self.saveButton.frame.origin.x = 0
        self.saveButton.frame.size.width = UIScreen.main.bounds.width
    }

    @IBAction func saveButtonAction(_ sender: Any) {
        tableViewController?.saveButtonAction("")
        
    }
}
