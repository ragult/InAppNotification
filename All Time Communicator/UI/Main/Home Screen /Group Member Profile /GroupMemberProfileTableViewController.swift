//
//  GroupMemberProfileTableViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 28/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class GroupMemberProfileTableViewController: UITableViewController {
    @IBOutlet var memberProfile: UIImageView!
    @IBOutlet var memberName: UILabel!
    @IBOutlet var roleOfUser: UITextField!
    @IBOutlet var makeAdminLabel: UILabel!
    @IBOutlet var makeAdminSwitch: UISwitch!
    @IBOutlet var addMembersBtn: UIButton!
    @IBOutlet var postEventsBtn: UIButton!
    @IBOutlet var postAlbumsBtn: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var blockMemberBtn: UIButton!
    @IBOutlet var removefromGroupBtn: UIButton!
    var appdelegate = UIApplication.shared.delegate as? AppDelegate

    @IBOutlet var lineLabel: UILabel!
    @IBOutlet var makePublicSwitch: UISwitch!

    @IBOutlet var permissionTop: UILabel!
    @IBOutlet var permissionLabelBottom: UILabel!
    @IBOutlet var topSpaceConstaint: NSLayoutConstraint!
    @IBOutlet var publicViewCell: UITableViewCell!
    @IBOutlet var superAdminBottomSpace: NSLayoutConstraint!

    var groupMembersList = [GroupMemberTable]()
    let user = DatabaseManager.getUser()
    var group = GroupTable()
    var groupId = ""
    var globalUserId = ""
    var sendUpdateDetails = UpdateGroupMembersRequest()
    var profile = GroupMemberTable()
    var oldDataprofile = GroupMemberTable()

    var superAdminText: Bool = false
    let checkMarkImage = UIImage(named: "checkmarkEnabled")
    let checkMarkGray = UIImage(named: "checkmark_gray")

    var access: BottomSaveButton?

    var showPublicView = false

    var isMemberAdmin = false

    fileprivate func setViewDidLoadUI() {
        
        makeAdminLabel.text = "Super Admin"
        makeAdminSwitch.transform = CGAffineTransform(scaleX: 0.72, y: 0.72)
        makePublicSwitch.transform = CGAffineTransform(scaleX: 0.72, y: 0.72)
        
        if let imageUrl = URL(string: profile.thumbUrl) {
            memberProfile.af_setImage(withURL: imageUrl)
        }
        memberName.isUserInteractionEnabled = true
        memberName.text = profile.memberName + " >"
        let tapComments = tableViewtapGesturePress(target: self, action: #selector(goToChats(_:)))
        memberName.addGestureRecognizer(tapComments)
        
        roleOfUser.text = profile.memberTitle
        if profile.album == true {
            postAlbumsBtn.isSelected = true
            buttonSelection()
        }
        if profile.publish == true {
            postEventsBtn.isSelected = true
            buttonSelection()
        }
        if profile.addMember == true {
            addMembersBtn.isSelected = true
            buttonSelection()
        }
        makeAdminSwitch.isOn = false
        print(profile.superAdmin)
        if profile.superAdmin == true {
            makeAdminLabel.text = "Super Admin"
            makeAdminSwitch.isOn = true
            addMembersBtn.isUserInteractionEnabled = false
            postAlbumsBtn.isUserInteractionEnabled = false
            postEventsBtn.isUserInteractionEnabled = false
            
            addMembersBtn.isSelected = true
            postAlbumsBtn.isSelected = true
            postEventsBtn.isSelected = true
            
            buttonSelection()
            postAlbumsBtn.setImage(checkMarkGray, for: .selected)
            postEventsBtn.setImage(checkMarkGray, for: .selected)
            addMembersBtn.setImage(checkMarkGray, for: .selected)
        }
        if profile.publicView == true {
            makePublicSwitch.isOn = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewDidLoadUI()
    }

    fileprivate func setViewWillAppearUI() {
        oldDataprofile = profile
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications
        
        if showPublicView {
            topSpaceConstaint.constant = -20
            superAdminBottomSpace.constant = 10
            
            permissionTop.isHidden = false
            permissionLabelBottom.isHidden = true
            postEventsBtn.isHidden = false
            lineLabel.isHidden = true
            
        } else {
            topSpaceConstaint.constant = 18
            superAdminBottomSpace.constant = 28.5
            permissionTop.isHidden = true
            permissionLabelBottom.isHidden = false
            postEventsBtn.isHidden = true
            lineLabel.isHidden = false
        }
        
        if isMemberAdmin {
            makePublicSwitch.isUserInteractionEnabled = false
            
            makeAdminSwitch.isUserInteractionEnabled = false
            makePublicSwitch.onTintColor = .gray
            
            makeAdminSwitch.onTintColor = .gray
            addMembersBtn.isUserInteractionEnabled = false
            postAlbumsBtn.isUserInteractionEnabled = false
            postEventsBtn.isUserInteractionEnabled = false
        }
        
        publicViewCell.isHidden = true
    }
    
    override func viewWillAppear(_: Bool) {
        setViewWillAppearUI()

    }

    @objc func goToChats(_: tableViewtapGesturePress) {
        var chTable: ChannelTable?
        let chatDisplay = ChannelDisplayObject()

        if profile.groupMemberContactId == "0" || profile.groupMemberContactId == "" {
            chTable = DatabaseManager.getChannelIndex(contactId: profile.groupMemberId, channelType: channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue)

            if chTable == nil {
                let channel = ACDatabaseMethods.createChannelTable(conatctId: profile.groupMemberId, channelType: channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue, globalChannelName: profile.globalUserId)
                let index = DatabaseManager.storeChannelData(channelTable: channel)
                chTable = channel
                chTable?.id = String(index)
            }

            chatDisplay.channelId = (chTable?.id)!
            chatDisplay.globalChannelName = (chTable?.globalChannelName)!
            chatDisplay.channelType = (chTable?.channelType)!
            chatDisplay.lastSenderPhoneBookContactId = (chTable?.contactId)!
            chatDisplay.channelDisplayNames = profile.memberName
            chatDisplay.channelImageUrl = profile.localImagePath

        } else {
            chTable = DatabaseManager.getChannelIndex(contactId: profile.groupMemberContactId, channelType: channelType.ONE_ON_ONE_CHAT.rawValue)
            if chTable == nil {
                let channel = ACDatabaseMethods.createChannelTable(conatctId: profile.groupMemberContactId, channelType: channelType.ONE_ON_ONE_CHAT.rawValue, globalChannelName: profile.globalUserId)
                let index = DatabaseManager.storeChannelData(channelTable: channel)
                chTable = channel
                chTable?.id = String(index)
            }
            let contact = DatabaseManager.getContactIndexforTable(tableIndex: profile.groupMemberContactId)
            chatDisplay.channelId = (chTable?.id)!
            chatDisplay.globalChannelName = (chTable?.globalChannelName)!
            chatDisplay.channelType = (chTable?.channelType)!
            chatDisplay.lastSenderPhoneBookContactId = (chTable?.contactId)!
            chatDisplay.channelDisplayNames = contact?.fullName ?? ""
            chatDisplay.channelImageUrl = contact?.localImageFilePath ?? ""
        }
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
            UserDefaults.standard.set(true, forKey: UserKeys.newIntro)
//            nextVC.loadTableViewData(chnlDetails: chatDisplay)
            nextVC.channelDetails = chatDisplay
            nextVC.customNavigationBar(name: chatDisplay.channelDisplayNames, image: chatDisplay.channelImageUrl, channelTyp: channelType(rawValue: chatDisplay.channelType)!)
            nextVC.displayName = chatDisplay.channelDisplayNames
            nextVC.displayImage = chatDisplay.channelImageUrl
            nextVC.isViewFirstTime = true
            nextVC.isViewFirstTimeLoaded = true
            nextVC.isFromContacts = true
            nextVC.isScrollToBottom = true

            navigationController?.pushViewController(nextVC, animated: true)
        }
    }

    func buttonSelection() {
        if addMembersBtn.isSelected == true {
            addMembersBtn.setImage(checkMarkImage, for: .selected)
        }
        if postEventsBtn.isSelected == true {
            postEventsBtn.setImage(checkMarkImage, for: .selected)
        }
        if postAlbumsBtn.isSelected == true {
            postAlbumsBtn.setImage(checkMarkImage, for: .selected)
        }
    }

    @IBAction func postAlbumsBtnAction(_: Any) {
        if postAlbumsBtn.isSelected == false {
            postAlbumsBtn.isSelected = true
            profile.album = true
        } else {
            postAlbumsBtn.isSelected = false
            profile.album = false
        }
        buttonSelection()
    }

    @IBAction func postEventsBtnAction(_: Any) {
        if postEventsBtn.isSelected == false {
            postEventsBtn.isSelected = true
            profile.publish = true
        } else {
            postEventsBtn.isSelected = false
            profile.publish = false
        }
        buttonSelection()
    }

    @IBAction func addMembersBtnAction(_: Any) {
        if addMembersBtn.isSelected == false {
            addMembersBtn.isSelected = true
            profile.addMember = true
        } else {
            addMembersBtn.isSelected = false
            profile.addMember = false
        }
        buttonSelection()
    }

    @IBAction func makeAdminAction(_: Any) {
        if makeAdminSwitch.isOn == false {
            profile.superAdmin = false
            makeAdminLabel.text = "Super Admin"
            postAlbumsBtn.isSelected = false
            profile.album = false
            postEventsBtn.isSelected = false
            profile.publish = false
            addMembersBtn.isSelected = false
            profile.addMember = false

            buttonSelection()
            addMembersBtn.isUserInteractionEnabled = true
            postAlbumsBtn.isUserInteractionEnabled = true
            postEventsBtn.isUserInteractionEnabled = true

        } else {
            profile.superAdmin = true
            makeAdminLabel.text = "Super Admin"
            postAlbumsBtn.isSelected = true
            profile.album = true
            postEventsBtn.isSelected = true
            profile.publish = true
            addMembersBtn.isSelected = true
            profile.addMember = true
            buttonSelection()
            addMembersBtn.isUserInteractionEnabled = false
            postAlbumsBtn.isUserInteractionEnabled = false
            postEventsBtn.isUserInteractionEnabled = false
            postAlbumsBtn.setImage(checkMarkGray, for: .selected)
            postEventsBtn.setImage(checkMarkGray, for: .selected)
            addMembersBtn.setImage(checkMarkGray, for: .selected)
        }
    }

    @IBAction func makePublicSwitch(_: Any) {
        if makePublicSwitch.isOn == false {
            profile.publicView = false
        } else {
            profile.publicView = true
        }
    }

    @IBAction func blockMemberAction(_: Any) {
        print("clicked block button")
    }

    @IBAction func removeFromGroupAction(_: Any) {
        print("clicked block button")

        if profile.superAdmin == true, isMemberAdmin {
            alert(message: "You cannot remove a Super admin")

        } else {
            let alertController = UIAlertController(title: "Alert", message: labelStrings.groupmemberRemoveAlert, preferredStyle: .alert)
            let exitgroup = UIAlertAction(title: "Remove member", style: .default, handler: { _ in

                self.removeMember()
            })

            let OKAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(exitgroup)

            alertController.addAction(OKAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    func removeMember() {
        Loader.show()
        let addGroupmembers = RemoveGroupMemberRequest()

        addGroupmembers.auth = DefaultDataProcessor().getAuthDetails()
        addGroupmembers.groupId = groupId
        var members: [String] = []
        members.append(profile.globalUserId)
        addGroupmembers.groupMembers = members

        NetworkingManager.removeGroupMember(addGroupMemberModel: addGroupmembers) { (result: Any, sucess: Bool) in
            if let result = result as? AddGroupMemberResponse, sucess {
                print(result)
                let status = result.status ?? ""

                if status != "Exception" {
                    let groupMem = GroupMemberTable()
                    groupMem.globalUserId = self.profile.globalUserId
                    groupMem.groupId = self.group.id
                    groupMem.memberStatus = groupMemberStats.INACTIVE.rawValue
                    DatabaseManager.updateGroupMembersStatus(groupMemebrsTable: groupMem)

                    self.navigationController?.popViewController(animated: true)
                    self.alert(message: "Member Removed Successfully")
                }
            }
            Loader.close()
        }
    }

    @IBAction func saveButtonAction(_: Any) {
        // Code to refresh table view
        if appdelegate != nil {
            if (appdelegate?.isInternetAvailable)! {
                Loader.show()
                profile.memberTitle = roleOfUser.text ?? ""
//                for  member in groupMembersList {
//                    if member.groupMemberId == profile.groupMemberId {
//                        member.addMember = profile.addMember
//                        member.superAdmin = profile.superAdmin
//                        member.events = profile.events
//                        member.album = profile.album
//                        member.publish = profile.publish
//                        member.memberTitle = profile.memberTitle
//                        member.publicView = profile.publicView
//
//                    }
//                }
                let list = [profile]

                let authDetails = DefaultDataProcessor().getAuthDetails()

                let updateGroupMembers = UpdateGroupMembersRequest(auth: authDetails, groupId: groupId, globalUserId: globalUserId, groupMembers: list)
                NetworkingManager.updateGroupMembers(updateGroupMemsModel: updateGroupMembers) { (result: Any, sucess: Bool) in
                    if let result = result as? UpdateGroupMembersResponse, sucess {
                        if sucess {
                            if result.status == "Success" {
                                _ = DatabaseManager.updateGroupMmembers(groupMemebrsTable: self.profile)

                                let chnltyp = ACGroupsProcessingObjectClass.getChannelForGroup(grpType: self.group.groupType)
                                let chnls = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: self.group.groupType)

                                if let chTable = DatabaseManager.getChannelIndex(contactId: self.group.id, channelType: chnls) {
                                    if self.profile.superAdmin {
                                        if self.oldDataprofile.superAdmin != self.profile.superAdmin {
                                            if self.profile.superAdmin {
                                                _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have made \(self.profile.memberName) as Super Admin", messageOtherType: otherMessageType.INFO, senderId: self.group.createdBy, channelId: chTable.id, channel: chTable)
                                            }
                                        }
                                    } else {
                                        if self.oldDataprofile.superAdmin != self.profile.superAdmin {
                                            if !self.profile.superAdmin {
                                                _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have removed \(self.profile.memberName) as Super Admin", messageOtherType: otherMessageType.INFO, senderId: self.group.createdBy, channelId: chTable.id, channel: chTable)
                                            }
                                        }

                                        if self.oldDataprofile.album != self.profile.album {
                                            if self.profile.album {
                                                _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have made \(self.profile.memberName) as Album Admin", messageOtherType: otherMessageType.INFO, senderId: self.group.createdBy, channelId: chTable.id, channel: chTable)
                                            } else {
                                                _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have removed \(self.profile.memberName) as Album Admin", messageOtherType: otherMessageType.INFO, senderId: self.group.createdBy, channelId: chTable.id, channel: chTable)
                                            }
                                        }

                                        if self.oldDataprofile.publish != self.profile.publish {
                                            if self.profile.publish {
                                                _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have granted \(self.profile.memberName) Publish rights", messageOtherType: otherMessageType.INFO, senderId: self.group.createdBy, channelId: chTable.id, channel: chTable)
                                            } else {
                                                _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have revoked \(self.profile.memberName) Publish rights", messageOtherType: otherMessageType.INFO, senderId: self.group.createdBy, channelId: chTable.id, channel: chTable)
                                            }
                                        }
                                        if self.oldDataprofile.addMember != self.profile.addMember {
                                            if self.profile.addMember {
                                                _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have made \(self.profile.memberName) as Member admin", messageOtherType: otherMessageType.INFO, senderId: self.group.createdBy, channelId: chTable.id, channel: chTable)
                                            } else {
                                                _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have removed \(self.profile.memberName) as Member admin", messageOtherType: otherMessageType.INFO, senderId: self.group.createdBy, channelId: chTable.id, channel: chTable)
                                            }
                                        }
                                    }

                                    if self.oldDataprofile.memberTitle != self.profile.memberTitle {
                                        _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have changed the member title of \(self.profile.memberName) to \(self.profile.memberTitle)", messageOtherType: otherMessageType.INFO, senderId: self.group.createdBy, channelId: chTable.id, channel: chTable)
                                    }
                                }
                                self.alert(message: "Group member profile updated successfully")

                            } else {
                                Loader.close()
                                if result.status == "Exception" {
                                    let errorMsg = result.errorMsg[0]
                                    if errorMsg == "IU-100" || errorMsg == "AUT-101" {
                                        self.gotohomePage()
                                    } else if errorMsg == "KCT-1" {
                                        let member = list.first
                                        if (member?.album == true){
                                            self.alert(message: "Members with IOS version cannot be Album Admins")
                                        }
                                        else{
                                            self.alert(message: "Members with iOS version cannot support Group Helpdesk")
                                        }
                                    } else {
                                        self.alert(message: errorStrings.unKnownAlert)
                                    }
                                }
                            }

                        } else {
                            self.alert(message: errorStrings.unKnownAlert)
                        }
                    }
                    Loader.close()
                }

            } else {
                alert(message: "Internet is required")
            }
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection _: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: view.frame.origin.y, width: tableView.frame.size.width, height: 56))
//        footerView.backgroundColor = UIColor.blue
//        saveButton.frame = CGRect(x: saveButton.frame.origin.x, y: saveButton.frame.origin.y, width: saveButton.frame.width, height: footerView.frame.height)
//        saveButton.frame = footerView.frame

//        footerView.addSubview(saveButton)
        return footerView
    }

    // set height for footer
    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return 56
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if isMemberAdmin {
//            if indexPath.row == 0 {
//                return 196
//            } else if indexPath.row == 1 {
//                    return 0
//            } else if indexPath.row == 2 {
//                return 0
//            } else if indexPath.row == 3 {
//                return 0
//            } else {
//                return self.view.frame.height - 250
//            }
//        } else {
        if indexPath.row == 0 {
            return 196
        } else if indexPath.row == 1 {
            if showPublicView {
                return 79
            } else {
                return 0
            }
        } else if indexPath.row == 2 {
            return 79
        } else if indexPath.row == 3 {
            return 151
        } else {
            return 120
        }
//        }
    }
}
