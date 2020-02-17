//
//  GUserProfile.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 01/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class GUserProfile: UIViewController {
    @IBOutlet var tableview: UITableView!
    var group = GroupTable()
    var groupMemberName = ""
    var groupMemberProfile = ""
    var memberDetails = UpdateGroupMembersRequest()

    override func viewDidLoad() {
        super.viewDidLoad()
        memberDetails.globalUserId = group.createdBy
        memberDetails.groupId = group.groupId
        tableview.register(UINib(nibName: "GroupUserProfileCell", bundle: nil), forCellReuseIdentifier: "cell1")
        tableview.register(UINib(nibName: "RoleOfUserCell", bundle: nil), forCellReuseIdentifier: "cell2")
        tableview.register(UINib(nibName: "AddUsersAdminsCell", bundle: nil), forCellReuseIdentifier: "cell3")
        tableview.register(UINib(nibName: "RemoveBlockUserCell", bundle: nil), forCellReuseIdentifier: "cell4")
        tableview.allowsSelection = false
        tableview.allowsMultipleSelection = false
    }

    @objc func didTapPostAlbums() {
        print("Taped PostsOnly")
        let cell = tableview.cellForRow(at: IndexPath(row: 0, section: 2)) as! AddUsersAdminsCell
        cell.postAlbumsImage.isHighlighted = !cell.postAlbumsImage.isHighlighted
    }

    @objc func didTapPostEvents() {
        print("Taped add Admins")
        let cell = tableview.cellForRow(at: IndexPath(row: 0, section: 2)) as! AddUsersAdminsCell
        cell.postEventsImage.isHighlighted = !cell.postEventsImage.isHighlighted
    }

    @objc func didTapAddMembers() {
        print("Taped Add users")
        let cell = tableview.cellForRow(at: IndexPath(row: 0, section: 2)) as! AddUsersAdminsCell
        cell.addUsersImage.isHighlighted = !cell.addUsersImage.isHighlighted
    }

    @objc func didTapRemoveFromGroup() {
        print("Taped remove From group")
//        let cell = tableview.cellForRow(at: IndexPath(row: 0, section: 3)) as! RemoveBlockUserCell
    }

    @objc func didTapBlock() {
        print("Taped Block")
//        let cell = tableview.cellForRow(at: IndexPath(row: 0, section: 3)) as! RemoveBlockUserCell
    }

    func makeAdmin() {
        let makeAdminCell = tableview.cellForRow(at: IndexPath(row: 0, section: 1)) as! RoleOfUserCell
        // make group admin cell
        makeAdminCell.makeAdminSwitch.isOn = !makeAdminCell.makeAdminSwitch.isOn
        print(makeAdminCell.makeAdminSwitch)
    }

    @IBAction func saveButtonAction(_: Any) {
        print(memberDetails)
    }
}

extension GUserProfile: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell1 = tableview.dequeueReusableCell(withIdentifier: "cell1") as! GroupUserProfileCell
        let cell2 = tableview.dequeueReusableCell(withIdentifier: "cell2") as! RoleOfUserCell
        let cell3 = tableview.dequeueReusableCell(withIdentifier: "cell3") as! AddUsersAdminsCell
        let cell4 = tableview.dequeueReusableCell(withIdentifier: "cell4") as! RemoveBlockUserCell
        let postAlbumsGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPostAlbums))
        let postEventsGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPostEvents))
        let addUsersGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddMembers))
        let removeFromGroupGesture = UITapGestureRecognizer(target: self, action: #selector(didTapRemoveFromGroup))
        let blockFromGroupGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBlock))
        cell3.postAlbumsStack.addGestureRecognizer(postAlbumsGesture)
        cell3.postEventsStack.addGestureRecognizer(postEventsGesture)
        cell3.addUsersStack.addGestureRecognizer(addUsersGesture)
        cell4.removeFromGroupStack.addGestureRecognizer(removeFromGroupGesture)
        cell4.blockStack.addGestureRecognizer(blockFromGroupGesture)

        if indexPath.row == 0, indexPath.section == 0 {
            // memberImage and image and title
            cell1.groupMemName.text = groupMemberName
            if let imageUrl = URL(string: groupMemberProfile) {
                cell1.profileImage.af_setImage(withURL: imageUrl)
            }
            return cell1
        } else if indexPath.row == 0, indexPath.section == 1 {
            makeAdmin()
            return cell2
        } else if indexPath.row == 0, indexPath.section == 2 {
            return cell3
        } else {
            return cell4
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0, indexPath.section == 0 {
            return 180

        } else if indexPath.row == 0, indexPath.section == 1 {
            return 64
        } else if indexPath.row == 0, indexPath.section == 2 {
            return 136

        } else {
            return 94
        }
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 4
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if section == 1 {
            return 48
        } else if section == 2 {
            return 54
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerTitle = UILabel(frame: CGRect(x: 28, y: 20, width: tableView.bounds.size.width, height: 16))
        headerTitle.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        headerView.addSubview(headerTitle)
        if section == 1 {
            headerTitle.text = "Member Title"
            let borderBottom = UIView(frame: CGRect(x: 16, y: 53, width: tableView.bounds.size.width - 38, height: 1.0))
            borderBottom.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.0)
            headerView.addSubview(borderBottom)
            return headerView

        } else if section == 2 {
            headerTitle.text = "PERMISSIONS"
            let borderTop = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 1.0))
            borderTop.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.0)
            headerView.addSubview(borderTop)
            headerTitle.textColor = .lightGray
            return headerView
        } else if section == 3 {
            let borderTop = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 1.0))
            borderTop.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.0)
            headerView.addSubview(borderTop)

            return headerView
        } else { return nil }
    }
}
