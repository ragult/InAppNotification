import Contacts
import UIKit

protocol passGroupMembers {
    func groupMembersToPass(members: NSArray, btnTitle: Bool)
}

protocol navigatingBackToGroupDetailsVC {
    func navigated(navigated: Bool)
}

class ACAddGroupMembersViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet var lblNoGroup: UILabel!
    @IBOutlet var contactsTable: UITableView!
    @IBOutlet var inviteBtnHeigthConstraint: NSLayoutConstraint!
    @IBOutlet var inviteBtnHeightConstraintIn: NSLayoutConstraint!
    @IBOutlet var grpBtn: UIButton!
    @IBOutlet var grpChatBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet var inviteButton: UIButton!
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    let store = CNContactStore()
    var contactsFromDB = DatabaseManager.getAppContacts()
    let user = DatabaseManager.getUser()
    var filteredData: [ProfileTable] = []
    var updateGroupMembers: [GroupMemberTable] = []
    var delegate: passGroupMembers?
    var secondDelegate: navigatingBackToGroupDetailsVC?
    var existingUsers: [ProfileTable] = []
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
    var grpType: String = ""

    var isFromAdhocAdd: Bool = false

    var appdelegate = UIApplication.shared.delegate as? AppDelegate

    var groupDetails: GroupTable!
    var groupmembersFromExistingGroup: [String] = []
    var navigatingFromGroupDetailsViewController: Bool = false
    var nonGroupMembersInExistingContacts: [ProfileTable] = []
    var refreshControl = UIRefreshControl()
    var contactsClass = ACContactsProcessor()
    struct Section {
        static var existingSection = 0
        static var nonExistingSection = 1
    }

    override func viewDidAppear(_: Bool) {
        contactsTable.reloadData()
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

        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }

        grpBtn.setTitle("ADD", for: .normal)
        inviteButton.isHidden = true
        inviteBtnHeigthConstraint.constant = 0
        inviteBtnHeightConstraintIn.constant = 0

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        contactsTable.addSubview(refreshControl) // not required when using UITableViewController
    }

    @objc func refreshData(refreshControl _: UIRefreshControl) {
        // Code to refresh table view
        if appdelegate != nil {
            if (appdelegate?.isInternetAvailable)! {
                DispatchQueue.global(qos: .background).async {
                    // do your job here
                    self.contactsClass.getContactsAndUpdate(notify: false, completionHandler: { (_) -> Void in
                        DispatchQueue.main.async {
                            // update ui here
                            self.contactsFromDB = DatabaseManager.getAppContacts()
                            self.getContacts()
                            self.contactsTable.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    })
                }
            } else {
                refreshControl.endRefreshing()

                alert(message: "Internet is required")
            }
            refreshControl.endRefreshing()
        }
    }
}

extension ACAddGroupMembersViewController: UIScrollViewDelegate {
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
extension ACAddGroupMembersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let notExistingUsersRowCount = notExistingUsers.filter { (notExistingUser) -> Bool in notExistingUser.selected }.count
        let existingUsersRowCount = existingUsers.filter { (existingUser) -> Bool in existingUser.selected }.count

        let section2HeaderView = UIView(frame: CGRect(x: 0, y: 0, width: contactsTable.frame.width, height: 48))
        section2HeaderView.layer.borderWidth = 1
        section2HeaderView.layer.borderColor = UIColor.lightGray.cgColor
        section2HeaderView.backgroundColor = .white
        // Button1
        let selectAllButton = UIButton(frame: CGRect(x: 16.0, y: 10, width: 150, height: 16))
        selectAllButton.setTitle("Select All/Cancel", for: .normal)
        selectAllButton.titleLabel!.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
        selectAllButton.setTitleColor(UIColor(r: 33, g: 140, b: 141), for: .normal)

        if existingUsersRowCount > 0 {
            print("EXISTING USERS SELECTED ALREADY. REMOVE ALL AND TRY AGAIN")
        } else {
            selectAllButton.addTarget(self, action: #selector(selectAll_CancelButtonAction), for: .touchUpInside)
        }

        let sendButton = UIButton(frame: CGRect(x: section2HeaderView.frame.width - 80, y: 10, width: 60, height: 16))
        sendButton.setTitle("SEND", for: .normal)
        sendButton.titleLabel!.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 14)
        sendButton.setTitleColor(UIColor(r: 33, g: 140, b: 141), for: .normal)
        if notExistingUsersRowCount == 0 {
            print("SELECTED CONTACTS ARE ZERO. PLEASE SELECT CONTACTS")
        } else {
            sendButton.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        }

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
        return 1
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 36
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filter == true {
            return filteredData.count
        } else {
            if section == Section.existingSection {
                if navigatingFromGroupDetailsViewController == true {
                    nonGroupMembersInExistingContacts = existingUsers.filter { (profile: ProfileTable) -> Bool in
                        print(groupmembersFromExistingGroup)
//                        if nonGroupMembersInExistingContacts.count == 0
//                        {
//                            self.lblNoGroup.isHidden = false
//                        }
//                        else
//                        {
//                            self.lblNoGroup.isHidden = true
//                        }
                        let temp = !groupmembersFromExistingGroup.contains(where: { (member) -> Bool in
                            profile.globalUserId == member
                        })
                        return temp
                    }
                    if nonGroupMembersInExistingContacts.count == 0 {
                        lblNoGroup.isHidden = false
                    } else {
                        lblNoGroup.isHidden = true
                    }
                    return nonGroupMembersInExistingContacts.count
                } else {
                    return existingUsers.count
                }
            }

            return notExistingUsersCount
        }
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactsTableCell = contactsTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactsTableCell
        contactsTableCell.chatButtonInSectionOne.setBackgroundImage(UIImage(named: "ChatHead"), for: .normal)
        contactsTableCell.chatButtonInSectionOne.setBackgroundImage(UIImage(named: "chat"), for: .selected)
        contactsTableCell.chatButtonInSectionOne.isHidden = true
        contactsTableCell.inviteButtonInSectionTwo.isHidden = true
        contactsTableCell.profileTickMark.isHidden = true
        if filter == true {
            contactsTableCell.memberPhonNumber.text = filteredData[indexPath.row].phoneNumber
            contactsTableCell.memberName.text = filteredData[indexPath.row].fullName
            contactsTableCell.memberProfielImage.image = UIImage(named: "icon_DefaultMutual")

            if filteredData[indexPath.row].selected == true {
                contactsTable.allowsMultipleSelection = true
                contactsTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                contactsTableCell.chatButtonInSectionOne.isHidden = false
                //                    contactsTableCell.chatButtonInSectionOne.isSelected = true
                contactsTableCell.chatButtonInSectionOne.setBackgroundImage(UIImage(named: "icon_member_selected"), for: .normal)

                print("group members ------ \(groupMembers)")
            } else if filteredData[indexPath.row].selected == false {
                contactsTable.deselectRow(at: indexPath, animated: false)
                contactsTableCell.chatButtonInSectionOne.isHidden = true
                contactsTableCell.chatButtonInSectionOne.isSelected = false
                if groupMembers.count == 0 {
                    grpChatBtnHeightConstraint.constant = 0.0
                }
            }

        } else {
            if indexPath.section == Section.existingSection {
                contactsTableCell.chatButtonInSectionOne.isHidden = false
                if navigatingFromGroupDetailsViewController == true {
                    contactsTableCell.memberPhonNumber.text = nonGroupMembersInExistingContacts[indexPath.row].phoneNumber
                    contactsTableCell.memberName.text = nonGroupMembersInExistingContacts[indexPath.row].fullName
                    if let imageUrl = URL(string: nonGroupMembersInExistingContacts[indexPath.row].picture) {
                        contactsTableCell.memberProfielImage.af_setImage(withURL: imageUrl)
                    } else {
                        contactsTableCell.memberProfielImage.image = LetterImageGenerator.imageWith(name: nonGroupMembersInExistingContacts[indexPath.row].fullName, randomColor: .gray)
                    }

                } else {
                    contactsTableCell.memberProfielImage.image = LetterImageGenerator.imageWith(name: existingUsers[indexPath.row].fullName, randomColor: .gray)
                    contactsTableCell.memberPhonNumber.text = existingUsers[indexPath.row].phoneNumber
                    contactsTableCell.memberName.text = existingUsers[indexPath.row].fullName

                    if existingUsers[indexPath.row].localImageFilePath == "" {
                        if existingUsers[indexPath.row].picture != "" {
                            downLoadImagesforIndexPathforUser(index: indexPath, downloadImage: existingUsers[indexPath.row].picture, userId: existingUsers[indexPath.row].id)

                        } else {
                            contactsTableCell.memberProfielImage.image = LetterImageGenerator.imageWith(name: existingUsers[indexPath.row].fullName, randomColor: .gray)
                        }
                    } else {
                        contactsTableCell.memberProfielImage.image = load(attName: existingUsers[indexPath.row].localImageFilePath)
                    }
                }
                //  section 0 - Selected
                if existingUsers[indexPath.row].selected == true {
                    contactsTable.allowsMultipleSelection = true
                    contactsTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    contactsTableCell.chatButtonInSectionOne.isHidden = false
//                    contactsTableCell.chatButtonInSectionOne.isSelected = true
                    contactsTableCell.chatButtonInSectionOne.setBackgroundImage(UIImage(named: "icon_member_selected"), for: .normal)

                    print("group members ------ \(groupMembers)")
                } else if existingUsers[indexPath.row].selected == false {
                    contactsTable.deselectRow(at: indexPath, animated: false)
                    contactsTableCell.chatButtonInSectionOne.isHidden = true
                    contactsTableCell.chatButtonInSectionOne.isSelected = false
                    if groupMembers.count == 0 {
                        grpChatBtnHeightConstraint.constant = 0.0
                    }
                }
            } else {
//                self.lblNoGroup.isHidden = false
                contactsTableCell.memberPhonNumber.text = notExistingUsers[indexPath.row].phoneNumber
                contactsTableCell.memberName.text = notExistingUsers[indexPath.row].fullName
                contactsTableCell.memberProfielImage.image = UIImage(named: "icon_DefaultMutual")

                // section 1 - selected
                if notExistingUsers[indexPath.row].selected == true {
                    contactsTable.allowsMultipleSelection = true
                    contactsTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    contactsTableCell.inviteButtonInSectionTwo.isHidden = true
                    contactsTableCell.memberProfielImage.image = nil
                    contactsTableCell.profileTickMark.isHidden = false
                    contactsTableCell.memberProfielImage.backgroundColor = UIColor(r: 33, g: 140, b: 141)
                } else if notExistingUsers[indexPath.row].selected == false {
                    contactsTable.deselectRow(at: indexPath, animated: false)
                    contactsTableCell.inviteButtonInSectionTwo.isHidden = false
                    contactsTableCell.memberProfielImage.image = UIImage(named: "icon_DefaultMutual")
                    contactsTableCell.profileTickMark.isHidden = true
                }
            }
        }
        return contactsTableCell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        grpChatBtnHeightConstraint.constant = 50.5

        if filter == true {
            let index = existingUsers.firstIndex(of: filteredData[indexPath.row])
            existingUsers[index!].selected = true
            filteredData[indexPath.row].selected = true
            groupMembers.append(filteredData[indexPath.row])

        } else {
            existingUsers[indexPath.row].selected = true
            if navigatingFromGroupDetailsViewController == true {
                groupMembers.append(nonGroupMembersInExistingContacts[indexPath.row])
            } else {
                groupMembers.append(existingUsers[indexPath.row])
            }
        }

        contactsTable.reloadData()
    }

    func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if filter == true {
            let index = existingUsers.firstIndex(of: filteredData[indexPath.row])
            existingUsers[index!].selected = false
            filteredData[indexPath.row].selected = false

            for member in groupMembers {
                if member.globalUserId == filteredData[indexPath.row].globalUserId {
                    groupMembers.remove(object: member)
                    print("group members ------ \(groupMembers)")
                }
            }

        } else {
            contactsTable.reloadData()
            let sectionNumber = indexPath.section
            let notExistingUsersRowCount = notExistingUsers.filter { (notExistingUser) -> Bool in notExistingUser.selected }.count
            let existingUsersRowCount = existingUsers.filter { (existingUser) -> Bool in existingUser.selected }.count
            if existingUsersRowCount == -1 {
                if sectionNumber == Section.existingSection {
                    doExistingSelected = false
                    contactsTable.reloadData()
                } else if notExistingUsersRowCount == -1 {
                    if sectionNumber == Section.nonExistingSection {
                        doNotExistingSelected = false
                        contactsTable.reloadData()
                    }
                }
            }
            if sectionNumber == Section.existingSection {
                if existingUsersRowCount <= 0 || groupMembers.count == 0 {
                    existingUsers[indexPath.row].selected = false
                    contactsTable.allowsSelection = false
                    print("group members ------ \(groupMembers)")
                    contactsTable.reloadData()
                } else {
                    existingUsers[indexPath.row].selected = false
                    for member in groupMembers {
                        if member.globalUserId == existingUsers[indexPath.row].globalUserId {
                            groupMembers.remove(object: member)
                            print("group members ------ \(groupMembers)")
                        }
                    }
                    //            contactsTable.reloadData()
                }
            } else if sectionNumber == Section.nonExistingSection {
                if notExistingUsersRowCount <= 0 {
                    notExistingUsers[indexPath.row].selected = false
                    contactsTable.allowsSelection = false
                    contactsTable.reloadData()
                } else {
                    notExistingUsers[indexPath.row].selected = false
                    contactsTable.reloadData()
                }
            }
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
extension ACAddGroupMembersViewController {
    @objc func contactsSearchButton() {
        if lblNoGroup.isHidden == true {
            if #available(iOS 11.0, *) {
                navigationItem.hidesSearchBarWhenScrolling = false
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            } else {
                // Fallback on earlier versions
            }
        } else {
            alert(message: "No Members available to search")
        }
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

    @IBAction func FabInviteButtonAction(_: Any) {
        if filter == false {
            if appdelegate != nil {
                if (appdelegate?.isInternetAvailable)! {
                    Loader.show()
                    DispatchQueue.global(qos: .background).async {
                        // do your job here
                        self.contactsClass.getContactsAndUpdate(notify: false, completionHandler: { (_) -> Void in
                            DispatchQueue.main.async {
                                // update ui here
                                self.contactsFromDB = DatabaseManager.getContacts()
                                self.getContacts()
                                self.contactsTable.reloadData()
                                self.refreshControl.endRefreshing()
                                Loader.close()
                            }
                        })
                    }
                } else {
                    alert(message: "Internet is required")
                }
            }

            inviteBtnHeigthConstraint.constant = 0
            inviteBtnHeightConstraintIn.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.inviteButton.layoutIfNeeded()
            }
        }
    }

    @IBAction func createGroupButtonAction(_: Any) {
        if navigatingFromGroupDetailsViewController == true {
            if groupMembers.count > 0 {
                if appdelegate != nil {
                    if (appdelegate?.isInternetAvailable)! {
                        Loader.show()

                        if isFromAdhocAdd {
                            let dictionary = NSMutableDictionary()
                            var members: [String] = []
                            for member in groupMembers {
                                members.append(member.globalUserId)
                            }
                            dictionary.setValue(members, forKey: "globalUserId")

                            let requestModel = AddMembersAdhocChatRequestModel()

                            var title = groupTitle
                            if title.contains("you, ") {
                                let mcount = groupMembers.count + groupmembersFromExistingGroup.count

                                title = "You, \(mcount) others"

                            } else if title == "" {
                                title = "You, \(groupMembers.count) others"
                            }
                            //        let nameString:String = "You, \(self.groupMembers.count) others"
                            let nameString: String = title
                            requestModel.title = nameString
                            requestModel.auth = DefaultDataProcessor().getAuthDetails()
                            requestModel.newjoiners = members as NSArray
                            requestModel.members = groupmembersFromExistingGroup as NSArray
                            requestModel.channelName = groupDetails.groupGlobalId

                            NetworkingManager.AddMembersAdhocChat(addAdhocMembersModel: requestModel) { (result: Any, sucess: Bool) in
                                if let result = result as? CreateAdhocResponseModel, sucess {
                                    Loader.close()
                                    if sucess {
                                        let status = result.status ?? ""

                                        if status != "Exception" {
                                            for member in self.groupMembers {
                                                let groupMem = GroupMemberTable()
                                                groupMem.memberName = member.fullName
                                                groupMem.globalUserId = member.globalUserId
                                                groupMem.phoneNumber = member.phoneNumber
                                                groupMem.thumbUrl = member.picture
                                                groupMem.groupMemberContactId = member.id

                                                groupMem.album = false
                                                groupMem.superAdmin = false
                                                groupMem.addMember = false
                                                groupMem.groupId = self.groupDetails.id
                                                groupMem.memberStatus = "1"
                                                let memId = DatabaseManager.updateGroupMmembers(groupMemebrsTable: groupMem)

                                                let chnltyp = ACGroupsProcessingObjectClass.getChannelForGroup(grpType: groupType.ADHOC_CHAT.rawValue)
                                                let chnls = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: groupType.ADHOC_CHAT.rawValue)

                                                if let chTable = DatabaseManager.getChannelIndex(contactId: self.groupDetails.id, channelType: chnls) {
                                                    if let member = DatabaseManager.getGroupMemberIndex(groupId: self.groupDetails.id, globalUserId: groupMem.globalUserId) {
                                                        let messageText = "You have added \(groupMem.memberName) the group"
                                                        _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: member.groupMemberContactId, channelId: chTable.id, channel: chTable)
                                                    }
                                                }
                                            }
                                            self.navigationController?.popViewController(animated: true)
                                            Loader.close()
                                        } else {
                                            Loader.close()
                                            if result.status == "Exception" {
                                                let errorMsg = result.errorMsg[0]
                                                if errorMsg == "MEM-512" {
                                                    self.alert(message: "Reaching limit. Only \(result.errorMsg[1]) member allowed" )
                                                } else if errorMsg == "IU-100" || errorMsg == "AUT-101" {
                                                    self.gotohomePage()
                                                } else {
                                                    self.alert(message: errorStrings.unKnownAlert)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            let addGroupmembers = AddGroupMemberRequest()

                            addGroupmembers.auth = DefaultDataProcessor().getAuthDetails()
                            addGroupmembers.groupId = groupDetails.groupGlobalId
                            addGroupmembers.joinType = "1"

                            var members: [String] = []
                            for member in groupMembers {
                                members.append(member.globalUserId)
                            }
                            addGroupmembers.groupMembers = members

                            NetworkingManager.addGroupMember(addGroupMemberModel: addGroupmembers) { (result: Any, sucess: Bool) in
                                if let result = result as? AddGroupMemberResponse, sucess {
                                    print(result)
                                    let status = result.status ?? ""

                                    if status != "Exception" {
                                        for member in self.groupMembers {
                                            let getMember = GroupMemberTable()
                                            getMember.globalUserId = member.globalUserId
                                            getMember.groupMemberContactId = member.id
                                            getMember.groupId = self.groupDetails.id
                                            getMember.memberName = member.fullName
                                            getMember.thumbUrl = member.picture
                                            getMember.phoneNumber = member.phoneNumber
                                            getMember.memberStatus = "1"
                                            getMember.createdBy = self.groupDetails.createdBy
                                            getMember.createdOn = self.groupDetails.createdOn

                                            if getMember.globalUserId == self.user?.globalUserId {
                                                getMember.addMember = true
                                                getMember.superAdmin = true
                                                getMember.events = true
                                                getMember.album = true
                                                getMember.publish = true
                                            }

                                            _ = DatabaseManager.storeGroupMembers(groupMemebrsTable: getMember)
                                        }
                                        self.navigationController?.popViewController(animated: true)
                                        Loader.close()
                                    } else {
                                        Loader.close()
                                        if result.status == "Exception" {
                                            let errorMsg = result.errorMsg[0]
                                            if errorMsg == "MAX-GRP" {
                                                self.alert(message: "Reaching limit. Only \(result.errorMsg[1]) member allowed" )
                                            } else if errorMsg == "IU-100" || errorMsg == "AUT-101" {
                                                self.gotohomePage()
                                            } else {
                                                self.alert(message: errorStrings.unKnownAlert)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                    } else {
                        Loader.close()
                        alert(message: "Internet is required")
                    }
                }

                secondDelegate?.navigated(navigated: true)
            } else {
                print("select Members")
            }
        } else {
            navigating = true
            delegate?.groupMembersToPass(members: groupMembers as NSArray, btnTitle: true)
            navigationController?.popViewController(animated: true)
        }
    }

    func getContacts() {
        existingUsers = contactsFromDB?.filter { (existingContacts: ProfileTable) -> Bool in

            existingContacts.isMember

        } ?? []
        existingUsersCount = existingUsers.count
        notExistingUsers = contactsFromDB?.filter { (notExistingContacts: ProfileTable) -> Bool in

            notExistingContacts.isMember == false

        } ?? []
        notExistingUsersCount = notExistingUsers.count
    }
}
