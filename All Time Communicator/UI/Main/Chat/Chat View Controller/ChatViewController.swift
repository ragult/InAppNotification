//
//  ChatViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 17/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import Accelerate
import AVFoundation
import AVKit
import AXPhotoViewer
import CallKit
import IQKeyboardManagerSwift
import Photos
import SwiftEventBus
import SwiftyJSON
import TZImagePickerController
import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, AXPhotosViewControllerDelegate, groupExitDelegate, processAudioDataDelegate, processPollDataDelegate, groupPhotoChangeDelegate {
    @IBOutlet var openGalleryWidthConstant: NSLayoutConstraint!
    var image: UIImageView?
    @IBOutlet var chatTable: UITableView!
    @IBOutlet var popUpViewHeightConst: NSLayoutConstraint!
    @IBOutlet var chatTableHeight: NSLayoutConstraint!

    @IBOutlet var chatKeyboardHeight: NSLayoutConstraint!

    @IBOutlet var bottomKeyboardView: UIView!
    @IBOutlet var bottomTabBarHeight: NSLayoutConstraint!
    @IBOutlet var textViewHC: NSLayoutConstraint!
    @IBOutlet var menuItemsStackView: UIStackView!
    @IBOutlet var inviteStackView: UIStackView!
    @IBOutlet var oepnGalleryButton: UIButton!
    @IBOutlet var pollStackView: UIStackView!
    @IBOutlet var galleryStackView: UIStackView!
    @IBOutlet var createPollButton: UIButton!
    @IBOutlet var inviteMemberButton: UIButton!
    @IBOutlet var menuView: UIView!
    @IBOutlet var openMenuPlusButton: UIButton!
    @IBOutlet var messageTextField: UITextView!
    @IBOutlet var openCameraButton: UIButton!
    @IBOutlet var recordAudioButton: UIButton!
    @IBOutlet var seperatorButton: UIButton!

    @IBOutlet var replyView: UIView!
    @IBOutlet var replyMessage: UILabel!
    @IBOutlet var replyName: UILabel!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var replyPopUpViewHeightConst: NSLayoutConstraint!
    @IBOutlet var replyImage: UIImageView!
    @IBOutlet var scrollFloatingButton: UIButton!

    @IBOutlet var noKeyboardView: UIView!

    @IBOutlet var chatViewLeadingConstraint: NSLayoutConstraint!

    @IBOutlet var audioWidthConstraint: NSLayoutConstraint!

    @IBOutlet var cameraWidthConstraint: NSLayoutConstraint!

    @IBOutlet var seperatorWidthConstraint: NSLayoutConstraint!

    var audioPlayer: AVAudioPlayer = AVAudioPlayer()

    var channelDetails: ChannelDisplayObject!
    var channelId: String?
    var userLocalId: String?
    var globalChatId: String?
    var displayName: String?
    var displayImage: String?
    var getIsConfidential: Bool = false

    let playerViewController = AVPlayerViewController()
    var isCellSelected: Bool = false
    var outGoingMessage: String?
    var group = GroupTable()
    var messages = NSMutableDictionary()
    var messagesArray = [MessagesTable]()
    var datesArray = NSMutableArray()
    var selectedObject = chatListObject()
    var groupMembers = [GroupMemberTable]()

    var deSelectedImage: UIImage?
    var typingMessageText: String = ""
    var replyMessageId: String = ""
    var isViewFirstTime: Bool!
    var isViewFirstTimeLoaded: Bool!
    var isScrollToBottom: Bool!

    var topicId: String = ""
    var lastIndex: CGPoint?
    var tapActive: Bool = false
    var isFromContacts: Bool = false
    var isfromNotifications: Bool = false

    var isUserOnline: Bool = false

    var refGroupId: String = ""
    var counter: Int = 0

    var timer: Timer!
    var currentSelectedIndex: IndexPath?
    var groupDetail : GroupTable?

    let imageCache = NSCache<AnyObject, AnyObject>()
    var delegate = UIApplication.shared.delegate as? AppDelegate
    var downloadTracker = NSMutableDictionary()

    override func viewDidLoad() {
        chatTable.isHidden = true
        chatTable.transform = CGAffineTransform(scaleX: 1, y: -1)

//        self.chatTable.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
//        self.chatTable.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: self.chatTable.bounds.size.width - 8.0)

        chatTable.register(UINib(nibName: "DayViewCell", bundle: nil), forCellReuseIdentifier: "DayViewCell")
        chatTable.register(UINib(nibName: "IncomingMessageCell", bundle: nil), forCellReuseIdentifier: "IncomingMessageCell")
        chatTable.register(UINib(nibName: "OutGoingMessageCell", bundle: nil), forCellReuseIdentifier: "OutGoingMessageCell")
        chatTable.register(UINib(nibName: "InitialViewsOfChatTableViewCell", bundle: nil), forCellReuseIdentifier: "InitialViewsOfChatTableViewCell")

        //  chatTable.transform = CGAffineTransform(scaleX: 1, y: -1)
        chatTable.backgroundColor = UIColor(r: 243, g: 243, b: 243)
        chatTable.estimatedRowHeight = 80
        chatTable.rowHeight = UITableView.automaticDimension

        showcameraAudioButton()
        messageTextField.delegate = self
        messageTextField.translatesAutoresizingMaskIntoConstraints = false

        navigationItem.hidesBackButton = true
        if openMenuPlusButton.isSelected == false {
            menuItemsStackView.isHidden = true
            popUpViewHeightConst.constant = 0
        }

        replyView.isHidden = true
        replyPopUpViewHeightConst.constant = 0

        listenToEventbus()

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func loadTableViewData(chnlDetails: ChannelDisplayObject) {
        if isViewFirstTime {
            isViewFirstTime = false
            let delegate = UIApplication.shared.delegate as? AppDelegate

            let userGlobalId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String

            if chnlDetails.channelType == channelType.ONE_ON_ONE_CHAT.rawValue {
                pollStackView.isHidden = true
                userLocalId = UserDefaults.standard.value(forKey: UserKeys.userContactIndex) as? String
                globalChatId = chnlDetails.globalChannelName
                delegate?.client.subscribeToChannels(["per." + (userGlobalId ?? "")], withPresence: true)
                getPresence(channelName: globalChatId ?? "")
            } else if chnlDetails.channelType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                pollStackView.isHidden = true
                let contactDetails = DatabaseManager.getGroupMemberIndexForMemberId(groupId: chnlDetails.lastSenderPhoneBookContactId)

                groupDetail = DatabaseManager.getGroupDetail(groupGlobalId: (contactDetails?.groupId)!)

                userLocalId = (contactDetails?.groupMemberId)!
                globalChatId = chnlDetails.globalChannelName
                refGroupId = (groupDetail?.groupGlobalId)!
                delegate?.client.subscribeToChannels([userGlobalId ?? ""], withPresence: true)
                getPresence(channelName: globalChatId ?? "")

            } else {
                pollStackView.isHidden = false
                let GroupMemberIndex = DatabaseManager.getGroupMemberIndex(groupId: chnlDetails.lastSenderPhoneBookContactId, globalUserId: userGlobalId!)
                groupDetail = DatabaseManager.getGroupDetail(groupGlobalId: chnlDetails.lastSenderPhoneBookContactId)

                userLocalId = GroupMemberIndex?.groupMemberId

                globalChatId = groupDetail?.groupGlobalId
                if groupDetail?.groupStatus == groupStats.INACTIVE.rawValue {
                    userLocationData(clearChat: false)
                } else {
                    delegate?.client.subscribeToChannels([chnlDetails.globalChannelName + "-pnpres"], withPresence: true)
                }

                groupMembers = DatabaseManager.getGroupMembers(globalGroupId: self.groupDetail?.id ?? "")
            }
            // to fetch messages based on the group type
            if chnlDetails.channelType == channelType.TOPIC_GROUP.rawValue || chnlDetails.channelType == channelType.PUBLIC_GROUP.rawValue || chnlDetails.channelType == channelType.PRIVATE_GROUP.rawValue {
                DatabaseManager.updateMessageTableToSeenForChannelIdandTopic(channelId: chnlDetails.channelId, topicId: topicId)
                messagesArray = DatabaseManager.getMessagesFormessageIdOfspeakerGroup(channelId: chnlDetails.channelId, replyMessageId: topicId)

            } else {
                messagesArray = DatabaseManager.getMessagesForChannelId(channelId: chnlDetails.channelId)

                let unreadMsgs = DatabaseManager.getUnreadMessagesForChannelId(channelId: chnlDetails.channelId)
                if unreadMsgs.count > 0 {
                    let firstMsg = unreadMsgs.last
                    let lastMsg = unreadMsgs.first
                    sendDeliveryReceipt(firstMsgId: firstMsg!.globalMsgId, LastmsgId: lastMsg!.globalMsgId)
                }

//                if let fmsgId = DatabaseManager.getFirstUnseenMessageChannelId(channelId: (self.channelDetails?.channelId)!) {
//
//                    if let lmsgId = DatabaseManager.getLastUnseenMessageChannelId(channelId: (self.channelDetails?.channelId)!) {
//                    }
//                }
            }

            if messagesArray.count == 0 {
                UserDefaults.standard.set(true, forKey: UserKeys.newIntro)
            }

            messages = ChatMessageProcessor.processMessage(messageObjectArray: messagesArray)

            let filArray = messages.allKeys as NSArray
            datesArray = filArray.descendingArrayWithData()

            chatTable.delegate = self
            chatTable.dataSource = self

            chatTable.reloadData()

            if messages.allKeys.count > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.chatTable.isHidden = false
                }
            }
        }
    }

    // MARK: Keyboard Notification

    let chatTableTap = UITapGestureRecognizer()

    @objc func keyboardWillShow(_ notification: NSNotification) {
        print("keyboard will show!")

        // To obtain the size of the keyboard:

        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if chatTableHeight.constant == 0 {
                chatKeyboardHeight.constant = keyboardHeight
//                chatTableHeight.constant = keyboardHeight
                hideMenu()
                scrollToBottom()
                chatTableTap.addTarget(self, action: #selector(ChatViewController.DismissKeyboard))
                chatTable.addGestureRecognizer(chatTableTap)
                tapActive = true
            }
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("Keyboard will hide!")
        chatTable.removeGestureRecognizer(chatTableTap)
        tapActive = false

        hideMenu()
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//            chatTableHeight.constant = 0
            chatKeyboardHeight.constant = 0
            if messageTextField.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                showcameraAudioButton()
            }
        }
    }

    func scrollToBottom() {
//        let scrollPoint = CGPoint(x: 0, y: self.chatTable.contentSize.height - self.chatTable.frame.size.height)
//        self.chatTable.setContentOffset(scrollPoint, animated: false)
        if chatTable.contentOffset.y >= (chatTable.contentSize.height - chatTable.frame.size.height) {
            // you reached end of the table
            if messages.allKeys.count > 0 {
                DispatchQueue.main.async {
                    if self.chatTable.numberOfSections > 0 {
                        if self.chatTable.numberOfRows(inSection: 0) > 0 {
                            let newIndexPaths = IndexPath(row: 0, section: 0)
                            self.chatTable.scrollToRow(at: newIndexPaths, at: .bottom, animated: false)
                        }
                    }
                }
            }
        }
    }

    var isViewActive: Bool = false

    func listenToEventbus() {
        // for new message received

        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.channelUpdated) { notification in
            if self.isViewActive {
                let eventObj: eventObject = notification!.object as! eventObject
                let channel = eventObj.channelObject
                let message = eventObj.messages
                if self.channelDetails?.channelId == channel!.id {
                    self.sendDeliveryReceipt(firstMsgId: message!.globalMsgId, LastmsgId: message!.globalMsgId)

                    let time = Double(message!.msgTimeStamp)! / 10_000_000
                    let finalDate = time.getDateFromUTC()

                    var iSNewMsg = true
                    if self.datesArray.contains(finalDate) {
                        let dateChatMessages = self.messages.value(forKey: finalDate) as! [chatListObject]

                        let msgs = dateChatMessages.filter { $0.messageContext?.globalMsgId == message!.globalMsgId }
                        if msgs.count == 0 {
                            iSNewMsg = true
                        } else if msgs.count > 0 {
                            iSNewMsg = false
                        }
                    }

                    DispatchQueue.main.async {
                        if iSNewMsg {
                            let item = ChatMessageProcessor.processSingleMessage(message: message!, chatobjectsDictionary: self.messages)
                            //                self.messages .append(item)
                            self.messages = item
                            DatabaseManager.updateChannelTableForChannelId(channelId: (self.channelDetails?.channelId)!)

                            if self.scrollFloatingButton.isHidden == false {
                                self.scrollFloatingButton.extCornerRadius = self.scrollFloatingButton.frame.width / 2
                                self.scrollFloatingButton.extBorderWidth = 2
                                self.scrollFloatingButton.extBorderColor = COLOURS.APP_MEDIUM_GREEN_COLOR

                                self.reloadTableViewToIndex(isScrollRequired: false)
                            } else {
                                self.scrollFloatingButton.extBorderWidth = 0
                                self.scrollFloatingButton.extBorderColor = .darkGray

                                self.reloadTableViewToIndex(isScrollRequired: true)
                            }
                            DefaultSound.eventBusNewMessage()
                        }
                    }
                }
            }
        }
        SwiftEventBus.onBackgroundThread(self, name: "readReceiptsMessage") { notification in

            if self.isViewActive {
                let eventObj: ACReadReceiptEventBusObject = notification!.object as! ACReadReceiptEventBusObject
                let eventChannelName = eventObj.channelName?.replacingOccurrences(of: "per.", with: "")
                let isIncoming =  eventObj.messageState == messageState.RECEIVER_RECEIVED || eventObj.messageState == messageState.RECEIVER_SEEN

                var recipientChannelName: String?
                if self.channelDetails?.channelType ==  channelType.ONE_ON_ONE_CHAT.rawValue {
                    if eventObj.isMine {
                        if isIncoming {
                            recipientChannelName = self.userId
                        } else {
                            recipientChannelName = self.channelDetails?.globalChannelName
                        }
                    } else {
                        recipientChannelName = self.userId
                    }
                } else{
                     recipientChannelName = self.channelDetails?.globalChannelName
                }
//                if self.channelDetails?.globalChannelName == recipientChannelName {
                if recipientChannelName == eventChannelName {
                    // || self.channelDetails?.channelId == eventObj.channelName
                   
                    if self.datesArray.contains(eventObj.messageDate) {
                        let dateChatMessages = self.messages.value(forKey: eventObj.messageDate) as! NSMutableArray
                        for msg in dateChatMessages {
                            let message = msg as! chatListObject
    
                            if let globalMsgId = message.messageContext?.globalMsgId {
                                if globalMsgId == eventObj.lastMsgId {
                                    DispatchQueue.main.async {
                                        let section = self.datesArray.index(of: eventObj.messageDate)
                                        let row = dateChatMessages.index(of: message)
                                        message.messageContext?.messageState = eventObj.messageState

                                        dateChatMessages.removeObject(at: row)
                                        dateChatMessages.insert(message, at: row)

                                        self.messages.removeObject(forKey: eventObj.messageDate)
                                        self.messages.setValue(dateChatMessages, forKey: eventObj.messageDate)

                                        let newIndexPaths = IndexPath(row: row, section: section)

                                        if eventObj.messageState == messageState.SENDER_SENT {
                                            DefaultSound.sendNewMessage()
                                        }
                                        self.chatTable.reloadRows(at: [newIndexPaths], with: UITableView.RowAnimation.none)
                                    }
                                }
                            }

                        }
                    }
                    //                DispatchQueue.main.async {
                    //                    self.viewWillAppear(false)
                    //                }
                }
            }
        }

        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.typingStatus) { notification in
            if self.isViewActive {
                let eventObj: ACTypingStatusObject = notification!.object as! ACTypingStatusObject
                let channel = eventObj.channelName

                if self.channelDetails?.globalChannelName == channel {
                    var typeText = "Typing.."
                    if self.channelDetails?.channelType == channelType.ADHOC_CHAT.rawValue || self.channelDetails?.channelType == channelType.GROUP_CHAT.rawValue || self.channelDetails?.channelType == channelType.TOPIC_GROUP.rawValue || self.channelDetails?.channelType == channelType.PUBLIC_GROUP.rawValue ||
                        self.channelDetails?.channelType == channelType.PRIVATE_GROUP.rawValue {
                        self.updateMemberListForTyping(uuid: eventObj.uuid)
                        if self.typingMemebrsArray.count > 2 {
                            typeText = "Typing: \(self.typingMemebrsArray[0]), \(self.typingMemebrsArray.count - 2) others"

                        } else if self.typingMemebrsArray.count == 2 {
                            typeText = "Typing: \(self.typingMemebrsArray[0]), 1 other"
                        } else if self.typingMemebrsArray.count == 1 {
                            typeText = "Typing: \(self.typingMemebrsArray[0])"
                        }
                        DispatchQueue.main.async {
                            self.customNavigationBar(name: self.displayName ?? "", image: self.displayImage ?? "", istyping: true, isTypingText: typeText, channelTyp: channelType(rawValue: (self.channelDetails?.channelType)!)!)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                // your code here
                                self.removeMemberListForTyping(uuid: eventObj.uuid)

                                self.customNavigationBar(name: self.displayName ?? "", image: self.displayImage ?? "", istyping: false, channelTyp: channelType(rawValue: (self.channelDetails?.channelType)!)!)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.customNavigationBar(name: self.displayName ?? "", image: self.displayImage ?? "", istyping: true, isTypingText: typeText, channelTyp: channelType(rawValue: (self.channelDetails?.channelType)!)!)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                // your code here

                                self.customNavigationBar(name: self.displayName ?? "", image: self.displayImage ?? "", istyping: false, channelTyp: channelType(rawValue: (self.channelDetails?.channelType)!)!)

                                self.getPresence(channelName: self.globalChatId ?? "")
                            }
                        }
                    }

                } else {
                    if self.channelDetails?.globalChannelName == eventObj.uuid {
                        DispatchQueue.main.async {
                            self.customNavigationBar(name: self.displayName ?? "", image: self.displayImage ?? "", istyping: true, isTypingText: "is typing....", channelTyp: channelType(rawValue: (self.channelDetails?.channelType)!)!)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                // your code here
                                self.customNavigationBar(name: self.displayName ?? "", image: self.displayImage ?? "", istyping: false, channelTyp: channelType(rawValue: (self.channelDetails?.channelType)!)!)
                            }
                        }
                    }
                }
            }
        }

        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.systemMessage) { notification in
            if self.isViewActive {
                let eventObj: eventObject = notification!.object as! eventObject
                let channel = eventObj.channelObject
                let message = eventObj.messages
                if self.channelDetails?.channelId == channel!.id {
                    DispatchQueue.main.async {
                        let item = ChatMessageProcessor.processSingleMessage(message: message!, chatobjectsDictionary: self.messages)
                        //                self.messages .append(item)
                        self.messages = item

                        self.reloadTableViewToIndex(isScrollRequired: false)
                    }
                }
            }
        }
        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.groupinactive) { notification in
            if self.isViewActive {
                let eventObj: eventObject = notification!.object as! eventObject
                let channel = eventObj.channelObject

                if self.channelDetails?.channelId == channel!.id {
                    DispatchQueue.main.async {
                        self.userLocationData(clearChat: false)
                    }
                }
            }
        }

        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.groupactive) { notification in
            if self.isViewActive {
                let eventObj: eventObject = notification!.object as! eventObject
                let channel = eventObj.channelObject

                if self.channelDetails?.channelId == channel!.id {
                    DispatchQueue.main.async {
                        self.bottomKeyboardView.isHidden = false
                        self.noKeyboardView.isHidden = true
                    }
                }
            }
        }
    }

    var typingMemebrsArray = NSMutableArray()

    func updateMemberListForTyping(uuid: String) {
        let containsUser = groupMembers.filter { $0.globalUserId == uuid }

        if containsUser.count > 0 {
            if typingMemebrsArray.contains(containsUser[0].memberName) {
                print("do nothing")
            } else {
                typingMemebrsArray.add(containsUser[0].memberName)
            }
        }
    }

    func removeMemberListForTyping(uuid: String) {
        let containsUser = groupMembers.filter { $0.globalUserId == uuid }

        if containsUser.count > 0 {
            if typingMemebrsArray.contains(containsUser[0].memberName) {
                typingMemebrsArray.remove(containsUser[0].memberName)
            } else {
                print("do nothing")
            }
        }
    }

    func json(from object: Any) -> String? {
        do {
//            //Convert to Data
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)

            // Convert back to string. Usually only do this for debugging
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                print(JSONString)
                return JSONString
            }

        } catch {
//            print(error.description)
            return nil
        }
        return nil
    }

    override func viewWillDisappear(_: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        UserDefaults.standard.set(false, forKey: UserKeys.newIntro)
        isViewActive = false
    }

    func processDataForAudio(mediaObj: [MediaUploadObject], type _: attachmentType) {
        for imageToSend in mediaObj {
            let sendMessage = ChatMessageProcessor.createImageContextObject(text: imageToSend.messageTextString, channel: (channelDetails?.globalChannelName)!, chanlType: channelType(rawValue: (channelDetails?.channelType)!)!, localSenderId: userLocalId!, localChannelId: (channelDetails?.channelId)!, globalChatId: globalChatId!, mediaType: imageToSend.msgType, mediaObject: imageToSend.localImagePath!, thumbnail: imageToSend.imageName!)
            if topicId != "" {
                sendMessage.messageContext!.topicId = topicId
            } else {
                sendMessage.messageContext!.topicId = ""
            }
            ACMessageSenderClass.sendMediaMessage(messageContext: sendMessage.messageContext!, url: imageToSend.localImagePath!, messageType: (sendMessage.messageItem?.messageType)!, imageObject: imageToSend, messageTextString: imageToSend.messageTextString, other: imageToSend.imageName!, groupName: displayName ?? "", refGroupId: "")
            //                        self.messages .append(sendMessage)
            addNewMessage(chatListItem: sendMessage)

            reloadTableViewToIndex()
//            DefaultSound.sendNewMessage()
        }
    }

    func processDataForPoll(mediaObj: Any, pollObj: PollTable, type: attachmentType) {
        let data = mediaObj as! String
        var type = otherMessageType.TEXT_POLL
        if pollObj.pollType == "2" {
            type = otherMessageType.IMAGE_POLL
        }
        let sendMessage = ChatMessageProcessor.createPollContextObject(text: "", channel: (channelDetails?.globalChannelName)!, chanlType: channelType(rawValue: (channelDetails?.channelType)!)!, localSenderId: userLocalId!, localChannelId: (channelDetails?.channelId)!, globalChatId: globalChatId!, mediaType: messagetype.OTHER, otherType: type, mediaObject: pollObj, localMediaData: pollObj.localData, cloudData: data)
        if topicId != "" {
            sendMessage.messageContext!.topicId = topicId
        } else {
            sendMessage.messageContext!.topicId = ""
        }
        ACMessageSenderClass.sendPollData(chatlist: sendMessage, url: data, messageType: (sendMessage.messageItem?.messageType)!, imageObject: [], otherType: type, messageTextString: "", groupName: displayName ?? "", refGroupId: refGroupId, attachId: "")
        //                    self.messages .append(sendMessage)
//        sendMessage.messageItem?.message = delegate.attachId!
        addNewMessage(chatListItem: sendMessage)

        reloadTableViewToIndex()
    }

    override func viewWillAppear(_: Bool) {
        isViewActive = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false

        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.showExceptSpecificChannelId
        delegate?.currentChannelId = channelDetails?.channelId ?? ""

        DispatchQueue.main.async {
            self.hideMenu()
            if self.isViewFirstTimeLoaded {
                self.isViewFirstTimeLoaded = false
                self.chatTable.bounces = true

                self.chatTable.layer.removeAllAnimations()
                self.chatTable.layoutIfNeeded()
                self.scrollFloatingButton.extBorderWidth = 0

                self.scrollFloatingButton.extBorderColor = .darkGray
                self.scrollFloatingButton.extDropShadow(scale: true)
                self.scrollFloatingButton.isHidden = true
                self.chatTable.reloadData()
            }
        }
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if delegate.isFromAttachmentView != attachmentType.TEXT {
                isViewFirstTime = false

                let type = delegate.isFromAttachmentView
                delegate.isFromAttachmentView = attachmentType.TEXT
                let attachMentsArray = delegate.attachmentArray
                delegate.attachmentArray.removeAll()

                switch type {
                case attachmentType.IMAGE:

                    for imageToSend in attachMentsArray {
                        let sendMessage = ChatMessageProcessor.createImageContextObject(text: imageToSend.messageTextString, channel: (channelDetails?.globalChannelName)!, chanlType: channelType(rawValue: (channelDetails?.channelType)!)!, localSenderId: userLocalId!, localChannelId: (channelDetails?.channelId)!, globalChatId: globalChatId!, mediaType: imageToSend.msgType, mediaObject: imageToSend.localImagePath!, thumbnail: imageToSend.imageName!)
                        if topicId != "" {
                            sendMessage.messageContext!.topicId = topicId
                        } else {
                            sendMessage.messageContext!.topicId = ""
                        }
                        ACMessageSenderClass.sendMediaMessage(messageContext: sendMessage.messageContext!, url: imageToSend.localImagePath!, messageType: (sendMessage.messageItem?.messageType)!, imageObject: imageToSend, messageTextString: imageToSend.messageTextString, other: imageToSend.imageName!, groupName: displayName ?? "", refGroupId: refGroupId)
//                        self.messages .append(sendMessage)
                        addNewMessage(chatListItem: sendMessage)

                        reloadTableViewToIndex()

//                        DefaultSound.sendNewMessage()
                    }
                case attachmentType.imageArray:
                    let localAttachArray = NSMutableArray()
                    for attachment in attachMentsArray {
                        let attch = NSMutableDictionary()
                        attch.setValue(attachment.localImagePath!, forKey: "imageName")
                        attch.setValue(attachment.msgType.rawValue, forKey: "msgType")
                        attch.setValue(attachment.imageName!, forKey: "thumbnail")

                        localAttachArray.add(attch)
                    }

                    let dataDict = NSMutableDictionary()

                    dataDict.setValue(localAttachArray, forKey: "attachmentArray")
                    let attachmentString = convertDictionaryToJsonString(dict: dataDict)

                    let sendMessage = ChatMessageProcessor.createOtherContextObject(text: attachMentsArray[0].messageTextString, channel: (channelDetails?.globalChannelName)!, chanlType: channelType(rawValue: (channelDetails?.channelType)!)!, localSenderId: userLocalId!, localChannelId: (channelDetails?.channelId)!, globalChatId: globalChatId!, mediaType: messagetype.OTHER, otherType: otherMessageType.MEDIA_ARRAY, mediaObject: attachmentString)
                    if topicId != "" {
                        sendMessage.messageContext!.topicId = topicId
                    } else {
                        sendMessage.messageContext!.topicId = ""
                    }
                    ACMessageSenderClass.sendImageArrayMessage(messageContext: sendMessage.messageContext!, url: attachmentString, messageType: (sendMessage.messageItem?.messageType)!, imageObject: attachMentsArray, otherType: otherMessageType.MEDIA_ARRAY, messageTextString: attachMentsArray[0].messageTextString, groupName: displayName ?? "", refGroupId: refGroupId)
//                    self.messages .append(sendMessage)
                    addNewMessage(chatListItem: sendMessage)

                    reloadTableViewToIndex()
//                    DefaultSound.sendNewMessage()

                case .TEXT:
                    print("Do nothing")
                case .AUDIO:
                    print("Do nothing")
                case .VIDEO:
                    print("Do nothing")
                case attachmentType.poll:
                    print("Do nothing")
                }

            } else {
                DatabaseManager.updateChannelTableForChannelId(channelId: (channelDetails?.channelId)!)

                loadTableViewData(chnlDetails: channelDetails)
            }
        }
    }

    func sendDeliveryReceipt(firstMsgId: String, LastmsgId: String) {
        let readReceipt = ACreadReceiptObjectClass()
        readReceipt.chnl_name = channelDetails?.globalChannelName
        readReceipt.chnl_typ = channelDetails?.channelType
        readReceipt.receiver = globalChatId
        readReceipt.senderPhone = UserDefaults.standard.value(forKey: UserKeys.userPhoneNumber) as? String
        readReceipt.senderUUID = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
        readReceipt.id_last = LastmsgId
        readReceipt.id_first = firstMsgId

        readReceipt.mesg_state = messageState.RECEIVER_SEEN.rawValue

        let pubnubClass = ACPubnubClass()

        let pubNubDictionary = NSMutableDictionary()
        pubNubDictionary.setValue("sys", forKey: "src")
        pubNubDictionary.setValue(readReceipt.chnl_name!, forKey: "chnl")
        let convertTodictionary = readReceipt.toDictionary() as? [String: Any]
        let systemData = NSMutableDictionary()
        systemData.setValue("com_seen", forKey: "action")
        systemData.setValue("comm_status", forKey: "type")
        systemData.setValue(convertTodictionary, forKey: "data")
        pubNubDictionary.setValue(systemData, forKey: "sys")

        let channelIdentifier = (channelDetails?.channelType == channelType.ONE_ON_ONE_CHAT.rawValue) ? "per." : ""
        pubnubClass.sendreceiptsMessageToPubNub(msgObject: pubNubDictionary, channel: channelIdentifier + readReceipt.chnl_name!, completionHandler: { (status) -> Void in

            if status {
                DatabaseManager.updateMessageTableToSeenForChannelId(channelId: self.channelDetails!.channelId)
            }
        })
    }

    override func viewDidLayoutSubviews() {
//        if isScrollToBottom {
//
//            isScrollToBottom = false
//        }
    }

    func getPresence(channelName: String) {
        ACPubnubClass().getPresenceStateForChannel(channelName: channelName, completionHandler: { (status) -> Void in

            print(status)
            self.isUserOnline = status
            self.customNavigationBar(name: self.displayName!, image: self.displayImage!, channelTyp: channelType(rawValue: (self.channelDetails?.channelType)!)!)

        })
    }

    func customNavigationBar(name: String, image: String, isSentMessage: Bool = false, istyping: Bool = false, isTypingText: String = "", channelTyp: channelType, showCopy: Bool = false, showFwd: Bool = true) {
        if isCellSelected == false {
            if currentSelectedIndex != nil {
                let cell = chatTable.cellForRow(at: currentSelectedIndex!)
                if cell != nil {
                    cell!.backgroundColor = .clear
                }
                currentSelectedIndex = nil
            }
            let tapRec = UITapGestureRecognizer()
            let groupDetailtapRec = UITapGestureRecognizer()

            // custom navigation bar in NON SELECTION
            // backButton with profile Image

            let backButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 100))
            let backBttonImageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 24, height: 20))
            backBttonImageView.image = UIImage(named: "rightBackButton")
            backBttonImageView.contentMode = UIView.ContentMode.scaleAspectFill
            backButtonView.addSubview(backBttonImageView)
            backButtonView.isUserInteractionEnabled = true
            backButtonView.addGestureRecognizer(tapRec)
            tapRec.addTarget(self, action: #selector(ChatViewController.back))

            let containView = UIView(frame: CGRect(x: 2, y: 0, width: 250, height: 40))

            let profileImage = UIImageView(frame: CGRect(x: 0, y: 4, width: 32, height: 32))
            profileImage.contentMode = UIView.ContentMode.scaleAspectFill
            if image == "" {
                if channelTyp == channelType.GROUP_CHAT || channelTyp == channelType.ADHOC_CHAT {
                    profileImage.image = UIImage(named: "icon_DefaultGroup")
                } else {
                    profileImage.image = LetterImageGenerator.imageWith(name: name, randomColor: .gray)
                }
            } else {
                profileImage.image = getImage(imageName: image)
            }
            profileImage.layer.cornerRadius = 16
            profileImage.layer.borderColor = UIColor.groupTableViewBackground.cgColor
            profileImage.layer.borderWidth = 1
            profileImage.layer.masksToBounds = true
            containView.addSubview(profileImage)

            //title view

            if istyping {
                let title = UILabel(frame: CGRect(x: 40, y: 2, width: 200, height: 20))
                title.text = name
                title.textAlignment = .left
                title.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 16)
                containView.addSubview(title)

                let typingtitle = UILabel(frame: CGRect(x: 40, y: 22, width: 200, height: 15))
                typingtitle.text = isTypingText
                typingtitle.textAlignment = .left
                typingtitle.textColor = .gray
                typingtitle.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 12)
                containView.addSubview(typingtitle)
            } else {
                if isUserOnline {
                    let title = UILabel(frame: CGRect(x: 40, y: 2, width: 200, height: 20))
                    title.text = name
                    title.textAlignment = .left
                    title.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 16)
                    containView.addSubview(title)

                    let typingtitle = UILabel(frame: CGRect(x: 40, y: 22, width: 200, height: 15))
                    typingtitle.text = "Online"
                    typingtitle.textAlignment = .left
                    typingtitle.textColor = .gray
                    typingtitle.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 12)
                    containView.addSubview(typingtitle)

                } else {
                    let title = UILabel(frame: CGRect(x: 40, y: 7, width: 200, height: 20))
                    title.text = name
                    title.textAlignment = .left
                    title.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 16)
                    containView.addSubview(title)
                }
            }
            containView.addGestureRecognizer(groupDetailtapRec)
            groupDetailtapRec.addTarget(self, action: #selector(ChatViewController.didTapGroupTitle))

            let backbuttonwithTitle = UIBarButtonItem(image: UIImage(named: "rightBackButton"), style: .plain, target: self, action: #selector(ChatViewController.back))

            let rightBarButton = UIBarButtonItem(customView: containView)
            navigationItem.leftBarButtonItems = [backbuttonwithTitle, rightBarButton]
            navigationItem.rightBarButtonItem = nil

            // right Bar button
//            let barButtonImage = UIImage(named:"NavSearch")?.withRenderingMode(.alwaysOriginal)
//            let searchIconButton = UIBarButtonItem(image: barButtonImage, style: .plain, target: self, action:#selector(chatSearchButton))
//            navigationItem.rightBarButtonItem = searchIconButton
            animate(duration: 0.1)
        } else {
            let replyButton = UIBarButtonItem(image: UIImage(named: "replyButton"), style: .plain, target: self, action: #selector(didTapReplyButton))
//            let soundButton   = UIBarButtonItem(image: UIImage(named: "volumeButton"),  style: .plain, target: self, action: #selector(didTapSoundButton))
            let deleteButton = UIBarButtonItem(image: UIImage(named: "recycleBinButton"), style: .plain, target: self, action: #selector(didTapDeleteButton))

            let copyButton = UIBarButtonItem(image: UIImage(named: "copyButton"), style: .plain, target: self, action: #selector(didTapCopyButton))
            let shareButton = UIBarButtonItem(image: UIImage(named: "icon_info"), style: .plain, target: self, action: #selector(didTapShareButton))

            let forwardButton = UIBarButtonItem(image: UIImage(named: "forwardButton"), style: .plain, target: self, action: #selector(didTapForwardButton))

            let closeButton = UIBarButtonItem(image: UIImage(named: "closeButton"), style: .plain, target: self, action: #selector(didTapCloseButton))
            navigationItem.rightBarButtonItem = closeButton
            if channelDetails?.channelType == channelType.ONE_ON_ONE_CHAT.rawValue || channelDetails?.channelType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                if showCopy {
                    if showFwd {
                        navigationItem.leftBarButtonItems = [replyButton, deleteButton, copyButton, forwardButton]

                    } else {
                        navigationItem.leftBarButtonItems = [replyButton, deleteButton, copyButton]
                    }
                } else {
                    if showFwd {
                        navigationItem.leftBarButtonItems = [replyButton, deleteButton, forwardButton]

                    } else {
                        navigationItem.leftBarButtonItems = [replyButton, deleteButton]
                    }
                }

            } else {
                if isSentMessage {
                    if getIsConfidential == true {
                        navigationItem.leftBarButtonItems = [replyButton, deleteButton, shareButton]
                    } else {
                        if showCopy {
                            if showFwd {
                                navigationItem.leftBarButtonItems = [replyButton, deleteButton, copyButton, shareButton, forwardButton]

                            } else {
                                navigationItem.leftBarButtonItems = [replyButton, deleteButton, copyButton, shareButton]
                            }

                        } else {
                            if showFwd {
                                navigationItem.leftBarButtonItems = [replyButton, deleteButton, shareButton, forwardButton]

                            } else {
                                navigationItem.leftBarButtonItems = [replyButton, deleteButton, shareButton]
                            }
                        }
                    }

                } else {
                    if getIsConfidential == true {
                        navigationItem.leftBarButtonItems = [replyButton, deleteButton]
                    } else {
                        if showCopy {
                            if showFwd {
                                navigationItem.leftBarButtonItems = [replyButton, deleteButton, copyButton, forwardButton]

                            } else {
                                navigationItem.leftBarButtonItems = [replyButton, deleteButton, copyButton]
                            }

                        } else {
                            if showFwd {
                                navigationItem.leftBarButtonItems = [replyButton, deleteButton, forwardButton]

                            } else {
                                navigationItem.leftBarButtonItems = [replyButton, deleteButton]
                            }
                        }
                    }
                }
            }
            animate(duration: 0.2)
        }
    }

    var count = 0
    var sendTypingStatus = true
    let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)

    // MARK: Navigation bar Options

    func setTypingStatus() {
        if count == 0 {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            let actyping = ACTypingStatusObject(uuid: userId ?? "", channelName: channelDetails?.globalChannelName ?? "", time: String(format: "%.0f", getcurrentTimeStampFOrPubnub()), status: true, topic: topicId)
            if channelDetails.channelType == channelType.ONE_ON_ONE_CHAT.rawValue || channelDetails.channelType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                actyping.channelName = "per." + actyping.channelName
            }
            ACPubnubClass.sendTypingStatus(typingObject: actyping)
        } else {
            if sendTypingStatus {
                let actyping = ACTypingStatusObject(uuid: userId ?? "", channelName: channelDetails?.globalChannelName ?? "", time: String(format: "%.0f", getcurrentTimeStampFOrPubnub()), status: true, topic: topicId)
                if channelDetails.channelType == channelType.ONE_ON_ONE_CHAT.rawValue || channelDetails.channelType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                    actyping.channelName = "per." + actyping.channelName
                }
                ACPubnubClass.sendTypingStatus(typingObject: actyping)
            }
        }
    }

    // must be internal or public.
    @objc func update() {
        // Something cool
        count = count + 1
        if count == 4 {
            count = 0
            sendTypingStatus = true
        } else {
            sendTypingStatus = false
        }
    }

    @objc func didTapGroupTitle() {
        messageTextField.resignFirstResponder()
        if channelDetails?.channelType == channelType.ONE_ON_ONE_CHAT.rawValue {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACProfileViewController") as? ACProfileViewController {
                if let navigator = navigationController {
                    nextViewController.pUser = DatabaseManager.getContactIndexforTable(tableIndex: (channelDetails?.lastSenderPhoneBookContactId)!)
                    nextViewController.isSelf = false
                    navigator.pushViewController(nextViewController, animated: true)
                }
            }

        } else if channelDetails?.channelType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACProfileViewController") as? ACProfileViewController {
                if let navigator = navigationController {
                    let groupMemberIndex = DatabaseManager.getGroupMemberIndexForMemberId(groupId: channelDetails!.lastSenderPhoneBookContactId)!
                    let user = ProfileTable()
                    user.fullName = groupMemberIndex.memberName
                    user.phoneNumber = ""
                    user.localImageFilePath = groupMemberIndex.localImagePath

                    nextViewController.pUser = user
                    nextViewController.isSelf = false
                    navigator.pushViewController(nextViewController, animated: true)
                }
            }

        } else {
            if channelDetails?.channelType == channelType.ADHOC_CHAT.rawValue {
                if let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelDetails!.lastSenderPhoneBookContactId) {
                    let groupMembersList = DatabaseManager.getGroupMembers(globalGroupId: groupTable.id)
                    var memberAppend: String = ""
                    for member in groupMembersList {
                        memberAppend = "\(memberAppend)" + " \(member.memberName) \n"
                    }

                    let alertController = UIAlertController(title: "Member", message: memberAppend, preferredStyle: .alert)

                    if groupTable.groupStatus != groupStats.INACTIVE.rawValue {
                        if groupTable.createdBy == userId {
                            let AddAction = UIAlertAction(title: "Add Members", style: .default, handler: { _ in
                                if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACAddGroupMembersViewController") as? ACAddGroupMembersViewController {
                                    for memberGlobalUserId in groupMembersList {
                                        nextViewController.groupmembersFromExistingGroup.append(memberGlobalUserId.globalUserId)
                                    }
                                    nextViewController.secondDelegate = self as? navigatingBackToGroupDetailsVC
                                    nextViewController.groupID = groupTable.groupGlobalId
                                    nextViewController.groupTitle = groupTable.groupName
                                    nextViewController.grpType = groupTable.groupType
                                    nextViewController.groupDetails = groupTable
                                    nextViewController.isFromAdhocAdd = true

                                    nextViewController.navigatingFromGroupDetailsViewController = true
                                    nextViewController.hidesBottomBarWhenPushed = false
                                    self.navigationController?.pushViewController(nextViewController, animated: true)
                                }

                            })
                            alertController.addAction(AddAction)
                        }
                    }

                    let exitAdhoc = UIAlertAction(title: "Exit", style: .default, handler: { _ in

                        Loader.show()

                        let requestModel = ExitMembersAdhocChatRequestModel()

                        requestModel.deleteGroup = "0"
                        requestModel.auth = DefaultDataProcessor().getAuthDetails()
                        requestModel.channelName = groupTable.groupGlobalId

                        NetworkingManager.ExitMembersAdhocChat(addAdhocMembersModel: requestModel) { (result: Any, sucess: Bool) in
                            if let result = result as? CreateAdhocResponseModel, sucess {
                                Loader.close()
                                if sucess {
                                    let status = result.status ?? ""

                                    if status != "Exception" {
                                        let groupMem = GroupMemberTable()
                                        groupMem.globalUserId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!
                                        groupMem.groupId = groupTable.id
                                        groupMem.memberStatus = groupMemberStats.INACTIVE.rawValue
                                        DatabaseManager.updateGroupMembersStatus(groupMemebrsTable: groupMem)

                                        DatabaseManager.UpdateGroupStatus(groupStatus: groupStats.INACTIVE.rawValue, groupId: groupTable.id)

                                        let chnltyp = ACGroupsProcessingObjectClass.getChannelForGroup(grpType: groupType.ADHOC_CHAT.rawValue)
                                        let chnls = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: groupType.ADHOC_CHAT.rawValue)

                                        if let chTable = DatabaseManager.getChannelIndex(contactId: groupTable.id, channelType: chnls) {
                                            if let member = DatabaseManager.getGroupMemberIndex(groupId: groupTable.id, globalUserId: groupMem.globalUserId) {
                                                let messageText = "You have exited the group"
                                                _ = ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: member.groupMemberContactId, channelId: chTable.id, channel: chTable)
                                            }
                                        }
                                        Loader.close()
                                        if groupTable.createdBy == self.userId {
                                            self.navigationController?.popToRootViewController(animated: true)
                                        } else {
                                            self.userLocationData(clearChat: false)
                                        }
                                    }
                                }
                            }
                        }
                    })

                    if groupTable.groupStatus != groupStats.INACTIVE.rawValue {
                        alertController.addAction(exitAdhoc)
                    }

                    let OKAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(OKAction)
                    present(alertController, animated: true, completion: nil)
                }
            } else {
                if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "groupDetailsViewController") as? groupDetailsViewController {
                    if let navigator = navigationController {
                        nextViewController.hidesBottomBarWhenPushed = true
                        let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelDetails!.lastSenderPhoneBookContactId)
                        nextViewController.groupDetails = groupTable!
                        nextViewController.datadelegate = self
                        nextViewController.photoChangedelegate = self
                        nextViewController.channelName = channelDetails.globalChannelName
                        navigator.pushViewController(nextViewController, animated: true)
                    }
                }
            }
        }
    }

    @objc func didTapReplyButton() {
        if menuItemsStackView.isHidden == false {
            menuItemsStackView.isHidden = true
        }
        replyImage.isHidden = true

        replyName.text = getUserName(object: selectedObject, isFromDisplay: false)

        let dict = getImageForChatListObject(object: selectedObject, isFromDisplay: false)
        replyMessage.text = dict.value(forKey: "text") as? String
        replyImage.image = dict.value(forKey: "image") as? UIImage
        if replyImage.image == nil {
            replyImage.isHidden = true
        } else {
            replyImage.isHidden = false
        }
        replyMessageId = (selectedObject.messageContext?.globalMsgId)!

        replyView.isHidden = false
        replyView.addBorder(toSide: .Top, withColor: UIColor.white.cgColor, andThickness: 10)
        replyView.layoutIfNeeded()
        replyPopUpViewHeightConst.constant = 110
        popUpViewHeightConst.constant = 110

        animate(duration: 0.2)
        isReplyActive = true

        didTapCloseButton()
        openGalleryWidthConstant.constant = 0
        openMenuPlusButton.isHidden = true
        showSendButton()
    }

    @objc func didTapSoundButton() {}

    @objc func didTapDeleteButton() {
        DatabaseManager.updateMessageTableforColoumnAndValue(coloumnName: "visibilityStatus", Value: visibilityStatus.deleted.rawValue, localId: (selectedObject.messageContext?.localMessageId)!)

        let time = Double(selectedObject.messageContext!.msgTimeStamp)! / 10_000_000
        let finalDate = time.getDateFromUTC()

        let dateChatMsgs = messages.value(forKey: finalDate) as! NSMutableArray
        let section = datesArray.index(of: finalDate)
        let row = dateChatMsgs.index(of: selectedObject)

        dateChatMsgs.remove(selectedObject)
        if dateChatMsgs.count == 0 {
            datesArray.remove(finalDate)
            chatTable.beginUpdates()
            let indexSet: IndexSet = [section]
            chatTable.deleteSections(indexSet, with: UITableView.RowAnimation.bottom)
            chatTable.endUpdates()
        } else {
            messages.removeObject(forKey: finalDate)
            messages.setValue(dateChatMsgs, forKey: finalDate)

            chatTable.beginUpdates()
            let newIndexPaths = IndexPath(row: row, section: section)
            chatTable.deleteRows(at: [newIndexPaths], with: UITableView.RowAnimation.bottom)
            chatTable.endUpdates()
        }
        selectedObject = chatListObject()

        didTapCloseButton()
    }

    @objc func didTapCopyButton() {
        let type = selectedObject.messageItem!.messageType
        switch type! {
        case messagetype.TEXT:
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = (selectedObject.messageItem!.messageTextString)
        default:

            print("do Nothing")
            alert(message: labelStrings.copyOnlyText)
        }

        didTapCloseButton()
    }

    @objc func didTapForwardButton() {
        didTapCloseButton()
        messageTextField.resignFirstResponder()

        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACForwardSelectionViewController") as? ACForwardSelectionViewController {
            if let navigator = self.navigationController {
                nextViewController.selectedMsg = DatabaseManager.getMessageIndex(globalMsgId: selectedObject.messageContext!.globalMsgId!)
                nextViewController.hidesBottomBarWhenPushed = true
                navigator.pushViewController(nextViewController, animated: true)
                nextViewController.createGroupFromAddButton = true
            }
        }
    }

    @objc func didTapShareButton() {
        didTapCloseButton()
        let homeStoryBoard = UIStoryboard(name: "OnBoarding", bundle: nil)
        let nextViewController = homeStoryBoard.instantiateViewController(withIdentifier: "ACMessageStatusViewController") as! ACMessageStatusViewController
        if let navigator = navigationController {
            if let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelDetails!.lastSenderPhoneBookContactId) {
                nextViewController.groupTable = groupTable
            }
            nextViewController.selectedObject = selectedObject
            navigator.pushViewController(nextViewController, animated: true)
        }
    }

    @objc func didTapCloseButton() {
        isCellSelected = false
        customNavigationBar(name: displayName!, image: displayImage!, channelTyp: channelType(rawValue: (channelDetails?.channelType)!)!)
    }

    @objc func back() {
        print("Pressed back button")

        DatabaseManager.updateChannelTableForChannelId(channelId: (channelDetails?.channelId)!)
        if isFromContacts {
            navigationController?.popToRootViewController(animated: true)
        } else if isfromNotifications {
            let homeStoryBoard = UIStoryboard(name: "OnBoarding", bundle: nil)
            let nextViewController = homeStoryBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
            present(nextViewController, animated: false, completion: nil)

        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc func DismissKeyboard() {
        print("dismissKeyboard")
        messageTextField.resignFirstResponder()
    }

    @objc func DismissMenu() {
        print("dismissKeyboard")
        hideMenu()
    }

    @objc func chatSearchButton() {}

    var isReplyActive = false

    @IBAction func onTapOfClosereplyView(_: Any) {
        replyView.isHidden = true
        replyPopUpViewHeightConst.constant = 0
        popUpViewHeightConst.constant = 0
        replyMessageId = ""
        animate(duration: 0.2)
        openGalleryWidthConstant.constant = 42
        openMenuPlusButton.isHidden = false
        isReplyActive = false
        showcameraAudioButton()
    }

    func hideMenu() {
        if menuItemsStackView.isHidden != true {
            if tapActive == false {
                chatTable.removeGestureRecognizer(chatTableTap)
            }

            menuItemsStackView.isHidden = true
            popUpViewHeightConst.constant = 0
            replyPopUpViewHeightConst.constant = 0

            openMenuPlusButton.isSelected = false
            animate(duration: 0.2)
        }
    }

    @IBAction func openGalleryBtnAction(_: Any) {
        print("pressed open Gallery")
        let pickerController = TZImagePickerController()

        pickerController.maxImagesCount = 8
        pickerController.isSelectOriginalPhoto = false
        pickerController.allowTakePicture = true
        pickerController.allowTakeVideo = false
        pickerController.allowPreview = false
        pickerController.allowPickingImage = true
        pickerController.allowPickingVideo = false
        pickerController.allowCameraLocation = false
        pickerController.didFinishPickingPhotosHandle = { (photos, assets, _) -> Void in

            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "AddImagesViewController") as? AddImagesViewController {
//                self.selectedImages = assets
                nextViewController.addImageDelegate = self
                nextViewController.selectedList = assets ?? []
                nextViewController.addedImages = photos ?? []
                self.present(nextViewController, animated: false, completion: nil)
            }
        }

        present(pickerController, animated: true, completion: nil)
    }

    @IBAction func inviteBtnAction(_: Any) {
        let pickerController = TZImagePickerController()

        pickerController.maxImagesCount = 1
        pickerController.isSelectOriginalPhoto = false
        pickerController.allowTakePicture = false
        pickerController.allowTakeVideo = true
        pickerController.allowPreview = false
        pickerController.allowPickingImage = false
        pickerController.allowPickingVideo = true
        pickerController.allowCameraLocation = false

        pickerController.didFinishPickingVideoHandle = { (photos, assets) -> Void in

            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "AddImagesViewController") as? AddImagesViewController {
                //                self.selectedImages = assets
                nextViewController.addImageDelegate = self
                nextViewController.isImage = false
                nextViewController.coverImage = photos!
                nextViewController.addedVideo = assets!
                self.present(nextViewController, animated: false, completion: nil)
            }
        }

        present(pickerController, animated: true, completion: nil)
    }

    @IBAction func createPollAction(_: Any) {
        print("pressed open createPoll")
        IQKeyboardManager.shared.resignFirstResponder()
        hideMenu()

        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "CreatePollViewController") as? CreatePollViewController {
            nextViewController.pollDelegate = self
            nextViewController.modalPresentationStyle = .fullScreen
            present(nextViewController, animated: false, completion: nil)
//            self.modalPresentationStyle = .overCurrentContext
        }
    }

    @IBAction func openMenuButtonAction(_: Any) {
        if menuItemsStackView.isHidden == true {
            if replyView.isHidden == false {
                replyView.isHidden = true
            }
            if tapActive == false {
                chatTableTap.addTarget(self, action: #selector(ChatViewController.DismissMenu))
                chatTable.addGestureRecognizer(chatTableTap)
            }
            menuItemsStackView.isHidden = false
            menuView.addBorder(toSide: .Top, withColor: UIColor.white.cgColor, andThickness: 10)
            menuView.layoutIfNeeded()
            openMenuPlusButton.isSelected = true
            popUpViewHeightConst.constant = 110
            replyPopUpViewHeightConst.constant = 110
            animate(duration: 0.2)
        } else {
            menuItemsStackView.isHidden = true
            openMenuPlusButton.isSelected = false
            popUpViewHeightConst.constant = 0
            replyPopUpViewHeightConst.constant = 0

            animate(duration: 0.2)
        }

        print("pressed open menuButton")
    }

    @IBAction func openCameraButtonAction(_: Any) {
        CameraHandler.shared.showCamera(vc: self)
        CameraHandler.shared.imagePickedBlock = { groupImage in
            DispatchQueue.main.async { () in
                if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "AddImagesViewController") as? AddImagesViewController {
                    nextViewController.addImageDelegate = self
                    nextViewController.addedImages = [groupImage]
                    self.present(nextViewController, animated: false, completion: nil)
                }
            }
        }
    }

    func isOnPhoneCall() -> Bool {
        for call in CXCallObserver().calls {
            if call.hasEnded == false {
                return true
            }
        }
        return false
    }

    @IBAction func onClickOfRecordAudio(_: Any) {
        if !isOnPhoneCall() {
            if isAuthAvaialableForAudio() == 1 {
                if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACAudioRecordingViewController") as? ACAudioRecordingViewController {
                    nextViewController.audioDelegate = self
                    nextViewController.modalPresentationStyle = .overCurrentContext
                    present(nextViewController, animated: false, completion: nil)
                    modalPresentationStyle = .overCurrentContext
                }
            } else {
                if isAuthAvaialableForAudio() == 0 {
                    alert(message: "Please enable permission from settings")
                }
            }

        } else {
            alert(message: "Cannot record audio while on call")
        }
    }

    func isAuthAvaialableForAudio() -> Int {
        var permissionCheck: Int = 0

        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            permissionCheck = 1
            return permissionCheck

        case AVAudioSession.RecordPermission.denied:
            permissionCheck = 0
            return permissionCheck

        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    permissionCheck = 1
                    DispatchQueue.main.async { () in
                        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACAudioRecordingViewController") as? ACAudioRecordingViewController {
                            nextViewController.audioDelegate = self
                            nextViewController.modalPresentationStyle = .overCurrentContext
                            self.present(nextViewController, animated: false, completion: nil)
                            self.modalPresentationStyle = .overCurrentContext
                        }
                    }
                } else {
                    permissionCheck = 0
                }
            }
            return 2

        default:
            return 0
        }
    }

    @IBAction func onClickOfSendButton(_: Any) {
        // Note : for testing purpose , messages are saving wuth audio record button.(send button was not implemented in zeplin designs)
        scrollFloatingButton.extBorderWidth = 0
        scrollFloatingButton.extBorderColor = .darkGray
        scrollFloatingButton.isHidden = true
        if !messageTextField.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // saving Message
            let msg = messageTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let sendMessage = ChatMessageProcessor.createMessageContextObject(groupType: group.groupType, text: msg, channel: (channelDetails?.globalChannelName)!, chanlType: channelType(rawValue: (channelDetails?.channelType)!)!, localSenderId: userLocalId!, localChannelId: (channelDetails?.channelId)!, globalChatId: globalChatId!, replyId: replyMessageId)
            if topicId != "" {
                sendMessage.messageContext!.topicId = topicId
            } else {
                sendMessage.messageContext!.topicId = ""
            }

            ACMessageSenderClass.sendTextMessage(messageContext: sendMessage.messageContext!, message: msg, groupName: displayName ?? "", grpRefId: refGroupId, messageTitle: "")

            if replyView.isHidden == false {
                onTapOfClosereplyView(self)
            }

            // to set based on timestamp
            let time = Double(sendMessage.messageContext!.msgTimeStamp)! / 10_000_000
            let finalDate = time.getDateFromUTC()

            let allDates = messages.allKeys as NSArray

            if allDates.contains(finalDate) {
                let dateChatMsgs = messages.value(forKey: finalDate) as! NSMutableArray
                dateChatMsgs.insert(sendMessage, at: 0)
                messages.removeObject(forKey: finalDate)
                messages.setValue(dateChatMsgs, forKey: finalDate)

            } else {
                let dateChatMsgs = NSMutableArray()
                dateChatMsgs.insert(sendMessage, at: 0)
                messages.setValue(dateChatMsgs, forKey: finalDate)
            }

            reloadTableViewToIndex()

            messageTextField.text = ""
            textViewHC.constant = 30
            openGalleryWidthConstant.constant = 42
            isReplyActive = false
            openMenuPlusButton.isHidden = false

            print("pressed open audio button")
        } else {
            print("Empty Message")
        }
    }

    func reloadTableViewToIndex(isScrollRequired: Bool = true) {
        let filArray = (messages.allKeys as NSArray).descendingArrayWithData()

        if isScrollRequired {
            if filArray.count != datesArray.count {
                datesArray = filArray
                //            self.chatTable.reloadData()
                let sectionToReload = 0
                let indexSet: IndexSet = [sectionToReload]
                chatTable.beginUpdates()

                chatTable.insertSections(indexSet, with: UITableView.RowAnimation.none)
                chatTable.endUpdates()
                //            self.chatTable.reloadSections(indexSet, with: UITableView.RowAnimation.bottom)

                let reloadIndexPaths = IndexPath(row: 0, section: 0)
                chatTable.scrollToRow(at: reloadIndexPaths, at: .top, animated: false)
                if chatTable.isHidden == true {
                    chatTable.isHidden = false
                }
            } else {
                let newIndexPaths = IndexPath(row: 0, section: 0)

                chatTable.beginUpdates()
                chatTable.insertRows(at: [newIndexPaths], with: UITableView.RowAnimation.none)
                chatTable.endUpdates()
                let reloadIndexPaths = IndexPath(row: 0, section: 0)
                chatTable.scrollToRow(at: reloadIndexPaths, at: .bottom, animated: false)
            }

        } else {
            if filArray.count != datesArray.count {
                datesArray = filArray
                //            self.chatTable.reloadData()
                let sectionToReload = 0
                let indexSet: IndexSet = [sectionToReload]
                chatTable.beginUpdates()

                chatTable.insertSections(indexSet, with: UITableView.RowAnimation.none)
                chatTable.endUpdates()

                if chatTable.isHidden == true {
                    chatTable.isHidden = false
                }
            } else {
                let newIndexPaths = IndexPath(row: 0, section: 0)

                chatTable.beginUpdates()
                chatTable.insertRows(at: [newIndexPaths], with: UITableView.RowAnimation.none)
                chatTable.endUpdates()
            }
        }

//        let scrollPoint = CGPoint(x: 0, y: self.chatTable.contentSize.height - self.chatTable.frame.size.height)
//            self.chatTable.setContentOffset(scrollPoint, animated: false)
    }

    // MARK: scrollview

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y > scrollView.contentOffset.y + 10 || targetContentOffset.pointee.y < scrollView.contentOffset.y + 10 {
            if scrollView.contentSize.height + 100 > chatTable.frame.maxY {
                if chatTable.contentOffset.y >= 200 {
                    scrollFloatingButton.isHidden = true
                } else {
                    scrollFloatingButton.extBorderWidth = 0

                    scrollFloatingButton.extBorderColor = .darkGray
                    scrollFloatingButton.isHidden = false
                }
            } else {
                scrollFloatingButton.isHidden = true
            }

            UIView.animate(withDuration: 1) {
                self.view.layoutIfNeeded()
            }
        } else {
            scrollFloatingButton.isHidden = true
            UIView.animate(withDuration: 1) {
                self.view.layoutIfNeeded()
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 200 {
            // reach bottom
            scrollFloatingButton.isHidden = true
        }
//            self.scrollFloatingButton.isHidden = true
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func scrollFloatingButtonAction(_: Any) {
        let newIndexPaths = IndexPath(row: 0, section: 0)
        chatTable.scrollToRow(at: newIndexPaths, at: .bottom, animated: false)

        scrollFloatingButton.isHidden = true
        scrollFloatingButton.extBorderWidth = 0
        scrollFloatingButton.extBorderColor = .darkGray
    }

    func rotateTable() {
//        if messages.count == 0 {
//            print("CHAT HAVE ZERO MESSAGES!")
//        } else {
//            chatTable.transform = CGAffineTransform(scaleX: 1, y: -1)
//        }
    }

    var isPlayingAudio = false
    var selectedAudioIndex = IndexPath()
    var playingAudioObject = chatListObject()
    var isTimerFirstTime = false

    func userLocationData(clearChat: Bool) {
        if clearChat {
            isViewFirstTime = true
            loadTableViewData(chnlDetails: channelDetails)
        } else {
            bottomKeyboardView.isHidden = true
            noKeyboardView.isHidden = false
        }
    }

    func photoUpdateData(photoName: String) {
        displayImage = photoName
        customNavigationBar(name: displayName!, image: displayImage!, channelTyp: channelType(rawValue: (channelDetails?.channelType)!)!)
    }
}
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return datesArray.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datesArray.count == 0 {
            return 0
        } else {
            let date = datesArray.object(at: section) as! String
            let dateMsgArray = messages.value(forKey: date) as! NSMutableArray
            return dateMsgArray.count
        }
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "DayViewCell") as! DayViewCell
        headerCell.backgroundColor = UIColor.clear
        let date = datesArray.object(at: section) as! String
        headerCell.dayButton.setTitle(date.checkIfTodayOrYesterday(), for: .normal)
//        headerCell.contentView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        headerCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)

        return headerCell.contentView
    }

    // MARK: Message Data

    fileprivate func processDataForVideoMessage(_ incomingCell: IncomingMessageCell, _ chatList: chatListObject, _ textMessageLabel: PaddedLabel, _ indexPath: IndexPath, _ longGesture: tableViewLongPress, _ msgContext: ACMessageContextObject?, _ outgoingCell: OutGoingMessageCell) -> UITableViewCell {
        incomingCell.viewType = TYPE_OF_MESSAGE.PHOTO_MESSAGE
        incomingCell.initializeViews()
        incomingCell.PhotosView?.playButton.isHidden = false

        if chatList.messageContext?.isMine == false {
            if chatList.messageItem?.thumbnail == "" {
                if delegate != nil {
                    if (delegate?.isInternetAvailable)! {
                        incomingCell.PhotosView?.activityView.isHidden = false
                        incomingCell.PhotosView?.activityIndicatorView.startAnimating()
                        // addObject TO Array
                        let json = convertJsonStringToDictionary(text: (chatList.messageItem?.cloudReference)!)
                        if json != nil {
                            let urlStr = json!["imgurl"]! as! String

                            if let trace = self.downloadTracker.value(forKey: urlStr) {
                                let tracer = trace as! Int
                                if tracer == downloadStatus.inProgress.rawValue || tracer == downloadStatus.failed.rawValue {
                                    incomingCell.PhotosView?.Photo.image = UIImage(named: "group_profile")
                                    incomingCell.PhotosView?.playButton.setImage(UIImage(named: "download"), for: .normal)
                                    incomingCell.PhotosView?.playButton.isHidden = false
                                    incomingCell.PhotosView?.activityView.isHidden = true
                                    incomingCell.PhotosView?.activityIndicatorView.stopAnimating()

                                    incomingCell.PhotosView?.playButton.tag = indexPath.row
                                    incomingCell.PhotosView?.playButton.superview?.tag = indexPath.section

                                    incomingCell.PhotosView?.playButton.addTarget(self, action: #selector(onTapOfDownLoadImage(_:)), for: .touchUpInside)
                                }
                            } else {
                                let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: urlStr, refernce: (chatList.messageContext?.localMessageId)!, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

                                DispatchQueue.global(qos: .background).async {
                                    self.downloadTracker.setValue(downloadStatus.inProgress.rawValue, forKey: urlStr)
                                    ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                                        if path == "" {
                                            self.downloadTracker.setValue(downloadStatus.failed.rawValue, forKey: urlStr)

                                            incomingCell.PhotosView?.activityView.isHidden = true
                                            incomingCell.PhotosView?.activityIndicatorView.stopAnimating()

                                        } else {
                                            self.downloadTracker.removeObject(forKey: urlStr)

                                            DatabaseManager.updateMessageTableForOtherColoumn(imageData: path, localId: (chatList.messageContext?.localMessageId)!)

                                            chatList.messageItem?.thumbnail = path
                                            DispatchQueue.main.async { () in
                                                incomingCell.PhotosView?.Photo.image = self.load(attName: (chatList.messageItem?.thumbnail)!)
                                                incomingCell.PhotosView?.activityView.isHidden = true
                                                incomingCell.PhotosView?.activityIndicatorView.stopAnimating()
                                            }
                                        }

                                    })
                                }
                            }
                        } else {
                            incomingCell.PhotosView?.Photo.image = UIImage(named: "group_profile")
                            incomingCell.PhotosView?.playButton.setImage(UIImage(named: "download"), for: .normal)
                            incomingCell.PhotosView?.playButton.isHidden = false
                            incomingCell.PhotosView?.activityView.isHidden = true
                            incomingCell.PhotosView?.activityIndicatorView.stopAnimating()
                        }

                    } else {
                        incomingCell.PhotosView?.Photo.image = UIImage(named: "group_profile")
                        incomingCell.PhotosView?.playButton.setImage(UIImage(named: "download"), for: .normal)
                        incomingCell.PhotosView?.playButton.isHidden = false
                        incomingCell.PhotosView?.activityView.isHidden = true
                        incomingCell.PhotosView?.activityIndicatorView.stopAnimating()
                        incomingCell.PhotosView?.playButton.tag = indexPath.row
                        incomingCell.PhotosView?.playButton.superview?.tag = indexPath.section
                        incomingCell.PhotosView?.playButton.addTarget(self, action: #selector(onTapOfDownLoadImage(_:)), for: .touchUpInside)
                    }
                } else {
                    incomingCell.PhotosView?.Photo.image = UIImage(named: "group_profile")
                    incomingCell.PhotosView?.playButton.setImage(UIImage(named: "download"), for: .normal)
                    incomingCell.PhotosView?.playButton.isHidden = false
                    incomingCell.PhotosView?.activityView.isHidden = true
                    incomingCell.PhotosView?.activityIndicatorView.stopAnimating()
                }

            } else {
                incomingCell.PhotosView?.activityView.isHidden = true
                incomingCell.PhotosView?.activityIndicatorView.stopAnimating()
                let attName = chatList.messageItem?.message as! String
                if attName == "" {
                    incomingCell.PhotosView?.playButton.setImage(UIImage(named: "download"), for: .normal)
                } else {
                    incomingCell.PhotosView?.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
                }

                DispatchQueue.global(qos: .background).async {
                    let imageName = chatList.messageItem?.thumbnail
                    let image = self.getImage(imageName: imageName!)
                    DispatchQueue.main.async { () in
                        incomingCell.PhotosView?.Photo.image = image
                    }
                }
                incomingCell.PhotosView?.previewButton.tag = indexPath.row
                incomingCell.PhotosView?.previewButton.superview?.tag = indexPath.section
                incomingCell.PhotosView?.previewButton.addTarget(self, action: #selector(onTapOfPlay(_:)), for: .touchUpInside)

                incomingCell.PhotosView?.playButton.addTarget(self, action: #selector(onTapOfPlay(_:)), for: .touchUpInside)
            }

            incomingCell.messageStackView.addArrangedSubview(incomingCell.PhotosView ?? incomingCell.messageStackView)
            if chatList.messageItem?.messageTextString != "" {
                textMessageLabel.padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)

                textMessageLabel.text = chatList.messageItem?.messageTextString
                incomingCell.messageStackView.addArrangedSubview(textMessageLabel)
            }

            //                    incomingCell.profileName.text = "  \(String(describing: incomingCell.profileName.text))"
            incomingCell.messageStackView.addGestureRecognizer(longGesture)
            incomingCell.bubbleWidth.constant = 270

            return incomingCell
        } else {
            if msgContext?.messageState == messageState.SENDER_UNSENT, chatList.messageItem?.cloudReference == "" {
                incomingCell.PhotosView?.activityView.isHidden = false
                incomingCell.PhotosView?.activityIndicatorView.startAnimating()

            } else {
                DispatchQueue.global(qos: .background).async {
                    let imageName = chatList.messageItem?.thumbnail
                    let image = self.getImage(imageName: imageName!)

                    DispatchQueue.main.async { () in
                        incomingCell.PhotosView?.Photo.image = image
                    }
                }
                let attName = chatList.messageItem?.message as! String
                if attName == "" {
                    incomingCell.PhotosView?.playButton.setImage(UIImage(named: "download"), for: .normal)
                } else {
                    incomingCell.PhotosView?.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
                }

                incomingCell.PhotosView?.activityView.isHidden = true
                incomingCell.PhotosView?.activityIndicatorView.stopAnimating()

                incomingCell.PhotosView?.previewButton.tag = indexPath.row
                incomingCell.PhotosView?.previewButton.superview?.tag = indexPath.section
                incomingCell.PhotosView?.playButton.addTarget(self, action: #selector(onTapOfPlay(_:)), for: .touchUpInside)

                incomingCell.PhotosView?.previewButton.addTarget(self, action: #selector(onTapOfPlay(_:)), for: .touchUpInside)

                incomingCell.PhotosView?.previewButton.addGestureRecognizer(longGesture)
            }

            outgoingCell.topSPaceCOnstraint.constant = 4
            outgoingCell.bottomSpaceConstraint.constant = 4
            outgoingCell.leadingCOnstraint.constant = 4
            outgoingCell.trailingConstraint.constant = 17
            outgoingCell.whitebackgroundHeightConstraint.constant = 0
            if chatList.messageContext?.showBeak == beakState.SHOWBEAK {
                outgoingCell.backgroundViewForCustumViews.isHidden = true
            } else {
                outgoingCell.backgroundViewForCustumViews.isHidden = false
                outgoingCell.trailingConstraint.constant = 4
            }
            outgoingCell.messageView.addArrangedSubview(incomingCell.PhotosView ?? outgoingCell.messageView)
            if chatList.messageItem?.messageTextString != "" {
                textMessageLabel.textColor = .white
                textMessageLabel.text = chatList.messageItem?.messageTextString
                outgoingCell.messageView.addArrangedSubview(textMessageLabel)
            }
            outgoingCell.bubbleWidth.constant = 270

            return outgoingCell
        }
    }

    fileprivate func processDataForAudioMessage(_ outgoingCell: OutGoingMessageCell, _ chatList: chatListObject, _ textMessageLabel: PaddedLabel, _ indexPath: IndexPath, _ msgContext: ACMessageContextObject?, _ longGesture: tableViewLongPress, _ incomingCell: IncomingMessageCell) -> UITableViewCell {
        outgoingCell.viewType = TYPE_OF_MESSAGE.AUDIO_MESSAGE
        outgoingCell.initializeViews()

        if chatList.messageContext?.isMine == true {
            outgoingCell.messageView.addArrangedSubview(outgoingCell.musicView!)
            if chatList.messageItem?.messageTextString != "" {
                textMessageLabel.text = chatList.messageItem?.messageTextString
                outgoingCell.messageView.addArrangedSubview(textMessageLabel)
            }
            outgoingCell.musicView!.playButton.tag = indexPath.row
            outgoingCell.musicView!.songSlider.tag = indexPath.row
            outgoingCell.musicView!.playButton.superview?.tag = indexPath.section
            outgoingCell.musicView!.songSlider.superview?.tag = indexPath.section

            if msgContext?.messageState == messageState.SENDER_UNSENT, chatList.messageItem?.cloudReference == "" {
                outgoingCell.musicView!.isUserInteractionEnabled = false
                outgoingCell.musicView!.playButton.isHidden = true
                outgoingCell.musicView!.activityImage.isHidden = false
                outgoingCell.musicView!.activityImage.startAnimating()

            } else {
                outgoingCell.musicView!.isUserInteractionEnabled = true
                outgoingCell.musicView!.playButton.isHidden = false
                outgoingCell.musicView!.activityImage.isHidden = true
                outgoingCell.musicView!.activityImage.stopAnimating()
            }

            outgoingCell.musicView!.playButton.setImage(UIImage(named: "shape"), for: .normal)
            outgoingCell.musicView!.playImage.image = UIImage(named: "nounAudio2112009Copy2")
            outgoingCell.musicView!.songSlider.thumbTintColor = UIColor.white
            outgoingCell.musicView!.songSlider.minimumTrackTintColor = UIColor(white: 1, alpha: 0.45)
            outgoingCell.musicView!.songSlider.maximumTrackTintColor = UIColor(white: 1, alpha: 0.45)
            outgoingCell.musicView!.lblTime.textColor = UIColor.white
            outgoingCell.backgroundViewForCustumViews.isHidden = true
            outgoingCell.musicView!.songSlider.setThumbImage(UIImage(named: "slider-white")!, for: .normal)

            outgoingCell.topSPaceCOnstraint.constant = 4
            outgoingCell.bottomSpaceConstraint.constant = 4
            outgoingCell.leadingCOnstraint.constant = 4
            outgoingCell.trailingConstraint.constant = 17

            if chatList.messageContext?.showBeak != beakState.SHOWBEAK {
                outgoingCell.trailingConstraint.constant = 4
            }
            // get duration
            let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
            let chatList = dayMessages[indexPath.row] as! chatListObject
            let attName = chatList.messageItem?.message as? String
            let bundle = getDir().appendingPathComponent(attName!.appending(".m4a"))

            if FileManager.default.fileExists(atPath: bundle.path) {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: bundle)
                    audioPlayer.delegate = self as? AVAudioPlayerDelegate

                    let gettime = NSString(format: "%.2f", (audioPlayer.duration / 60) / 2) as String
                    outgoingCell.musicView!.lblTime.text = "\(gettime)"
                    outgoingCell.musicView!.songSlider.minimumValue = Float(0)
                    outgoingCell.musicView!.songSlider.maximumValue = Float(audioPlayer.duration)

                } catch {
                    print("play(with name:), ", error.localizedDescription)
                }
            }

            outgoingCell.musicView!.playButton.addTarget(self, action: #selector(onTapOfPlayAudioFile(_:)), for: .touchUpInside)
            outgoingCell.musicView!.songSlider.addTarget(self, action: #selector(moveSlide(sender:)), for: .valueChanged)
            outgoingCell.messageView.addGestureRecognizer(longGesture)
            outgoingCell.bubbleWidth.constant = 270

            return outgoingCell
        } else {
            incomingCell.viewType = TYPE_OF_MESSAGE.AUDIO_MESSAGE
            incomingCell.initializeViews()
            incomingCell.messageStackView.addArrangedSubview(incomingCell.musicView!)

            incomingCell.musicView!.playButton.isHidden = false
            incomingCell.musicView!.activityImage.isHidden = true
            incomingCell.musicView!.activityImage.stopAnimating()

            incomingCell.musicView!.playButton.superview?.tag = indexPath.section
            incomingCell.musicView!.playButton.tag = indexPath.row
            incomingCell.musicView!.songSlider.tag = indexPath.row
            incomingCell.musicView!.songSlider.superview?.tag = indexPath.section
            //                incomingCell.musicView!.colorView.backgroundColor = UIColor.white

            incomingCell.musicView!.playButton.setImage(UIImage(named: "shapeGreen"), for: .normal)
            incomingCell.musicView!.playImage.image = UIImage(named: "nounAudio2112009Copy3")
            incomingCell.musicView!.songSlider.thumbTintColor = UIColor(red: 18 / 255.0, green: 151 / 255.0, blue: 147 / 255.0, alpha: 1)
            incomingCell.musicView!.songSlider.minimumTrackTintColor = COLOURS.APP_MEDIUM_GREEN_COLOR

            incomingCell.musicView!.songSlider.maximumTrackTintColor = UIColor(red: 155.0 / 255.0, green: 155.0 / 255.0, blue: 155.0 / 255.0, alpha: 0.43)
            incomingCell.musicView!.lblTime.textColor = UIColor.darkGray
            incomingCell.musicView!.songSlider.setThumbImage(UIImage(named: "slider-green")!, for: .normal)

            // get duration

            let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
            let chatList = dayMessages[indexPath.row] as! chatListObject
            let attName = chatList.messageItem?.message as? String
            let bundle = getDir().appendingPathComponent(attName!.appending(".m4a"))

            if FileManager.default.fileExists(atPath: bundle.path) {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: bundle)
                    audioPlayer.delegate = self as? AVAudioPlayerDelegate

                    let gettime = NSString(format: "%.2f", (audioPlayer.duration / 60) / 2) as String
                    incomingCell.musicView!.lblTime.text = "\(gettime)"
                    incomingCell.musicView!.songSlider.minimumValue = Float(0)
                    incomingCell.musicView!.songSlider.maximumValue = Float(audioPlayer.duration)

                } catch {
                    print("play(with name:), ", error.localizedDescription)
                }

            } else {
                incomingCell.musicView!.playButton.setImage(UIImage(named: "download-music"), for: .normal)
            }

            incomingCell.musicView!.playButton.addTarget(self, action: #selector(onTapOfPlayAudioFile(_:)), for: .touchUpInside)
            incomingCell.musicView!.songSlider.addTarget(self, action: #selector(moveSlide(sender:)), for: .valueChanged)

            if chatList.messageItem?.messageTextString != "" {
                textMessageLabel.textColor = .white
                textMessageLabel.text = chatList.messageItem?.messageTextString
                incomingCell.messageStackView.addArrangedSubview(textMessageLabel)
            }

            incomingCell.messageStackView.addGestureRecognizer(longGesture)
            incomingCell.bubbleWidth.constant = 270

            return incomingCell
        }
    }

    fileprivate func processDataForImageMessage(_ chatList: chatListObject, _ incomingCell: IncomingMessageCell, _ indexPath: IndexPath, _ longGesture: tableViewLongPress, _ textMessageLabel: PaddedLabel, _ outgoingCell: OutGoingMessageCell, _ msgContext: ACMessageContextObject?) -> UITableViewCell {
        // for handling image

        if chatList.messageContext?.isMine == false {
            incomingCell.viewType = TYPE_OF_MESSAGE.PHOTO_MESSAGE
            incomingCell.initializeViews()

            if chatList.messageItem?.message as! String == "" {
                incomingCell.PhotosView?.Photo.image = UIImage(named: "group_profile")

                if delegate != nil {
                    if (delegate?.isInternetAvailable)! {
                        incomingCell.PhotosView?.activityView.isHidden = false
                        incomingCell.PhotosView?.activityIndicatorView.startAnimating()

                        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: (chatList.messageItem?.cloudReference)!, refernce: (chatList.messageContext?.localMessageId)!, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

                        DispatchQueue.global(qos: .background).async {
                            ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                                if path == "" {
                                    DispatchQueue.main.async { () in
                                        incomingCell.PhotosView?.playButton.setImage(UIImage(named: "download"), for: .normal)
                                        incomingCell.PhotosView?.playButton.isHidden = false
                                        incomingCell.PhotosView?.activityView.isHidden = true
                                        incomingCell.PhotosView?.activityIndicatorView.stopAnimating()
                                        incomingCell.PhotosView?.playButton.tag = indexPath.row
                                        incomingCell.PhotosView?.playButton.superview?.tag = indexPath.section
                                        incomingCell.PhotosView?.playButton.addTarget(self, action: #selector(self.onTapOfDownLoadImage(_:)), for: .touchUpInside)
                                    }

                                } else {
                                    DatabaseManager.updateMessageTableForLocalImage(localImagePath: path, localId: (chatList.messageContext?.localMessageId)!)
                                    chatList.messageItem?.message = path
                                    DispatchQueue.main.async { () in
                                        incomingCell.PhotosView?.Photo.image = self.load(attName: chatList.messageItem?.message as! String)
                                        incomingCell.PhotosView?.activityView.isHidden = true
                                        incomingCell.PhotosView?.activityIndicatorView.stopAnimating()
                                    }
                                }

                            })
                        }

                    } else {
                        incomingCell.PhotosView?.Photo.image = UIImage(named: "group_profile")
                        incomingCell.PhotosView?.playButton.setImage(UIImage(named: "download"), for: .normal)
                        incomingCell.PhotosView?.playButton.isHidden = false
                        incomingCell.PhotosView?.activityView.isHidden = true
                        incomingCell.PhotosView?.activityIndicatorView.stopAnimating()
                        incomingCell.PhotosView?.playButton.tag = indexPath.row
                        incomingCell.PhotosView?.playButton.superview?.tag = indexPath.section
                        incomingCell.PhotosView?.playButton.addTarget(self, action: #selector(onTapOfDownLoadImage(_:)), for: .touchUpInside)
                    }
                }

            } else {
                DispatchQueue.global(qos: .background).async {
                    let imageString = chatList.messageItem?.message as! String
                    let image = self.getImage(imageName: imageString)

                    DispatchQueue.main.async { () in
                        incomingCell.PhotosView?.Photo.image = image
                    }
                }

                incomingCell.PhotosView?.activityView.isHidden = true
                incomingCell.PhotosView?.activityIndicatorView.stopAnimating()
                incomingCell.PhotosView?.previewButton.tag = indexPath.row
                incomingCell.PhotosView?.previewButton.superview?.tag = indexPath.section

                incomingCell.PhotosView?.previewButton.addTarget(self, action: #selector(onTapOfPreview(_:)), for: .touchUpInside)

                incomingCell.PhotosView?.previewButton.addGestureRecognizer(longGesture)
            }

            incomingCell.messageStackView.addArrangedSubview(incomingCell.PhotosView ?? incomingCell.messageStackView)
            if chatList.messageItem?.messageTextString != "" {
                textMessageLabel.padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)

                textMessageLabel.text = chatList.messageItem?.messageTextString
                incomingCell.messageStackView.addArrangedSubview(textMessageLabel)
            }

            incomingCell.bubbleWidth.constant = 270

            return incomingCell
        } else {
            outgoingCell.viewType = TYPE_OF_MESSAGE.PHOTO_MESSAGE
            outgoingCell.initializeViews()

            DispatchQueue.global(qos: .background).async {
                let imageString = chatList.messageItem?.message as! String
                let image = self.getImage(imageName: imageString)

                DispatchQueue.main.async { () in
                    outgoingCell.PhotosView?.Photo.image = image
                }
            }
            if msgContext?.messageState == messageState.SENDER_UNSENT, chatList.messageItem?.cloudReference == "" {
                outgoingCell.PhotosView?.activityView.isHidden = false
                outgoingCell.PhotosView?.activityIndicatorView.startAnimating()

            } else {
                outgoingCell.PhotosView?.activityView.isHidden = true
                outgoingCell.PhotosView?.activityIndicatorView.stopAnimating()
                outgoingCell.PhotosView?.previewButton.tag = indexPath.row
                outgoingCell.PhotosView?.previewButton.superview?.tag = indexPath.section

                outgoingCell.PhotosView?.previewButton.addTarget(self, action: #selector(onTapOfPreview(_:)), for: .touchUpInside)

                outgoingCell.PhotosView?.previewButton.addGestureRecognizer(longGesture)
            }
            outgoingCell.topSPaceCOnstraint.constant = 4
            outgoingCell.bottomSpaceConstraint.constant = 4
            outgoingCell.leadingCOnstraint.constant = 4
            outgoingCell.trailingConstraint.constant = 17
            outgoingCell.whitebackgroundHeightConstraint.constant = 0

            if chatList.messageContext?.showBeak == beakState.SHOWBEAK {
                outgoingCell.backgroundViewForCustumViews.isHidden = false
            } else {
                outgoingCell.topSPaceCOnstraint.constant = 3
                outgoingCell.trailingConstraint.constant = 4
                outgoingCell.bottomSpaceConstraint.constant = 4

                outgoingCell.backgroundViewForCustumViews.isHidden = true
            }
            //                    outgoingCell.backgroundVIew.isLastMessage = false
            outgoingCell.messageView.addArrangedSubview(outgoingCell.PhotosView ?? outgoingCell.messageView)

            if chatList.messageItem?.messageTextString != "" {
                textMessageLabel.padding = UIEdgeInsets(top: 12, left: 5, bottom: 5, right: 5)

                textMessageLabel.textColor = .white
                textMessageLabel.text = chatList.messageItem?.messageTextString
                outgoingCell.messageView.addArrangedSubview(textMessageLabel)
            }
            outgoingCell.bubbleWidth.constant = 270

            return outgoingCell
        }
    }

    fileprivate func processDataForTextMessage(_ chatList: chatListObject, _ incomingCell: IncomingMessageCell, _ outgoingCell: OutGoingMessageCell, _ longGesture: tableViewLongPress) -> UITableViewCell {
        let txtMessageLabel = UILabel(frame: CGRect(x: 17, y: 8, width: view.frame.size.width, height: 5))
        txtMessageLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
        txtMessageLabel.lineBreakMode = .byWordWrapping
        txtMessageLabel.numberOfLines = 0
        txtMessageLabel.textAlignment = .left
        txtMessageLabel.textColor = .black
        txtMessageLabel.text = "label"

        if chatList.messageContext?.isMine == false {
            for view in incomingCell.messageStackView.arrangedSubviews {
                view.removeFromSuperview()
            }

            incomingCell.viewType = TYPE_OF_MESSAGE.TEXT_MESSAGE
            incomingCell.initializeViews()

            incomingCell.textView?.textLabel.textColor = .black
            incomingCell.textView?.textLabel.numberOfLines = 0
            incomingCell.textView?.textLabel.text = chatList.messageItem?.messageTextString
            incomingCell.textView?.textLabel.sizeToFit()

            let width = Float((incomingCell.textView?.textLabel.frame.width)!)
            if width > 250 {
                incomingCell.textView?.textViewWidth.constant = 250
            } else {
                incomingCell.textView?.textViewWidth.constant = (incomingCell.textView?.textLabel.frame.width)! + 10
                if incomingCell.profileName.isHidden == false {
                    incomingCell.profileName.sizeToFit()
                    if incomingCell.profileName.frame.width > (incomingCell.textView?.textLabel.frame.width)! {
                        incomingCell.textView?.textViewWidth.constant = (incomingCell.profileName.frame.width + 15)
                    }
                }
                if chatList.messageContext?.isForward ?? false {
                    if width < 50 {
                        incomingCell.textView?.textViewWidth.constant = 50
                    }
                }
            }

            incomingCell.messageStackView.addArrangedSubview(incomingCell.textView!)

            incomingCell.messageStackView.addGestureRecognizer(longGesture)

            return incomingCell
        } else {
            for view in outgoingCell.messageView.arrangedSubviews {
                view.removeFromSuperview()
            }
            outgoingCell.viewType = TYPE_OF_MESSAGE.TEXT_MESSAGE
            outgoingCell.initializeViews()

            outgoingCell.backgroundViewForCustumViews.isHidden = true
            outgoingCell.textView?.textLabel.textColor = .white
            outgoingCell.textView?.textLabel.numberOfLines = 0

            outgoingCell.textView?.textLabel.text = chatList.messageItem?.messageTextString
            outgoingCell.textView?.textLabel.sizeToFit()

            let width = Float((outgoingCell.textView?.textLabel.frame.width)!)
            let height = Float((outgoingCell.textView?.textLabel.frame.height)!)

            outgoingCell.messageView.addArrangedSubview(outgoingCell.textView!)
            if width > 250 {
                outgoingCell.textView?.textViewWidth.constant = 250
                outgoingCell.textView?.textViewHeight.constant = CGFloat(height)
            } else {
                outgoingCell.textView?.textViewWidth.constant = (outgoingCell.textView?.textLabel.frame.width)!
                outgoingCell.textView?.textViewHeight.constant = CGFloat(height)
                if chatList.messageContext?.isForward ?? false {
                    if width < 50 {
                        outgoingCell.textView?.textViewWidth.constant = 50
                    }
                }
            }

            outgoingCell.backgroundVIew.frame = CGRect(x: outgoingCell.messageView.frame.origin.x, y: outgoingCell.messageView.frame.origin.y, width: outgoingCell.messageView.frame.width, height: CGFloat(height + 20))

            outgoingCell.topSPaceCOnstraint.constant = 8
            outgoingCell.bottomSpaceConstraint.constant = 8
            outgoingCell.leadingCOnstraint.constant = 14
            outgoingCell.trailingConstraint.constant = 18

            if chatList.messageContext?.showBeak == beakState.SHOWBEAK {
                outgoingCell.trailingConstraint.constant = 26
            }

            outgoingCell.messageView.addGestureRecognizer(longGesture)
            return outgoingCell
        }
    }

    fileprivate func processDataForReplyMessage(_ incomingCell: IncomingMessageCell, _ chatList: chatListObject, _ indexPath: IndexPath, _ longGesture: tableViewLongPress, _ outgoingCell: OutGoingMessageCell) -> UITableViewCell {
        incomingCell.viewType = TYPE_OF_MESSAGE.REPLY_TO_MESSAGE
        incomingCell.initializeViews()

        incomingCell.ReplyToMessageView?.messageSender.text = getUserName(object: chatList, isFromDisplay: true)

        let dict = getImageForChatListObject(object: chatList, isFromDisplay: true)
        incomingCell.ReplyToMessageView?.messageLabel.text = dict.value(forKey: "text") as? String
        incomingCell.ReplyToMessageView?.imageView.image = dict.value(forKey: "image") as? UIImage
        incomingCell.ReplyToMessageView?.previewButton.tag = indexPath.row
        incomingCell.ReplyToMessageView?.previewButton.superview?.tag = indexPath.section

        incomingCell.ReplyToMessageView?.previewButton.addTarget(self, action: #selector(onTapOfReplyMessage(_:)), for: .touchUpInside)

        if incomingCell.ReplyToMessageView?.imageView.image == nil {
            incomingCell.ReplyToMessageView?.imageView.isHidden = true
        } else {
            incomingCell.ReplyToMessageView?.imageView.isHidden = false
        }

        if chatList.messageContext?.isMine == false {
            for view in incomingCell.messageStackView.arrangedSubviews {
                view.removeFromSuperview()
            }

            let cmtLabel = UILabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: incomingCell.backGroundView?.frame.height ?? 20))
            cmtLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
            cmtLabel.lineBreakMode = .byClipping
            cmtLabel.numberOfLines = 0
            cmtLabel.text = "Hello there , All time! Hello there , All time! Hello there , All time!"
            cmtLabel.textAlignment = .left
            cmtLabel.textColor = .black

            cmtLabel.text = chatList.messageItem?.messageTextString

            incomingCell.messageStackView.addArrangedSubview(incomingCell.ReplyToMessageView ?? incomingCell.messageStackView)
            incomingCell.messageStackView.addArrangedSubview(cmtLabel)

            incomingCell.messageStackView.addGestureRecognizer(longGesture)

            return incomingCell

        } else {
            let commentLabel = PaddedLabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: incomingCell.backGroundView?.frame.height ?? 20))
            commentLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
            commentLabel.lineBreakMode = .byClipping
            commentLabel.numberOfLines = 0
            commentLabel.text = "Hello there , All time! Hello there , All time! Hello there , All time!"
            commentLabel.textAlignment = .left
            commentLabel.textColor = .white

            outgoingCell.backgroundViewForCustumViews.isHidden = true
            commentLabel.textColor = .white

            commentLabel.text = chatList.messageItem?.messageTextString

            outgoingCell.messageView.addArrangedSubview(incomingCell.ReplyToMessageView ?? outgoingCell.messageView)

            outgoingCell.messageView.addArrangedSubview(commentLabel)

            outgoingCell.topSPaceCOnstraint.constant = 4
            outgoingCell.bottomSpaceConstraint.constant = 3
            outgoingCell.leadingCOnstraint.constant = 4
            outgoingCell.trailingConstraint.constant = 17
            commentLabel.padding = UIEdgeInsets(top: 12, left: 5, bottom: 5, right: 5)

            if chatList.messageContext?.showBeak != beakState.SHOWBEAK {
                outgoingCell.trailingConstraint.constant = 4
            }
            outgoingCell.messageView.addGestureRecognizer(longGesture)
            return outgoingCell
        }
    }

    fileprivate func processDataForMediaArray(_ incomingCell: IncomingMessageCell, _ chatList: chatListObject, _ indexPath: IndexPath, _ longGesture: tableViewLongPress, _ textMessageLabel: PaddedLabel, _ msgContext: ACMessageContextObject?, _ outgoingCell: OutGoingMessageCell) -> UITableViewCell {
        // handling image
        incomingCell.viewType = TYPE_OF_MESSAGE.PHOTO_COLLECTION_MESSAGE
        incomingCell.initializeViews()
        let text = chatList.messageItem?.message as! String
        DispatchQueue.global(qos: .background).async {
            var image1: UIImage = UIImage(named: "group_profile")!
            var image2: UIImage = UIImage(named: "group_profile")!
            var image3: UIImage = UIImage(named: "group_profile")!
            var image4: UIImage = UIImage(named: "group_profile")!
            let images: NSArray!

            if let json = self.convertJsonStringToDictionary(text: text) {
                images = json["attachmentArray"] as? NSArray

                let img1 = images[0] as! NSDictionary
                if img1.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                    let imageString = img1.value(forKey: "thumbnail") as! String
                    let image = self.getImage(imageName: imageString)

                    image1 = image

                } else {
                    let imageString = img1.value(forKey: "imageName") as! String
                    let image = self.getImage(imageName: imageString)

                    image1 = image
                }

                if images.count == 2 {
                    let img2 = images[1] as! NSDictionary

                    if img2.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                        let imageString = img2.value(forKey: "thumbnail") as! String
                        let image = self.getImage(imageName: imageString)

                        image2 = image

                    } else {
                        let imageString = img2.value(forKey: "imageName") as! String
                        let image = self.getImage(imageName: imageString)

                        image2 = image
                    }

                } else if images.count == 3 {
                    let img2 = images[1] as! NSDictionary
                    let img3 = images[2] as! NSDictionary

                    if img2.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                        let imageString = img2.value(forKey: "thumbnail") as! String
                        let image = self.getImage(imageName: imageString)

                        image2 = image

                    } else {
                        let imageString = img2.value(forKey: "imageName") as! String
                        let image = self.getImage(imageName: imageString)

                        image2 = image
                    }

                    if img3.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                        let imageString = img3.value(forKey: "thumbnail") as! String
                        let image = self.getImage(imageName: imageString)

                        image3 = image

                    } else {
                        let imageString = img3.value(forKey: "imageName") as! String
                        let image = self.getImage(imageName: imageString)

                        image3 = image
                    }

                } else if images.count >= 4 {
                    let img2 = images[1] as! NSDictionary
                    let img3 = images[2] as! NSDictionary
                    let img4 = images[3] as! NSDictionary

                    if img2.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                        let imageString = img2.value(forKey: "thumbnail") as! String
                        let image = self.getImage(imageName: imageString)

                        image2 = image

                    } else {
                        let imageString = img2.value(forKey: "imageName") as! String
                        let image = self.getImage(imageName: imageString)

                        image2 = image
                    }

                    if img3.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                        let imageString = img3.value(forKey: "thumbnail") as! String
                        let image = self.getImage(imageName: imageString)

                        image3 = image

                    } else {
                        let imageString = img3.value(forKey: "imageName") as! String
                        let image = self.getImage(imageName: imageString)

                        image3 = image
                    }

                    if img4.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                        let imageString = img4.value(forKey: "thumbnail") as! String
                        let image = self.getImage(imageName: imageString)

                        image4 = image

                    } else {
                        let imageString = img4.value(forKey: "imageName") as! String
                        let image = self.getImage(imageName: imageString)

                        image4 = image
                    }
                }

                DispatchQueue.main.async(execute: { () in
                    let pollTap1 = pollTapGesture()
                    let pollTap2 = pollTapGesture()
                    let pollTap3 = pollTapGesture()
                    let pollTap4 = pollTapGesture()

                    pollTap1.myRow = indexPath.row
                    pollTap2.myRow = indexPath.row
                    pollTap3.myRow = indexPath.row
                    pollTap4.myRow = indexPath.row

                    pollTap1.mySection = indexPath.section
                    pollTap2.mySection = indexPath.section
                    pollTap3.mySection = indexPath.section
                    pollTap4.mySection = indexPath.section

                    pollTap1.selectedTag = 0
                    pollTap2.selectedTag = 1
                    pollTap3.selectedTag = 2
                    pollTap4.selectedTag = 3

                    incomingCell.ImageCollection?.image1.isUserInteractionEnabled = true
                    incomingCell.ImageCollection?.image2.isUserInteractionEnabled = true
                    incomingCell.ImageCollection?.image3.isUserInteractionEnabled = true
                    incomingCell.ImageCollection?.image4.isUserInteractionEnabled = true

                    incomingCell.ImageCollection?.image1.addGestureRecognizer(pollTap1)
                    incomingCell.ImageCollection?.image2.addGestureRecognizer(pollTap2)
                    incomingCell.ImageCollection?.image3.addGestureRecognizer(pollTap3)
                    incomingCell.ImageCollection?.image4.addGestureRecognizer(pollTap4)

                    pollTap1.addTarget(self, action: #selector(ChatViewController.onTapOfMediaArray(sender:)))
                    pollTap2.addTarget(self, action: #selector(ChatViewController.onTapOfMediaArray(sender:)))
                    pollTap3.addTarget(self, action: #selector(ChatViewController.onTapOfMediaArray(sender:)))
                    pollTap4.addTarget(self, action: #selector(ChatViewController.onTapOfMediaArray(sender:)))

                    incomingCell.ImageCollection?.image1.image = image1
                    if images.count == 2 {
                        incomingCell.ImageCollection?.image2.image = image2
                        incomingCell.ImageCollection?.image3.isHidden = true
                        incomingCell.ImageCollection?.image4.isHidden = true

                    } else if images.count == 3 {
                        incomingCell.ImageCollection?.image2.image = image2
                        incomingCell.ImageCollection?.image3.image = image3
                        incomingCell.ImageCollection?.image4.isHidden = true

                    } else if images.count >= 4 {
                        incomingCell.ImageCollection?.image2.image = image2
                        incomingCell.ImageCollection?.image3.image = image3
                        incomingCell.ImageCollection?.image4.image = image4
                    }

                    let count = String(images.count - 4)
                    if count <= "0" {
                        incomingCell.ImageCollection?.extraImageCount.isHidden = true
                    } else {
                        incomingCell.ImageCollection?.extraImageCount.isHidden = false
                        incomingCell.ImageCollection?.extraImageCount.text = "+" + count
                    }

                })
            }
        }

        if chatList.messageContext?.isMine == false {
            if chatList.messageItem?.message as! String == "" {
                incomingCell.ImageCollection?.activityView.isHidden = false
                incomingCell.ImageCollection?.activityIndicatorView.startAnimating()

                let images = ACMessageSenderClass.convertJsonStringToDictionary(text: (chatList.messageItem?.cloudReference)!)
                let imgArray: NSMutableArray = images.mutableCopy() as! NSMutableArray
                let localAttachArray = NSMutableArray()

                for image in imgArray {
                    let imageData = image as! [String: Any]
                    let cloudUrl = imageData["cloudUrl"]
                    let type = imageData["messagetype"]

                    // addObject TO Array
                    let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: cloudUrl as! String, refernce: (chatList.messageContext?.localMessageId)!, jobType: downLoadType.media, mediaType: type! as! String, mediaExtension: "")

                    ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in

                        let result = success
                        let attch = NSMutableDictionary()
                        if result.mediaType == messagetype.VIDEO.rawValue {
                            attch.setValue(path, forKey: "thumbnail")
                            attch.setValue("", forKey: "imageName")

                        } else {
                            attch.setValue(path, forKey: "imageName")
                        }
                        attch.setValue(result.mediaType, forKey: "msgType")

                        localAttachArray.add(attch)

                        // check if count matches
                        if localAttachArray.count == imgArray.count {
                            let dataDict = NSMutableDictionary()
                            dataDict.setValue(localAttachArray, forKey: "attachmentArray")
                            let attachmentString = self.convertDictionaryToJsonString(dict: dataDict)
                            DatabaseManager.updateMessageTableForOtherColoumn(imageData: attachmentString, localId: result.refernce)
                            chatList.messageItem?.message = attachmentString
                            // get main thread and reload cell
                            DispatchQueue.main.async { () in
                                self.chatTable.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                            }
                        }

                    })
                }

            } else {
                incomingCell.ImageCollection?.activityView.isHidden = true
                incomingCell.ImageCollection?.activityIndicatorView.stopAnimating()
                incomingCell.ImageCollection?.previewButton.tag = indexPath.row
                incomingCell.ImageCollection?.previewButton.superview?.tag = indexPath.section
                incomingCell.ImageCollection?.previewButton.isHidden = true

                incomingCell.ImageCollection?.addGestureRecognizer(longGesture)
            }

            incomingCell.messageStackView.addArrangedSubview(incomingCell.ImageCollection ?? incomingCell.messageStackView)

            if chatList.messageItem?.messageTextString != "" {
                textMessageLabel.padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)

                textMessageLabel.text = chatList.messageItem?.messageTextString
                incomingCell.messageStackView.addArrangedSubview(textMessageLabel)
            }
            incomingCell.bubbleWidth.constant = 270

            return incomingCell
        } else {
            //                    outgoingCell.backgroundViewForCustumViews.isHidden = false

            if msgContext?.messageState == messageState.SENDER_UNSENT, chatList.messageItem?.cloudReference == "" {
                incomingCell.ImageCollection?.activityView.isHidden = false
                incomingCell.ImageCollection?.activityIndicatorView.startAnimating()

            } else {
                incomingCell.ImageCollection?.activityView.isHidden = true
                incomingCell.ImageCollection?.activityIndicatorView.stopAnimating()
                incomingCell.ImageCollection?.previewButton.tag = indexPath.row
                incomingCell.ImageCollection?.previewButton.superview?.tag = indexPath.section

                incomingCell.ImageCollection?.previewButton.isHidden = true

                incomingCell.ImageCollection?.addGestureRecognizer(longGesture)
            }
            outgoingCell.ImageCollection = incomingCell.ImageCollection
            outgoingCell.topSPaceCOnstraint.constant = 4
            outgoingCell.bottomSpaceConstraint.constant = 4
            outgoingCell.leadingCOnstraint.constant = 4
            outgoingCell.trailingConstraint.constant = 17

            if chatList.messageContext?.showBeak == beakState.SHOWBEAK {
                outgoingCell.backgroundViewForCustumViews.isHidden = false
            } else {
                outgoingCell.topSPaceCOnstraint.constant = 3
                outgoingCell.trailingConstraint.constant = 4
                outgoingCell.bottomSpaceConstraint.constant = 4

                outgoingCell.backgroundViewForCustumViews.isHidden = true
            }
            outgoingCell.whitebackgroundHeightConstraint.constant = 0

            outgoingCell.messageView.addArrangedSubview(outgoingCell.ImageCollection ?? outgoingCell.messageView)

            if chatList.messageItem?.messageTextString != "" {
                textMessageLabel.padding = UIEdgeInsets(top: 12, left: 5, bottom: 5, right: 5)

                textMessageLabel.textColor = .white
                textMessageLabel.text = (chatList.messageItem?.messageTextString)!
                outgoingCell.messageView.addArrangedSubview(textMessageLabel)
            }
            outgoingCell.bubbleWidth.constant = 270

            return outgoingCell
        }
    }

    fileprivate func ProcessDataForTextPoll(_ incomingCell: IncomingMessageCell, _ pollData: NSDictionary, _ pollTap1: pollTapGesture, _ pollTap2: pollTapGesture, _ pollTap3: pollTapGesture, _ pollTap4: pollTapGesture, _ indexPath: IndexPath, _ chatList: chatListObject, _ longGesture: tableViewLongPress, _ outgoingCell: OutGoingMessageCell, _ textMessageLabel: PaddedLabel) -> UITableViewCell {
        incomingCell.viewType = TYPE_OF_MESSAGE.POLL_MESSAGE
        incomingCell.initializeViews()

        incomingCell.PollView?.pollTitle.text = pollData["pollTitle"] as? String
        let tim = Double(pollData["pollExpireOn"] as! String)! / 1000
        incomingCell.PollView?.pollTime.text = tim.getDateandhours()

        let count = pollData["numberOfOptions"] as? Int
        if (pollData["selectedChoice"] as! String) == "", (pollData["pollCreatedBy"] as! String) != userId {
            incomingCell.PollView?.numberOfVotesForOptionOne.isHidden = true
            incomingCell.PollView?.numberOfVotesForOptionTwo.isHidden = true
            incomingCell.PollView?.numberOfVotesForOptionThree.isHidden = true
            incomingCell.PollView?.numberOfVotesForOptionFour.isHidden = true

            incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = true
            incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = true
            incomingCell.PollView?.pollOptionourCheckMark.isHidden = true
            incomingCell.PollView?.pollOptionOneCheckMark.isHidden = true

            incomingCell.PollView?.optionStack1.addGestureRecognizer(pollTap1)
            incomingCell.PollView?.optionStack2.addGestureRecognizer(pollTap2)
            incomingCell.PollView?.optionStack3.addGestureRecognizer(pollTap3)
            incomingCell.PollView?.optionStack4.addGestureRecognizer(pollTap4)

            pollTap1.addTarget(self, action: #selector(ChatViewController.onTapOfPoll(sender:)))
            pollTap2.addTarget(self, action: #selector(ChatViewController.onTapOfPoll(sender:)))
            pollTap3.addTarget(self, action: #selector(ChatViewController.onTapOfPoll(sender:)))
            pollTap4.addTarget(self, action: #selector(ChatViewController.onTapOfPoll(sender:)))

            incomingCell.PollView?.pollBtn.setTitle("SUBMIT", for: .normal)
            incomingCell.PollView?.pollBtn.tag = indexPath.row
            incomingCell.PollView?.pollBtn.superview?.tag = indexPath.section

            incomingCell.PollView?.pollBtn.addTarget(self, action: #selector(ChatViewController.submitPollOption(sender:)), for: .touchUpInside)

        } else {
            incomingCell.PollView?.numberOfVotesForOptionOne.isHidden = false
            incomingCell.PollView?.numberOfVotesForOptionTwo.isHidden = false
            incomingCell.PollView?.numberOfVotesForOptionThree.isHidden = false
            incomingCell.PollView?.numberOfVotesForOptionFour.isHidden = false

            incomingCell.PollView?.pollBtn.setTitle("REFRESH", for: .normal)
            incomingCell.PollView?.pollBtn.tag = indexPath.row
            incomingCell.PollView?.pollBtn.superview?.tag = indexPath.section

            incomingCell.PollView?.pollBtn.addTarget(self, action: #selector(ChatViewController.refreshPollOption(sender:)), for: .touchUpInside)
        }

        let data = pollData["pollOPtions"] as? String
        if data != "" {
            let oPtionsArray = data!.toJSON() as! NSArray

            if count == 2 {
                let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                let opt2 = oPtionsArray.object(at: 1) as! [String: Any]

                incomingCell.PollView?.pollOptionOneLabel.text = "1. \(opt1["choiceText"] as? String ?? "")"
                incomingCell.PollView?.pollOptionTwoLabel.text = "2. \(opt2["choiceText"] as? String ?? "")"
                incomingCell.PollView?.numberOfVotesForOptionOne.text = opt1["numberOfVotes"] as! String + " vote(s)"
                incomingCell.PollView?.numberOfVotesForOptionTwo.text = opt2["numberOfVotes"] as! String + " vote(s)"

                if pollData["selectedChoice"] as! String != "" {
                    if (pollData["selectedChoice"] as! String) == opt1["choiceId"] as! String {
                        incomingCell.PollView?.pollOptionOneCheckMark.isHidden = false
                    } else {
                        incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = false
                    }
                }

                incomingCell.PollView?.optionStack3.isHidden = true
                incomingCell.PollView?.optionStack4.isHidden = true

            } else if count == 3 {
                let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                let opt2 = oPtionsArray.object(at: 1) as! [String: Any]
                let opt3 = oPtionsArray.object(at: 2) as! [String: Any]

                incomingCell.PollView?.pollOptionOneLabel.text = "1. \(opt1["choiceText"] as? String ?? "")"
                incomingCell.PollView?.pollOptionTwoLabel.text = "2. \(opt2["choiceText"] as? String ?? "")"
                incomingCell.PollView?.pollOptionLabelThree.text = "3. \(opt3["choiceText"] as? String ?? "")"

                incomingCell.PollView?.numberOfVotesForOptionOne.text = opt1["numberOfVotes"] as! String + " vote(s)"
                incomingCell.PollView?.numberOfVotesForOptionTwo.text = opt2["numberOfVotes"] as! String + " vote(s)"
                incomingCell.PollView?.numberOfVotesForOptionThree
                    .text = opt3["numberOfVotes"] as! String + " vote(s)"
                incomingCell.PollView?.optionStack4.isHidden = true

                if pollData["selectedChoice"] as! String != "" {
                    if (pollData["selectedChoice"] as! String) == opt1["choiceId"] as! String {
                        incomingCell.PollView?.pollOptionOneCheckMark.isHidden = false
                    } else if (pollData["selectedChoice"] as! String) == opt2["choiceId"] as! String {
                        incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = false
                    } else {
                        incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = false
                    }
                }

            } else {
                let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                let opt2 = oPtionsArray.object(at: 1) as! [String: Any]
                let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                let opt4 = oPtionsArray.object(at: 3) as! [String: Any]

                incomingCell.PollView?.pollOptionOneLabel.text = "1. \(opt1["choiceText"] as? String ?? "")"
                incomingCell.PollView?.pollOptionTwoLabel.text = "2. \(opt2["choiceText"] as? String ?? "")"
                incomingCell.PollView?.pollOptionLabelThree.text = "3. \(opt3["choiceText"] as? String ?? "")"
                incomingCell.PollView?.pollOptionLabelFour.text = "4. \(opt4["choiceText"] as? String ?? "")"

                incomingCell.PollView?.numberOfVotesForOptionOne.text = (opt1["numberOfVotes"] as! String) + " vote(s)"
                incomingCell.PollView?.numberOfVotesForOptionTwo.text = opt2["numberOfVotes"] as! String + " vote(s)"
                incomingCell.PollView?.numberOfVotesForOptionThree
                    .text = opt3["numberOfVotes"] as! String + " vote(s)"

                incomingCell.PollView?.numberOfVotesForOptionFour
                    .text = opt4["numberOfVotes"] as! String + " vote(s)"

                if (pollData["selectedChoice"] as! String) != "" {
                    if (pollData["selectedChoice"] as! String) == opt1["choiceId"] as! String {
                        incomingCell.PollView?.pollOptionOneCheckMark.isHidden = false
                    } else if (pollData["selectedChoice"] as! String) == opt2["choiceId"] as! String {
                        incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = false
                    } else if (pollData["selectedChoice"] as! String) == opt3["choiceId"] as! String {
                        incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = false
                    } else {
                        incomingCell.PollView?.pollOptionourCheckMark.isHidden = false
                    }
                }
            }

        } else {
            getPollDataForIndexPath(index: indexPath, pollId: pollData["pollId"] as! String)
        }

        if chatList.messageContext?.isMine == false {
            incomingCell.PollView?.setTextToDefault()

            incomingCell.messageStackView.addArrangedSubview(incomingCell.PollView ?? incomingCell.messageStackView)
            incomingCell.PollView!.addGestureRecognizer(longGesture)
            incomingCell.bubbleWidth.constant = 270

            return incomingCell

        } else {
            outgoingCell.backgroundViewForCustumViews.isHidden = false

            outgoingCell.PollView = incomingCell.PollView
            outgoingCell.PollView?.setTextToWhite()

            outgoingCell.messageView.addArrangedSubview(outgoingCell.PollView ?? outgoingCell.messageView)
            outgoingCell.whitebackgroundHeightConstraint.constant = 0
            outgoingCell.PollView!.addGestureRecognizer(longGesture)

            if chatList.messageItem?.messageTextString != "" {
                textMessageLabel.padding = UIEdgeInsets(top: 12, left: 5, bottom: 5, right: 5)

                textMessageLabel.textColor = .white
                textMessageLabel.text = (chatList.messageItem?.messageTextString)!
                outgoingCell.messageView.addArrangedSubview(textMessageLabel)
            }
            outgoingCell.bubbleWidth.constant = 270

            return outgoingCell
        }
    }

    fileprivate func processDAtaForImagepOll(_ incomingCell: IncomingMessageCell, _ pollData: NSDictionary, _ pollTap1: pollTapGesture, _ pollTap2: pollTapGesture, _ pollTap3: pollTapGesture, _ pollTap4: pollTapGesture, _ indexPath: IndexPath, _ chatList: chatListObject, _ longGesture: tableViewLongPress, _ outgoingCell: OutGoingMessageCell, _ textMessageLabel: PaddedLabel) -> UITableViewCell {
        incomingCell.viewType = TYPE_OF_MESSAGE.POLL_MESSAGE_WITH_IMAGES
        incomingCell.initializeViews()

        incomingCell.PollwithImages?.pollQuestion.text = pollData["pollTitle"] as! String
        let tim = Double(pollData["pollExpireOn"] as! String)! / 1000
        incomingCell.PollwithImages?.timeForPollLabel.text = tim.getDateandhours()
        let count = pollData["numberOfOptions"] as! Int
        if (pollData["selectedChoice"] as! String) == "", (pollData["pollCreatedBy"] as! String) != userId {
            incomingCell.PollwithImages?.pollOptionOneVotes.isHidden = true
            incomingCell.PollwithImages?.pollOptionViewVotes.isHidden = true
            incomingCell.PollwithImages?.pollOptionThreeVotes.isHidden = true
            incomingCell.PollwithImages?.pollOptionFourVotes.isHidden = true

            incomingCell.PollwithImages?.image1Selected.isHidden = false
            incomingCell.PollwithImages?.image2Selected.isHidden = false
            incomingCell.PollwithImages?.image3Selected.isHidden = false
            incomingCell.PollwithImages?.image4Selected.isHidden = false

            incomingCell.PollwithImages?.pollImage1.isUserInteractionEnabled = true
            incomingCell.PollwithImages?.pollOptionTwo.isUserInteractionEnabled = true
            incomingCell.PollwithImages?.pollOptionThree.isUserInteractionEnabled = true
            incomingCell.PollwithImages?.pollOptionFour.isUserInteractionEnabled = true

            incomingCell.PollwithImages?.pollImage1.addGestureRecognizer(pollTap1)
            incomingCell.PollwithImages?.pollOptionTwo.addGestureRecognizer(pollTap2)
            incomingCell.PollwithImages?.pollOptionThree.addGestureRecognizer(pollTap3)
            incomingCell.PollwithImages?.pollOptionFour.addGestureRecognizer(pollTap4)

            pollTap1.addTarget(self, action: #selector(ChatViewController.onTapOfImagePoll(sender:)))
            pollTap2.addTarget(self, action: #selector(ChatViewController.onTapOfImagePoll(sender:)))
            pollTap3.addTarget(self, action: #selector(ChatViewController.onTapOfImagePoll(sender:)))
            pollTap4.addTarget(self, action: #selector(ChatViewController.onTapOfImagePoll(sender:)))

            incomingCell.PollwithImages?.pollSubmit.setTitle("SUBMIT", for: .normal)
            incomingCell.PollwithImages?.pollSubmit.tag = indexPath.row
            incomingCell.PollwithImages?.pollSubmit.superview?.tag = indexPath.section

            incomingCell.PollwithImages?.pollSubmit.addTarget(self, action: #selector(ChatViewController.submitImagePollOption(sender:)), for: .touchUpInside)

        } else {
            incomingCell.PollwithImages?.image1Selected.isHidden = true
            incomingCell.PollwithImages?.image2Selected.isHidden = true
            incomingCell.PollwithImages?.image3Selected.isHidden = true
            incomingCell.PollwithImages?.image4Selected.isHidden = true

            incomingCell.PollwithImages?.pollOptionOneVotes.isHidden = false
            incomingCell.PollwithImages?.pollOptionViewVotes.isHidden = false

            incomingCell.PollwithImages?.pollSubmit.setTitle("REFRESH", for: .normal)
            incomingCell.PollwithImages?.pollSubmit.tag = indexPath.row
            incomingCell.PollwithImages?.pollSubmit.superview?.tag = indexPath.section

            incomingCell.PollwithImages?.pollSubmit.addTarget(self, action: #selector(ChatViewController.refreshPollOption(sender:)), for: .touchUpInside)
        }

        let data = pollData["pollOPtions"] as! String
        if data != "" {
            let oPtionsArray = data.toJSON() as! NSArray
            let locData = chatList.messageItem?.localMediaPaths
            if locData != "" {
                let locimgData = convertJsonStringToDictionary(text: locData!) as NSDictionary?
                //

                if count == 2 {
                    incomingCell.PollwithImages?.image3Selected.isHidden = true
                    incomingCell.PollwithImages?.image4Selected.isHidden = true

                    let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                    let opt2 = oPtionsArray.object(at: 1) as! [String: Any]

                    let choiceId1 = opt1["choiceId"] as? String
                    let imgName1 = locimgData![choiceId1!]
                    let img1 = getImage(imageName: imgName1 as! String)
                    incomingCell.PollwithImages?.pollImage1.image = img1

                    let choiceId2 = opt2["choiceId"] as? String
                    let imgName2 = locimgData![choiceId2!]
                    let img2 = getImage(imageName: imgName2 as! String)
                    incomingCell.PollwithImages?.pollOptionTwo.image = img2

                    incomingCell.PollwithImages?.pollOptionOneVotes.text = opt1["numberOfVotes"] as! String + " vote(s)"
                    incomingCell.PollwithImages?.pollOptionViewVotes.text = opt2["numberOfVotes"] as! String + " vote(s)"

                    if (pollData["selectedChoice"] as! String) != "" {
                        if (pollData["selectedChoice"] as! String) == opt1["choiceId"] as! String {
                            incomingCell.PollwithImages?.image1Selected.setImage(UIImage(named: "ticMarkSmall"), for: .normal)

                            incomingCell.PollwithImages?.image1Selected.isHidden = false
                        } else {
                            incomingCell.PollwithImages?.image2Selected.setImage(UIImage(named: "ticMarkSmall"), for: .normal)

                            incomingCell.PollwithImages?.image2Selected.isHidden = false
                        }
                    }
                    incomingCell.PollwithImages?.pollOptionThreeVotes.isHidden = true
                    incomingCell.PollwithImages?.pollOptionFourVotes.isHidden = true

                    incomingCell.PollwithImages?.BottomImageHeightConstraint.constant = 0

                } else if count == 3 {
                    incomingCell.PollwithImages?.image4Selected.isHidden = true
                    let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                    let opt2 = oPtionsArray.object(at: 1) as! [String: Any]
                    let opt3 = oPtionsArray.object(at: 2) as! [String: Any]

                    let choiceId1 = opt1["choiceId"] as? String
                    let imgName1 = locimgData![choiceId1!]
                    let img1 = getImage(imageName: imgName1 as! String)
                    incomingCell.PollwithImages?.pollImage1.image = img1

                    let choiceId2 = opt2["choiceId"] as? String
                    let imgName2 = locimgData![choiceId2!]
                    let img2 = getImage(imageName: imgName2 as! String)
                    incomingCell.PollwithImages?.pollOptionTwo.image = img2

                    let choiceId3 = opt3["choiceId"] as? String
                    let imgName3 = locimgData![choiceId3!]
                    let img3 = getImage(imageName: imgName3 as! String)
                    incomingCell.PollwithImages?.pollOptionThree.image = img3

                    incomingCell.PollwithImages?.pollOptionOneVotes.text = opt1["numberOfVotes"] as! String + " vote(s)"
                    incomingCell.PollwithImages?.pollOptionViewVotes.text = opt2["numberOfVotes"] as! String + " vote(s)"
                    incomingCell.PollwithImages?.pollOptionThreeVotes.text = opt3["numberOfVotes"] as! String + " vote(s)"

                    if (pollData["selectedChoice"] as! String) != "" {
                        if (pollData["selectedChoice"] as! String) == opt1["choiceId"] as! String {
                            incomingCell.PollwithImages?.image1Selected.setImage(UIImage(named: "ticMarkSmall"), for: .normal)

                            incomingCell.PollwithImages?.image1Selected.isHidden = false
                        } else if (pollData["selectedChoice"] as! String) == opt2["choiceId"] as! String {
                            incomingCell.PollwithImages?.image2Selected.setImage(UIImage(named: "ticMarkSmall"), for: .normal)

                            incomingCell.PollwithImages?.image2Selected.isHidden = false
                        } else {
                            incomingCell.PollwithImages?.image3Selected.setImage(UIImage(named: "ticMarkSmall"), for: .normal)

                            incomingCell.PollwithImages?.image3Selected.isHidden = false
                        }
                    }
                    incomingCell.PollwithImages?.pollOptionThreeVotes.isHidden = false
                    incomingCell.PollwithImages?.pollOptionFourVotes.isHidden = true

                    incomingCell.PollwithImages?.pollOptionFour.isHidden = true

                } else {
                    let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                    let opt2 = oPtionsArray.object(at: 1) as! [String: Any]
                    let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                    let opt4 = oPtionsArray.object(at: 3) as! [String: Any]

                    let choiceId1 = opt1["choiceId"] as? String
                    let imgName1 = locimgData![choiceId1!]
                    let img1 = getImage(imageName: imgName1 as! String)
                    incomingCell.PollwithImages?.pollImage1.image = img1

                    let choiceId2 = opt2["choiceId"] as? String
                    let imgName2 = locimgData![choiceId2!]
                    let img2 = getImage(imageName: imgName2 as! String)
                    incomingCell.PollwithImages?.pollOptionTwo.image = img2

                    let choiceId3 = opt3["choiceId"] as? String
                    let imgName3 = locimgData![choiceId3!]
                    let img3 = getImage(imageName: imgName3 as! String)
                    incomingCell.PollwithImages?.pollOptionThree.image = img3

                    let choiceId4 = opt4["choiceId"] as? String
                    let imgName4 = locimgData![choiceId4!]
                    let img4 = getImage(imageName: imgName4 as! String)
                    incomingCell.PollwithImages?.pollOptionFour.image = img4

                    incomingCell.PollwithImages?.pollOptionOneVotes.text = opt1["numberOfVotes"] as! String + " vote(s)"
                    incomingCell.PollwithImages?.pollOptionViewVotes.text = opt2["numberOfVotes"] as! String + " vote(s)"
                    incomingCell.PollwithImages?.pollOptionThreeVotes.text = opt3["numberOfVotes"] as! String + " vote(s)"
                    incomingCell.PollwithImages?.pollOptionFourVotes.text = opt4["numberOfVotes"] as! String + " vote(s)"

                    if (pollData["selectedChoice"] as! String) != "" {
                        if (pollData["selectedChoice"] as! String) == opt1["choiceId"] as! String {
                            incomingCell.PollwithImages?.image1Selected.setImage(UIImage(named: "ticMarkSmall"), for: .normal)

                            incomingCell.PollwithImages?.image1Selected.isHidden = false
                        } else if (pollData["selectedChoice"] as! String) == opt2["choiceId"] as! String {
                            incomingCell.PollwithImages?.image2Selected.setImage(UIImage(named: "ticMarkSmall"), for: .normal)

                            incomingCell.PollwithImages?.image2Selected.isHidden = false
                        } else if (pollData["selectedChoice"] as! String) == opt3["choiceId"] as! String {
                            incomingCell.PollwithImages?.image3Selected.setImage(UIImage(named: "ticMarkSmall"), for: .normal)

                            incomingCell.PollwithImages?.image3Selected.isHidden = false
                        } else {
                            incomingCell.PollwithImages?.image4Selected.setImage(UIImage(named: "ticMarkSmall"), for: .normal)

                            incomingCell.PollwithImages?.image4Selected.isHidden = false
                        }
                    }
                    incomingCell.PollwithImages?.pollOptionThreeVotes.isHidden = false
                    incomingCell.PollwithImages?.pollOptionFourVotes.isHidden = false
                }

            } else {
                let attch = NSMutableDictionary()

                for option in oPtionsArray {
                    let opt = option as! [String: Any]

                    let cloudUrl = opt["choiceImage"] as! String
                    let type = "image"
                    let ref = opt["choiceId"] as! String

                    // addObject TO Array
                    let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: cloudUrl, refernce: ref, jobType: downLoadType.media, mediaType: type, mediaExtension: "")

                    ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in

                        let result = success

                        attch.setValue(path, forKey: result.refernce)

                        // check if count matches
                        if attch.allKeys.count == oPtionsArray.count {
                            let attachmentString = self.convertDictionaryToJsonString(dict: attch)
//
                            DatabaseManager.updateMessageTableForLocalImage(localImagePath: attachmentString, localId: chatList.messageContext!.localMessageId!)

                            // get main thread and reload cell
                            DispatchQueue.main.async { () in
                                self.chatTable.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                            }
                        }

                    })
                }
            }
        } else {
            getPollDataForIndexPath(index: indexPath, pollId: pollData["pollId"] as! String)
        }

        if chatList.messageContext?.isMine == false {
            incomingCell.PollwithImages?.setTextToDefault()

            incomingCell.messageStackView.addArrangedSubview(incomingCell.PollwithImages ?? incomingCell.messageStackView)
            incomingCell.bubbleWidth.constant = 270
            incomingCell.PollwithImages!.addGestureRecognizer(longGesture)
            return incomingCell

        } else {
            outgoingCell.backgroundViewForCustumViews.isHidden = false
            outgoingCell.PollwithImages = incomingCell.PollwithImages
            outgoingCell.PollwithImages?.setTextToWhite()

            outgoingCell.messageView.addArrangedSubview(outgoingCell.PollwithImages ?? outgoingCell.messageView)
            outgoingCell.whitebackgroundHeightConstraint.constant = 0
            incomingCell.PollwithImages!.addGestureRecognizer(longGesture)
            if chatList.messageContext?.showBeak != beakState.SHOWBEAK {
                outgoingCell.trailingConstraint.constant = 6
            }

            if chatList.messageItem?.messageTextString != "" {
                textMessageLabel.padding = UIEdgeInsets(top: 12, left: 5, bottom: 5, right: 5)

                textMessageLabel.textColor = .white
                textMessageLabel.text = (chatList.messageItem?.messageTextString)!
                outgoingCell.messageView.addArrangedSubview(textMessageLabel)
            }
            outgoingCell.bubbleWidth.constant = 270

            return outgoingCell
        }
    }

    fileprivate func shareButtonView(shareButton: UIButton, image: UIImage) {
        shareButton.setTitle("Shared", for: UIControl.State.normal)
//        shareButton.titleLabel?.textAlignment = .left
//        shareButton.backgroundColor = .red
//        shareButton.semanticContentAttribute = .forceRightToLeft
        shareButton.contentHorizontalAlignment = .right
        shareButton.setImage(resizedImage(at: image, for: CGSize.init(width: 10, height: 10))!, for: UIControl.State.normal)
        shareButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        shareButton.titleLabel?.adjustsFontSizeToFitWidth = true
        shareButton.imageView?.contentMode = .scaleAspectFit
        shareButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
    }
    
    fileprivate func addSharedView(_ chatList: chatListObject, _ incomingCell: IncomingMessageCell, _ outgoingCell: OutGoingMessageCell) {
        if chatList.messageContext?.isForward ?? false {
            let image = UIImage.init(named: "forwardButton")!
            let textFrame = incomingCell.textView?.frame
            let shareButton = UIButton.init(frame: CGRect.init(0, textFrame?.maxY ?? 0, textFrame?.width ?? 0, 40))
            shareButtonView(shareButton: shareButton, image: image)
            shareButton.setTitleColor(COLOURS.APP_MEDIUM_GREEN_COLOR, for: UIControl.State.normal)
            shareButton.tintColor = COLOURS.APP_MEDIUM_GREEN_COLOR
            
            shareButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 10)
            shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 14)
            let imageOutgoing = UIImage.init(named: "forwardButton-1")!
            let textFrameOutgoing = outgoingCell.textView?.frame
            let shareButtonOutgoing = UIButton.init(frame: CGRect.init(0, textFrameOutgoing?.maxY ?? 0, textFrameOutgoing?.width ?? 60, 40))
            shareButtonView(shareButton: shareButtonOutgoing, image: imageOutgoing)
            shareButtonOutgoing.setTitleColor(.white, for: UIControl.State.normal)
            shareButtonOutgoing.tintColor = .white
            incomingCell.messageStackView.addArrangedSubview(shareButton)
            outgoingCell.messageView.addArrangedSubview(shareButtonOutgoing)
        }
    }
    
    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "DayViewCell") as! DayViewCell
        headerCell.backgroundColor = UIColor.clear

        let outgoingCell = chatTable.dequeueReusableCell(withIdentifier: "OutGoingMessageCell") as! OutGoingMessageCell
        let incomingCell = chatTable.dequeueReusableCell(withIdentifier: "IncomingMessageCell") as!
            IncomingMessageCell
        outgoingCell.selectionStyle = .none
        incomingCell.selectionStyle = .none
        incomingCell.backgroundColor = .clear
        outgoingCell.backgroundColor = .clear
        outgoingCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        incomingCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)

//        outgoingCell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
//        incomingCell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));

        let textMessageLabel = PaddedLabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: incomingCell.PhotosView?.frame.height ?? 20))
        textMessageLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
        textMessageLabel.lineBreakMode = .byWordWrapping
        textMessageLabel.numberOfLines = 0
        textMessageLabel.textAlignment = .left
        textMessageLabel.textColor = .black
        textMessageLabel.text = "label"

        // NOTE
        // To add reply to message, must add another arranged subview to message stackview.(i.e.., incomingCell.messageStackView.addArrangedSubview(textMessageLabel) )
        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
        let chatList = dayMessages[indexPath.row] as! chatListObject

        let longGesture = tableViewLongPress(target: self, action: #selector(onLongTap))
        longGesture.myRow = indexPath.row
        longGesture.mySection = indexPath.section

        for view in outgoingCell.messageView.arrangedSubviews {
            view.removeFromSuperview()
        }

        let msgContext = chatList.messageContext
        let type = chatList.messageItem?.messageType
        let time = Double(msgContext!.msgTimeStamp)! / 10_000_000

        if chatList.messageContext?.showBeak == beakState.noData {
            if indexPath.row == dayMessages.count - 1 {
                chatList.messageContext?.showBeak = beakState.SHOWBEAK
            } else {
                if (dayMessages.count - 1) > indexPath.row {
                    let previousMsg = dayMessages[indexPath.row + 1] as! chatListObject
                    if chatList.messageContext?.localSenderId == previousMsg.messageContext?.localSenderId {
                        let pMsgContext = previousMsg.messageContext
                        let ptime = Double(pMsgContext!.msgTimeStamp)! / 10_000_000

                        let status = checkifTimeDiffGreaterThan5Mins(currentMsgTime: Int(time), previousMsgTime: Int(ptime))

                        if status {
                            chatList.messageContext?.showBeak = beakState.SHOWBEAK
                        } else {
                            chatList.messageContext?.showBeak = beakState.NOBEAK
                        }

                    } else {
                        chatList.messageContext?.showBeak = beakState.SHOWBEAK
                    }
                } else if (dayMessages.count - 1) == indexPath.row {
                    chatList.messageContext?.showBeak = beakState.SHOWBEAK
                }
            }
        }

        // get meesage time
        if chatList.messageContext?.isMine == true {
            outgoingCell.messageTimeStamp.text = time.getTimeStringFromUTC()
            // get message sent status
            outgoingCell.seenStatusMessageView.image = getMessageStatus(chatObj: chatList)

            incomingCell.profileName.isHidden = true
            if chatList.messageContext?.showBeak == beakState.SHOWBEAK {
                outgoingCell.isLastMessage(status: true)
            } else {
                outgoingCell.isLastMessage(status: false)
            }

        } else {
            incomingCell.messageTimeStamp.text = time.getTimeStringFromUTC()

            if chatList.messageContext?.channelType != channelType.ONE_ON_ONE_CHAT, chatList.messageContext?.channelType != channelType.GROUP_MEMBER_ONE_ON_ONE {
                if chatList.messageContext?.showBeak == beakState.SHOWBEAK {
                    incomingCell.isLastMessage(status: true)
                    let name = getUserName(object: chatList, isFromDisplay: false)
                    incomingCell.profileName.text = " " + name

                    incomingCell.profileName.isHidden = false

                } else {
                    incomingCell.isLastMessage(status: false)

//                    incomingCell.backGroundView.isLastMessage = false
                    incomingCell.profileName.isHidden = true
                }
            } else {
                if chatList.messageContext?.showBeak == beakState.SHOWBEAK {
                    incomingCell.isLastMessage(status: true)
                } else {
                    incomingCell.isLastMessage(status: false)
                }
                incomingCell.profileName.isHidden = true
            }
        }
        print()
        switch type! {
        case messagetype.TEXT:

            // MARK: messageType REPLY

            if chatList.messageContext?.action == useractionType.REPLY {
                let cell = processDataForReplyMessage(incomingCell, chatList, indexPath, longGesture, outgoingCell)
                addSharedView(chatList, incomingCell, outgoingCell)
                return cell
            } else {
                // MARK: text
                let cell = processDataForTextMessage(chatList, incomingCell, outgoingCell, longGesture)
                addSharedView(chatList, incomingCell, outgoingCell)
                return cell
            }

        case messagetype.VIDEO:

            // MARK: VIDEO

            let cell = processDataForVideoMessage(incomingCell, chatList, textMessageLabel, indexPath, longGesture, msgContext, outgoingCell)
            addSharedView(chatList, incomingCell, outgoingCell)
            return cell

        case messagetype.AUDIO:

            // MARK: Audio

            let cell = processDataForAudioMessage(outgoingCell, chatList, textMessageLabel, indexPath, msgContext, longGesture, incomingCell)
            addSharedView(chatList, incomingCell, outgoingCell)
            return cell
        case messagetype.IMAGE:

            // MARK: Image

            let cell =  processDataForImageMessage(chatList, incomingCell, indexPath, longGesture, textMessageLabel, outgoingCell, msgContext)
            addSharedView(chatList, incomingCell, outgoingCell)
            return cell

        case messagetype.OTHER:
            let otherType = chatList.messageItem?.otherMessageType
            if otherType != nil {
                switch otherType! {
                case otherMessageType.MEDIA_ARRAY:

                    // MARK: Image Array

                    let cell = processDataForMediaArray(incomingCell, chatList, indexPath, longGesture, textMessageLabel, msgContext, outgoingCell)
                    addSharedView(chatList, incomingCell, outgoingCell)
                    return cell
                case otherMessageType.TEXT_POLL:

                    let pollTap1 = pollTapGesture()
                    let pollTap2 = pollTapGesture()
                    let pollTap3 = pollTapGesture()
                    let pollTap4 = pollTapGesture()

                    pollTap1.myRow = indexPath.row
                    pollTap2.myRow = indexPath.row
                    pollTap3.myRow = indexPath.row
                    pollTap4.myRow = indexPath.row

                    pollTap1.mySection = indexPath.section
                    pollTap2.mySection = indexPath.section
                    pollTap3.mySection = indexPath.section
                    pollTap4.mySection = indexPath.section

                    pollTap1.selectedTag = 0
                    pollTap2.selectedTag = 1
                    pollTap3.selectedTag = 2
                    pollTap4.selectedTag = 3

                    let pollString = chatList.messageItem?.message as! String
                    if let pollData = self.convertJsonStringToDictionary(text: pollString) {
                        let polldat = pollData as NSDictionary
                        let cell = ProcessDataForTextPoll(incomingCell, polldat, pollTap1, pollTap2, pollTap3, pollTap4, indexPath, chatList, longGesture, outgoingCell, textMessageLabel)
                        addSharedView(chatList, incomingCell, outgoingCell)
                        return cell
                    }

                case otherMessageType.IMAGE_POLL:

                    let pollTap1 = pollTapGesture()
                    let pollTap2 = pollTapGesture()
                    let pollTap3 = pollTapGesture()
                    let pollTap4 = pollTapGesture()

                    pollTap1.myRow = indexPath.row
                    pollTap2.myRow = indexPath.row
                    pollTap3.myRow = indexPath.row
                    pollTap4.myRow = indexPath.row

                    pollTap1.mySection = indexPath.section
                    pollTap2.mySection = indexPath.section
                    pollTap3.mySection = indexPath.section
                    pollTap4.mySection = indexPath.section

                    pollTap1.selectedTag = 0
                    pollTap2.selectedTag = 1
                    pollTap3.selectedTag = 2
                    pollTap4.selectedTag = 3

                    let pollString = chatList.messageItem?.message as! String
                    if let pollData = self.convertJsonStringToDictionary(text: pollString) {
                        // MARK: Image Poll

                        let polldat = pollData as NSDictionary
                        let cell = processDAtaForImagepOll(incomingCell, polldat, pollTap1, pollTap2, pollTap3, pollTap4, indexPath, chatList, longGesture, outgoingCell, textMessageLabel)
                        addSharedView(chatList, incomingCell, outgoingCell)
                        return cell
                    }

                    // MARK: Info

                case otherMessageType.INFO:

                    headerCell.dayButton.setTitle((chatList.messageItem?.messageTextString)!, for: .normal)
                    headerCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)

//                    headerCell.contentView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                    headerCell.selectionStyle = .none
                    return headerCell

                default:
                    print("Error while fetching type of message \(String(describing: chatList.messageItem?.messageType?.rawValue))")
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
//        isCellSelected = true
//        customNavigationBar(groupName: group.groupName, groupImage: group.fullImageUrl)
    }

    func tableView(_: UITableView, didDeselectRowAt _: IndexPath) {
//        isCellSelected = false
//        customNavigationBar(groupName: group.groupName, groupImage: group.fullImageUrl)
    }

    @objc func showVideo() {
        present(playerViewController, animated: true) {
            // play video
        }
    }

    func getUserName(object: chatListObject, isFromDisplay: Bool) -> String {
        var chatlistObj = object
        if isFromDisplay {
            if let msg = DatabaseManager.getMessageIndex(globalMsgId: (chatlistObj.messageContext?.replyToId)!) {
                let msgProcessed = ChatMessageProcessor.processSingleMessageContext(message: msg)
                chatlistObj = msgProcessed
            }
        }
        var nameString: String = ""
        if (chatlistObj.messageContext?.isMine)! {
            nameString = "You"
        } else {
            if chatlistObj.messageContext?.channelType! == channelType.ONE_ON_ONE_CHAT {
                let contact = DatabaseManager.getContactIndexforTable(tableIndex: (chatlistObj.messageContext?.localSenderId)!)

                nameString = (contact?.fullName)!

            } else if chatlistObj.messageContext?.channelType! == channelType.GROUP_MEMBER_ONE_ON_ONE {
                if let memebrIndex = DatabaseManager.getGroupMemberIndexForMemberId(groupId: (chatlistObj.messageContext?.localSenderId)!) {
                    nameString = memebrIndex.memberName
                }
            } else {
                if let memebrIndex = DatabaseManager.getGroupMemberIndexForMemberId(groupId: (chatlistObj.messageContext?.localSenderId)!) {
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
            }
        }
        return nameString
    }

    func getUserNameForNotif(object: MessagesTable) -> String {
        var chatlistObj = object

        var nameString: String = ""
        if object.isMine {
            nameString = "You"
        } else {
            if object.channelType == channelType.ONE_ON_ONE_CHAT.rawValue {
                let contact = DatabaseManager.getContactIndexforTable(tableIndex: object.senderId)

                nameString = (contact?.fullName)!

            } else if object.channelType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                if let memebrIndex = DatabaseManager.getGroupMemberIndexForMemberId(groupId: object.senderId) {
                    nameString = memebrIndex.memberName
                }
            } else {
                if let memebrIndex = DatabaseManager.getGroupMemberIndexForMemberId(groupId: object.senderId) {
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
            }
        }
        return nameString
    }

    func getPollDataForIndexPath(index: IndexPath, pollId: String) {
        let getPoll = GetPollDataRequestObject()
        getPoll.auth = DefaultDataProcessor().getAuthDetails()
        getPoll.pollId = pollId

        NetworkingManager.getPollData(getGroupModel: getPoll) { (result: Any, sucess: Bool) in
            if let results = result as? GetPollDataResponseObject, sucess {
                if sucess {
                    if results.status == "Success" {
                        let choices = results.data

                        var data = [PollTable.PollOptions]()
                        for choice in (choices?.first!.choices)! {
                            let ch = choice
                            let option = PollTable.PollOptions()
                            option.choiceImage = ch.choiceImage
                            option.choiceText = ch.choiceText

                            option.choiceId = ch.choiceId

                            data.append(option)
                        }

                        let obj = data.toJsonString()

                        let polldat = PollTable()
                        polldat.pollId = pollId
                        polldat.messageId = ""

                        polldat.pollTitle = choices?.first?.pollQuestion ?? ""
                        polldat.pollCreatedOn = choices?.first?.createdBy ?? ""

                        polldat.pollCreatedBy = choices?.first?.createdBy ?? ""

                        polldat.pollExpireOn = choices?.first?.pollEndDate ?? ""
                        polldat.pollType = choices?.first?.pollType ?? ""
                        polldat.pollOPtions = obj
                        polldat.selectedChoice = ""
                        polldat.numberOfOptions = data.count

                        _ = DatabaseManager.storePollData(pollTable: polldat)

                        DispatchQueue.main.async {
                            self.chatTable.reloadRows(at: [index], with: .none)
                        }
                    }
                }
            }
        }
    }

    func getMessageStatus(chatObj: chatListObject) -> UIImage {
        if channelDetails?.channelType == channelType.ONE_ON_ONE_CHAT.rawValue || channelDetails?.channelType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
            let msgContxt = chatObj.messageContext
            let msgState = msgContxt!.messageState as! messageState
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
        } else {
            var image: UIImage?

            let seenMembers = chatObj.messageContext?.seenMembers
            let readMembers = chatObj.messageContext?.readMembers
            var totalMemberCount = Int(chatObj.messageContext!.targetCount ?? "0")
            
            
                

            var seenMembersArray = seenMembers?.components(separatedBy: ",")
            var readMembersArray = readMembers?.components(separatedBy: ",")
            if seenMembersArray != nil || readMembersArray != nil {
                seenMembersArray = Array(Set(seenMembersArray!))
                readMembersArray = Array(Set(readMembersArray!))

                seenMembersArray?.remove(object: "")
                readMembersArray?.remove(object: "")

                let seenCOunt = seenMembersArray?.count
                let readCount = readMembersArray?.count

                if totalMemberCount == nil {
                    totalMemberCount = 0
                } else {
                    totalMemberCount = totalMemberCount! - 1
                }
                if seenCOunt ?? 0 >= totalMemberCount ?? 0 {
                    image = UIImage(named: "lastSeen")!
                } else if readCount ?? 0 >= totalMemberCount ?? 0 {
                    image = UIImage(named: "lastDelivered")
                } else {
                    let msgContxt = chatObj.messageContext
                    let msgState = msgContxt!.messageState as! messageState
                    if msgState == messageState.SENDER_SENT {
                        image = UIImage(named: "ic_sent_new")!

                    } else if msgState == messageState.SENDER_UNSENT {
                        image = UIImage(named: "ic_unsent")!
                    }
                    else if msgState == messageState.RECEIVER_RECEIVED {
                        image = UIImage(named: "lastDelivered")!
                    }
                }
            } else {
                let msgContxt = chatObj.messageContext
                let msgState = msgContxt!.messageState as! messageState
                if msgState == messageState.SENDER_SENT {
                    image = UIImage(named: "ic_sent_new")!

                } else if msgState == messageState.SENDER_UNSENT {
                    image = UIImage(named: "ic_unsent")!
                }
                else if msgState == messageState.RECEIVER_RECEIVED {
                    image = UIImage(named: "lastDelivered")!
                }
                else if msgState == messageState.RECEIVER_SEEN {
                    image = UIImage(named: "lastSeen")!
                }
            }

            return image!
        }
    }

    func getImageForChatListObject(object: chatListObject, isFromDisplay: Bool) -> NSMutableDictionary {
        var chatListObj = object
        if isFromDisplay {
            if let msg = DatabaseManager.getMessageIndex(globalMsgId: (chatListObj.messageContext?.replyToId)!) {
                let msgProcessed = ChatMessageProcessor.processSingleMessageContext(message: msg)
                chatListObj = msgProcessed
            }
        }

        let imageDictionary = NSMutableDictionary()
        var image: UIImage?
        var text = ""
        let type = chatListObj.messageItem?.messageType
        switch type! {
        case messagetype.TEXT:
            text = (chatListObj.messageItem?.messageTextString)!
            image = nil

        case messagetype.VIDEO:
            text = (chatListObj.messageItem?.messageTextString)!

            if text == "" {
                text = ""
            }
            image = load(attName: (chatListObj.messageItem?.thumbnail)!)

        case messagetype.IMAGE:
            text = (chatListObj.messageItem?.messageTextString)!

            if text == "" {
                text = ""
            }
            image = load(attName: (chatListObj.messageItem?.message)! as! String)

        case messagetype.AUDIO:
            text = (chatListObj.messageItem?.messageTextString)!

            if text == "" {
                text = ""
            }
            image = UIImage(named: "microphone")

        case messagetype.OTHER:
            text = (chatListObj.messageItem?.messageTextString)!
            if text == "" {
                text = ""
            }
            let otherType = chatListObj.messageItem?.otherMessageType
            switch otherType! {
            case otherMessageType.MEDIA_ARRAY:
                let texts = chatListObj.messageItem?.message as! String
                if texts.count > 2, texts.contains("attachmentArray") {
                    let json = convertJsonStringToDictionary(text: texts)
                    let images = json!["attachmentArray"] as! NSArray
                    let img1 = images[0] as! NSDictionary

                    if img1.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                        image = load(attName: img1.value(forKey: "thumbnail") as! String)
                    } else {
                        image = load(attName: img1.value(forKey: "imageName") as! String)
                    }
                }
            case otherMessageType.TEXT_POLL:

                text = ""
                image = UIImage(named: "poll")
                if let pollData = DatabaseManager.getPollDataForId(localPollId: chatListObj.messageItem?.message as! String) {
                    text = pollData.pollTitle
                }

            case otherMessageType.IMAGE_POLL:

                text = ""
                image = UIImage(named: "poll")
                if let pollData = DatabaseManager.getPollDataForId(localPollId: chatListObj.messageItem?.message as! String) {
                    text = pollData.pollTitle
                }

            default:
                print("do nothing")
            }
        default:
            print("do nothing")
        }
        imageDictionary.setValue(text, forKey: "text")
        imageDictionary.setValue(image, forKey: "image")
        return imageDictionary
    }

    @objc func onLongTap(_ sender: tableViewLongPress) {
        print("Long press")
        if sender.mySection < datesArray.count {
            let buttonPosition: CGPoint = sender.location(in: chatTable)
            let indexPath = chatTable.indexPathForRow(at: buttonPosition)!

            let tag = indexPath.row
            let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
            if tag < dayMessages.count {
                if isCellSelected == true {
                    let cell = chatTable.cellForRow(at: currentSelectedIndex!)
                    cell!.backgroundColor = .clear
                }
                isCellSelected = true

                selectedObject = dayMessages[tag] as! chatListObject
                currentSelectedIndex = indexPath
                let cell = chatTable.cellForRow(at: indexPath)
                if cell != nil {
                    cell!.backgroundColor = COLOURS.chatSelectedColor
                }
                let type = selectedObject.messageContext?.messageType!
                if type == messagetype.TEXT {
                    customNavigationBar(name: displayName!, image: displayImage!, isSentMessage: selectedObject.messageContext?.isMine ?? false, channelTyp: channelType(rawValue: (channelDetails?.channelType)!)!, showCopy: true)
                } else {
                    if type == messagetype.OTHER, selectedObject.messageItem!.otherMessageType!.rawValue == otherMessageType.TEXT_POLL.rawValue || selectedObject.messageItem!.otherMessageType!.rawValue == otherMessageType.IMAGE_POLL.rawValue {
                        customNavigationBar(name: displayName!, image: displayImage!, isSentMessage: selectedObject.messageContext?.isMine ?? false, channelTyp: channelType(rawValue: (channelDetails?.channelType)!)!, showCopy: false, showFwd: false)
                    } else {
                        customNavigationBar(name: displayName!, image: displayImage!, isSentMessage: selectedObject.messageContext?.isMine ?? false, channelTyp: channelType(rawValue: (channelDetails?.channelType)!)!, showCopy: false)
                    }
                }
            }
        }
    }

    func getDir() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let type = fileName.audiomediaFileName
        let fileURL = paths!.appendingPathComponent(type + "/")
        return fileURL
    }

    fileprivate func playAudioFile(_ attName: String?) {
        let bundle = getDir().appendingPathComponent(attName!.appending(".m4a"))

        if FileManager.default.fileExists(atPath: bundle.path) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: bundle)
                audioPlayer.delegate = self as? AVAudioPlayerDelegate
                audioPlayer.prepareToPlay()
                audioPlayer.play()

            } catch {
                print("play(with name:), ", error.localizedDescription)
            }
        }
    }

    @objc func onTapOfPlayAudioFile(_ sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: chatTable)
        let indexPath = chatTable.indexPathForRow(at: buttonPosition)

        let tag = indexPath!.row

        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath!.section) as! String) as! NSMutableArray
        let chatList = dayMessages[tag] as! chatListObject
        let attName = chatList.messageItem?.message as? String
        let index = indexPath!

        if attName != "" {
            if isPlayingAudio == true {
                // if both index same

                if chatList.messageContext?.isMine == true {
                    let cell = chatTable.cellForRow(at: selectedAudioIndex) as! OutGoingMessageCell
                    cell.musicView!.playButton.setImage(UIImage(named: "shapeWhite"), for: .normal)
                    counter = 0
                    audioPlayer.stop()
                    isPlayingAudio = false
                    cell.musicView!.songSlider.value = Float(0)
                    let total = Float((audioPlayer.duration / 60) / 2)
                    let start = Float(0)

                    cell.musicView!.lblTime.text = NSString(format: "%.2f/%.2f", start, total) as String
                } else {
                    let cell = chatTable.cellForRow(at: selectedAudioIndex) as! IncomingMessageCell
                    cell.musicView!.playButton.setImage(UIImage(named: "shapeGreen"), for: .normal)
                    counter = 0
                    audioPlayer.stop()
                    isPlayingAudio = false
                    cell.musicView!.songSlider.value = Float(0)
                    let total = Float((audioPlayer.duration / 60) / 2)
                    let start = Float(0)

                    cell.musicView!.lblTime.text = NSString(format: "%.2f/%.2f", start, total) as String
                }

                if index != selectedAudioIndex {
                    if chatList.messageContext?.isMine == true {
                        let cell = chatTable.cellForRow(at: index) as! OutGoingMessageCell
                        selectedAudioIndex = index
                        cell.musicView!.playButton.setImage(UIImage(named: "shape"), for: .normal)
                        counter = 0
                        playingAudioObject = chatList

                        cell.musicView!.songSlider.value = Float(0)
                        let total = Float((audioPlayer.duration / 60) / 2)
                        let start = Float(0)

                        cell.musicView!.lblTime.text = NSString(format: "%.2f/%.2f", start, total) as String
                        sender.setImage(UIImage(named: "pausewhite"), for: .normal)
                        playAudioFile(attName)

                        if isTimerFirstTime == false {
                            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayTimer), userInfo: nil, repeats: true)
                            isTimerFirstTime = true
                        }
                        isPlayingAudio = true
                    } else {
                        let cell = chatTable.cellForRow(at: index) as! IncomingMessageCell
                        cell.musicView!.playButton.setImage(UIImage(named: "shape"), for: .normal)
                        playingAudioObject = chatList
                        selectedAudioIndex = index
                        counter = 0
                        cell.musicView!.songSlider.value = Float(0)
                        let total = Float((audioPlayer.duration / 60) / 2)
                        let start = Float(0)

                        cell.musicView!.lblTime.text = NSString(format: "%.2f/%.2f", start, total) as String
                        sender.setImage(UIImage(named: "pauseGreen"), for: .normal)
                        playAudioFile(attName)

                        if isTimerFirstTime == false {
                            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayTimer), userInfo: nil, repeats: true)
                            isTimerFirstTime = true
                        }
                        isPlayingAudio = true
                    }
                }

            } else {
                if chatList.messageContext?.isMine == true {
                    let cell = chatTable.cellForRow(at: index) as! OutGoingMessageCell
                    selectedAudioIndex = index
                    cell.musicView!.playButton.setImage(UIImage(named: "shape"), for: .normal)
                    counter = 0
                    playingAudioObject = chatList

                    cell.musicView!.songSlider.value = Float(0)
                    let total = Float((audioPlayer.duration / 60) / 2)
                    let start = Float(0)

                    cell.musicView!.lblTime.text = NSString(format: "%.2f/%.2f", start, total) as String
                    sender.setImage(UIImage(named: "pausewhite"), for: .normal)
                    playAudioFile(attName)

                    if isTimerFirstTime == false {
                        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayTimer), userInfo: nil, repeats: true)
                        isTimerFirstTime = true
                    }
                    isPlayingAudio = true
                } else {
                    let cell = chatTable.cellForRow(at: index) as! IncomingMessageCell
                    cell.musicView!.playButton.setImage(UIImage(named: "shape"), for: .normal)
                    playingAudioObject = chatList
                    selectedAudioIndex = index
                    counter = 0
                    cell.musicView!.songSlider.value = Float(0)
                    let total = Float((audioPlayer.duration / 60) / 2)
                    let start = Float(0)

                    cell.musicView!.lblTime.text = NSString(format: "%.2f/%.2f", start, total) as String
                    sender.setImage(UIImage(named: "pauseGreen"), for: .normal)
                    playAudioFile(attName)
                    if isTimerFirstTime == false {
                        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayTimer), userInfo: nil, repeats: true)
                        isTimerFirstTime = true
                    }
                    isPlayingAudio = true
                }
            }
        } else {
            let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: (chatList.messageItem?.cloudReference)!, refernce: (chatList.messageContext?.localMessageId)!, jobType: downLoadType.media, mediaType: mediaDownloadType.audio.rawValue, mediaExtension: ".m4a")

            DispatchQueue.global(qos: .background).async {
                ACImageDownloader.downloadAudio(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                    DatabaseManager.updateMessageTableForLocalImage(localImagePath: path, localId: (chatList.messageContext?.localMessageId)!)
                    chatList.messageItem?.message = path

                    DispatchQueue.main.async { () in
                        self.chatTable.reloadRows(at: [index], with: .none)
                    }

                })
            }
        }
    }

    @objc private func updatePlayTimer() {
        if isPlayingAudio {
            updateProgress()
        }
    }

    // Timer delegate method that updates current time display in minutes
    func updateProgress() {
        if !audioPlayer.isPlaying, isPlayingAudio {
            isPlayingAudio = false
            audioPlayer.currentTime = 0
        }
        let total = Float((audioPlayer.duration / 60) / 2)
        let current_time = Float((audioPlayer.currentTime / 60) / 2)

        if playingAudioObject.messageContext?.isMine == true {
            if let acell = chatTable.cellForRow(at: selectedAudioIndex) {
                let cell = acell as! OutGoingMessageCell
                cell.musicView!.songSlider.setValue(Float(audioPlayer.currentTime), animated: true)
                cell.musicView!.lblTime.text = NSString(format: "%.2f/%.2f", current_time, total) as String

                if !audioPlayer.isPlaying {
                    cell.musicView!.playButton.setImage(UIImage(named: "shapeWhite"), for: .normal)
                    cell.musicView!.songSlider.setValue(Float(0), animated: true)
                }
            } else {
                audioPlayer.stop()
                isPlayingAudio = false
            }

        } else {
            if let acell = chatTable.cellForRow(at: selectedAudioIndex) {
                let cell = acell as! IncomingMessageCell

                cell.musicView!.songSlider.setValue(Float(audioPlayer.currentTime), animated: true)
                cell.musicView!.lblTime.text = NSString(format: "%.2f/%.2f", current_time, total) as String
                if !audioPlayer.isPlaying {
                    cell.musicView!.playButton.setImage(UIImage(named: "shapeGreen"), for: .normal)
                    cell.musicView!.songSlider.setValue(Float(0), animated: true)
                }
            } else {
                audioPlayer.stop()
                isPlayingAudio = false
            }
        }
    }

    @objc func moveSlide(sender: UISlider) {
        if isPlayingAudio {
            if audioPlayer.isPlaying {
                audioPlayer.currentTime = TimeInterval(sender.value)

                let total = Float(audioPlayer.duration / 60)
                let current_time = Float(audioPlayer.currentTime / 60)

                if playingAudioObject.messageContext?.isMine == true {
                    let cell = chatTable.cellForRow(at: selectedAudioIndex) as! OutGoingMessageCell

                    cell.musicView!.lblTime.text = NSString(format: "%.2f/%.2f", current_time, total) as String

                    if !audioPlayer.isPlaying {
                        cell.musicView!.playButton.setImage(UIImage(named: "shapeWhite"), for: .normal)
                        cell.musicView!.songSlider.setValue(Float(0), animated: true)
                    }

                } else {
                    let cell = chatTable.cellForRow(at: selectedAudioIndex) as! IncomingMessageCell

                    cell.musicView!.lblTime.text = NSString(format: "%.2f/%.2f", current_time, total) as String
                    if !audioPlayer.isPlaying {
                        cell.musicView!.playButton.setImage(UIImage(named: "shapeGreen"), for: .normal)
                        cell.musicView!.songSlider.setValue(Float(0), animated: true)
                    }
                }
            }
        }
    }

    @objc func onTapOfDownLoadImage(_ sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: chatTable)
        let indexPath = chatTable.indexPathForRow(at: buttonPosition)!

        let tag = indexPath.row
        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
        let chatList = dayMessages[tag] as! chatListObject

        var urlStr = (chatList.messageItem?.cloudReference)!
        let type = chatList.messageItem?.messageType

        if type == messagetype.VIDEO {
            let json = convertJsonStringToDictionary(text: (chatList.messageItem?.cloudReference)!)

            if json != nil {
                urlStr = json!["imgurl"]! as! String
            }
        }

        if urlStr != "" {
            if delegate != nil {
                if (delegate?.isInternetAvailable)! {
                    downloadTracker.removeObject(forKey: urlStr)
                    let index = indexPath
                    chatTable.reloadRows(at: [index], with: .none)
                } else {
                    alert(message: "Internet is required")
                }
            }
        }
    }

    @objc func onTapOfPlay(_ sender: TableViewButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: chatTable)
        let indexPath = chatTable.indexPathForRow(at: buttonPosition)

        let tag = indexPath!.row
        let dayMessages = messages.value(forKey: datesArray.object(at: (indexPath?.section)!) as! String) as! NSMutableArray
        let chatList = dayMessages[tag] as! chatListObject

        let attName = chatList.messageItem?.message as? String

        if attName == "" {
            let json = convertJsonStringToDictionary(text: (chatList.messageItem?.cloudReference)!)
            let urlStr = json!["vidurl"]! as! String

            let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: urlStr, refernce: (chatList.messageContext?.localMessageId)!, jobType: downLoadType.media, mediaType: mediaDownloadType.video.rawValue, mediaExtension: "")
            let newIndexPaths = IndexPath(row: tag, section: (indexPath?.section)!)
            let incomingCell = chatTable.cellForRow(at: newIndexPaths) as! IncomingMessageCell
            incomingCell.PhotosView?.activityView.isHidden = false
            incomingCell.PhotosView?.activityIndicatorView.startAnimating()
            DispatchQueue.global(qos: .background).async {
                ACImageDownloader.downloadVideo(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                    DatabaseManager.updateMessageTableForLocalImage(localImagePath: path, localId: (chatList.messageContext?.localMessageId)!)
                    chatList.messageItem?.message = path
                    DispatchQueue.main.async { () in
                        incomingCell.PhotosView?.activityView.isHidden = true
                        incomingCell.PhotosView?.activityIndicatorView.stopAnimating()

                        self.chatTable.reloadRows(at: [newIndexPaths], with: UITableView.RowAnimation.none)
                    }

                })
            }
        } else {
            let type = fileName.imagemediaFileName
            let fileURL = documentsUrl.appendingPathComponent(type + "/" + attName!)
            let asset = AVAsset(url: fileURL)

            let avPlayerItem = AVPlayerItem(asset: asset)

            let avPlayer = AVPlayer(playerItem: avPlayerItem)
            let player = AVPlayerViewController()
            player.player = avPlayer

            avPlayer.play()

            present(player, animated: true, completion: nil)
        }
    }

    @objc func onTapOfReplyMessage(_ sender: TableViewButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: chatTable)
        let indexPath = chatTable.indexPathForRow(at: buttonPosition)!

        let tag = indexPath.row
        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
        let chatList = dayMessages[tag] as! chatListObject
        if let msg = DatabaseManager.getMessageIndex(globalMsgId: (chatList.messageContext?.replyToId)!) {
            let time = Double(msg.msgTimeStamp)! / 10_000_000
            let finalDate = time.getDateFromUTC()
            let section = datesArray.index(of: finalDate)
            let daysMessages = messages.value(forKey: datesArray.object(at: section) as! String) as! [chatListObject]

//            let msgProcessed = ChatMessageProcessor.processSingleMessageContext(message: msg)
            if let row = daysMessages.firstIndex(where: { $0.messageContext?.globalMsgId == msg.globalMsgId }) {
                let indexPath = NSIndexPath(row: row, section: section)
                chatTable.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
            }
        }
    }

    @objc func refreshPollOption(sender: TableViewButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: chatTable)
        let indexPath = chatTable.indexPathForRow(at: buttonPosition)!

        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
        let chatList = dayMessages[indexPath.row] as! chatListObject

        let pollString = chatList.messageItem?.message as! String
        if let pollData = self.convertJsonStringToDictionary(text: pollString) {
            let data = pollData["pollOPtions"] as! String
            let oPtionsArray = data.toJSON() as! NSArray
            let pollDat = pollData as NSDictionary

            let indexpath = indexPath

            getPollDetailsForPollIdAndIndex(pollId: pollData["pollId"] as! String, pollIndex: indexpath, pollOptions: oPtionsArray, msgId: chatList.messageContext!.localMessageId ?? "", pollData: pollDat)
        }
    }

    @objc func submitImagePollOption(sender: TableViewButton) {
        messageTextField.resignFirstResponder()
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: chatTable)
        let indexPath = chatTable.indexPathForRow(at: buttonPosition)!

        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
        let chatList = dayMessages[indexPath.row] as! chatListObject

        let pollString = chatList.messageItem?.message as! String

        if let pollDat = self.convertJsonStringToDictionary(text: pollString) {
            let pollData = pollDat as NSDictionary

            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ShowImagePollViewController") as? ShowImagePollViewController {
                if let navigator = navigationController {
                    nextViewController.hidesBottomBarWhenPushed = true
                    nextViewController.navigationController?.navigationBar.isHidden = true
                    nextViewController.pollData = pollData.mutableCopy() as! NSMutableDictionary
                    nextViewController.localMsgId = chatList.messageContext?.localMessageId!

                    nextViewController.imagesLocalData = chatList.messageItem?.localMediaPaths

                    let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
                    navigator.navigationBar.tintColor = color3
                    navigator.pushViewController(nextViewController, animated: true)
                }
            }
        }
    }

    @objc func submitPollOption(sender: TableViewButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: chatTable)
        let indexPath = chatTable.indexPathForRow(at: buttonPosition)!

        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
        let chatList = dayMessages[indexPath.row] as! chatListObject

        let pollString = chatList.messageItem?.message as! String
        if let pollData = self.convertJsonStringToDictionary(text: pollString) {
            let data = pollData["pollOPtions"] as! String
            let oPtionsArray = data.toJSON() as! NSArray
            let pollDat = pollData as NSDictionary

            let indexpath = indexPath
            var selectedId = ""

            if chatList.messageContext?.isMine == false {
                let incomingCell = chatTable.cellForRow(at: indexpath) as! IncomingMessageCell
                if (incomingCell.PollView?.pollOptionOneCheckMark.isHidden)! == false {
                    let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                    selectedId = (opt1["choiceId"] as? String)!

                } else if (incomingCell.PollView?.pollOptionTwoCheckMark.isHidden)! == false {
                    let opt2 = oPtionsArray.object(at: 1) as! [String: Any]
                    selectedId = (opt2["choiceId"] as? String)!

                } else if (incomingCell.PollView?.pollOptionThreeCheckMark.isHidden)! == false {
                    let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                    selectedId = (opt3["choiceId"] as? String)!

                } else if (incomingCell.PollView?.pollOptionourCheckMark.isHidden)! == false {
                    let opt4 = oPtionsArray.object(at: 3) as! [String: Any]
                    selectedId = (opt4["choiceId"] as? String)!
                }
            } else {
                let incomingCell = chatTable.cellForRow(at: indexpath) as! OutGoingMessageCell
                if (incomingCell.PollView?.pollOptionOneCheckMark.isHidden)! == false {
                    let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                    selectedId = (opt1["choiceId"] as? String)!

                } else if (incomingCell.PollView?.pollOptionTwoCheckMark.isHidden)! == false {
                    let opt2 = oPtionsArray.object(at: 1) as! [String: Any]
                    selectedId = (opt2["choiceId"] as? String)!

                } else if (incomingCell.PollView?.pollOptionThreeCheckMark.isHidden)! == false {
                    let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                    selectedId = (opt3["choiceId"] as? String)!

                } else if (incomingCell.PollView?.pollOptionourCheckMark.isHidden)! == false {
                    let opt4 = oPtionsArray.object(at: 3) as! [String: Any]
                    selectedId = (opt4["choiceId"] as? String)!
                }
            }
            if selectedId != "" {
                submitSelectedpollId(pollData: pollDat, selectedId: selectedId, optionsArray: oPtionsArray, pollIndex: indexpath, msgId: chatList.messageContext!.localMessageId ?? "", grpType: groupDetail?.groupType as! String)

            } else {
                alert(message: "Please choose an option to submit poll")
            }
        }
    }

    func submitSelectedpollId(pollData: NSDictionary, selectedId: String, optionsArray: NSArray, pollIndex: IndexPath, msgId: String, grpType: String) {
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                let time = Double(pollData["pollExpireOn"] as! String)! / 1000

                if checkIfDateExpired(timeStamp: time) {
                    let pollReq = submitPollIdRequestObject()
                    pollReq.auth = DefaultDataProcessor().getAuthDetails()
                    pollReq.pollId = pollData["pollId"] as! String
                    pollReq.pollChoiceId = selectedId
                    pollReq.groupType = Int(grpType) ?? 0

                    Loader.show()
                    NetworkingManager.submitPoll(getGroupModel: pollReq) { (result: Any, sucess: Bool) in
                        if let results = result as? SubmitPollDataResponseObject, sucess {
                            Loader.close()
                            if sucess {
                                if results.status == "Success" {
                                    let pollD = pollData.mutableCopy() as! NSMutableDictionary
                                    pollD.setValue(selectedId, forKey: "selectedChoice")
                                    let str = pollD.toJsonString()
                                    DatabaseManager.updateMessageTableForOtherColoumn(imageData: str, localId: msgId)

                                    self.getPollDetailsForPollIdAndIndex(pollId: pollData["pollId"] as! String, pollIndex: pollIndex, pollOptions: optionsArray, msgId: msgId, pollData: pollD.mutableCopy() as! NSDictionary)
                                }
                            }
                        }
                    }
                } else {
                    alert(message: "The Poll has ended")
                }

            } else {
                alert(message: "Internet is required")
            }
        }
    }

    func getPollDetailsForPollIdAndIndex(pollId: String, pollIndex: IndexPath, pollOptions: NSArray, msgId: String, pollData: NSDictionary) {
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                let getPoll = GetPollDataRequestObject()
                getPoll.auth = DefaultDataProcessor().getAuthDetails()
                getPoll.pollId = pollId
                getPoll.groupType = Int(groupDetail?.groupType ?? "0") ?? 0

                Loader.show()

                NetworkingManager.getPollCounts(getGroupModel: getPoll) { (result: Any, sucess: Bool) in
                    if let results = result as? PollStatusResponseObject, sucess {
                        Loader.close()

                        if sucess {
                            if results.status == "Success" {
                                var obj = [PollTable.PollOptions]()
                                let choices = results.data?.pollstats

                                for choice in pollOptions {
                                    let pollOps = PollTable.PollOptions()
                                    let ch = choice as! NSDictionary

                                    for object in choices! {
                                        if object.choiceId == ch.value(forKey: "choiceId") as! String {
                                            pollOps.choiceId = object.choiceId
                                            pollOps.numberOfVotes = object.count
                                            pollOps.choiceImage = ch.value(forKey: "choiceImage") as! String
                                            pollOps.choiceText = ch.value(forKey: "choiceText") as! String

                                            obj.append(pollOps)
                                        }
                                    }
                                }

                                let dat = obj.toJsonString()
                                let pollD = pollData.mutableCopy() as! NSMutableDictionary
                                pollD.setValue(dat, forKey: "pollOPtions")
                                let str = pollD.toJsonString()
                                DatabaseManager.updateMessageTableForOtherColoumn(imageData: str, localId: msgId)

                                let dayMessages = self.messages.value(forKey: self.datesArray.object(at: pollIndex.section) as! String) as! NSMutableArray
                                let chatList = dayMessages[pollIndex.row] as! chatListObject

                                chatList.messageItem?.message = str

                                self.chatTable.reloadRows(at: [pollIndex], with: .none)
                            }
                        }
                    }
                }
            } else {
                alert(message: "Internet is required")
            }
        }
    }

    @objc func onTapOfImagePoll(sender: pollTapGesture) {
        print("Pressed pollChoice button")

        let dayMessages = messages.value(forKey: datesArray.object(at: sender.mySection) as! String) as! NSMutableArray
        let chatList = dayMessages[sender.myRow] as! chatListObject

        let indexpath = IndexPath(row: sender.myRow, section: sender.mySection)

        let pollString = chatList.messageItem?.message as! String

        if let pollDat = self.convertJsonStringToDictionary(text: pollString) {
            let pollData = pollDat as NSDictionary

            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ShowImagePollViewController") as? ShowImagePollViewController {
                if let navigator = navigationController {
                    nextViewController.hidesBottomBarWhenPushed = true
                    nextViewController.navigationController?.navigationBar.isHidden = true
                    nextViewController.pollData = pollData.mutableCopy() as! NSMutableDictionary
                    nextViewController.localMsgId = chatList.messageContext?.localMessageId!

                    nextViewController.imagesLocalData = chatList.messageItem?.localMediaPaths

                    let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR

                    navigator.navigationBar.tintColor = color3
                    navigator.pushViewController(nextViewController, animated: true)
                }
            }
        }
    }

    @objc func onTapOfPoll(sender: pollTapGesture) {
        print("Pressed pollChoice button")

        let dayMessages = messages.value(forKey: datesArray.object(at: sender.mySection) as! String) as! NSMutableArray
        let chatList = dayMessages[sender.myRow] as! chatListObject

        let indexpath = IndexPath(row: sender.myRow, section: sender.mySection)

        if chatList.messageContext?.isMine == false {
            let incomingCell = chatTable.cellForRow(at: indexpath) as! IncomingMessageCell

            if sender.selectedTag == 0 {
                incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionourCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionOneCheckMark.isHidden = false
            } else if sender.selectedTag == 1 {
                incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = false
                incomingCell.PollView?.pollOptionourCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionOneCheckMark.isHidden = true
            } else if sender.selectedTag == 2 {
                incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = false
                incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionourCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionOneCheckMark.isHidden = true

            } else if sender.selectedTag == 3 {
                incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionourCheckMark.isHidden = false
                incomingCell.PollView?.pollOptionOneCheckMark.isHidden = true
            }
        } else {
            let incomingCell = chatTable.cellForRow(at: indexpath) as! OutGoingMessageCell

            if sender.selectedTag == 0 {
                incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionourCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionOneCheckMark.isHidden = false
            } else if sender.selectedTag == 1 {
                incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = false
                incomingCell.PollView?.pollOptionourCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionOneCheckMark.isHidden = true
            } else if sender.selectedTag == 2 {
                incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = false
                incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionourCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionOneCheckMark.isHidden = true

            } else if sender.selectedTag == 3 {
                incomingCell.PollView?.pollOptionThreeCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionTwoCheckMark.isHidden = true
                incomingCell.PollView?.pollOptionourCheckMark.isHidden = false
                incomingCell.PollView?.pollOptionOneCheckMark.isHidden = true
            }
        }
    }

    @objc func onTapOfPreview(_ sender: TableViewButton) {
        print("pressed show Preview button")

        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: chatTable)
        let indexPath = chatTable.indexPathForRow(at: buttonPosition)!

        let tag = indexPath.row
        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
        let chatList = dayMessages[tag] as! chatListObject
        let type = chatList.messageItem?.messageType
        var imgData: Any!
        var count: Int!
        var imageText: String!
        var photos = [AXPhoto]()

        switch type! {
        case messagetype.IMAGE:
            imgData = chatList.messageItem?.message as! String
            count = 1
            imageText = chatList.messageItem?.messageTextString

            let img = getImage(imageName: imgData as! String)
            let str = NSAttributedString(string: imageText ?? "")
            photos = [AXPhoto(attributedTitle: str, image: img)]

            var imageView = UIImageView()
            if chatList.messageContext?.isMine == false {
                let cell = chatTable.cellForRow(at: indexPath as IndexPath) as! IncomingMessageCell
                imageView = (cell.PhotosView?.Photo)!
            } else {
                let cell = chatTable.cellForRow(at: indexPath as IndexPath) as! OutGoingMessageCell
                imageView = (cell.PhotosView?.Photo)!
            }

            let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) { [weak self] (_, _) -> UIImageView? in
                guard let self = self else { return nil }

                guard let cell = self.chatTable.cellForRow(at: indexPath as IndexPath) else { return nil }

                // adjusting the reference view attached to our transition info to allow for contextual animation
                if chatList.messageContext?.isMine == false {
                    let cardscell = cell as! IncomingMessageCell
                    return (cardscell.PhotosView?.Photo)!
                } else {
                    let cardscell = cell as! OutGoingMessageCell
                    return (cardscell.PhotosView?.Photo)!
                }
            }
            let dataSource = AXPhotosDataSource(photos: photos)
            let pagingConfig = AXPagingConfig(loadingViewClass: nil)
            let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: pagingConfig, transitionInfo: transitionInfo)
            photosViewController.delegate = self

            present(photosViewController, animated: true)
        case messagetype.OTHER:
            let otherType = chatList.messageItem?.otherMessageType
            switch otherType! {
            case otherMessageType.MEDIA_ARRAY:
                // handling image

                let text = chatList.messageItem?.message as! String
                if text.count > 2, text.contains("attachmentArray") {
                    let json = convertJsonStringToDictionary(text: text)
                    let data = json!["attachmentArray"] as! NSArray
                    imageText = chatList.messageItem?.messageTextString

                    for dat in data {
                        let img1 = dat as! NSDictionary

                        let img = getImage(imageName: img1.value(forKey: "imageName") as! String)
                        let str = NSAttributedString(string: imageText ?? "")
                        let photo = AXPhoto(attributedTitle: str, image: img)
                        photos.append(photo)
                    }
                    var imageView = UIImageView()
                    if chatList.messageContext?.isMine == false {
                        let cell = chatTable.cellForRow(at: indexPath as IndexPath) as! IncomingMessageCell

                        imageView = cell.ImageCollection?.image1 ?? imageView
                    } else {
                        let cell = chatTable.cellForRow(at: indexPath as IndexPath) as! OutGoingMessageCell

                        imageView = cell.ImageCollection?.image1 ?? imageView
                    }

                    let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) { [weak self] (_, _) -> UIImageView? in
                        guard let self = self else { return nil }

                        guard let cell = self.chatTable.cellForRow(at: indexPath as IndexPath) else { return nil }

                        // adjusting the reference view attached to our transition info to allow for contextual animation
                        if chatList.messageContext?.isMine == false {
                            let cardscell = cell as! IncomingMessageCell
                            return (cardscell.ImageCollection?.image1)!
                        } else {
                            let cardscell = cell as! OutGoingMessageCell
                            return (cardscell.ImageCollection?.image1)!
                        }
                    }
                    let dataSource = AXPhotosDataSource(photos: photos)
                    let pagingConfig = AXPagingConfig(loadingViewClass: nil)
                    let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: pagingConfig, transitionInfo: transitionInfo)
                    photosViewController.delegate = self

                    present(photosViewController, animated: true)
                }
            case .POST_SYSTEM_EVENT:
                print("do nothing")
            case .ENTITY_SPAM_REP_CHOICE:
                print("do nothing")

            case .PERSON_INTRO:
                print("do nothing")

            case .INFO:
                print("do nothing")

            case .TEXT_POLL:

                print("do nothing")

            case .IMAGE_POLL:
                print("do nothing")

            case .MEETING:
                print("do nothing")

            case .INVITE:
                print("do nothing")

            case .REMINDER:
                print("do nothing")
            }
        default:
            print("do Nothing")
        }
    }

    @objc func onTapOfMediaArray(sender: pollTapGesture) {
        let dayMessages = messages.value(forKey: datesArray.object(at: sender.mySection) as! String) as! NSMutableArray
        let chatList = dayMessages[sender.myRow] as! chatListObject

        let indexPath = IndexPath(row: sender.myRow, section: sender.mySection)

//        let type = chatList.messageItem?.messageType
//        var imgData:Any!
//        var count:Int!
        var imageText: String!
        var photos = [AXPhoto]()

        let text = chatList.messageItem?.message as! String
        if text.count > 2, text.contains("attachmentArray") {
            let json = convertJsonStringToDictionary(text: text)
            let data = json!["attachmentArray"] as! NSArray
            imageText = chatList.messageItem?.messageTextString

            for dat in data {
                let img1 = dat as! NSDictionary

                let img = getImage(imageName: img1.value(forKey: "imageName") as! String)
                let str = NSAttributedString(string: imageText ?? "")
                let photo = AXPhoto(attributedTitle: str, image: img)
                photos.append(photo)
            }
            var imageView = UIImageView()
            if chatList.messageContext?.isMine == false {
                let cell = chatTable.cellForRow(at: indexPath as IndexPath) as! IncomingMessageCell

                if sender.selectedTag == 0 {
                    imageView = cell.ImageCollection?.image1 ?? imageView
                } else if sender.selectedTag == 1 {
                    imageView = cell.ImageCollection?.image2 ?? imageView
                } else if sender.selectedTag == 2 {
                    imageView = cell.ImageCollection?.image3 ?? imageView
                } else if sender.selectedTag == 3 {
                    imageView = cell.ImageCollection?.image4 ?? imageView
                }

            } else {
                let cell = chatTable.cellForRow(at: indexPath as IndexPath) as! OutGoingMessageCell

                if sender.selectedTag == 0 {
                    imageView = cell.ImageCollection?.image1 ?? imageView
                } else if sender.selectedTag == 1 {
                    imageView = cell.ImageCollection?.image2 ?? imageView
                } else if sender.selectedTag == 2 {
                    imageView = cell.ImageCollection?.image3 ?? imageView
                } else if sender.selectedTag == 3 {
                    imageView = cell.ImageCollection?.image4 ?? imageView
                }
            }

            let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) { [weak self] (_, index) -> UIImageView? in
                guard let self = self else { return nil }

                guard let cell = self.chatTable.cellForRow(at: indexPath as IndexPath) else { return nil }

                // adjusting the reference view attached to our transition info to allow for contextual animation
                if chatList.messageContext?.isMine == false {
                    let cardscell = cell as! IncomingMessageCell

                    if index == 0 {
                        return (cardscell.ImageCollection?.image1)!
                    } else if index == 1 {
                        return (cardscell.ImageCollection?.image2)!
                    } else if index == 2 {
                        return (cardscell.ImageCollection?.image3)!
                    } else {
                        return (cardscell.ImageCollection?.image4)!
                    }
                } else {
                    let cardscell = cell as! OutGoingMessageCell

                    if index == 0 {
                        return (cardscell.ImageCollection?.image1)!
                    } else if index == 1 {
                        return (cardscell.ImageCollection?.image2)!
                    } else if index == 2 {
                        return (cardscell.ImageCollection?.image3)!
                    } else {
                        return (cardscell.ImageCollection?.image4)!
                    }
                }
            }
            let dataSource = AXPhotosDataSource(photos: photos, initialPhotoIndex: sender.selectedTag)
            let pagingConfig = AXPagingConfig(loadingViewClass: nil)
            let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: pagingConfig, transitionInfo: transitionInfo)
            photosViewController.delegate = self

            present(photosViewController, animated: true)
        }
    }

    func animate(duration: Double) {
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

    func addNewMessage(chatListItem: chatListObject) {
        // to set based on timestamp
        let time = Double(chatListItem.messageContext!.msgTimeStamp)! / 10_000_000
        let finalDate = time.getDateFromUTC()

        let allDates = messages.allKeys as NSArray

        if allDates.contains(finalDate) {
            let dateChatMsgs = messages.value(forKey: finalDate) as! NSMutableArray
            dateChatMsgs.insert(chatListItem, at: 0)

            messages.removeObject(forKey: finalDate)
            messages.setValue(dateChatMsgs, forKey: finalDate)

        } else {
            let dateChatMsgs = NSMutableArray()
            dateChatMsgs.insert(chatListItem, at: 0)
            messages.setValue(dateChatMsgs, forKey: finalDate)
        }
    }

    func showSendButton() {
        sendButton.isHidden = false
        openCameraButton.isHidden = true
        recordAudioButton.isHidden = true
        seperatorButton.isHidden = true
        seperatorWidthConstraint.constant = 0
        cameraWidthConstraint.constant = 0
        audioWidthConstraint.constant = 0
        chatViewLeadingConstraint.constant = 0
    }

    func showcameraAudioButton() {
        sendButton.isHidden = true
        openCameraButton.isHidden = false
        recordAudioButton.isHidden = false
        seperatorButton.isHidden = false
        seperatorWidthConstraint.constant = 4
        chatViewLeadingConstraint.constant = -34
        cameraWidthConstraint.constant = 55
        audioWidthConstraint.constant = 34
    }

    func getImage(imageName: String) -> UIImage {
        var image = UIImage()
        if let cachedimage = self.imageCache.object(forKey: imageName as AnyObject) as? UIImage {
            image = cachedimage
        } else {
            if imageName != "" {
                if let img = self.load(attName: imageName) {
                    image = img
                    imageCache.setObject(image, forKey: imageName as AnyObject)
                }
            }
        }
        return image
    }
    }
    
extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_: UITextView) {
        let size = CGSize(width: messageTextField.frame.width, height: .infinity)
        let estimatedSize = messageTextField.sizeThatFits(size)
        textViewHC.constant = estimatedSize.height
    }

    @objc func textDidChange(_: NSNotification) {
        let size = CGSize(width: messageTextField.frame.width, height: .infinity)
        let estimatedSize = messageTextField.sizeThatFits(size)
        textViewHC.constant = estimatedSize.height
    }

    func textViewDidChangeSelection(_: UITextView) {
        let size = CGSize(width: messageTextField.frame.width, height: .infinity)
        let estimatedSize = messageTextField.sizeThatFits(size)
        textViewHC.constant = estimatedSize.height
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.count > 0 {
            hideMenu()
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)

        if newText.count > 0 {
            showSendButton()

        } else {
            if !isReplyActive {
                showcameraAudioButton()
            }
        }

        guard let string = textView.text else { return true }
        let newLength = text.count + string.count - range.length
        if newLength <= 250 {
            setTypingStatus()
            return true
        } else {
            alert(message: "The maximum length for the text message has been reached.")
            return false
        }
    }
}

extension Double {
    func getTimeStringFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
}

extension String {
    func checkIfTodayOrYesterday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd, MMMM yyyy"
        let date = dateFormatter.date(from: self)

        if Calendar.current.isDateInToday(date!) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date!) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "dd MMMM"
            let datestring = dateFormatter.string(from: date!)
            return datestring
        }
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

class TableViewButton: UIButton {
    var myRow: Int = 0
    var mySection: Int = 0
}

class tableViewLongPress: UILongPressGestureRecognizer {
    var myRow: Int = 0
    var mySection: Int = 0
}

class pollTapGesture: UITapGestureRecognizer {
    var myRow: Int = 0
    var mySection: Int = 0
    var selectedTag: Int = 0
}

class PaddedLabel: UILabel {}

extension UILabel {
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString: NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))

        attributedText = attributedString
    }

    func addCharacterSpacing(kernValue: Double = 1.15) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}

extension ChatViewController: AddImageDelegate {
    func imageAdded() {
        viewWillAppear(true)
    }
}
