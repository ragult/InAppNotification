import Contacts
import MessageUI
import UIKit

// protocol passGroupMembers {
//    func groupMembersToPass(members:NSArray,btnTitle:Bool)
// }
// protocol navigatingBackToGroupDetailsVC {
//    func navigated(navigated:Bool)
// }
class ContactsViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
    @IBOutlet var contactsTable: UITableView!
    @IBOutlet var inviteBtnHeigthConstraint: NSLayoutConstraint!
    @IBOutlet var inviteBtnHeightConstraintIn: NSLayoutConstraint!
    @IBOutlet var grpBtn: UIButton!
    @IBOutlet var grpChatBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet var inviteButton: UIButton!
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    let store = CNContactStore()
    var contactsFromDB = DatabaseManager.getContacts()
    let user = DatabaseManager.getUser()
    var filteredData: [ProfileTable] = []
    var updateGroupMembers: [GroupMemberTable] = []
//    var delegate:passGroupMembers?
//    var secondDelegate:navigatingBackToGroupDetailsVC?
    var existingUsers: [ProfileTable] = []
    var notExistingUsers: [ProfileTable] = []
    var groupMembers: [ProfileTable] = []
    var inviteNonMembers: [ProfileTable] = []
    var existingUsersCount = 0
    var notExistingUsersCount = 0
    var filter: Bool = false
    var navigating: Bool = false
    var doExistingSelected: Bool = false
    var doNotExistingSelected: Bool = false
    var createGroupFromAddButton: Bool = false
    var groupTitle: String = ""
    var groupID: String = ""
    var groupsType: String = ""
    var longPressGesture: UILongPressGestureRecognizer!
    //
    var groupmembersFromExistingGroup: [String] = []
    var navigatingFromGroupDetailsViewController: Bool = false
    var nonGroupMembersInExistingContacts: [ProfileTable] = []
    var refreshControl = UIRefreshControl()
    var contactsClass = ACContactsProcessor()
    var delegate = UIApplication.shared.delegate as? AppDelegate
    var okAction = UIAlertAction()
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
        searchController.searchBar.barStyle = .default
        searchController.searchBar.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]

        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }

        self.showRefreshButton()
//        self.hideRefreshButton()
        if createGroupFromAddButton == true {
            grpBtn.setTitle("ADD", for: .normal)
        } else if navigatingFromGroupDetailsViewController == true {
            grpBtn.setTitle("Add Members to \(groupTitle)", for: .normal)
        }
        // Long Press
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.7
        longPressGesture.delegate = self
        contactsTable.addGestureRecognizer(longPressGesture)

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        contactsTable.addSubview(refreshControl) // not required when using UITableViewController
    }

    override func viewWillAppear(_: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications
    }

    @objc func refreshData(refreshControl _: UIRefreshControl) {
        // Code to refresh table view
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
//                DispatchQueue.global(qos: .background).async {
                    // do your job here
                    self.refreshControl.endRefreshing()
                    self.showRefreshButton()
//                    self.contactsClass.getContactsAndUpdate(notify: false, completionHandler: { (_) -> Void in
//                        DispatchQueue.main.async {
//                            // update ui here
//                            self.contactsFromDB = DatabaseManager.getContacts()
//                            self.getContacts()
//                            self.contactsTable.reloadData()
//                            self.refreshControl.endRefreshing()
//                        }
//                    })
//                }
            } else {
                refreshControl.endRefreshing()
                alert(message: "Internet is required")
            }
        }
    }
}

extension ContactsViewController: UIScrollViewDelegate {
    fileprivate func hideBottomButton() {
        grpChatBtnHeightConstraint.constant = 0.0
    }

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

                if navigatingFromGroupDetailsViewController == true {
                    groupMembers.append(nonGroupMembersInExistingContacts[indexPath?.row ?? -1])
                } else {
                    groupMembers.append(existingUsers[indexPath?.row ?? -1])
                }
                contactsTable.reloadData()
            } else if indexPath?.section == Section.nonExistingSection {
                notExistingUsers[indexPath?.row ?? -1].selected = true
                hideBottomButton()
                contactsTable.reloadData()
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
        if createGroupFromAddButton == true || navigatingFromGroupDetailsViewController == true {
            print("navigating from create Group or navigating from group details view conroller")
        } else {
            if targetContentOffset.pointee.y < scrollView.contentOffset.y {
                self.showRefreshButton()
            } else {
//                self.hideRefreshButton()
            }
        }
    }
    
    func hideRefreshButton() {
        inviteButton.isHidden = true
        inviteBtnHeigthConstraint.constant = 0
        inviteBtnHeightConstraintIn.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showRefreshButton(){
        
        inviteButton.isHidden = false
        inviteBtnHeigthConstraint.constant = 40
        inviteBtnHeightConstraintIn.constant = 28
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        filter = false
        contactsTable.scrollsToTop = true
        searchController.searchBar.text = ""
        searchBar.resignFirstResponder()
        contactsTable.reloadData()
    }
}

// Mark: Tableview methods
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let notExistingUsersRowCount = notExistingUsers.filter { (notExistingUser) -> Bool in notExistingUser.selected }.count
        let existingUsersRowCount = existingUsers.filter { (existingUser) -> Bool in existingUser.selected }.count

        let section2HeaderView = UIView(frame: CGRect(x: 0, y: 0, width: contactsTable.frame.width, height: 48))
        section2HeaderView.layer.borderWidth = 1
        section2HeaderView.layer.borderColor = UIColor.lightGray.cgColor.copy(alpha: 0.2)
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
        sendButton.titleLabel!.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
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
        if createGroupFromAddButton == true || navigatingFromGroupDetailsViewController == true {
            return 1
        }
        return filter == true ? 1 : 2
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
                        let temp = !groupmembersFromExistingGroup.contains(where: { (member) -> Bool in
                            profile.globalUserId == member
                        })
                        return temp
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
            if filteredData[indexPath.row].isAnonymus == true {
                contactsTableCell.memberPhonNumber.text = ""
            }
        } else {
            if indexPath.section == Section.existingSection {
                contactsTableCell.chatButtonInSectionOne.isHidden = false
                if navigatingFromGroupDetailsViewController == true {
                    contactsTableCell.memberPhonNumber.text = nonGroupMembersInExistingContacts[indexPath.row].phoneNumber
                    contactsTableCell.memberName.text = nonGroupMembersInExistingContacts[indexPath.row].fullName
                    if let imageUrl = URL(string: nonGroupMembersInExistingContacts[indexPath.row].picture) {
                        contactsTableCell.memberProfielImage.af_setImage(withURL: imageUrl)
                    }
                } else {
                    contactsTableCell.memberPhonNumber.text = existingUsers[indexPath.row].phoneNumber
                    contactsTableCell.memberName.text = existingUsers[indexPath.row].fullName
//                    if indexPath.row == 1 {
//                        contactsTableCell.memberPhonNumber.text = ""
//                    }

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
                }
                //  section 0 - Selected
                if existingUsers[indexPath.row].selected == true {
                    contactsTable.allowsMultipleSelection = true
                    contactsTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    contactsTableCell.chatButtonInSectionOne.isHidden = false
                    contactsTableCell.chatButtonInSectionOne.isSelected = true

                    print("group members ------ \(groupMembers)")
                } else if existingUsers[indexPath.row].selected == false {
                    contactsTable.deselectRow(at: indexPath, animated: false)
                    contactsTableCell.chatButtonInSectionOne.isHidden = false
                    contactsTableCell.chatButtonInSectionOne.isSelected = false
//                    if groupMembers.count < 2 {
//                        hideBottomButton()
//                    }
                }
            } else {
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
                    contactsTableCell.memberProfielImage.backgroundColor = UIColor(red: 33.0 / 255.0, green: 140.0 / 255.0, blue: 141.0 / 255.0, alpha: 1)
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

    func clearGroupSelection() {
        groupMembers = []
        for member in existingUsers {
            member.selected = false
        }
        checkChatOrInvite()
    }

    func checkChatOrInvite() {
        if groupMembers.count > 1  && inviteNonMembers.count == 0 {
            setChatTogether()
        }
        if inviteNonMembers.count > 0 && groupMembers.count == 0 {
            setSmsInvite()
        }
        if groupMembers.count == 0, inviteNonMembers.count == 0 {
            hideBottomButton()
        }
    }

    func clearInviteSelection() {
        inviteNonMembers = []
        for member in notExistingUsers {
            member.selected = false
        }
        checkChatOrInvite()
    }

    func setChatTogether() {
        grpBtn.setTitle("Chat Together", for: .normal)
        showBottomButton()
    }

    func setSmsInvite() {
        grpBtn.setTitle("Send SMS Invite", for: .normal)
        showBottomButton()
//        grpChatBtnHeightConstraint
    }

//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        let sectionNumber = indexPath.section
//        if sectionNumber == Section.existingSection {
//            if doNotExistingSelected {
//                return nil
//            }
//            doExistingSelected = true
//        } else {
//            if doExistingSelected {
//                return nil
//            }
//            doNotExistingSelected = true
//        }
//        return indexPath
//    }
    fileprivate func showBottomButton() {
        grpChatBtnHeightConstraint.constant = 50.5
        inviteButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filter != true {
            let sectionNumber = indexPath.section
            let notExistingUsersRowCount = notExistingUsers.filter { (notExistingUser) -> Bool in notExistingUser.selected }.count
            let existingUsersRowCount = existingUsers.filter { (existingUser) -> Bool in existingUser.selected }.count
            if sectionNumber == Section.existingSection {
                if existingUsersRowCount == 0, notExistingUsersRowCount == 0 {
                    existingUsers[indexPath.row].selected = false
                    if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
                        var chTable = DatabaseManager.getChannelIndex(contactId: existingUsers[indexPath.row].id, channelType: channelType.ONE_ON_ONE_CHAT.rawValue)
                        if chTable == nil {
                            let channel = ACDatabaseMethods.createChannelTable(conatctId: existingUsers[indexPath.row].id, channelType: channelType.ONE_ON_ONE_CHAT.rawValue, globalChannelName: existingUsers[indexPath.row].globalUserId)
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

                        nextVC.customNavigationBar(name: existingUsers[indexPath.row].fullName, image: existingUsers[indexPath.row].localImageFilePath, channelTyp: channelType(rawValue: channelDIspObj.channelType)!)
                        nextVC.displayName = existingUsers[indexPath.row].fullName
                        nextVC.displayImage = existingUsers[indexPath.row].localImageFilePath
                        nextVC.isViewFirstTime = true
                        nextVC.isViewFirstTimeLoaded = true
                        nextVC.isFromContacts = true
                        nextVC.isScrollToBottom = true

                        navigationController?.pushViewController(nextVC, animated: true)
//                    contactsTable.reloadData()
                    }
                } else if existingUsersRowCount == 0 {
                    contactsTable.reloadData()
                    print("CONDITION CHECKING")
                } else {
                    clearInviteSelection()
                    existingUsers[indexPath.row].selected = true
                    if navigatingFromGroupDetailsViewController == true {
                        groupMembers.append(nonGroupMembersInExistingContacts[indexPath.row])
                    } else {
                        groupMembers.append(existingUsers[indexPath.row])
                    }
                    if groupMembers.count > 1 {
                        setChatTogether()
                    }
                    contactsTable.reloadData()
                }
                contactsTable.reloadData()
            } else if sectionNumber == Section.nonExistingSection {
                clearGroupSelection()
                notExistingUsers[indexPath.row].selected = true
                contactsTable.reloadData()
                inviteNonMembers.append(notExistingUsers[indexPath.row])
                if inviteNonMembers.count > 0 {
                    setSmsInvite()
                }
            }
        }
    }

    func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
        contactsTable.reloadData()
        if filter != true {
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
                    if groupMembers.count < 2 {
                        hideBottomButton()
                    }
                    //            contactsTable.reloadData()
                }
            } else if sectionNumber == Section.nonExistingSection {
                if notExistingUsersRowCount <= 0 || inviteNonMembers.count == 0 {
                    notExistingUsers[indexPath.row].selected = false
                    contactsTable.allowsSelection = false
                    contactsTable.reloadData()
                } else {
                    notExistingUsers[indexPath.row].selected = false
                    for member in inviteNonMembers {
                        if member.id == notExistingUsers[indexPath.row].id {
                            inviteNonMembers.remove(object: member)
                            print("Invite members ------ \(inviteNonMembers)")
                        }
                    }
                    if inviteNonMembers.count < 1 {
                        hideBottomButton()
                    }
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
extension ContactsViewController {
    @objc func contactsSearchButton() {
        navigationItem.hidesSearchBarWhenScrolling = !navigationItem.hidesSearchBarWhenScrolling
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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
            if delegate != nil {
                if (delegate?.isInternetAvailable)! {
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
            self.hideRefreshButton()
        }
    }

    fileprivate func createAdhocGroupWithAppMembers() {
        if createGroupFromAddButton == false, navigatingFromGroupDetailsViewController == false {
            print("group members ------ \(groupMembers)")

            let count = groupMembers.filter { $0.selected == true }.count
            if count > 12 {
                alert(message: "Limit the participants to 12")
            }
            let alertController = UIAlertController(title: "Specify a title", message: "", preferredStyle: .alert)
            alertController.addTextField(configurationHandler: { (textField: UITextField!) in
                textField.delegate = self
                textField.placeholder = "(Optional)"
            })
            okAction = UIAlertAction(title: "Continue", style: .default, handler: { _ in
                let firstTextField = alertController.textFields![0] as UITextField
                self.createAdhocChat(getTitle: firstTextField.text!)
            })
            okAction.isEnabled = true

            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (_: UIAlertAction!) -> Void in })

            alertController.addAction(cancelAction)
            alertController.addAction(okAction)

            present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func createGroupButtonAction(_: Any) {
        if groupMembers.count > 1 {
            createAdhocGroupWithAppMembers()
        } else if inviteNonMembers.count > 0 {
            let numbers = inviteNonMembers.map({ $0.phoneNumber }).joined(separator: ",")
            sendSMS(numbers: numbers)
        }
    }

    func sendSMS(numbers: String) {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = "Alltime has built-in privacy for connections with Personal, Official and Social circles. Download Alltime Communicator https://alltime.app/get"
            let phoneNumberString = numbers
            let recipientsArray = phoneNumberString.components(separatedBy: ",")
            controller.recipients = recipientsArray
            controller.messageComposeDelegate = self
            present(controller, animated: true, completion: nil)
        } else {
            print("Error")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = range.length == 0 ? textField.text! + string : (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if newText == "" {
            okAction.isEnabled = true
        } else {
            okAction.isEnabled = true
        }
        return true
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

    func createAdhocChat(getTitle: String) {
        Loader.show()
        let dictionary = NSMutableDictionary()
        var members: [String] = []
        for member in groupMembers {
            members.append(member.globalUserId)
        }
        dictionary.setValue(members, forKey: "globalUserId")
        let requestModel = CreateAdhocChatRequestModel()
        var title = getTitle
        if title == "" {
            title = "You, \(groupMembers.count) others"
        }
//        let nameString:String = "You, \(self.groupMembers.count) others"
        let nameString: String = title
        requestModel.title = nameString
        requestModel.auth = DefaultDataProcessor().getAuthDetails()
        requestModel.members = dictionary
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                NetworkingManager.createAdhocChat(createGroupModel: requestModel) { (result: Any, sucess: Bool) in
                    if let result = result as? CreateAdhocResponseModel, sucess {
                        if sucess {
                            if result.status == "Success" {
                                let timestamp = NSDate().timeIntervalSince1970
                                let finalTS = String(format: "%.0f", timestamp)

                                let group = GroupTable()
                                group.groupName = nameString
                                group.groupGlobalId = (result.data?.channel)!
                                group.groupType = groupType.ADHOC_CHAT.rawValue
                                group.groupStatus = groupStats.ACTIVE.rawValue
                                group.fullImageUrl = ""
                                group.confidentialFlag = "0"
                                group.createdOn = finalTS
                                group.createdBy = (UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String)!

                                DatabaseManager.checkIfGroupExistsOrUpdateTheSummary(groupTable: group)
                                let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: group.groupGlobalId)
                                if let selfContact = DatabaseManager.getSelfContactDetails() {
                                    self.groupMembers.append(selfContact)
                                }
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
                                    groupMem.groupId = (groupIdTable?.id)!
                                    groupMem.memberStatus = "1"
                                    _ = DatabaseManager.updateGroupMmembers(groupMemebrsTable: groupMem)
                                }

                                let channel = ACDatabaseMethods.createChannelTable(conatctId: (groupIdTable?.id)!, channelType: channelType.ADHOC_CHAT.rawValue, globalChannelName: (result.data?.channel)!)
                                _ = DatabaseManager.storeChannelData(channelTable: channel)

                                let channelIndex = DatabaseManager.getChannelIndex(contactId: (groupIdTable?.id)!, channelType: channelType.ADHOC_CHAT.rawValue)

                                let channelObject = ChannelDisplayObject()
                                channelObject.channelId = channelIndex!.id
                                channelObject.channelType = channelIndex!.channelType
                                channelObject.unseenCount = channelIndex!.unseenCount
                                channelObject.lastMessageIdOfChannel = channelIndex!.lastSavedMsgid
                                channelObject.lastMessageTime = channelIndex!.lastMsgTime
                                channelObject.lastSenderPhoneBookContactId = channelIndex!.contactId
                                channelObject.globalChannelName = (channelIndex?.globalChannelName)!

                                let pubnubNotication = ACPubnubClass()
                                pubnubNotication.subscribeToPubnubNotificationForGroup(groupChannelId: (result.data?.channel) ?? "")

                                if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
                                    if let navigator = self.navigationController {
                                        nextViewController.hidesBottomBarWhenPushed = true
                                        nextViewController.navigationController?.navigationBar.isHidden = true

                                        if channelObject.channelDisplayNames == "" {
                                            // find channel type
                                            channelObject.channelDisplayNames = nameString
                                            channelObject.channelImageUrl = ""
                                        }
//                                        nextViewController.loadTableViewData(chnlDetails: channelObject)

                                        nextViewController.customNavigationBar(name: channelObject.channelDisplayNames, image: channelObject.channelImageUrl, channelTyp: channelType(rawValue: channelObject.channelType)!)
                                        nextViewController.displayName = channelObject.channelDisplayNames
                                        nextViewController.displayImage = channelObject.channelImageUrl
                                        nextViewController.channelDetails = channelObject
                                        nextViewController.isViewFirstTime = true
                                        nextViewController.isViewFirstTimeLoaded = true
                                        nextViewController.isFromContacts = true
                                        nextViewController.isScrollToBottom = true

                                        navigator.pushViewController(nextViewController, animated: true)
                                    }
                                }
                                print(result)
                                Loader.close()
                            } else {
                                print(result)
                                Loader.close()
                                if result.status == "Exception" {
                                    let errorMsg = result.errorMsg[0]
                                    if errorMsg == "IU-100" || errorMsg == "AUT-101" {
                                        self.gotohomePage()
                                        self.alert(message: errorMsg)
                                    }
                                }
                            }

                        } else {
                            print("Error")
                            Loader.close()
                        }
                    } else {
                        print("Error")
                        Loader.close()
                    }
                }
            } else {
                Loader.close()
                alert(message: "Internet is required")
            }
        }
    }
}
