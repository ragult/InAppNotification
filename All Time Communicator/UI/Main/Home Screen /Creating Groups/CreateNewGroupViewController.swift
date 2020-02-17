//
//  CreateNewGroupViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 01/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class CreateNewGroupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, passGroupMembers, locationDataDelegate {
    func groupMembersToPass(members: NSArray, btnTitle: Bool) {
        groupMems = members as? [ProfileTable]
        buttonTitleShouldChange = btnTitle
    }

    @IBOutlet var groupProfileImage: UIImageView!
    @IBOutlet var groupNameTextfield: UITextField!
    @IBOutlet var groupTopicTextField: UITextField!
    @IBOutlet var confidentialTriggeringSwitch: UISwitch!
    @IBOutlet var uploadingImageIndicator: UIActivityIndicatorView!
    @IBOutlet var addContactBtnRef: UIButton!
    var createGroupModel = CreateGroupRequestModel()
    var groupId: String?
    var groupMems: [ProfileTable]?
    var buttonTitle: String?
    var getGroupImage: UIImage?
    var groupImageData: Data?
    var confidentialFlag = "0"
    var localImagePath = ""
    var isPublicOrPrivate: String?
    var cloudinaryImageUrl: String?
    var chatGroup: Bool = false
    var privateBroadCast: Bool = false
    var publicBroadCast: Bool = false
    let user = DatabaseManager.getUser()
    var groupMembers: [GroupMemberTable] = []
    var createGroupRequest = CreateGroupRequestModel()
    var buttonTitleShouldChange = false
    var delegate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet var confidentialDescStackView: UIStackView!
    @IBOutlet var confidentialTextLabel: UILabel!
    @IBOutlet var groupName: UILabel!
    @IBOutlet var confidentialDescription: UILabel!

    @IBOutlet var locationVerified: UILabel!
    @IBOutlet var localSerchLabel: UILabel!
    @IBOutlet var leftArrow: UIImageView!

    @IBOutlet var tickImage: UIImageView!
    @IBOutlet var deleteBtn: UIButton!
    @IBOutlet var searchLocationOnMapBtn: UIButton!
    @IBOutlet var lblPublicMember: UILabel!
    @IBOutlet var broadcastDescLabel: UILabel!
    @IBOutlet var groupDescLabel: UILabel!
    @IBOutlet var lblOnlyPrivate: UILabel!

    @IBOutlet var imgPrivateRadio: UIImageView!
    @IBOutlet var imgPublicRadio: UIImageView!
    @IBOutlet var hideView: UIView!

    @IBOutlet weak var validate: UILabel!
    @IBOutlet var whoCanReceiveLabelHeight: NSLayoutConstraint!
    @IBOutlet var whoCanRecevieBroadcast: UILabel!
    @IBOutlet var groupChoiceStackView: UIStackView!
    @IBOutlet var confidentialStackView: UIStackView!

    func userLocationData(info: String, locationId: String, address: String) {
        locationVerified.text = info
        deleteBtn.isHidden = false
        tickImage.isHidden = false
        localSerchLabel.isHidden = false
        localSerchLabel.text = "Qualified for local search"
        validate.isHidden = true
        leftArrow.isHidden = true
        groupLocationId = locationId
        locationVerified.isHidden = false
        self.address = address
    }

    @IBAction func deleteAction(_ sender: Any) {
        self.groupLocationId = ""
        self.address = ""
        self.locationVerified.text = ""
        localSerchLabel.text = "Qualify for local search"
        deleteBtn.isHidden = true
        tickImage.isHidden = true
        localSerchLabel.isHidden = false
        validate.isHidden = false
        leftArrow.isHidden = false
        locationVerified.isHidden = true

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        hideView.isHidden = false
        imgPrivateRadio.image = UIImage(named: "radioUnselect")
        imgPublicRadio.image = UIImage(named: "radioSelect")
        isPublicOrPrivate = "Public"
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(CreateNewGroupViewController.PrivateMember(sender:)))
        lblOnlyPrivate.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(CreateNewGroupViewController.publicMember(sender:)))
        lblPublicMember.addGestureRecognizer(tap2)

        groupProfileImage.backgroundColor = .black
        uploadingImageIndicator.hidesWhenStopped = true
        uploadingImageIndicator.color = UIColor(r: 33, g: 140, b: 141)
        confidentialTriggeringSwitch.transform = CGAffineTransform(scaleX: 0.72, y: 0.72)
        groupNameTextfield.borderStyle = .roundedRect
        groupTopicTextField.borderStyle = .roundedRect
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        groupProfileImage.isUserInteractionEnabled = true
        groupProfileImage.addGestureRecognizer(tapGestureRecognizer)
        if privateBroadCast == true {
            hideView.isHidden = false
            confidentialStackView.isHidden = true
            whoCanReceiveLabelHeight.constant = 0
            groupChoiceStackView.isHidden = true
//            self.confidentialTextLabel.isHidden = true
//            self.confidentialTriggeringSwitch.isHidden = true
            confidentialTextLabel.text = "Private Broadcast"
            confidentialDescription.isHidden = true
            groupName.text = "Group Name"
            broadcastDescLabel.isHidden = false
            leftArrow.isHidden = false
            localSerchLabel.isHidden = false
            searchLocationOnMapBtn.isHidden = false
            UserDefaults.standard.set(false, forKey: "locationSuccess")
            UserDefaults.standard.removeObject(forKey: "locationname")
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Broadcast group", style: .plain, target: nil, action: nil)

        } else {
//            self.confidentialTextLabel.isHidden = false
//            self.confidentialTriggeringSwitch.isHidden = false
            hideView.isHidden = true
            confidentialStackView.isHidden = true
            whoCanReceiveLabelHeight.constant = 0
            groupChoiceStackView.isHidden = true
            broadcastDescLabel.isHidden = true
            searchLocationOnMapBtn.isHidden = true

            confidentialDescription.isHidden = false

            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Group chat", style: .plain, target: nil, action: nil)
        }
        groupDescLabel.text = "Description"
    }

    override func viewWillAppear(_: Bool) {}

    override func viewDidAppear(_: Bool) {
        modifyButtonTitle()
    }

    @objc func publicMember(sender _: UITapGestureRecognizer) {
        print("public")
        searchLocationOnMapBtn.isHidden = false
        localSerchLabel.isHidden = false
        leftArrow.isHidden = false
        isPublicOrPrivate = "Public"
        imgPrivateRadio.image = UIImage(named: "radioUnselect")
        imgPublicRadio.image = UIImage(named: "radioSelect")
    }

    @objc func PrivateMember(sender _: UITapGestureRecognizer) {
        print("private")
        searchLocationOnMapBtn.isHidden = true
        localSerchLabel.isHidden = true
        leftArrow.isHidden = true
        isPublicOrPrivate = "Private"
        imgPrivateRadio.image = UIImage(named: "radioSelect")
        imgPublicRadio.image = UIImage(named: "radioUnselect")
    }

    func modifyButtonTitle() {
        if buttonTitleShouldChange == true {
            if privateBroadCast == true {
                addContactBtnRef.setTitle("CREATE GROUP", for: .normal)
                addContactBtnRef.setNeedsLayout()

            } else {
                addContactBtnRef.setTitle("CREATE GROUP", for: .normal)
            }
        }
    }

    @IBAction func confidentialSwitchAction(_: Any) {
        if confidentialTriggeringSwitch.isOn == true {
            confidentialFlag = "1"
        } else {
            confidentialFlag = "0"
        }
    }

    @objc func imageTapped(tapGestureRecognizer _: UITapGestureRecognizer) {
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                CameraHandler.shared.showActionSheet(vc: self)
                CameraHandler.shared.imagePickedBlock = { groupImage in
                    self.groupProfileImage.image = UIImage.resizedCroppedImage(image: groupImage, newSize: CGSize(width: self.groupProfileImage.frame.width, height: self.groupProfileImage.frame.height))
                    self.getGroupImage = groupImage
                    let resizedImage: UIImage? = groupImage.resizedTo500Kb()
                    self.groupImageData = resizedImage?.pngData()
                    self.uploadingImageIndicator.startAnimating()
                    self.addContactBtnRef.isEnabled = false
                    self.addContactBtnRef.backgroundColor = .gray
                    // self.groupProfileImage.addBlur()
                    self.groupProfileImage.alpha = 0.1
                    if self.delegate != nil {
                        if (self.delegate?.isInternetAvailable)! {
                            if let data = self.groupImageData {
                                ACImageDownloader.downloadImageForLocalPath(imageData: data, ref: "", completionHandler: { (success, _) -> Void in

                                    print(success)
                                    self.localImagePath = success

                                    if let data = self.groupImageData {
                                        let config = AWSManager.instance.getConfig(
                                            gType: self.getGroupType(),
                                            isChat: false,
                                            isProfile: true,
                                            isGroup: true,
                                            fileName: success,
                                            type: s3BucketName.imageType
                                        )

                                        AWSManager.instance.uploadDataS3(config: config, data: data, completionHandler: { url, error in

                                            DispatchQueue.main.async { () in

                                                if error == nil {
                                                    // s3BucketName.profileBucketName
                                                    self.cloudinaryImageUrl = url
                                                    self.uploadingImageIndicator.stopAnimating()
                                                    self.groupProfileImage.alpha = 1
                                                    // self.groupProfileImage.removeBlur()
                                                    self.addContactBtnRef.backgroundColor = UIColor(r: 33, g: 140, b: 141)
                                                    self.addContactBtnRef.isEnabled = true
                                                }
                                            }

                                        })
                                    }
                                })
                            }

                        } else {
                            self.alert(message: "Internet is required")
                        }
                    }
                }
            } else {
                alert(message: "Internet is required")
            }
        }
    }

    func getGroupType() -> String {
        if chatGroup == true {
            return groupType.GROUP_CHAT.rawValue
        } else if privateBroadCast == true, isPublicOrPrivate == "Private" {
            return groupType.PRIVATE_GROUP.rawValue
        } else if privateBroadCast == true {
            return groupType.PUBLIC_GROUP.rawValue
        } else {
            return groupType.PRIVATE_GROUP.rawValue
        }
    }

    @IBAction func onClickOfMapButton(_: Any) {
        let storyBoard = UIStoryboard(name: "OnBoarding", bundle: nil)
        if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ACLocationSelectionViewController") as? ACLocationSelectionViewController {
            nextViewController.datadelegate = self
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }

    var groupLocationId = ""
    var address: String = ""
    @IBAction func addContactAction(_: UIButton) {
//        addContactBtnRef .setTitle("CREATE GROUP", for: .normal)
        if groupNameTextfield.text?.count == 0 {
            alert(message: "please enter group name")
        } else if groupMems?.count == nil, groupNameTextfield.text?.count != 0 {
            print("No group members")
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACAddGroupMembersViewController") as? ACAddGroupMembersViewController {
                if let navigator = self.navigationController {
                    nextViewController.delegate = self
                    nextViewController.hidesBottomBarWhenPushed = true
                    navigator.pushViewController(nextViewController, animated: true)
                    nextViewController.createGroupFromAddButton = true
                }
            }
        } else if (cloudinaryImageUrl ?? "") == "",
            getGroupType() == groupType.PUBLIC_GROUP.rawValue
            || getGroupType() == groupType.PRIVATE_GROUP.rawValue {
            alert(message: "Photo is required")
        } else {
            if delegate != nil {
                if (delegate?.isInternetAvailable)! {
                    var members: [String] = []
                    for member in groupMems! {
                        members.append(member.globalUserId)
                    }
                    createGroupRequest.groupMembers = members
                    print(createGroupRequest.groupMembers.count)
                    if createGroupRequest.groupMembers.count > 0 {
                        addContactBtnRef.titleLabel?.text = buttonTitle
                        Loader.show()
                        let group = GroupTable()

                        createGroupRequest.auth = DefaultDataProcessor().getAuthDetails()
                        createGroupRequest.confidentialFlag = confidentialFlag
                        createGroupRequest.createdBy = user?.globalUserId ?? ""
                        createGroupRequest.fullImageUrl = cloudinaryImageUrl ?? ""
                        createGroupRequest.groupDescription = groupTopicTextField.text ?? ""
                        createGroupRequest.name = groupNameTextfield.text ?? ""
                        createGroupRequest.groupStatus = "1"
                        createGroupModel.address = address
                        createGroupRequest.groupLocationId = groupLocationId
                        createGroupRequest.type = getGroupType()

                        NetworkingManager.createGroup(createGroupModel: createGroupRequest) { (result: Any, sucess: Bool) in
                            if let result = result as? createGroupResponseModel, sucess {
                                if result.status == "Success" {
                                    group.groupGlobalId = result.data?.first?.groupId ?? ""
                                    group.groupName = self.groupNameTextfield.text ?? ""
                                    group.groupType = self.createGroupRequest.type
                                    group.groupDescription = self.groupTopicTextField.text ?? ""
                                    group.confidentialFlag = self.confidentialFlag
                                    group.fullImageUrl = self.cloudinaryImageUrl ?? ""
                                    group.thumbnailUrl = ""
                                    group.groupStatus = groupStats.ACTIVE.rawValue
                                    group.createdBy = self.user?.globalUserId ?? ""
                                    
                                    group.publicGroupCode = result.data?.first?.publicGroupCode ?? ""
                                    group.qrURL = result.data?.first?.qrCode ?? ""
                                    group.webUrl = result.data?.first?.webUrl ?? ""
                                    group.qrCode = result.data?.first?.qrCode ?? ""
                                    
                                    group.createdOn = self.getCurrentDate()
                                    group.createdByThumbnailUrl = self.user?.picture ?? ""
                                    group.createdByMobileNumber = self.user?.phoneNumber ?? ""
                                    group.localImagePath = self.localImagePath
                                    group.address = self.address
                                    if DatabaseManager.getGroupIndex(groupGlobalId: result.data?.first?.groupId ?? "") != nil {
                                        let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: result.data?.first?.groupId ?? "")
                                        group.id = (groupIdTable?.id)!
                                    } else {
                                        let groupId = DatabaseManager.storeGroup(groupTable: group)
                                        group.id = String(groupId)
                                        let selfUser = DatabaseManager.getSelfContactDetails()
                                        self.groupMems?.append(selfUser!)
                                        for member in self.groupMems! {
                                            let getMember = GroupMemberTable()
                                            getMember.globalUserId = member.globalUserId
                                            getMember.groupMemberContactId = member.id
                                            getMember.groupId = String(groupId)
                                            getMember.memberName = member.fullName
                                            getMember.thumbUrl = member.picture
                                            getMember.phoneNumber = member.phoneNumber
                                            getMember.memberStatus = "1"
                                            getMember.createdBy = (self.user?.globalUserId)!
                                            getMember.createdOn = group.createdOn

                                            if getMember.globalUserId == self.user?.globalUserId {
                                                getMember.addMember = true
                                                getMember.superAdmin = true
                                                getMember.events = true
                                                getMember.album = true
                                                getMember.publish = true
                                            }

                                            _ = DatabaseManager.storeGroupMembers(groupMemebrsTable: getMember)
                                        }

                                        if DatabaseManager.getChannelIndex(contactId: String(groupId), channelType: "1") == nil {
                                            //to store to channel table

                                            let channel = ChannelTable()
                                            channel.contactId = String(groupId)
                                            //        channel.ID = group.groupId
                                            channel.channelType = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: self.createGroupRequest.type)
                                            channel.globalChannelName = result.data?.first?.channelName ?? ""
                                            channel.channelStatus = "0"
                                            channel.unseenCount = "0"
                                            let chnlId = DatabaseManager.storeChannelData(channelTable: channel)
                                            channel.id = String(chnlId)
                                            ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: channelType(rawValue: channel.channelType)!, messageType: messagetype.OTHER, messageText: "You have created the group", messageOtherType: otherMessageType.INFO, senderId: group.createdBy, channelId: String(chnlId), channel: channel)
                                        }
                                    }

//                                            let pubnubNotication = ACPubnubClass()
//                                            pubnubNotication.subscribeToPubnubNotificationForGroup(groupChannelId: result.data?.first?.channelName ?? "")

                                    DispatchQueue.main.async {
                                        Loader.close()
                                    }
                                    if group.groupType == groupType.GROUP_CHAT.rawValue {
                                        self.GotoChatView(groups: group)
                                    } else {
                                        self.GototopicChatView(groups: group)
                                    }

                                } else {
                                    Loader.close()
                                    if result.status == "Exception" {
                                        let errorMsg = result.errorMsg[0]
                                        if errorMsg == "IU-100" || errorMsg == "AUT-101" {
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
                    alert(message: "Internet is required")
                }
            }
        }
    }

    func GotoChatView(groups: GroupTable) {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
            if let navigator = navigationController {
                nextViewController.hidesBottomBarWhenPushed = true
                nextViewController.navigationController?.navigationBar.isHidden = true
                nextViewController.getIsConfidential = groups.confidentialFlag.boolValue
                let channelDIspObj = ChannelDisplayObject()
                let chnl = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: groups.groupType)

                if let chTable = DatabaseManager.getChannelIndex(contactId: groups.id, channelType: chnl) {
                    channelDIspObj.channelId = chTable.id
                    channelDIspObj.globalChannelName = chTable.globalChannelName
                    channelDIspObj.channelType = chTable.channelType
                    channelDIspObj.lastSenderPhoneBookContactId = chTable.contactId
                } else {
                    let chTable = DatabaseManager.getChannelIndex(contactId: groups.id, channelType: "1")
                    channelDIspObj.channelId = (chTable?.id)!
                    channelDIspObj.globalChannelName = (chTable?.globalChannelName)!
                    channelDIspObj.channelType = (chTable?.channelType)!
                    channelDIspObj.lastSenderPhoneBookContactId = (chTable?.contactId)!
                }
                nextViewController.customNavigationBar(name: groups.groupName, image: groups.localImagePath, channelTyp: channelType(rawValue: channelDIspObj.channelType)!)

                //                nextViewController.loadTableViewData(chnlDetails: channelDIspObj)

                nextViewController.channelDetails = channelDIspObj
                nextViewController.displayName = groups.groupName
                nextViewController.displayImage = groups.localImagePath
                nextViewController.isViewFirstTime = true
                nextViewController.isViewFirstTimeLoaded = true
                nextViewController.isScrollToBottom = true
                nextViewController.isFromContacts = true
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    func GototopicChatView(groups: GroupTable) {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACSpeakerCardsViewController") as? ACSpeakerCardsViewController {
            if let navigator = navigationController {
                nextViewController.hidesBottomBarWhenPushed = true
                nextViewController.navigationController?.navigationBar.isHidden = true
                nextViewController.customNavigationBar(name: groups.groupName, image: groups.localImagePath)

                let channelDIspObj = ChannelDisplayObject()
                let chnl = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: groups.groupType)

                if let chTable = DatabaseManager.getChannelIndex(contactId: groups.id, channelType: chnl) {
                    channelDIspObj.channelId = chTable.id
                    channelDIspObj.globalChannelName = chTable.globalChannelName
                    channelDIspObj.channelType = chTable.channelType
                    channelDIspObj.lastSenderPhoneBookContactId = chTable.contactId
                } else {
                    let chTable = DatabaseManager.getChannelIndex(contactId: groups.id, channelType: "1")
                    channelDIspObj.channelId = (chTable?.id)!
                    channelDIspObj.globalChannelName = (chTable?.globalChannelName)!
                    channelDIspObj.channelType = (chTable?.channelType)!
                    channelDIspObj.lastSenderPhoneBookContactId = (chTable?.contactId)!
                }
                nextViewController.displayName = groups.groupName
                nextViewController.groupType = groups.groupType

                nextViewController.channelDetails = channelDIspObj
                nextViewController.channelId = channelDIspObj.channelId

                nextViewController.isViewFirstTime = true
                nextViewController.isViewFirstTimeLoaded = true
                nextViewController.isfromNotifications = true
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    func getCurrentDate() -> String {
        // according to date format your date string
        let date = NSDate().timeIntervalSince1970
        // Date to String

        return String(format: "%.0f", date)
    }
}
