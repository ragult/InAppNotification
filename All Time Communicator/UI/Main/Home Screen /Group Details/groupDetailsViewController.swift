//
//  AddAdminsViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 01/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import AXPhotoViewer
import UIKit

protocol groupExitDelegate: AnyObject {
    func userLocationData(clearChat: Bool)
}

protocol groupPhotoChangeDelegate: AnyObject {
    func photoUpdateData(photoName: String)
}

struct SectionData {
    var type: SectionType = .image
    var isAvailable = false
    var section = 0
}

enum SectionType {
    case image
    case desc
    case reconnect
    case address
    case members
    case keyContacts
    case info
    case footer
}

class groupDetailsViewController: UIViewController, navigatingBackToGroupDetailsVC {
    @IBOutlet var adminsTableview: UITableView!

    let userDetails = DatabaseManager.getUser()
    var groupDetails = GroupTable()
    var backButton: Bool = false
    var userAdmin: Bool = false
    var navigatedFrmContacts: Bool = false
    var groupAllMembersList = [GroupMemberTable]()
    var groupMembersList = [GroupMemberTable]()
    var titleMembersList = [GroupMemberTable]()
    var userId = ""
    weak var datadelegate: groupExitDelegate?
    var channelName: String = ""
    var grpType: String = ""
    var isReconnect : Bool = false
    weak var photoChangedelegate: groupPhotoChangeDelegate?

    var sectionDetails: (sectionData: [SectionData], count: Int)?
    var filteredSection: [SectionData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        adminsTableview.tableFooterView = UIView()
        if backButton == true {
            navigationItem.hidesBackButton = true
            let newBackButton = UIBarButtonItem(image: UIImage(named: "rightBackButton"), style: .plain, target: self, action:
                #selector(back))
            navigationItem.leftBarButtonItem = newBackButton
        } else {
            navigationItem.hidesBackButton = true
            let newBackButton = UIBarButtonItem(image: UIImage(named: "rightBackButton"), style: .plain, target: self, action:
                #selector(OnClickOfBack))
            navigationItem.leftBarButtonItem = newBackButton
        }

        userId = userDetails?.globalUserId ?? ""

//        let more   = UIBarButtonItem(image:UIImage(named: "more"),  style: .plain, target: self, action: #selector(didTapMoreButton))
//        navigationItem.rightBarButtonItem = more
//        adminsTableview.allowsSelection = false
        adminsTableview.register(UINib(nibName: "AddAdminsTableviewCell", bundle: nil), forCellReuseIdentifier: "cell")
        adminsTableview.register(UINib(nibName: "GroupProfileCell", bundle: nil), forCellReuseIdentifier: "GroupProfileCell")
        adminsTableview.register(UINib(nibName: "GroupNumberOfMembersCellTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupNumberOfMembersCellTableViewCell")
        adminsTableview.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }

    override func viewWillAppear(_: Bool) {
        //            self.groupDetails  = DatabaseManager.fetchGroup(groupId:groupDetails.id) ?? groupDummy

        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications
        getDataForView()
    }

    override func viewDidAppear(_: Bool) {
        adminsTableview.reloadData()
    }

    func getDataForView() {
        groupAllMembersList = DatabaseManager.getGroupMembers(globalGroupId: groupDetails.id)

        let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)
        let groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
        if groupMember.count == 1 {
            groupMembersList.remove(object: groupMember[0])
            groupMembersList.insert(groupMember[0], at: 0)
            isReconnect = false
//            groupAllMembersList.remove(object: groupMember[0])
//            groupAllMembersList.insert(groupMember[0], at: 0)
        } else {
            isReconnect = true
        }
        titleMembersList = groupAllMembersList.filter { $0.memberTitle != "" }
        groupMembersList = groupAllMembersList.filter { $0.memberTitle == "" }

        groupDetails = DatabaseManager.getGroupDetail(groupGlobalId: groupDetails.id)!
        sectionDetails = getSectionCount()
        filteredSection = sectionDetails?.sectionData ?? []
        filteredSection = filteredSection.filter { $0.isAvailable == true }
        adminsTableview.reloadData()
    }

    func getSectionCount() -> (sectionData: [SectionData], count: Int) {
        var sectionData: [SectionData] = []
        var count = 0, image: SectionData, desc: SectionData, address: SectionData,reconnect:SectionData, members: SectionData, keyContacts: SectionData, info: SectionData, footer: SectionData
        // Added one for Image
        image = SectionData(type: .image, isAvailable: true, section: count)
        count = count + 1
        sectionData.append(image)
        // Check for description
        if groupDetails.groupDescription != ""{
            desc = SectionData(type: .desc, isAvailable: true, section: count)
            count = count + 1
        } else {
            desc = SectionData(type: .desc, isAvailable: false, section: -1)
        }
        sectionData.append(desc)

        // Check for address
        if groupDetails.address != "" {
            address = SectionData(type: .address, isAvailable: true, section: count)
            count = count + 1
        } else {
            address = SectionData(type: .address, isAvailable: false, section: -1)
        }
        sectionData.append(address)
        // check for members
        let groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
        if groupMembersList.count > 0 {
            members = SectionData(type: .members, isAvailable: true, section: count)
            count = count + 1
        } else if groupMember.count == 1 && (groupMember[0].addMember || groupMember[0].superAdmin) {
            members = SectionData(type: .members, isAvailable: true, section: count)
            count = count + 1
        } else {
            members = SectionData(type: .members, isAvailable: false, section: -1)
        }
        sectionData.append(members)
        // check for Key Contacts
        if isReconnect{
            reconnect = SectionData(type: .reconnect, isAvailable: true, section: count)
            count = count + 1
        } else {
            reconnect = SectionData(type: .reconnect, isAvailable: false, section: -1)
        }
        sectionData.append(reconnect)

        if titleMembersList.count > 0 {
            keyContacts = SectionData(type: .keyContacts, isAvailable: true, section: count)
            count = count + 1
        } else {
            keyContacts = SectionData(type: .keyContacts, isAvailable: false, section: -1)
        }
        sectionData.append(keyContacts)

        // Check for group info
        if (groupDetails.groupType == groupType.PRIVATE_GROUP.rawValue && groupDetails.webUrl != "") || groupDetails.groupType == groupType.PUBLIC_GROUP.rawValue {
            info = SectionData(type: .info, isAvailable: true, section: count)
            count = count + 1
        } else {
            info = SectionData(type: .info, isAvailable: false, section: -1)
        }
        sectionData.append(info)

        // Add one for footer
        footer = SectionData(type: .footer, isAvailable: true, section: count)
        count = count + 1
        sectionData.append(footer)

        return (sectionData: sectionData, count: count)
    }
}

extension groupDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func navigated(navigated: Bool) {
        navigatedFrmContacts = navigated
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
        if filteredSection[section].type == .image {
            return 1
        } else if filteredSection[section].type == .desc {
            return 0
        }else if filteredSection[section].type == .address {
            return 1
        }
        else if filteredSection[section].type == .reconnect {
            return 1
        } else if filteredSection[section].type == .members && groupMember.count == 1 && groupAllMembersList.count == 1 {
            return 1
        } else if filteredSection[section].type == .members && filteredSection[section].isAvailable {
            return groupMembersList.count
        } else if filteredSection[section].type == .keyContacts {
            return titleMembersList.count
        } else if filteredSection[section].type == .info {
            return 1
        } else if filteredSection[section].type == .footer {
            if groupDetails.groupStatus == groupStats.INACTIVE.rawValue {
                return 1
            } else {
                let groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
                if groupMember.count != 0 {
                    if groupMember[0].superAdmin == true {
                        return 3

                    } else {
                        return 2
                    }
                } else {
                    return 1
                }
            }
        }
        return 0
    }

//        if section == 0 {
//            return 1
//        } else if section == 1 {
//            return groupMembersList.count
//        } else if section == 2, titleMembersList.count > 0 {
//            return titleMembersList.count
//        } else {
//            if groupDetails.groupStatus == groupStats.INACTIVE.rawValue {
//                return 1
//
//            } else {
//                let groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
//                if groupMember.count != 0 {
//                    if groupMember[0].superAdmin == true {
//                        return 3
//
//                    } else {
//                        return 2
//                    }
//
//                } else {
//                    return 1
//                }
//            }
//        }

    func numberOfSections(in _: UITableView) -> Int {
        return filteredSection.count
//        if titleMembersList.count > 0 {
//            return 4
//        }
//        return 3
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if filteredSection[section].type == .image || filteredSection[section].type == .desc {
            return 0
        } else if filteredSection[section].type == .address || filteredSection[section].type == .members || filteredSection[section].type == .keyContacts || filteredSection[section].type == .info {
            return 46
        } else {
            // if self.filteredSection[section].type == .footer
            return 10
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
        if filteredSection[section].type == .image {
            return 250
        } else if filteredSection[section].type == .desc {
            return 48
        } else if filteredSection[section].type == .address {
            return 48
        } else if filteredSection[section].type == .reconnect {
            return 48
        }else if filteredSection[section].type == .members && groupMember.count == 1 && groupAllMembersList.count == 1 {
            return 48
        } else if filteredSection[section].type == .members {
            return 84
        } else if filteredSection[section].type == .keyContacts {
            return 84
        } else if filteredSection[section].type == .info {
            if groupDetails.groupType == groupType.PRIVATE_GROUP.rawValue || (groupDetails.groupType == groupType.PUBLIC_GROUP.rawValue && groupDetails.webUrl == "") {
                return 144
            }
            return 180
        } else {
            return 64
        }
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
        cell.backgroundColor = UIColor(r: 249, g: 250, b: 251)
    }

    func getSectionView() -> UIView {
        let sectionOne = UIView(frame: CGRect(x: 16, y: 0, width: adminsTableview.frame.width, height: 56))
        sectionOne.layer.borderWidth = 1
        sectionOne.layer.borderColor = UIColor.lightGray.cgColor
        sectionOne.backgroundColor = .lightGray
        sectionOne.layer.borderWidth = 0.0
        sectionOne.backgroundColor = UIColor(r: 249, g: 250, b: 251)
        return sectionOne
    }

    func getHeaderTitle(title: String) -> UILabel {
        let headerTitle = UILabel(frame: CGRect(x: 16, y: 8, width: adminsTableview.bounds.size.width, height: 40))
        headerTitle.text = title
        headerTitle.textColor = .gray
        return headerTitle
    }

    func getAddButton(width: CGFloat) -> UIButton {
        let addButton = UIButton(frame: CGRect(x: width - 43, y: 20, width: 24, height: 24))
        addButton.setImage(UIImage(named: "PlusButtonGray"), for: .normal)
        addButton.setTitleColor(UIColor(r: 33, g: 140, b: 141), for: .normal)
        addButton.addTarget(self, action: #selector(didTapPluseButton), for: .touchUpInside)
        addButton.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        return addButton
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionOne = getSectionView()
        if filteredSection[section].type == .desc {
            let headerTitle = getHeaderTitle(title: "Description")
            sectionOne.addSubview(headerTitle)
            return sectionOne
        } else if filteredSection[section].type == .address {
            let headerTitle = getHeaderTitle(title: "Location")
            sectionOne.addSubview(headerTitle)
            return sectionOne
        } else if filteredSection[section].type == .members {
            let headerTitle = getHeaderTitle(title: "Members")
            sectionOne.addSubview(headerTitle)
            let addButton = getAddButton(width: sectionOne.frame.width)
            let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)
            if groupDetails.groupStatus != groupStats.INACTIVE.rawValue {
                let groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
                if groupMember.count != 0 {
                    if groupMember[0].superAdmin == true || groupMember[0].addMember == true {
                        sectionOne.addSubview(addButton)
                    }
                }
            }
            return sectionOne
        } else if filteredSection[section].type == .keyContacts {
            let headerTitle = getHeaderTitle(title: "Group Help Desk")
            sectionOne.addSubview(headerTitle)
            return sectionOne
        } else if filteredSection[section].type == .info {
            let headerTitle = getHeaderTitle(title: "Group Details")
            sectionOne.addSubview(headerTitle)
            return sectionOne
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
        if filteredSection[section].type == .image {
            let groupProfileCell = adminsTableview.dequeueReusableCell(withIdentifier: "GroupProfileCell", for: indexPath) as! GroupProfileCell
            groupProfileCell.setGroupProfileData(groupDetails: groupDetails, groupAllMembersList: groupAllMembersList, setLocalPath: { path in
                self.groupDetails.localImagePath = path
            }) { path in
                groupProfileCell.groupImage.image = self.load(attName: path)
            }
            let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)
            let groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
            if groupMember.count != 0 {
                if groupDetails.groupStatus != groupStats.INACTIVE.rawValue {
                    if groupMember[0].superAdmin == true {
                        groupProfileCell.groupEditButton.isHidden = false
                        groupProfileCell.groupEditButton.addTarget(self, action: #selector(onTapOfedit(_:)), for: .touchUpInside)
                    }
                }
            }
            groupProfileCell.selectionStyle = .none
            return groupProfileCell
        } else if filteredSection[section].type == .desc {
            let tableViewCell = adminsTableview.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            let cell = GroupDescription.initWith()
            cell.frame = CGRect(0, 0, adminsTableview.frame.size.width, 48)
            cell.setDescription(desc: groupDetails.groupDescription)
            tableViewCell.addSubview(cell)
            tableViewCell.selectionStyle = .none
            return tableViewCell
        } else if filteredSection[section].type == .address {
            let tableViewCell = adminsTableview.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            let cell = GroupDescription.initWith()
            cell.frame = CGRect(0, 0, adminsTableview.frame.size.width, 48)
            cell.setDescription(desc: groupDetails.address)
            tableViewCell.addSubview(cell)
            tableViewCell.selectionStyle = .none
            return tableViewCell
        }  else if filteredSection[section].type == .reconnect {
            let tableViewCell = adminsTableview.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            let cell = Reconnect.initWith()
            cell.frame = CGRect(0, 0, adminsTableview.frame.size.width, 48)
            cell.reconnectBtn.addTarget(self, action: #selector(onClickOfJoinGroup(_:)), for: .touchUpInside)
            tableViewCell.addSubview(cell)
            tableViewCell.selectionStyle = .none
            return tableViewCell
        }
        else if filteredSection[section].type == .members && groupAllMembersList.count == 1 && groupMember.count == 1 {
            let tableViewCell = adminsTableview.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            let label = UILabel.init(frame: CGRect.init(16, 0, tableView.frame.size.width, 48))
            label.text = "Start adding members using '+' icon"
            label.textColor = COLOURS.textDarkGrey
            tableViewCell.addSubview(label)
            tableViewCell.selectionStyle = .none
            return tableViewCell
        } else if filteredSection[section].type == .members || filteredSection[section].type == .keyContacts {
            let cell = adminsTableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddAdminsTableviewCell
            cell.adminLabel.isHidden = false

            var data = (filteredSection[section].type == .members) ? groupMembersList[indexPath.row] : titleMembersList[indexPath.row]

            cell.adminLabel.text = getPermissionTitle(member: data)
            cell.adminLabel.layoutIfNeeded()
            cell.adminLabel.setNeedsLayout()
            cell.adminLabel.setNeedsDisplay()

            cell.memberTitle.text = data.memberTitle.uppercased()

            if data.globalUserId != userId {
                if data.groupMemberContactId != "" {
                    if Int(data.groupMemberContactId)! > 0 {
                        let contact = DatabaseManager.getContactIndexforTable(tableIndex: data.groupMemberContactId)
                        cell.groupMemName.text = (contact?.fullName)!
                    } else {
                        cell.groupMemName.text = data.memberName
                    }

                } else {
                    cell.groupMemName.text = data.memberName
                }

//                cell.groupMemName.text = self.data.memberName
                cell.leftArrow.isHidden = false

            } else {
                cell.groupMemName.text = "You"
                cell.leftArrow.isHidden = true
            }
            if groupDetails.groupStatus == groupStats.INACTIVE.rawValue {
                cell.leftArrow.isHidden = true
                cell.isUserInteractionEnabled = false
            }

            if let imageUrl = URL(string: data.thumbUrl) {
                if data.localImagePath == "" {
                    if data.thumbUrl != "" {
                        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: data.thumbUrl, refernce: data.groupMemberId, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

                        DispatchQueue.global(qos: .background).async {
                            ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in
                                if path != "" {
                                    DatabaseManager.updateGroupMembersLocalImagePath(localImagePath: path, localId: data.groupMemberId)
                                    if self.filteredSection[section].type == .members {
                                        self.groupMembersList[indexPath.row].localImagePath = path
                                    } else {
                                        self.titleMembersList[indexPath.row].localImagePath = path
                                    }
                                    data = (self.filteredSection[section].type == .members) ? self.groupMembersList[indexPath.row] : self.titleMembersList[indexPath.row]

                                    DispatchQueue.main.async { () in
                                        cell.groupMemberProfileImage.image = self.load(attName: data.localImagePath)
                                    }
                                }
                            })
                        }
                    }
                } else {
                    cell.groupMemberProfileImage.image = load(attName: data.localImagePath)
                }
//                cell.groupMemberProfileImage.af_setImage(withURL: imageUrl)
            } else {
                cell.groupMemberProfileImage.image = LetterImageGenerator.imageWith(name: cell.groupMemName.text, randomColor: .gray)
            }

            cell.selectionStyle = .none

            return cell
        } else if filteredSection[section].type == .info {
            let tableViewCell = adminsTableview.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            let cell = GroupInfo.initWith()
            cell.setWebLink(link: groupDetails.webUrl)
            cell.frame.size.width = adminsTableview.frame.size.width
            if groupDetails.groupType == groupType.PRIVATE_GROUP.rawValue {
                cell.showPrivateBroadCastInfo()
            } else {
                cell.showPublicProcastInfo()
                if groupDetails.publicGroupCode != "" {
                    cell.setGroupCode(code: groupDetails.publicGroupCode)
                } else {
                    cell.setGroupCode(code: groupDetails.groupCode)
                }
                cell.copyView.isUserInteractionEnabled = true
                cell.copyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyGroupCode)))

                if groupDetails.localQrcode != "" {
                    cell.setQRImage(image: load(attName: groupDetails.localQrcode)!)
                    cell.qrImage.isUserInteractionEnabled = true
                    cell.qrImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openQrImage)))

                } else {
                    let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: groupDetails.qrCode, refernce: groupDetails.id, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")
                    DispatchQueue.global(qos: .background).async {
                        ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in
                            self.groupDetails.localQrcode = path
                            DatabaseManager.updateGroupLocalQrPath(localImagePath: path, localId: success.refernce)
                            DispatchQueue.main.async { () in
                                cell.setQRImage(image: self.load(attName: self.groupDetails.localQrcode)!)
                            }
                        })
                    }
                }
                if groupDetails.webUrl != "" {
                    cell.setWebLink(link: groupDetails.webUrl)
                    cell.showUrl()
                } else {
                    cell.hideUrl()
                }
            }
            cell.showInfoDetail()
//            cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector()))
//            cell.hideInfoDetail()
            tableViewCell.addSubview(cell)
            tableViewCell.selectionStyle = .none
            return tableViewCell
        } else {
            let groupMembersCell = adminsTableview.dequeueReusableCell(withIdentifier: "GroupNumberOfMembersCellTableViewCell", for: indexPath) as! GroupNumberOfMembersCellTableViewCell
//            groupMembersCell.remainingMembersInGroup.text = ("\(self.groupMembersList.count - 4) members")
            groupMembersCell.selectionStyle = .none
            groupMembersCell.isUserInteractionEnabled = true
            if indexPath.row == 0 {
                groupMembersCell.exitGroup.text = "Clear Chat"
                groupMembersCell.exitGroup.textColor = .gray
                groupMembersCell.exitImage.tintColor = .gray

                groupMembersCell.exitImage.image = UIImage(named: "delete_gray")

            } else if indexPath.row == 1 {
                groupMembersCell.exitGroup.text = "Exit Group"
                groupMembersCell.exitGroup.textColor = .gray
                groupMembersCell.exitImage.tintColor = .gray
                groupMembersCell.exitImage.image = UIImage(named: "exit")

            } else if indexPath.row == 2 {
                groupMembersCell.exitGroup.textColor = .gray
                groupMembersCell.exitImage.image = UIImage(named: "ic_close")
                groupMembersCell.exitImage.tintColor = .gray
                groupMembersCell.exitGroup.text = "Close Group"
            }
            if groupDetails.groupStatus == groupStats.INACTIVE.rawValue {
                groupMembersCell.exitGroup.text = "Remove Group"
                groupMembersCell.exitGroup.textColor = .gray
                groupMembersCell.exitImage.tintColor = .gray

                groupMembersCell.exitImage.image = UIImage(named: "delete_gray")
            }
            groupMembersCell.selectionStyle = .none

            return groupMembersCell
        }
    }
    @objc func onClickOfJoinGroup(_: UIButton) {
        Loader.show()
        let addGroupmembers = JoinGroupMemberRequest()

        addGroupmembers.auth = DefaultDataProcessor().getAuthDetails()
        addGroupmembers.publicGroupId = groupDetails.groupPublicId

        NetworkingManager.joinGroupMember(addGroupMemberModel: addGroupmembers) { (result: Any, sucess: Bool) in

            if let result = result as? AddGroupMemberResponse, sucess {
                print(result)
                let status = result.status ?? ""
                Loader.close()
                
                if status != "Exception" {
                    if result.successMsg[1] == "No valid users to add. Possibility of attempted duplicate record addition"{
                        self.alert(message: "No valid users to add. Possibility of attempted duplicate record addition")
                        return
                    }
                    let dataToProcess = ACFeedProcessorObjectClass()
                    
                    let dataDict: NSDictionary = result.data?.toDictionary() as! NSDictionary
                    dataToProcess.checkTypeOfDataReceived(dataDictionary: dataDict)
                    self.alert(message: "Group list is updated")
                    let groupMem = GroupMemberTable()
                    groupMem.globalUserId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!
                    groupMem.groupId = self.groupDetails.id
                    groupMem.memberStatus = groupMemberStats.ACTIVE.rawValue
                    DatabaseManager.updateGroupMembersStatus(groupMemebrsTable: groupMem)
                    
                    DatabaseManager.UpdateGroupStatus(groupStatus: groupStats.ACTIVE.rawValue, groupId: self.groupDetails.id)
                    
                    Loader.close()
                    self.getDataForView()
                } else {
                    let errMsg = result.errorMsg[0]
                    self.alert(message: errMsg)
                }
            }
        }
    }
    
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if filteredSection[section].type == .image {
            previewPhoto()
        } else if filteredSection[section].type == .members || filteredSection[section].type == .keyContacts {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "GroupMemberViewController") as? GroupMemberViewController {
                let data = (filteredSection[section].type == .members) ? groupMembersList[indexPath.row] : titleMembersList[indexPath.row]

                if data.globalUserId != userId {
                    if let navigator = navigationController {
                        nextViewController.hidesBottomBarWhenPushed = true
                        nextViewController.groupId = groupDetails.groupGlobalId
                        nextViewController.globalUserId = userDetails?.globalUserId ?? ""
                        nextViewController.group = groupDetails
                        nextViewController.groupMembersList = groupMembersList

                        nextViewController.profile = data

                        if groupDetails.groupType == groupType.GROUP_CHAT.rawValue {
                            nextViewController.showPublicView = false
                        } else {
                            nextViewController.showPublicView = true
                        }

                        if data.superAdmin == true {
                            nextViewController.profile.superAdmin = true
                        } else {
                            nextViewController.profile.superAdmin = data.superAdmin
                        }
                        var groupMember = [GroupMemberTable]()
//                        if filteredSection[section].type == .members {
                        groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
//                        } else {
//                            groupMember = titleMembersList.filter { $0.globalUserId == userId }
//                        }
                        if groupMember.count != 0 {
                            if groupMember[0].superAdmin == true || groupMember[0].addMember == true {
                                if groupMember[0].addMember == true, groupMember[0].superAdmin == false {
                                    nextViewController.isMemberAdmin = true
                                }
                                navigator.pushViewController(nextViewController, animated: true)
                            } else {
                                goToChats(profile: data)
                            }
                        }
                    }
                }
            }

        } else if filteredSection[section].type == .footer {
            if indexPath.row == 0 {
                if groupDetails.groupStatus == groupStats.INACTIVE.rawValue {
                    let alertController = UIAlertController(title: "Alert", message: labelStrings.groupRemoveChatClose, preferredStyle: .alert)
                    let exitgroup = UIAlertAction(title: "Remove Group", style: .default, handler: { _ in

                        self.deleteGroupData()

                    })

                    let OKAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(exitgroup)

                    alertController.addAction(OKAction)
                    present(alertController, animated: true, completion: nil)
                } else {
                    clearChats()
                }
            } else if indexPath.row == 1 {
                let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)

                let groupMember = groupAllMembersList.filter { $0.globalUserId == userId }
                if groupMember.count != 0 {
                    if groupMember[0].superAdmin == true {
                        checkIfuserSuperAdminALone()
                    } else {
                        let alertController = UIAlertController(title: "Alert", message: labelStrings.groupmemberExitAlert, preferredStyle: .alert)
                        let exitgroup = UIAlertAction(title: "Exit Group", style: .default, handler: { _ in

                            self.removeMember()
                        })

                        let OKAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                        alertController.addAction(exitgroup)

                        alertController.addAction(OKAction)
                        present(alertController, animated: true, completion: nil)
                    }
                }
            } else if indexPath.row == 2 {
                showDeleteGroup()
            }
        }
    }
    
    @objc func copyGroupCode() {
        if groupDetails.publicGroupCode != "" {
            UIPasteboard.general.string = groupDetails.publicGroupCode
        } else {
            UIPasteboard.general.string = groupDetails.groupCode
        }
        self.alert(message: "Group code has been copied to your clipboard")
    }
    
    @objc func openQrImage() {
       if groupDetails.localQrcode != "" {
//            let indexpath = IndexPath(row: 0, section: 0)
//            let tableViewCell = adminsTableview.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
//            let imageView = cell.q
//
//            let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) { [weak self] (_, _) -> UIImageView? in
//                guard let self = self else { return nil }
//
//                guard let cell = self.adminsTableview.cellForRow(at: indexpath) else { return nil }
//
//                // adjusting the reference view attached to our transition info to allow for contextual animation
//                let cardscell = cell as! GroupProfileCell
//                return cardscell.groupImage
//            }
            let img = load(attName: groupDetails.localQrcode)
            let str = NSAttributedString(string: "")
            var photos = [AXPhoto]()
             photos = [AXPhoto(attributedTitle: str, image: img)]
            
            let dataSource = AXPhotosDataSource(photos: photos)
            let pagingConfig = AXPagingConfig(loadingViewClass: nil)
            let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: pagingConfig)
            photosViewController.delegate = self as? AXPhotosViewControllerDelegate

            present(photosViewController, animated: true)
        }
    }

    func clearChats() {
        let alertController = UIAlertController(title: "Alert", message: labelStrings.groupClearChatClose, preferredStyle: .alert)
        let exitgroup = UIAlertAction(title: "Clear Chat", style: .default, handler: { _ in

            let chnl = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: self.groupDetails.groupType)

            if let chTable = DatabaseManager.getChannelIndex(contactId: self.groupDetails.id, channelType: chnl) {
                DatabaseManager.deleteMessagesForChannelId(channelId: chTable.id)
                self.datadelegate?.userLocationData(clearChat: true)
                self.navigationController?.popViewController(animated: true)
            }

        })

        let OKAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(exitgroup)

        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }

    func deleteGroupData() {
        let chnl = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: groupDetails.groupType)

        if let chTable = DatabaseManager.getChannelIndex(contactId: self.groupDetails.id, channelType: chnl) {
            DatabaseManager.deleteFromGroupsTable(groupId: groupDetails.id)
            DatabaseManager.deleteMessagesForChannelId(channelId: chTable.id)
            DatabaseManager.deleteFromMembersTable(globalGroupId: groupDetails.id)
            DatabaseManager.deleteFromChannelTable(channelId: chTable.id)

            navigationController?.popToRootViewController(animated: true)
        }
    }

    func showDeleteGroup() {
        let alertController = UIAlertController(title: "Alert", message: labelStrings.groupAlertClose, preferredStyle: .alert)
        let exitgroup = UIAlertAction(title: "Close Group", style: .default, handler: { _ in

            self.deleteGroup()
        })

        let OKAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(exitgroup)

        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }

    func getPermissionTitle(member: GroupMemberTable) -> String {
        var str = "Member"

        if member.superAdmin == true {
            str = "Super Admin"
        } else if member.addMember {
            str = "Permission: Member"
            if member.album {
                str = "Permission(s): Member, Album"
            }
            if member.publish {
                str = "Permission(s): Member, Album, Publish"
            }
        } else if member.album {
            str = "Permission: Album"
            if member.publish {
                str = "Permission(s): Album, Publish"
            }
        } else if member.publish {
            str = "Permission: Publish"
        }

        return str
    }

    func previewPhoto() {
        if groupDetails.localImagePath != "" {
            let indexpath = IndexPath(row: 0, section: 0)
            let cell = adminsTableview.cellForRow(at: indexpath) as! GroupProfileCell
            let imageView = cell.groupImage

            let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) { [weak self] (_, _) -> UIImageView? in
                guard let self = self else { return nil }

                guard let cell = self.adminsTableview.cellForRow(at: indexpath) else { return nil }

                // adjusting the reference view attached to our transition info to allow for contextual animation
                let cardscell = cell as! GroupProfileCell
                return cardscell.groupImage
            }
            let img = load(attName: groupDetails.localImagePath)
            let str = NSAttributedString(string: "")
            let photos = [AXPhoto(attributedTitle: str, image: img)]

            let dataSource = AXPhotosDataSource(photos: photos)
            let pagingConfig = AXPagingConfig(loadingViewClass: nil)
            let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: pagingConfig, transitionInfo: transitionInfo)
            photosViewController.delegate = self as? AXPhotosViewControllerDelegate
            present(photosViewController, animated: true)
        }
    }

    func checkIfuserSuperAdminALone() {
        let containsImage = groupAllMembersList.filter { $0.superAdmin == true }

        if containsImage.count == 1 {
            let alertController = UIAlertController(title: "Alert", message: labelStrings.groupAlert, preferredStyle: .alert)
//            let exitgroup = UIAlertAction(title: "Delete Group", style: .default, handler: { _ in
//
//                self.deleteGroup()
//            })

            let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
//            alertController.addAction(exitgroup)

            alertController.addAction(OKAction)
            present(alertController, animated: true, completion: nil)

        } else if containsImage.count > 1 {
            let alertController = UIAlertController(title: "Alert", message: labelStrings.groupmemberExitAlert, preferredStyle: .alert)
            let exitgroup = UIAlertAction(title: "Exit Group", style: .default, handler: { _ in

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

        let globeUserId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String

        addGroupmembers.auth = DefaultDataProcessor().getAuthDetails()
        addGroupmembers.groupId = groupDetails.groupGlobalId
        var members: [String] = []
        members.append(globeUserId!)
        addGroupmembers.groupMembers = members
        NetworkingManager.removeGroupMember(addGroupMemberModel: addGroupmembers) { (result: Any, sucess: Bool) in

            if let result = result as? AddGroupMemberResponse, sucess {
                print(result)
                let status = result.status ?? ""
                Loader.close()
                _ = self.navigationController?.popViewController(animated: true)

                if status != "Exception" {
                    let groupMem = GroupMemberTable()
                    groupMem.globalUserId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!
                    groupMem.groupId = self.groupDetails.id
                    groupMem.memberStatus = groupMemberStats.INACTIVE.rawValue
                    DatabaseManager.updateGroupMembersStatus(groupMemebrsTable: groupMem)

                    DatabaseManager.UpdateGroupStatus(groupStatus: groupStats.INACTIVE.rawValue, groupId: self.groupDetails.id)
                    let delegate = UIApplication.shared.delegate as? AppDelegate

                    delegate?.client.unsubscribeFromPresenceChannels([self.channelName + "-pnpres"])

                    self.datadelegate?.userLocationData(clearChat: false)
                    self.getDataForView()
                    Loader.close()
                    self.adminsTableview.reloadData()

                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.alert(message: "Error in exit group")
                }
            }
        }
    }

    func deleteGroup() {
        Loader.show()
        let addGroupmembers = deleteGroupRequest()
        addGroupmembers.auth = DefaultDataProcessor().getAuthDetails()
        addGroupmembers.groupId = groupDetails.groupGlobalId

        NetworkingManager.DeleteGroup(addGroupMemberModel: addGroupmembers) { (result: Any, sucess: Bool) in

            if let result = result as? AddGroupMemberResponse, sucess {
                print(result)
                let status = result.status ?? ""
                Loader.close()

                if status != "Exception" {
                    let groupMem = GroupMemberTable()
                    groupMem.globalUserId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!
                    groupMem.groupId = self.groupDetails.id
                    groupMem.memberStatus = groupMemberStats.INACTIVE.rawValue
                    DatabaseManager.updateGroupMembersStatus(groupMemebrsTable: groupMem)
                    Loader.close()

                    self.deleteGroupData()
                }
            }
        }
    }

    func goToChats(profile: GroupMemberTable) {
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
//                nextVC.loadTableViewData(chnlDetails: chatDisplay)

            nextVC.channelDetails = chatDisplay
            UserDefaults.standard.set(false, forKey: UserKeys.newIntro)

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

    @objc func didTapPluseButton() {
        print("+ clicked")
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACAddGroupMembersViewController") as? ACAddGroupMembersViewController {
            if let navigator = navigationController {
                for memberGlobalUserId in groupMembersList {
                    nextViewController.groupmembersFromExistingGroup.append(memberGlobalUserId.globalUserId)
                }
                nextViewController.secondDelegate = self
                nextViewController.groupID = groupDetails.groupGlobalId
                nextViewController.groupTitle = groupDetails.groupName
                nextViewController.grpType = groupDetails.groupType
                nextViewController.groupDetails = groupDetails

                nextViewController.navigatingFromGroupDetailsViewController = true
                nextViewController.hidesBottomBarWhenPushed = false
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    @objc func didTapMoreButton() {
        print("[][][][]")
    }

    @objc func back() {
        navigationController?.popToRootViewController(animated: true)

//        for controller in self.navigationController!.viewControllers as Array {
//
//            if controller.isKind(of: GroupChatsController.self) {
//                self.navigationController!.popToViewController(controller, animated: true)
//                break
//            }
//        }
    }

    @objc func OnClickOfBack() {
        photoChangedelegate?.photoUpdateData(photoName: groupDetails.localImagePath)
        navigationController?.popViewController(animated: true)
    }

    @objc func onTapOfedit(_: TableViewButton) {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "AcUpdateGroupViewController") as? AcUpdateGroupViewController {
            if let navigator = navigationController {
                nextViewController.groupInfo = groupDetails
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }
}
