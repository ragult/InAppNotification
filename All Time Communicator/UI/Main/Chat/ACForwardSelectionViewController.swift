//
//  ACForwardSelectionViewController.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 12/06/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACForwardSelectionViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet var lblNoGroup: UILabel!
    @IBOutlet var contactsTable: UITableView!
    @IBOutlet var inviteBtnHeigthConstraint: NSLayoutConstraint!
    @IBOutlet var inviteBtnHeightConstraintIn: NSLayoutConstraint!
    @IBOutlet var grpBtn: UIButton!
    @IBOutlet var grpChatBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet var inviteButton: UIButton!
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    var contactsFromDB = DatabaseManager.getAppContacts()
    let user = DatabaseManager.getUser()
    var filteredData: [ProfileTable] = []
    var delegate: passGroupMembers?
    var secondDelegate: navigatingBackToGroupDetailsVC?
    var existingUsers: [ProfileTable] = []
    var selectedMembers: [ProfileTable] = []

    var notExistingUsers: [ProfileTable] = []
    var groupMembers: [ProfileTable] = []
    var existingUsersCount = 0
    var notExistingUsersCount = 0
    var filter: Bool = false
    var navigating: Bool = false
    var doExistingSelected: Bool = false
    var doNotExistingSelected: Bool = false
    var createGroupFromAddButton: Bool = false
    var groupTitle: String = ""
    var groupID: String = ""
    var groupType: String = ""

    var channels = [ChannelDisplayObject]()
    var selectedChannels = [ChannelDisplayObject]()
    var selectedMsg: MessagesTable?

    var isFromAdhocAdd: Bool = false

    var appdelegate = UIApplication.shared.delegate as? AppDelegate

    var groupDetails: GroupTable!
    var groupmembersFromExistingGroup: [String] = []
    var navigatingFromGroupDetailsViewController: Bool = false
    var nonGroupMembersInExistingContacts: [ProfileTable] = []
    var contactsClass = ACContactsProcessor()
    struct Section {
        static var existingSection = 0
        static var nonExistingSection = 1
    }

    override func viewDidAppear(_: Bool) {
        contactsTable.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        print("Forward page")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContacts()
        print("non existing group members in table  - \(nonGroupMembersInExistingContacts)")
        contactsTable.register(UINib(nibName: "ContactsTableCell", bundle: nil), forCellReuseIdentifier: "Cell")
        let barButtonImage = UIImage(named: "NavSearch")?.withRenderingMode(.alwaysOriginal)
        let searchIconButton = UIBarButtonItem(image: barButtonImage, style: .plain, target: self, action: #selector(contactsSearchButton))
        navigationItem.rightBarButtonItem = searchIconButton
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        contactsTable.allowsMultipleSelection = true

        definesPresentationContext = true
//        if #available(iOS 11.0, *) {
//            self.navigationItem.searchController = searchController
//        } else {
//            // Fallback on earlier versions
//        }

        grpBtn.setTitle("FORWARD", for: .normal)
        inviteButton.isHidden = true
        inviteBtnHeigthConstraint.constant = 0
        inviteBtnHeightConstraintIn.constant = 0
    }

    @objc func refreshData(refreshControl _: UIRefreshControl) {
        // Code to refresh table view
//        if (appdelegate != nil) {
//            if (appdelegate?.isInternetAvailable)! {
//                DispatchQueue.global(qos: .background).async {
//                    // do your job here
//                    self.contactsClass.getContactsAndUpdate (notify:false, completionHandler: {(success)   -> Void in
//                        DispatchQueue.main.async {
//                            // update ui here
//                            self.contactsFromDB = DatabaseManager.getAppContacts()
//                            self.getContacts()
//                            self.contactsTable .reloadData()
//                            self.refreshControl.endRefreshing()
//
//                        }
//                    })
//
//                }
//            } else {
//                self.refreshControl.endRefreshing()
//
//                self.alert(message: "Internet is required")
//            }
//            self.refreshControl.endRefreshing()
//
//        }
    }
}

extension ACForwardSelectionViewController: UIScrollViewDelegate {
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let notExistingUsersRowCount = notExistingUsers.filter { (notExistingUser) -> Bool in notExistingUser.selected }.count
        let existingUsersRowCount = existingUsers.filter { (existingUser) -> Bool in existingUser.selected }.count
        let p = longPressGesture.location(in: contactsTable)
        let indexPath = contactsTable.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        } else if notExistingUsersRowCount > 0 || existingUsersRowCount > 0 {
            print("ROWS SELECTED. TAP GESTURE DENIED")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            print("Long press on row, at \(indexPath!.row)")

            if indexPath?.section == Section.existingSection {
                existingUsers[indexPath?.row ?? -1].selected = true
                grpChatBtnHeightConstraint.constant = 50.5
                if navigatingFromGroupDetailsViewController == true {
                    groupMembers.append(nonGroupMembersInExistingContacts[indexPath?.row ?? -1])
                } else {
                    groupMembers.append(existingUsers[indexPath?.row ?? -1])
                }
                contactsTable.reloadData()
            } else if indexPath?.section == Section.nonExistingSection {
                notExistingUsers[indexPath?.row ?? -1].selected = true
                grpChatBtnHeightConstraint.constant = 0.0
                contactsTable.reloadData()
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            // Fallback on earlier versions
        }
        if createGroupFromAddButton == true || navigatingFromGroupDetailsViewController == true {
            print("navigating from create Group or navigating from group details view conroller")
        } else {
            if targetContentOffset.pointee.y < scrollView.contentOffset.y {
                inviteBtnHeigthConstraint.constant = 0
                inviteBtnHeightConstraintIn.constant = 0
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            } else {
                inviteBtnHeigthConstraint.constant = 40
                inviteBtnHeightConstraintIn.constant = 28
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                inviteButton.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        filteredData = existingUsers + notExistingUsers

        if !searchText.isEmpty {
            print("Non - filered Data count\(filteredData.count)")
            filter = true
            filteredData = filteredData.filter { (profiles) -> Bool in
                profiles.fullName.lowercased().starts(with: searchText.lowercased())
            }
            contactsTable.reloadData()
            print(" filered Data count\(filteredData.count)")
        }
        contactsTable.reloadData()
    }

    func searchBarTextDidBeginEditing(_: UISearchBar) {
        searchController.searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filter = false
        contactsTable.scrollsToTop = true
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.text = ""
        searchBar.resignFirstResponder()
        contactsTable.reloadData()
    }
}

// Mark: Tableview methods
extension ACForwardSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section2HeaderView = UIView(frame: CGRect(x: 0, y: 0, width: contactsTable.frame.width, height: 48))
        section2HeaderView.layer.borderWidth = 1
        section2HeaderView.layer.borderColor = UIColor.lightGray.cgColor
        section2HeaderView.backgroundColor = .white
        // Button1
        let selectAllButton = UIButton(frame: CGRect(x: 6.0, y: 10, width: 150, height: 16))
        if section == 0 {
            selectAllButton.setTitle("Recent chats", for: .normal)

        } else {
            selectAllButton.setTitle("Contacts", for: .normal)
        }
        selectAllButton.titleLabel!.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
        selectAllButton.setTitleColor(UIColor(r: 33, g: 140, b: 141), for: .normal)

//        if existingUsersRowCount > 0 {
//            print("EXISTING USERS SELECTED ALREADY. REMOVE ALL AND TRY AGAIN")
//        } else {
//            selectAllButton.addTarget(self, action: #selector(selectAll_CancelButtonAction), for: .touchUpInside)
//        }

        let sendButton = UIButton(frame: CGRect(x: section2HeaderView.frame.width - 80, y: 10, width: 60, height: 16))
        sendButton.setTitle("", for: .normal)
        sendButton.titleLabel!.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 14)
        sendButton.setTitleColor(UIColor(r: 33, g: 140, b: 141), for: .normal)
//        if notExistingUsersRowCount == 0 {
//            print("SELECTED CONTACTS ARE ZERO. PLEASE SELECT CONTACTS")
//        } else {
        ////            sendButton.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
//        }

        sendButton.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        section2HeaderView.addSubview(selectAllButton)
        section2HeaderView.addSubview(sendButton)
        return section2HeaderView
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 36
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return channels.count
        } else {
            return existingUsers.count
        }
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactsTableCell = contactsTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactsTableCell

        contactsTableCell.chatButtonInSectionOne.setBackgroundImage(UIImage(named: "icon_member_selected"), for: .normal)
        contactsTableCell.chatButtonInSectionOne.isHidden = true
        contactsTableCell.inviteButtonInSectionTwo.isHidden = true
        contactsTableCell.profileTickMark.isHidden = true

        contactsTableCell.memberPhonNumber.isHidden = true

        if indexPath.section == 0 {
            let channelTableList = channels[indexPath.row]

            if channelTableList.channelDisplayNames == "" {
                // find channel type
                switch channelTableList.channelType {
                case channelType.GROUP_CHAT.rawValue:
                    let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                    channelTableList.channelDisplayNames = (groupTable?.groupName)!

                    if groupTable?.localImagePath == "" {
                        channelTableList.channelImageUrl = ""

                        if groupTable?.fullImageUrl != "" {
                            //                        self.downLoadImagesforIndexPath(index: indexPath, downloadImage: (groupTable?.fullImageUrl)!, groupId: (groupTable?.id)!)
                        }

                    } else {
                        channelTableList.channelImageUrl = (groupTable?.localImagePath)!
                    }
                    contactsTableCell.memberProfielImage.image = UIImage(named: "icon_DefaultGroup")
                    //                if groupTable?.confidentialFlag == "1" {
                    //                    channelCell.confidentialImage.isHidden = false
                    //                    channels[indexPath.row].isConfidential = (groupTable?.confidentialFlag)!
                    //                }

                case channelType.ONE_ON_ONE_CHAT.rawValue:
                    let contactDetails = DatabaseManager.getContactDetails(phoneNumber: channelTableList.lastSenderPhoneBookContactId)
                    channelTableList.channelDisplayNames = (contactDetails?.fullName)!
                    if contactDetails?.localImageFilePath == "" {
                        channelTableList.channelImageUrl = ""
                        if contactDetails?.picture != "" {
                            downLoadImagesforIndexPathforUser(index: indexPath, downloadImage: (contactDetails?.picture)!, userId: (contactDetails?.id)!)
                        }
                    } else {
                        channelTableList.channelImageUrl = (contactDetails?.localImageFilePath)!
                    }
                    contactsTableCell.memberProfielImage.image = UIImage(named: "icon_DefaultMutual")
                case channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue:

                    let contactDetails = DatabaseManager.getGroupMemberIndexForMemberId(groupId: channelTableList.lastSenderPhoneBookContactId)
                    let groupDetail = DatabaseManager.getGroupDetail(groupGlobalId: (contactDetails?.groupId)!)

                    channelTableList.channelDisplayNames = (contactDetails?.memberName)! + "( via \(groupDetail?.groupName ?? ""))"

                    if contactDetails?.localImagePath == "" {
                        channelTableList.channelImageUrl = ""
                        if contactDetails?.thumbUrl != "" {
                            //                        self.downLoadGroupMemberImagesforIndexPath(index: indexPath, downloadImage: (contactDetails?.thumbUrl)!, groupId: (contactDetails?.globalUserId)!)
                        }
                    } else {
                        channelTableList.channelImageUrl = (contactDetails?.localImagePath)!
                    }
                    contactsTableCell.memberProfielImage.image = UIImage(named: "icon_DefaultMutual")

                case channelType.ADHOC_CHAT.rawValue:
                    let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                    channelTableList.channelDisplayNames = (groupTable?.groupName)!

                    if groupTable?.localImagePath == "" {
                        channelTableList.channelImageUrl = ""
                        if groupTable?.fullImageUrl != "" {
                            //                        self.downLoadImagesforIndexPath(index: indexPath, downloadImage: (groupTable?.fullImageUrl)!, groupId: (groupTable?.id)!)
                        }
                    } else {
                        channelTableList.channelImageUrl = (groupTable?.localImagePath)!
                    }

                    contactsTableCell.memberProfielImage.image = UIImage(named: "icon_DefaultGroup")

                default:
                    print("do nothing")
                    contactsTableCell.memberProfielImage.image = UIImage(named: "icon_DefaultGroup")
                }
            }

            contactsTableCell.memberName.text = channelTableList.channelDisplayNames
            if channelTableList.channelImageUrl != "" {
                contactsTableCell.memberProfielImage.image = load(attName: channelTableList.channelImageUrl)
            } else {
                if channelTableList.channelType == channelType.GROUP_CHAT.rawValue || channelTableList.channelType == channelType.ADHOC_CHAT.rawValue {
                    contactsTableCell.memberProfielImage.image = UIImage(named: "icon_DefaultGroup")
                } else {
                    contactsTableCell.memberProfielImage.image = LetterImageGenerator.imageWith(name: channelTableList.channelDisplayNames, randomColor: .gray)
                }
            }
            if selectedChannels.contains(channels[indexPath.row]) {
                contactsTableCell.chatButtonInSectionOne.isHidden = false
                contactsTableCell.isSelected = true
                contactsTableCell.inviteButtonInSectionTwo.isHidden = true

            } else {
                contactsTableCell.isSelected = false
                contactsTableCell.chatButtonInSectionOne.isHidden = true
                if channelTableList.channelType == channelType.GROUP_CHAT.rawValue || channelTableList.channelType == channelType.ADHOC_CHAT.rawValue {
                    contactsTableCell.inviteButtonInSectionTwo.isHidden = false
                    contactsTableCell.inviteButtonInSectionTwo.setTitle("Group", for: .normal)
                    if channelTableList.channelType == channelType.ADHOC_CHAT.rawValue {
                        contactsTableCell.inviteButtonInSectionTwo.setTitle("Adhoc", for: .normal)
                    }
                    contactsTableCell.inviteButtonInSectionTwo.setTitleColor(.lightGray, for: .normal)
                }
            }

        } else {
            contactsTableCell.memberPhonNumber.text = existingUsers[indexPath.row].phoneNumber
            contactsTableCell.memberName.text = existingUsers[indexPath.row].fullName

            contactsTableCell.memberProfielImage.image = LetterImageGenerator.imageWith(name: existingUsers[indexPath.row].fullName, randomColor: .gray)

            if existingUsers[indexPath.row].localImageFilePath == "" {
                if existingUsers[indexPath.row].picture != "" {
                    downLoadImagesforIndexPathforUser(index: indexPath, downloadImage: existingUsers[indexPath.row].picture, userId: existingUsers[indexPath.row].id)

                } else {
                    contactsTableCell.memberProfielImage.image = LetterImageGenerator.imageWith(name: existingUsers[indexPath.row].fullName, randomColor: .gray)
                }
            } else {
                contactsTableCell.memberProfielImage.image = load(attName: existingUsers[indexPath.row].localImageFilePath)
            }

            //  section 0 - Selected
            if selectedMembers.contains(existingUsers[indexPath.row]) {
                contactsTableCell.chatButtonInSectionOne.isHidden = false

            } else {
                contactsTableCell.chatButtonInSectionOne.isHidden = true
            }
        }

        return contactsTableCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        grpChatBtnHeightConstraint.constant = 50.5
        let contactsTableCell = tableView.cellForRow(at: indexPath) as! ContactsTableCell

        if indexPath.section == 0 {
            if selectedChannels.contains(channels[indexPath.row]) {
                contactsTableCell.chatButtonInSectionOne.isHidden = true
                selectedChannels.remove(object: channels[indexPath.row])
                let channelTableList = channels[indexPath.row]
                if channelTableList.channelType == channelType.GROUP_CHAT.rawValue || channelTableList.channelType == channelType.ADHOC_CHAT.rawValue {
                    contactsTableCell.inviteButtonInSectionTwo.isHidden = false
                    contactsTableCell.inviteButtonInSectionTwo.setTitle("Group", for: .normal)
                    if channelTableList.channelType == channelType.ADHOC_CHAT.rawValue {
                        contactsTableCell.inviteButtonInSectionTwo.setTitle("Adhoc", for: .normal)
                    }
                    contactsTableCell.inviteButtonInSectionTwo.setTitleColor(.lightGray, for: .normal)
                }

            } else {
                contactsTableCell.inviteButtonInSectionTwo.isHidden = true
                contactsTableCell.chatButtonInSectionOne.isHidden = false
                selectedChannels.append(channels[indexPath.row])
            }
        } else {
            if selectedMembers.contains(existingUsers[indexPath.row]) {
                selectedMembers.remove(object: existingUsers[indexPath.row])

                contactsTableCell.chatButtonInSectionOne.isHidden = true

            } else {
                contactsTableCell.chatButtonInSectionOne.isHidden = false
                selectedMembers.append(existingUsers[indexPath.row])
            }
        }

        if selectedChannels.count > 0 || selectedMembers.count > 0 {
            grpChatBtnHeightConstraint.constant = 50.5

        } else {
            grpChatBtnHeightConstraint.constant = 0
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let contactsTableCell = tableView.cellForRow(at: indexPath) as! ContactsTableCell

        if indexPath.section == 0 {
            if selectedChannels.contains(channels[indexPath.row]) {
                contactsTableCell.chatButtonInSectionOne.isHidden = true

                selectedChannels.remove(object: channels[indexPath.row])
                let channelTableList = channels[indexPath.row]
                if channelTableList.channelType == channelType.GROUP_CHAT.rawValue || channelTableList.channelType == channelType.ADHOC_CHAT.rawValue {
                    contactsTableCell.inviteButtonInSectionTwo.isHidden = false
                    contactsTableCell.inviteButtonInSectionTwo.setTitle("Group", for: .normal)
                    if channelTableList.channelType == channelType.ADHOC_CHAT.rawValue {
                        contactsTableCell.inviteButtonInSectionTwo.setTitle("Adhoc", for: .normal)
                    }
                    contactsTableCell.inviteButtonInSectionTwo.setTitleColor(.lightGray, for: .normal)
                }

            } else {
                contactsTableCell.chatButtonInSectionOne.isHidden = false
                contactsTableCell.inviteButtonInSectionTwo.isHidden = true

                selectedChannels.append(channels[indexPath.row])
            }
        } else {
            if selectedMembers.contains(existingUsers[indexPath.row]) {
                selectedMembers.remove(object: existingUsers[indexPath.row])

                contactsTableCell.chatButtonInSectionOne.isHidden = true

            } else {
                contactsTableCell.chatButtonInSectionOne.isHidden = false
                selectedMembers.append(existingUsers[indexPath.row])
            }
        }

        if selectedChannels.count > 0 || selectedMembers.count > 0 {
            grpChatBtnHeightConstraint.constant = 50.5

        } else {
            grpChatBtnHeightConstraint.constant = 0
        }
    }

    @objc func selectAll_CancelButtonAction(_: Any) {
        let totalRowsInSectionOne = notExistingUsers.count
        let totalSelectedRowsInSectionOne = notExistingUsers.filter { (notExistingUser) -> Bool in notExistingUser.selected }.count
        print(" total row count in section 1 \(totalRowsInSectionOne)")
        if totalSelectedRowsInSectionOne == totalRowsInSectionOne {
            for row in notExistingUsers {
                contactsTable.allowsMultipleSelection = false
                row.selected = false
                contactsTable.reloadData()
            }
        } else {
            for row in notExistingUsers {
                contactsTable.allowsMultipleSelection = true
                row.selected = true
                contactsTable.reloadData()
            }
        }
    }

    func downLoadImagesforIndexPathforUser(index: IndexPath, downloadImage: String, userId: String) {
        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: downloadImage, refernce: userId, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

        DispatchQueue.global(qos: .background).async {
            ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in

                DatabaseManager.updateMemberPhotoForId(picture: path, userId: success.refernce)

                self.existingUsers[index.row].localImageFilePath = path
                DispatchQueue.main.async { () in
                    self.contactsTable.reloadRows(at: [index], with: .none)
                }

            })
        }
    }
}

// Mark: Action functions
extension ACForwardSelectionViewController {
    @objc func contactsSearchButton() {
//        if self.lblNoGroup.isHidden == true {
//            if #available(iOS 11.0, *) {
//                navigationItem.hidesSearchBarWhenScrolling = false
//                UIView.animate(withDuration:0.3) {
//                    self.view.layoutIfNeeded()
//                }
//            } else {
//                // Fallback on earlier versions
//            }
//        } else {
//            self.alert(message: "No Members available to search")
//        }
    }

    @objc func sendButtonAction(_: Any) {
        let string = "Hello, world!"
        let url = URL(string: "https://nshipster.com")!
        let image = UIImage(named: "chat")
        let pdf = Bundle.main.url(forResource: "Q4 Projections",
                                  withExtension: "pdf")

        let activityViewController =
            UIActivityViewController(activityItems: [string, url, image ?? "", pdf ?? ""],
                                     applicationActivities: nil)

        present(activityViewController, animated: true) {
            // ...
        }
    }

    @IBAction func FabInviteButtonAction(_: Any) {}

    func processMessage(msg: MessagesTable, chnls: [ChannelDisplayObject]) {
        for chnl in chnls {
            let directMsgObj = ACCommunicationMsgObject()

            let timestamp = NSDate().timeIntervalSince1970 * 1000 * 10000
            let finalTS = String(format: "%.0f", timestamp)

            directMsgObj.senderUUID = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
            directMsgObj.senderPhone = UserDefaults.standard.value(forKey: UserKeys.userPhoneNumber) as? String

            directMsgObj.action = useractionType.NEW.rawValue
            directMsgObj.channelType = chnl.channelType
            directMsgObj.contSource = ""
            directMsgObj.sent_utc = finalTS
            directMsgObj.globalMsgId = (directMsgObj.senderUUID)! + (directMsgObj.sent_utc)!

            if chnl.channelType == channelType.TOPIC_GROUP.rawValue {
                directMsgObj.globalTopicId = directMsgObj.globalMsgId
            } else {
                directMsgObj.globalTopicId = ""
            }

            directMsgObj.msgType = msg.messageType

            if directMsgObj.msgType == messagetype.TEXT.rawValue {
                directMsgObj.text = msg.text
                directMsgObj.other = ""

            } else if directMsgObj.msgType == messagetype.OTHER.rawValue {
                directMsgObj.other = msg.attachmentsExtra
                directMsgObj.otherType = msg.otherType
                directMsgObj.text = msg.text

            } else {
                directMsgObj.other = ""

                directMsgObj.media = msg.attachmentsExtra
                directMsgObj.text = msg.text
            }
            var grpName = ""
            directMsgObj.receiver = chnl.globalChannelName
            if chnl.channelType != channelType.ONE_ON_ONE_CHAT.rawValue || chnl.channelType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: chnl.lastSenderPhoneBookContactId)
                directMsgObj.receiver = groupTable?.groupGlobalId
                grpName = groupTable?.groupName ?? ""
            }
            directMsgObj.replyToId = ""
            directMsgObj.refGroupId = ""
            directMsgObj.isForward = true
            
            var userLocalId = UserDefaults.standard.value(forKey: UserKeys.userContactIndex) as? String

            if chnl.channelType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                let contactDetails = DatabaseManager.getGroupMemberIndexForMemberId(groupId: chnl.lastSenderPhoneBookContactId)
                userLocalId = (contactDetails?.groupMemberId)!
            } else if chnl.channelType == channelType.GROUP_CHAT.rawValue || chnl.channelType == channelType.TOPIC_GROUP.rawValue {
                let userGlobalId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String

                let GroupMemberIndex = DatabaseManager.getGroupMemberIndex(groupId: chnl.lastSenderPhoneBookContactId, globalUserId: userGlobalId!)

                userLocalId = GroupMemberIndex?.groupMemberId
            }

            let chtlistMsg = createMessageContextObject(commObj: directMsgObj, localChannelId: chnl.channelId, localSenderId: userLocalId ?? "", channel: chnl.globalChannelName)

            ACMessageSenderClass.saveToDbAndPublish(communicationObject: directMsgObj, messageContext: chtlistMsg.messageContext!, groupName: grpName, oldMsg: msg)
        }
    }

    func createMessageContextObject(commObj: ACCommunicationMsgObject, localChannelId: String, localSenderId: String, channel: String) -> chatListObject {
        let ChatList = chatListObject()
        let message = ACMessageContextObject()
        let messageItem = MessageItem()

        message.senderGlobalId = commObj.senderUUID
        message.senderPhoneNo = commObj.senderPhone
        message.channelType = commObj.channelType.map { channelType(rawValue: $0) }!
        message.localChanelId = localChannelId
        message.messageType = commObj.msgType.map { messagetype(rawValue: $0) }!
        message.messageState = messageState.SENDER_UNSENT
        message.isMine = true
        message.action = useractionType.NEW
        message.groupType = groupType

        message.replyToId = commObj.replyToId
        message.msgTimeStamp = commObj.sent_utc!
        message.globalMsgId = commObj.globalMsgId
        message.localSenderId = localSenderId
        message.globalChannelName = channel
        message.receiverGlobalId = commObj.receiver
        message.isForward = commObj.isForward
        ChatList.messageContext = message

        return ChatList
    }

    @IBAction func createGroupButtonAction(_: Any) {
        if selectedMembers.count > 0 {
            for member in selectedMembers {
                var chTable = DatabaseManager.getChannelIndex(contactId: member.id, channelType: channelType.ONE_ON_ONE_CHAT.rawValue)
                if chTable == nil {
                    let channel = ACDatabaseMethods.createChannelTable(conatctId: member.id, channelType: channelType.ONE_ON_ONE_CHAT.rawValue, globalChannelName: member.globalUserId)
                    let index = DatabaseManager.storeChannelData(channelTable: channel)
                    chTable = channel
                    chTable?.id = String(index)
                }

                let channelDIspObj = ChannelDisplayObject()
                channelDIspObj.channelId = (chTable?.id)!
                channelDIspObj.globalChannelName = (chTable?.globalChannelName)!
                channelDIspObj.channelType = (chTable?.channelType)!
                channelDIspObj.lastSenderPhoneBookContactId = (chTable?.contactId)!

                selectedChannels.append(channelDIspObj)
            }
        }

        if selectedChannels.count > 0 {
            Loader.show()
            processMessage(msg: selectedMsg!, chnls: selectedChannels)
            Loader.close()

            let channel = selectedChannels.last
            goToNextView(channelTableList: channel!)
        }
    }

    func goToNextView(channelTableList: ChannelDisplayObject, isConfidential: Bool = false) {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
            if let navigator = navigationController {
                nextViewController.hidesBottomBarWhenPushed = true
                nextViewController.navigationController?.navigationBar.isHidden = true
                nextViewController.getIsConfidential = isConfidential
                if channelTableList.channelDisplayNames == "" {
                    // find channel type
                    switch channelTableList.channelType {
                    case channelType.GROUP_CHAT.rawValue:
                        let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                        channelTableList.channelDisplayNames = (groupTable?.groupName)!
                        channelTableList.channelImageUrl = (groupTable?.localImagePath)!

                    case channelType.ONE_ON_ONE_CHAT.rawValue:
                        let contactDetails = DatabaseManager.getContactDetails(phoneNumber: channelTableList.lastSenderPhoneBookContactId)
                        channelTableList.channelDisplayNames = (contactDetails?.fullName)!
                        channelTableList.channelImageUrl = (contactDetails?.localImageFilePath)!

                    case channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue:
                        let contactDetails = DatabaseManager.getGroupMemberIndexForMemberId(groupId: channelTableList.lastSenderPhoneBookContactId)
                        channelTableList.channelDisplayNames = (contactDetails?.memberName)!
                        channelTableList.channelImageUrl = (contactDetails?.localImagePath)!

                    case channelType.ADHOC_CHAT.rawValue:
                        let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                        channelTableList.channelDisplayNames = (groupTable?.groupName)!
                        channelTableList.channelImageUrl = (groupTable?.localImagePath)!
                    case channelType.TOPIC_GROUP.rawValue:
                        let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                        channelTableList.channelDisplayNames = (groupTable?.groupName)!
                        channelTableList.channelImageUrl = (groupTable?.localImagePath)!

                    default:
                        print("do nothing")
                    }
                }
                //                nextViewController.loadTableViewData(chnlDetails: channelTableList)

                nextViewController.customNavigationBar(name: channelTableList.channelDisplayNames, image: channelTableList.channelImageUrl, channelTyp: channelType(rawValue: channelTableList.channelType)!)
                nextViewController.displayName = channelTableList.channelDisplayNames
                nextViewController.displayImage = channelTableList.channelImageUrl
                nextViewController.isViewFirstTime = true
                nextViewController.isViewFirstTimeLoaded = true
                nextViewController.isScrollToBottom = true
                nextViewController.isFromContacts = true

                nextViewController.channelDetails = channelTableList

                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    func gotToConatctsChat(profileList: ProfileTable) {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
            var chTable = DatabaseManager.getChannelIndex(contactId: profileList.id, channelType: channelType.ONE_ON_ONE_CHAT.rawValue)
            if chTable == nil {
                let channel = ACDatabaseMethods.createChannelTable(conatctId: profileList.id, channelType: channelType.ONE_ON_ONE_CHAT.rawValue, globalChannelName: profileList.globalUserId)
                let index = DatabaseManager.storeChannelData(channelTable: channel)
                chTable = channel
                chTable?.id = String(index)
            }

            let channelDIspObj = ChannelDisplayObject()
            channelDIspObj.channelId = (chTable?.id)!
            channelDIspObj.globalChannelName = (chTable?.globalChannelName)!
            channelDIspObj.channelType = (chTable?.channelType)!
            channelDIspObj.lastSenderPhoneBookContactId = (chTable?.contactId)!
            nextVC.channelDetails = channelDIspObj

            //                    nextVC.loadTableViewData(chnlDetails: channelDIspObj)

            nextVC.customNavigationBar(name: profileList.fullName, image: profileList.localImageFilePath, channelTyp: channelType(rawValue: channelDIspObj.channelType)!)
            nextVC.displayName = profileList.fullName
            nextVC.displayImage = profileList.localImageFilePath
            nextVC.isViewFirstTime = true
            nextVC.isViewFirstTimeLoaded = true
            nextVC.isFromContacts = true
            nextVC.isScrollToBottom = true

            navigationController?.pushViewController(nextVC, animated: true)
            //                    contactsTable.reloadData()
        }
    }

    func getContacts() {
        existingUsers = contactsFromDB?.filter { (existingContacts: ProfileTable) -> Bool in
            existingContacts.isMember
        } ?? []
        existingUsersCount = existingUsers.count

        getChannelDetails()
    }

    func getChannelDetails() {
        let channelList = DatabaseManager.fetchChannel()
        channels.removeAll()
        if channelList != nil {
            if channelList?.count == 0 {
            } else {
                for channel in channelList! {
                    if (channel.channelType == channelType.GROUP_CHAT.rawValue) || (channel.channelType == channelType.ADHOC_CHAT.rawValue) {
                        if let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channel.contactId) {
                            if groupTable.groupStatus != groupStats.INACTIVE.rawValue {
                                let channelObject = ChannelDisplayObject()
                                channelObject.channelId = channel.id
                                channelObject.globalChannelName = channel.globalChannelName

                                channelObject.channelType = channel.channelType
                                channelObject.unseenCount = channel.unseenCount
                                channelObject.lastMessageIdOfChannel = channel.lastSavedMsgid
                                channelObject.lastMessageTime = channel.lastMsgTime
                                if channel.lastMsgTime == "" {
                                    channelObject.lastMessageTime = DatabaseManager.getgroupCreatedTimeStamp(contactId: channel.contactId)!
                                }
                                channelObject.lastSenderPhoneBookContactId = channel.contactId
                                channels.append(channelObject)
                            }
                        }
                    } else {
                        let channelObject = ChannelDisplayObject()
                        channelObject.channelId = channel.id
                        channelObject.globalChannelName = channel.globalChannelName

                        channelObject.channelType = channel.channelType
                        channelObject.unseenCount = channel.unseenCount
                        channelObject.lastMessageIdOfChannel = channel.lastSavedMsgid
                        channelObject.lastMessageTime = channel.lastMsgTime
                        if channel.lastMsgTime == "" {
                            channelObject.lastMessageTime = DatabaseManager.getgroupCreatedTimeStamp(contactId: channel.contactId)!
                        }
                        channelObject.lastSenderPhoneBookContactId = channel.contactId
                        channels.append(channelObject)
                    }
                }

                channels = channels.sorted(by: {
                    $0.lastMessageTime.compare($1.lastMessageTime) == .orderedDescending
                })
            }
        }
        contactsTable.reloadData()
    }
}
