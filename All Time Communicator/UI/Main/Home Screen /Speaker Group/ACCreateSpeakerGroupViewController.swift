//
//  CreateNewGroupViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 01/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class ACCreateSpeakerGroupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, passGroupMembers {
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
    var cloudinaryImageUrl: String?
    var chatGroup: Bool = false
    var privateBroadCast: Bool = false
    var publicBroadCast: Bool = false
    let user = DatabaseManager.getUser()
    var groupMembers: [GroupMemberTable] = []
    var createGroupRequest = CreateGroupRequestModel()
    var buttonTitleShouldChange = false
    var delegate = UIApplication.shared.delegate as? AppDelegate
    var localImagePath = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        groupProfileImage.backgroundColor = .black
        uploadingImageIndicator.hidesWhenStopped = true
        uploadingImageIndicator.color = UIColor(r: 33, g: 140, b: 141)
        confidentialTriggeringSwitch.transform = CGAffineTransform(scaleX: 0.72, y: 0.72)
        groupNameTextfield.borderStyle = .roundedRect
        groupTopicTextField.borderStyle = .roundedRect
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        groupProfileImage.isUserInteractionEnabled = true
        groupProfileImage.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewWillAppear(_: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications
        navigationController?.navigationBar.backItem?.title = ""
    }

    override func viewDidAppear(_: Bool) {
        modifyButtonTitle()
    }

    func modifyButtonTitle() {
        if buttonTitleShouldChange == true {
//            addContactBtnRef.titleLabel?.text = "CREATE GROUP"
            addContactBtnRef.setTitle("CREATE GROUP", for: .normal)
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
                                            gType: groupType.PRIVATE_GROUP.rawValue,
                                            isChat: false,
                                            isProfile: true,
                                            isGroup: true,
                                            fileName: success,
                                            type: s3BucketName.imageType
                                        )

                                        AWSManager.instance.uploadDataS3(config: config, data: data, completionHandler: { (url, error) in

                                            if error == nil {
                                                // s3BucketName.profileBucketName
                                                self.cloudinaryImageUrl = url
                                                self.uploadingImageIndicator.stopAnimating()
                                                self.groupProfileImage.alpha = 1
                                                // self.groupProfileImage.removeBlur()
                                                self.addContactBtnRef.backgroundColor = UIColor(r: 33, g: 140, b: 141)
                                                self.addContactBtnRef.isEnabled = true
                                            }
                                        })
                                    }

                                })
                            }

                        } else {
                            self.delegate?.showCustomAlert()
                        }
                    }

                    print("clicked")
                }
            } else {
                alert(message: "Internet is required")
            }
        }
    }

    @IBAction func addContactAction(_: UIButton) {
//        addContactBtnRef.titleLabel?.text = "CREATE GROUP"
        addContactBtnRef.setTitle("CREATE GROUP", for: .normal)
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
        } else if (cloudinaryImageUrl ?? "") == "" {
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

                        // MARK: TOPIC_GROUP updated to PRIVATE_GROUP

                        createGroupRequest.type = groupType.PRIVATE_GROUP.rawValue

                        NetworkingManager.createGroup(createGroupModel: createGroupRequest) { (result: Any, sucess: Bool) in
                            if let results = result as? createGroupResponseModel, sucess {
                                if sucess {
                                    if results.status == "Success" {
                                        group.groupGlobalId = results.data?.first?.groupId ?? ""
                                        group.groupName = self.groupNameTextfield.text ?? ""
                                        group.groupType = self.createGroupRequest.type
                                        group.groupDescription = self.groupTopicTextField.text ?? ""
                                        group.confidentialFlag = self.confidentialFlag
                                        group.fullImageUrl = self.cloudinaryImageUrl ?? ""
                                        group.thumbnailUrl = ""
                                        group.groupStatus = groupStats.ACTIVE.rawValue
                                        group.createdBy = self.user?.globalUserId ?? ""
                                        group.webUrl = results.data?.first?.webUrl ?? ""
                                        group.createdOn = self.getCurrentDate()
                                        group.createdByThumbnailUrl = self.user?.picture ?? ""
                                        group.createdByMobileNumber = self.user?.phoneNumber ?? ""
                                        group.localImagePath = self.localImagePath
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
                                            channel.channelType = channelType.PRIVATE_GROUP.rawValue
                                            channel.globalChannelName = results.data?.first?.channelName ?? ""
                                            channel.channelStatus = "0"
                                            channel.unseenCount = "0"
                                            _ = DatabaseManager.storeChannelData(channelTable: channel)
                                        }

                                        DispatchQueue.main.async {
                                            Loader.close()
                                        }
                                        self.GotoChatView(groups: group)
                                    }
                                } else {
                                    Loader.close()
                                    if results.status == "Exception" {
                                        let errorMsg = results.errorMsg[0]
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
                    fatalError("Please check the logic here for Correct channel Id implementation to query from channel table")
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

        return String(date)
    }
}
