//
//  Group_Chat_List_ViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 23/10/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import LocalAuthentication
import SwiftEventBus
import UIKit

class Group_Chat_List_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var noChatView: UIView!
//    @IBOutlet var searchHeight: NSLayoutConstraint!
//    @IBOutlet var serachbar: UIView!
    @IBOutlet var channelTableView: UITableView!
    private let OTP_MAX_LENGTH = 4

    @IBOutlet weak var searchbarButtonItem: UIBarButtonItem!
    var channels = [ChannelDisplayObject]()
    var userDetails = DatabaseManager.getUser()
    var isViewActive: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchbarButtonItem.tintColor = .clear
//         searchHeight.constant = 0
        channelTableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        channelTableView.register(UINib(nibName: "ConfidentialGroupCell", bundle: nil), forCellReuseIdentifier: "cell2")

        let backItem = UIBarButtonItem()
        backItem.title = "Contacts"
        navigationItem.backBarButtonItem = backItem
        channelTableView.dataSource = self
        channelTableView.delegate = self
        channelTableView.tableFooterView = UIView()
        listenToEventbus()
    }

//    override func viewDidLayoutSubviews() {
//        searchHeight.constant = 0
//        self.serachbar.layoutIfNeeded()
//    }

    func listenToEventbus() {
        // for new message received

        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.channelUpdated) { notification in
            if self.isViewActive {
                let eventObj: eventObject = notification!.object as! eventObject
                let channel = eventObj.channelObject
                if (channel?.channelType)! == channelType.ONE_ON_ONE_CHAT.rawValue || (channel?.channelType)! == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue || (channel?.channelType)! == channelType.GROUP_CHAT.rawValue || (channel?.channelType)! == channelType.ADHOC_CHAT.rawValue {
                    if self.channels.contains(where: { $0.channelId == channel!.id }) {
                        // found
                        let results = self.channels.filter { $0.channelId == channel!.id }
                        if results.isEmpty == false {
                            self.channels.remove(object: results[0])
                            let channelObject = ChannelDisplayObject()

                            channelObject.channelId = channel!.id
                            channelObject.channelType = channel!.channelType
                            channelObject.unseenCount = channel!.unseenCount
                            channelObject.lastMessageIdOfChannel = channel!.lastSavedMsgid
                            channelObject.lastMessageTime = channel!.lastMsgTime
                            channelObject.lastSenderPhoneBookContactId = channel!.contactId
                            channelObject.globalChannelName = channel!.globalChannelName

                            self.channels.insert(channelObject, at: 0)
                        }

                    } else {
                        let channelObject = ChannelDisplayObject()
                        channelObject.channelId = channel!.id
                        channelObject.channelType = channel!.channelType
                        channelObject.unseenCount = channel!.unseenCount
                        channelObject.lastMessageIdOfChannel = channel!.lastSavedMsgid
                        channelObject.lastMessageTime = channel!.lastMsgTime
                        channelObject.lastSenderPhoneBookContactId = channel!.contactId
                        channelObject.globalChannelName = channel!.globalChannelName

                        self.channels.insert(channelObject, at: 0)
                    }
                    DispatchQueue.main.async {
                        if self.noChatView.isHidden == false {
                            self.noChatView.isHidden = true
                        }
                        self.channelTableView.reloadData()
                    }
                }
                //            SwiftEventBus.postToMainThread("updateText")
            }
        }
    }

    override func viewWillAppear(_: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.showRecentChatNotifications
        isViewActive = true
        getChannelDetails()
    }

    override func viewWillDisappear(_: Bool) {
        isViewActive = false
    }

    func getChannelDetails() {
        let channelList = DatabaseManager.fetchChannel()
        channels.removeAll()
        if channelList != nil {
            noChatView.isHidden = true
            if channelList?.count == 0 {
                noChatView.isHidden = false
            } else {
                for channel in channelList! {
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

                channels = channels.sorted(by: {
                    $0.lastMessageTime.compare($1.lastMessageTime) == .orderedDescending
                })
            }

        } else {
            noChatView.isHidden = false
        }
        channelTableView.reloadData()
    }

    // MARK: TableViews

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return channels.count
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let channelCell = channelTableView.dequeueReusableCell(withIdentifier:"channelCell") as! ChannelTableViewCell
        let channelCell = channelTableView.dequeueReusableCell(withIdentifier: "cell") as! ChannelTableViewCell

        let channelTableList = channels[indexPath.row]
        channelCell.confidentialImage.isHidden = true
        channelCell.channelMessageLabel.isHidden = false
        channelCell.selectionStyle = .none
        channelCell.sentStatus.isHidden = true
        channelCell.attachIcon.isHidden = true
        channelCell.userNameLabel.text = "No new Messages available"
        if channelTableList.channelDisplayNames == "" {
            // find channel type
            switch channelTableList.channelType {
            case channelType.GROUP_CHAT.rawValue:
                let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                channelTableList.channelDisplayNames = (groupTable?.groupName)!

                if groupTable?.localImagePath == "" {
                    channelTableList.channelImageUrl = ""

                    if groupTable?.fullImageUrl != "" {
                        downLoadImagesforIndexPath(index: indexPath, downloadImage: (groupTable?.fullImageUrl)!, groupId: (groupTable?.id)!)
                    }

                } else {
                    channelTableList.channelImageUrl = (groupTable?.localImagePath)!
                }
                channelCell.channelImageView.image = UIImage(named: "icon_DefaultGroup")
                if groupTable?.confidentialFlag == "1" {
                    channelCell.confidentialImage.isHidden = false
                    channels[indexPath.row].isConfidential = (groupTable?.confidentialFlag)!
                }

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
                channelCell.channelImageView.image = UIImage(named: "icon_DefaultMutual")
            case channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue:

                let contactDetails = DatabaseManager.getGroupMemberIndexForMemberId(groupId: channelTableList.lastSenderPhoneBookContactId)
                let groupDetail = DatabaseManager.getGroupDetail(groupGlobalId: (contactDetails?.groupId)!)

                channelTableList.channelDisplayNames = (contactDetails?.memberName)! + "( via \(groupDetail?.groupName ?? ""))"

                if contactDetails?.localImagePath == "" {
                    channelTableList.channelImageUrl = ""
                    if contactDetails?.thumbUrl != "" {
                        downLoadGroupMemberImagesforIndexPath(index: indexPath, downloadImage: (contactDetails?.thumbUrl)!, groupId: (contactDetails?.globalUserId)!)
                    }
                } else {
                    channelTableList.channelImageUrl = (contactDetails?.localImagePath)!
                }
                channelCell.channelImageView.image = UIImage(named: "icon_DefaultMutual")

            case channelType.ADHOC_CHAT.rawValue:
                let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                channelTableList.channelDisplayNames = (groupTable?.groupName)!

                if groupTable?.localImagePath == "" {
                    channelTableList.channelImageUrl = ""
                    if groupTable?.fullImageUrl != "" {
                        downLoadImagesforIndexPath(index: indexPath, downloadImage: (groupTable?.fullImageUrl)!, groupId: (groupTable?.id)!)
                    }
                } else {
                    channelTableList.channelImageUrl = (groupTable?.localImagePath)!
                }

                channelCell.channelImageView.image = UIImage(named: "icon_DefaultGroup")

            default:
                print("do nothing")
                channelCell.channelImageView.image = UIImage(named: "icon_DefaultGroup")
            }
        }

        channelCell.channelNameLabel.text = channelTableList.channelDisplayNames
        if channelTableList.channelImageUrl != "" {
            channelCell.channelImageView.image = load(attName: channelTableList.channelImageUrl)
        } else {
            if channelTableList.channelType == channelType.GROUP_CHAT.rawValue || channelTableList.channelType == channelType.ADHOC_CHAT.rawValue {
                channelCell.channelImageView.image = UIImage(named: "icon_DefaultGroup")
            } else {
                channelCell.channelImageView.image = LetterImageGenerator.imageWith(name: channelTableList.channelDisplayNames, randomColor: .gray)
            }
        }

        if channels[indexPath.row].isConfidential == "1" {
            channelCell.confidentialImage.isHidden = false
            channelCell.sentStatus.isHidden = true
            channelCell.attachIcon.isHidden = true

            let text = "--- Confidential ---"
            let completeText = NSMutableAttributedString(string: text)

            channelCell.channelMessageLabel.textAlignment = .left
            channelCell.channelMessageLabel.attributedText = completeText

            if let message = DatabaseManager.getMessage(messageId: channelTableList.lastMessageIdOfChannel) {
                if message.isMine {
                    // Create Attachment
                    channelCell.userNameLabel.text = "You:"
                } else {
                    if message.channelType != channelType.ONE_ON_ONE_CHAT.rawValue, message.channelType != channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                        let name = getUserName(message: message)
                        channelCell.userNameLabel.text = name + ":"
                        //                         completeText = NSMutableAttributedString(string: name + ":\n")

                    } else {
                        channelCell.userNameLabel.text = "Received:"
                    }
                }
            } else {
                if let message = DatabaseManager.getLatestMessage(channelId: channelTableList.channelId, channelType: channelTableList.channelType) {
                    let type = message.messageType
                    if type == messagetype.OTHER.rawValue {
                        let oTyp = message.otherType
                        if oTyp == otherMessageType.INFO.rawValue {
                            channelCell.sentStatus.isHidden = true

                            channelCell.userNameLabel.text = "Info:"
                        }
                    }
                }
            }

        } else {
            channelCell.confidentialImage.isHidden = true

            if let message = DatabaseManager.getMessage(messageId: channelTableList.lastMessageIdOfChannel) {
                channelCell.sentStatus.isHidden = true

                if message.isMine {
                    channelCell.userNameLabel.text = "You:"

                    // Initialize mutable string
                    let completeText = NSMutableAttributedString(string: "")

                    if message.visibilityStatus != visibilityStatus.deleted.rawValue {
                        if message.messageType == messagetype.OTHER.rawValue {
                            let oTyp = message.otherType
                            if oTyp == otherMessageType.INFO.rawValue {
                                channelCell.userNameLabel.text = "Info:"
                            } else {
                                channelCell.sentStatus.isHidden = false
                                // Create Attachment

                                let imageAttachment = NSTextAttachment()
                                channelCell.sentStatus.image = getMessageStatus(msgState: messageState(rawValue: message.messageState)!)
                                imageAttachment.setImageHeight(height: 8)

                                // Create string with attachment
                                let attachmentString = NSAttributedString(attachment: imageAttachment)
                                // Add image to mutable string
                                completeText.append(attachmentString)
                            }
                        } else {
                            // Create Attachment
                            channelCell.sentStatus.isHidden = false

                            let imageAttachment = NSTextAttachment()
                            channelCell.sentStatus.image = getMessageStatus(msgState: messageState(rawValue: message.messageState)!)
                            imageAttachment.setImageHeight(height: 8)

                            // Create string with attachment
                            let attachmentString = NSAttributedString(attachment: imageAttachment)
                            // Add image to mutable string
                            completeText.append(attachmentString)
                        }
                    }

                    channelCell.attachIcon.isHidden = true

                    let attachmentImg = NSTextAttachment()
                    var text = message.text
                    if message.visibilityStatus == visibilityStatus.deleted.rawValue {
                        text = "Message deleted"
                    } else {
                        if message.messageType != messagetype.TEXT.rawValue {
                            channelCell.attachIcon.isHidden = false

                            switch message.messageType {
                            case messagetype.IMAGE.rawValue:
                                channelCell.attachIcon.image = UIImage(named: "recent_gallery")
                                text = " Photo"
                                attachmentImg.setImageHeight(height: 13)
                                let spaceText = NSMutableAttributedString(string: "  ")
                                completeText.append(spaceText)
                                let attachString = NSAttributedString(attachment: attachmentImg)
                                completeText.append(attachString)
                                let textAfterIcon = NSMutableAttributedString(string: " ")
                                completeText.append(textAfterIcon)

                            case messagetype.VIDEO.rawValue:
                                channelCell.attachIcon.image = UIImage(named: "recent_video1")
                                text = " Video"
                                attachmentImg.setImageHeight(height: 13)
                                let spaceText = NSMutableAttributedString(string: "  ")
                                completeText.append(spaceText)
                                let attachString = NSAttributedString(attachment: attachmentImg)
                                completeText.append(attachString)
                                let textAfterIcon = NSMutableAttributedString(string: " ")
                                completeText.append(textAfterIcon)

                            case messagetype.AUDIO.rawValue:
                                channelCell.attachIcon.image = UIImage(named: "recent_audio")
                                text = " Audio"
                                attachmentImg.setImageHeight(height: 13)
                                let spaceText = NSMutableAttributedString(string: "  ")
                                completeText.append(spaceText)
                                let attachString = NSAttributedString(attachment: attachmentImg)
                                completeText.append(attachString)
                                let textAfterIcon = NSMutableAttributedString(string: " ")
                                completeText.append(textAfterIcon)

                            case messagetype.OTHER.rawValue:
                                let oTyp = message.otherType
                                if oTyp == otherMessageType.INFO.rawValue {
                                    text = "" + text
                                    channelCell.attachIcon.isHidden = true

                                } else {
                                    if oTyp == otherMessageType.TEXT_POLL.rawValue {
                                        channelCell.attachIcon.image = UIImage(named: "pollSmall")
                                        text = " Text poll"
                                    } else if oTyp == otherMessageType.IMAGE_POLL.rawValue {
                                        channelCell.attachIcon.image = UIImage(named: "pollSmall")
                                        text = " Image poll"
                                    } else {
                                        channelCell.attachIcon.image = UIImage(named: "recent_gallery")
                                        text = " Media"
                                    }
                                    attachmentImg.setImageHeight(height: 13)
                                    let spaceText = NSMutableAttributedString(string: "  ")
                                    completeText.append(spaceText)
                                    let attachString = NSAttributedString(attachment: attachmentImg)
                                    completeText.append(attachString)
                                    let textAfterIcon = NSMutableAttributedString(string: " ")
                                    completeText.append(textAfterIcon)
                                }

                            default:
                                print("do nothing")
                            }
                        } else {
                            text = "" + text
                        }
                    }

                    // Add your text to mutable string
                    let textAfterIcon = NSMutableAttributedString(string: text)
                    completeText.append(textAfterIcon)

                    channelCell.channelMessageLabel.textAlignment = .left
                    channelCell.channelMessageLabel.text = text

                } else {
                    var completeText = NSMutableAttributedString(string: "")

                    if message.channelType != channelType.ONE_ON_ONE_CHAT.rawValue, message.channelType != channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                        let name = getUserName(message: message)
                        channelCell.userNameLabel.text = name + ":"
//                         completeText = NSMutableAttributedString(string: name + ":\n")

                    } else {
                        channelCell.userNameLabel.text = "Received:"
                    }

                    if message.messageType == messagetype.OTHER.rawValue {
                        let oTyp = message.otherType
                        if oTyp == otherMessageType.INFO.rawValue {
                            channelCell.userNameLabel.text = "Info:"
                        }
                    }

                    let attachmentImg = NSTextAttachment()

                    var text = message.text
                    channelCell.attachIcon.isHidden = true

                    if message.visibilityStatus == visibilityStatus.deleted.rawValue {
                        text = "Message deleted"
                    } else {
                        if message.messageType != messagetype.TEXT.rawValue {
                            channelCell.attachIcon.isHidden = false
                            switch message.messageType {
                            case messagetype.IMAGE.rawValue:
                                channelCell.attachIcon.image = UIImage(named: "recent_gallery")
                                text = " Photo"
                                attachmentImg.setImageHeight(height: 13)
                                let spaceText = NSMutableAttributedString(string: "")
                                completeText.append(spaceText)
                                let attachString = NSAttributedString(attachment: attachmentImg)
                                completeText.append(attachString)
                                let textAfterIcon = NSMutableAttributedString(string: " ")
                                completeText.append(textAfterIcon)

                            case messagetype.VIDEO.rawValue:
                                channelCell.attachIcon.image = UIImage(named: "recent_video1")
                                //                            if text == "" {
                                text = " Video"
                                attachmentImg.setImageHeight(height: 13)
                                let spaceText = NSMutableAttributedString(string: "")
                                completeText.append(spaceText)
                                let attachString = NSAttributedString(attachment: attachmentImg)
                                completeText.append(attachString)
                                let textAfterIcon = NSMutableAttributedString(string: " ")
                                completeText.append(textAfterIcon)

                            case messagetype.AUDIO.rawValue:
                                channelCell.attachIcon.image = UIImage(named: "recent_audio")
                                text = " Audio"
                                attachmentImg.setImageHeight(height: 13)
                                let spaceText = NSMutableAttributedString(string: "")
                                completeText.append(spaceText)
                                let attachString = NSAttributedString(attachment: attachmentImg)
                                completeText.append(attachString)
                                let textAfterIcon = NSMutableAttributedString(string: " ")
                                completeText.append(textAfterIcon)
                            case messagetype.OTHER.rawValue:
                                let oTyp = message.otherType
                                if oTyp == otherMessageType.INFO.rawValue {
                                    channelCell.attachIcon.isHidden = true

                                    text = "" + text
                                } else {
                                    if oTyp == otherMessageType.TEXT_POLL.rawValue {
                                        channelCell.attachIcon.image = UIImage(named: "pollSmall")
                                        text = " Text poll"
                                    } else if oTyp == otherMessageType.IMAGE_POLL.rawValue {
                                        channelCell.attachIcon.image = UIImage(named: "pollSmall")
                                        text = " Image poll"
                                    } else {
                                        channelCell.attachIcon.image = UIImage(named: "recent_gallery")
                                        text = " Media"
                                    }

                                    attachmentImg.setImageHeight(height: 13)
                                    let spaceText = NSMutableAttributedString(string: "")
                                    completeText.append(spaceText)
                                    let attachString = NSAttributedString(attachment: attachmentImg)
                                    completeText.append(attachString)
                                    let textAfterIcon = NSMutableAttributedString(string: " ")
                                    completeText.append(textAfterIcon)
                                }

                            default:
                                print("do nothing")
                            }
                        }
                    }

                    let textAfterIcon = NSMutableAttributedString(string: text)
                    completeText.append(textAfterIcon)

                    channelCell.channelMessageLabel.textAlignment = .left
                    channelCell.channelMessageLabel.text = text
                }
//                let completeText = NSMutableAttributedString(string: channelCell.channelMessageLabel.text!,
//                                                         attributes: [NSAttributedString.Key.font:UIFont(name: "SanFranciscoDisplay-Regular",size: 14.0)!])
//                channelCell.channelMessageLabel.attributedText = completeText;
//                channelCell.channelMessageLabel.font = UIFont(name: "SanFranciscoDisplay-Regular",size: 13.0)
                channelCell.channelMessageLabel.font = UIFont.systemFont(ofSize: 14.5)
//                channelCell.channelMessageLabel.textColor = .darkGray
                channelCell.channelMessageLabel.setLineSpacing(lineSpacing: 2, lineHeightMultiple: 1.025)

                channelTableList.lastMessage = message.text
            } else {
                var textAfterIcon = NSMutableAttributedString(string: "")
                var text = ""
                if let message = DatabaseManager.getLatestMessage(channelId: channelTableList.channelId, channelType: channelTableList.channelType) {
                    let type = message.messageType
                    if type == messagetype.OTHER.rawValue {
                        let oTyp = message.otherType
                        if oTyp == otherMessageType.INFO.rawValue {
                            channelCell.attachIcon.isHidden = true

                            channelCell.userNameLabel.text = "Info:"
                            text = message.text
                            textAfterIcon = NSMutableAttributedString(string: text)
                        }
                    }
                }

                let completeText = NSMutableAttributedString(string: "")

                completeText.append(textAfterIcon)
                channelCell.channelMessageLabel.textAlignment = .left
                channelCell.channelMessageLabel.text = text
            }
        }

        channelCell.channelMessageLabel.adjustsFontSizeToFitWidth = false
        channelCell.channelMessageLabel.lineBreakMode = .byTruncatingTail
//        channelCell.channelMessageLabel.text = channelTableList.lastMessage

        if channelTableList.lastMessageTime != "" {
            if channelTableList.lastMessageTime.count == 10 {
                let time = Double(channelTableList.lastMessageTime)!
                channelCell.timeLabel.text = time.getDateStringFromUTC()
            } else {
                let time = Double(channelTableList.lastMessageTime)! / 10_000_000
                channelCell.timeLabel.text = time.getDateStringFromUTC()
            }

        } else {
            channelCell.timeLabel.text = ""
        }

        // for unseen count
        if let count = Int(channelTableList.unseenCount) {
            if count > 0 {
                channelCell.unreadCountLabel.isHidden = false
                channelCell.unreadCountLabel.text = channelTableList.unseenCount
            } else {
                channelCell.unreadCountLabel.isHidden = true
            }
        }

//        let attrString = NSMutableAttributedString(string: channelCell.channelMessageLabel.text!)
//        let style = NSMutableParagraphStyle()
        ////        style.lineSpacing = 19 // change line spacing between paragraph like 36 or 48
//        style.minimumLineHeight = 19 // change line spacing between each line like 30 or 40
//        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: (channelCell.channelMessageLabel.text?.count)!))
//
//        channelCell.channelMessageLabel.attributedText = attrString
//        channelCell.channelMessageLabel .sizeToFit()

        return channelCell
    }

    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }

    func getMessageStatus(msgState: messageState) -> UIImage {
        var image: UIImage?
        switch msgState {
        case messageState.SENDER_SENT:
            image = UIImage(named: "ic_sent_new")!

        case .INSTR_RECEIVED:
            print("nothing")

        case .SENDER_UNSENT:
            image = UIImage(named: "ic_unsent")!

        case .RECEIVER_RECEIVED:
            image = UIImage(named: "lastDelivered")!

        case .RECEIVER_SEEN:
            image = UIImage(named: "lastSeen")!
        case .MESSAGE_HIDDEN:
            print("nothing")

        case .MESSAGE_MARKED_DELETE:
            print("nothing")

        case .MESSAGE_INFO:
            print("nothing")
        }

        return image!
    }

    func downLoadImagesforIndexPath(index: IndexPath, downloadImage: String, groupId: String) {
        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: downloadImage, refernce: groupId, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

        DispatchQueue.global(qos: .background).async {
            ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in

                DatabaseManager.updateGroupLocalImagePath(localImagePath: path, localId: success.refernce)

                self.channels[index.row].channelImageUrl = path
                DispatchQueue.main.async { () in
                    self.channelTableView.reloadRows(at: [index], with: .none)
                }

            })
        }
    }

    func downLoadImagesforIndexPathforUser(index: IndexPath, downloadImage: String, userId: String) {
        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: downloadImage, refernce: userId, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

        DispatchQueue.global(qos: .background).async {
            ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in

                DatabaseManager.updateMemberPhotoForId(picture: path, userId: success.refernce)

                self.channels[index.row].channelImageUrl = path
                DispatchQueue.main.async { () in
                    self.channelTableView.reloadRows(at: [index], with: .none)
                }

            })
        }
    }

    func downLoadGroupMemberImagesforIndexPath(index: IndexPath, downloadImage: String, groupId: String) {
        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: downloadImage, refernce: groupId, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

        DispatchQueue.global(qos: .background).async {
            ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in

                DatabaseManager.updateGroupMembersPicture(globalUserId: success.refernce, image: path)

                self.channels[index.row].channelImageUrl = path
                DispatchQueue.main.async { () in
                    self.channelTableView.reloadRows(at: [index], with: .none)
                }

            })
        }
    }

    var selectedList = ChannelDisplayObject()
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if channels[indexPath.row].isConfidential == "1" {
            selectedList = channels[indexPath.row]

            showPinView()

        } else {
            let channelTableList = channels[indexPath.row]
            goToNextView(channelTableList: channelTableList)
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

                nextViewController.channelDetails = channelTableList

                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    func getUserName(message: MessagesTable) -> String {
        var nameString: String = ""

        if message.channelType == channelType.GROUP_CHAT.rawValue || message.channelType == channelType.ADHOC_CHAT.rawValue {
            if let memebrIndex = DatabaseManager.getGroupMemberIndexForMemberId(groupId: message.senderId) {
                if memebrIndex.groupMemberContactId != "" {
                    if Int(memebrIndex.groupMemberContactId)! > 0 {
                        let contact = DatabaseManager.getContactIndexforTable(tableIndex: memebrIndex.groupMemberContactId)
                        nameString = (contact?.fullName)!
                    } else {
                        nameString = memebrIndex.memberName
                    }

                } else {
                    nameString = memebrIndex.memberName
                }
            }
        } else {
            let contact = DatabaseManager.getContactIndexforTable(tableIndex: message.senderId)

            nameString = (contact?.fullName)!
        }

        return nameString
    }

    // show pinview
    var pinView = ACPinView()

    func showPinView() {
        pinView = Bundle.main.loadNibNamed("ACPinView", owner: self, options: nil)?[0] as! ACPinView
        pinView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        pinView.iphonePassCodeBtn.addTarget(self, action: #selector(pressButton(_:)), for: .touchUpInside)
        pinView.setButton.addTarget(self, action: #selector(onCLickOfSetPin(_:)), for: .touchUpInside)

        pinView.closeButton.addTarget(self, action: #selector(closeButton(_:)), for: .touchUpInside)

        if UserDefaults.standard.value(forKey: UserKeys.userconfidentialpin) != nil {
            pinView.setButton.setTitle(labelStrings.verify, for: .normal)
            pinView.enterPinLabel.text = labelStrings.enterPin
            pinView.pinDescriptionLabel.text = labelStrings.enterPinDesc
        } else {
            pinView.setButton.setTitle(labelStrings.setPin, for: .normal)
            pinView.enterPinLabel.text = labelStrings.setPin
            pinView.pinDescriptionLabel.text = labelStrings.setPinDesc
        }
        view.addSubview(pinView)
    }

    @objc func pressButton(_ sender: UIButton) {
        print("\(sender)")
        authenticationWithTouchID()
    }

    @objc func closeButton(_ sender: UIButton) {
        print("\(sender)")
        pinView.removeFromSuperview()
    }

    @objc func onCLickOfSetPin(_ sender: UIButton) {
        if sender.titleLabel?.text == "VERIFY" {
            let pin = UserDefaults.standard.value(forKey: UserKeys.userconfidentialpin) as! String
            var userOtp: String = ""
            pinView.otpTextFieldParentStackView.subviews.forEach { view in
                if let view = view as? UITextField {
                    userOtp.append(view.text ?? "")
                }
            }

            if !userOtp.isEmpty || userOtp.count == OTP_MAX_LENGTH {
                if pin == userOtp {
                    print("verified")
                    pinView.removeFromSuperview()
                    goToNextView(channelTableList: selectedList, isConfidential: true)

                } else {
                    print("not verified")
                    alert(message: "The app PIN is incorrect")
                }
            }
        } else {
            var userOtp: String = ""
            pinView.otpTextFieldParentStackView.subviews.forEach { view in
                if let view = view as? UITextField {
                    userOtp.append(view.text ?? "")
                }
            }
            if !userOtp.isEmpty || userOtp.count == OTP_MAX_LENGTH {
                UserDefaults.standard.set(userOtp, forKey: UserKeys.userconfidentialpin)
                pinView.removeFromSuperview()
                showPinView()
            }
        }
    }

    @IBAction func groupsButton(_: Any) {
        let groups = DatabaseManager.getGroups()

        if groups.count == 0 {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "CreateGroup_BroadcastsViewController") as? CreateGroup_BroadcastsViewController {
                if let navigator = navigationController {
                    let backItem = UIBarButtonItem()
                    backItem.title = "Create group"
                    navigationItem.backBarButtonItem = backItem
                    nextViewController.hidesBottomBarWhenPushed = true
                    navigator.pushViewController(nextViewController, animated: true)
                }
            }
        } else {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "GroupChatsController") as? GroupChatsController {
                if let navigator = navigationController {
                    let backItem = UIBarButtonItem()
                    backItem.title = "Groups"
                    navigationItem.backBarButtonItem = backItem
                    nextViewController.hidesBottomBarWhenPushed = false
                    navigator.pushViewController(nextViewController, animated: true)
                }
            }
        }
    }

    @IBAction func searchBtn(_: Any) {}

//    @IBAction func search(_: Any) {
//        self.searchHeight.constant = 10
//        UIView.animate(withDuration: 1) {
//            self.serachbar.layoutIfNeeded()
//        }
//
//        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "QRViewController") as? QRViewController {
//            if let navigator = navigationController {
//                let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
//                navigator.navigationBar.tintColor = color3
//                navigator.pushViewController(nextViewController, animated: true)
//            }
//        }
//    }

    @IBAction func chatsBtn(_: Any) {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "QRViewController") as? QRViewController {
            if let navigator = navigationController {
                let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
                navigator.navigationBar.tintColor = color3
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    @IBAction func contactsBtn(_: Any) {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ContactsViewController") as? ContactsViewController {
            if let navigator = navigationController {
                let backItem = UIBarButtonItem()
                backItem.title = "Contacts"
                navigationItem.backBarButtonItem = backItem
                nextViewController.hidesBottomBarWhenPushed = true
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }
}

extension Double {
    func getDateStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)

        let datev = NSDate()

        let calendar = Calendar.current
//
//        let dateFormatter = DateFormatter()
//
//        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
//        dateFormatter.date(from: Date())

        let date1 = calendar.startOfDay(for: datev as Date)
        let date2 = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: date1, to: date2)

        if Calendar.current.isDateInToday(date) {
            let components = calendar.dateComponents([.hour], from: Date(), to: date)
            print(components)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "hh:mm a"

            return dateFormatter.string(from: date)

        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
//        }else if components.day == 2
//        {
//            return "2d"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateStyle = .short
            let monthComponents = dateFormatter.shortMonthSymbols
            dateFormatter.monthSymbols = monthComponents
            dateFormatter.dateFormat = "MMMM dd"
            return dateFormatter.string(from: date)
        }
    }

    func getDateandhours() -> String {
        let date = Date(timeIntervalSince1970: self)

        let diffInDays = Calendar.current.dateComponents([.hour, .day, .month, .year, .minute], from: Date(), to: date)

        if diffInDays.hour! <= 24, diffInDays.hour! == 0, diffInDays.day! == 0, diffInDays.month! == 0, diffInDays.year! == 0, diffInDays.minute! > 0 {
            let da = diffInDays.minute! == 1 ? "Min" : "Mins"
            return "\(String(describing: diffInDays.minute!)) \(da)"
        } else if diffInDays.hour! <= 24, diffInDays.hour! > 0, diffInDays.day! == 0, diffInDays.month! == 0, diffInDays.year! == 0 {
            let da = diffInDays.hour! == 1 ? "hr" : "hrs"
            let min = diffInDays.minute! == 1 ? "min" : "mins"

            return "\(String(describing: diffInDays.hour!)) \(da), \(String(describing: diffInDays.minute!)) \(min) "
        } else if diffInDays.hour! <= 24, diffInDays.day! > 0, diffInDays.day! <= 30, diffInDays.month! == 0, diffInDays.year! == 0 {
            if diffInDays.hour! > 0 {
                let da = diffInDays.day! == 1 ? "day" : "days"
                let h = diffInDays.hour! == 1 ? "hr" : "hrs"
                return "\(String(describing: diffInDays.day!)) \(da) \(String(describing: diffInDays.hour!)) \(h)"
            } else {
                let da = diffInDays.day! == 1 ? "day" : "days"
                return "\(String(describing: diffInDays.day!)) \(da)"
            }
        } else if diffInDays.month! > 0, diffInDays.month! <= 12, diffInDays.year! == 0 {
            if diffInDays.day! > 0 {
                let da = diffInDays.day! == 1 ? "day" : "days"
                let mo = diffInDays.month! == 1 ? "month" : "months"
                return "\(String(describing: diffInDays.month!)) \(mo) \(String(describing: diffInDays.day!)) \(da)"
            } else {
                let mo = diffInDays.month! == 1 ? "month" : "months"
                return "\(String(describing: diffInDays.month!)) \(mo)"
            }
        } else if diffInDays.year! > 0, diffInDays.month! > 0 {
            let mo = diffInDays.month! == 1 ? "month" : "months"
            return "\(String(describing: diffInDays.year!)) y \(String(describing: diffInDays.month!)) \(mo)"
        } else {
            if diffInDays.year! > 0 {
                return "\(String(describing: diffInDays.year!)) y"
            } else {
                return "Poll Expired"
            }
        }
    }
}

// MARK: - Alerts

extension Group_Chat_List_ViewController {
    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
//        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"

        var authError: NSError?
        let reasonString = GlobalStrings.accessConfidentialMessages

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in

                if success {
                    // TODO: User authenticated successfully, take appropriate action
                    print(success)
                    DispatchQueue.main.async {
                        self.pinView.removeFromSuperview()

                        self.goToNextView(channelTableList: self.selectedList, isConfidential: true)
                    }

                } else {
                    // TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }

                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))

                    // TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                }
            }
        } else {
            guard let error = authError else {
                return
            }
            // TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print(evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }

    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."

            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."

            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."

            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."

            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"

            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"

            default:
                message = "Did not find error code on LAError object"
            }
        }

        return message
    }

    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        var message = ""

        switch errorCode {
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"

        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"

        case LAError.invalidContext.rawValue:
            message = "The context is invalid"

        case LAError.notInteractive.rawValue:
            message = "Not interactive"

        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"

        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"

        case LAError.userCancel.rawValue:
            message = "The user did cancel"

        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"

        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }

        return message
    }
}

extension NSTextAttachment {
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height

        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
    }
}
