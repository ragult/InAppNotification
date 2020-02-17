//
//  ACSpeakerCardsViewController.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 13/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import AVKit
import AXPhotoViewer
import CallKit
import IQKeyboardManagerSwift
import Photos
import SwiftEventBus
import SwiftyJSON
import TZImagePickerController
import UIKit

protocol processAudioDataDelegate: AnyObject {
    func processDataForAudio(mediaObj: [MediaUploadObject], type: attachmentType)
}

protocol processPollDataDelegate: AnyObject {
    func processDataForPoll(mediaObj: Any, pollObj: PollTable, type: attachmentType)
}

class ACSpeakerCardsViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, AXPhotosViewControllerDelegate, groupExitDelegate, processAudioDataDelegate, processPollDataDelegate, groupPhotoChangeDelegate {
    var channels = [ChannelDisplayObject]()
    var delegate = UIApplication.shared.delegate as? AppDelegate
    var messages = NSMutableDictionary()
    var messagesArray = [MessagesTable]()
    var datesArray = NSMutableArray()
    var displayName: String?
    var groupType: String?
    var displayImage: String = ""
    var unPublish : Bool = false
    @IBOutlet var cardsTableView: UITableView!
    @IBOutlet var popUpViewHeightConst: NSLayoutConstraint!
    let appColour = UIColor(red: 0.137, green: 0.6235, blue: 0.6078, alpha: 1)

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
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var scrollFloatingButton: UIButton!
    @IBOutlet var bottomKeyboardView: UIView!

    @IBOutlet var chatTableHeight: NSLayoutConstraint!

    @IBOutlet var chatKeyboardHeight: NSLayoutConstraint!

    @IBOutlet var noKeyboardView: UIView!

    @IBOutlet var chatViewLeadingConstraint: NSLayoutConstraint!

    @IBOutlet var audioWidthConstraint: NSLayoutConstraint!

    @IBOutlet var cameraWidthConstraint: NSLayoutConstraint!

    @IBOutlet var seperatorWidthConstraint: NSLayoutConstraint!

    @IBOutlet var titleView: UIView!

    @IBOutlet var titleTf: PaddedTextField!

    var topicId: String = ""
    var channelDetails: ChannelDisplayObject?
    var isViewFirstTime: Bool!
    var isViewFirstTimeLoaded: Bool!
    var isfromNotifications: Bool = false
    var channelId: String?
    var userLocalId: String?
    var globalChatId: String?
    var replyMessageId: String = ""
    var tapActive: Bool = false
    let imageCache = NSCache<AnyObject, AnyObject>()
    var isPlayingAudio = false
    var selectedAudioIndex = IndexPath()
    var playingAudioObject = chatListObject()
    var isTimerFirstTime = false
    var timer: Timer!
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()

    var isCellSelected: Bool = false
    var currentSelectedIndex: IndexPath?
    var selectedObject = chatListObject()

    @IBOutlet var noKeyboardText: UILabel!

    func userLocationData(clearChat: Bool) {
        if clearChat {
            isViewFirstTime = true
            viewWillAppear(true)
        } else {
            bottomKeyboardView.isHidden = true
            noKeyboardView.isHidden = false
        }
    }

    func photoUpdateData(photoName: String) {
        displayImage = photoName
        customNavigationBar(name: displayName!, image: displayImage)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardsTableView.register(UINib(nibName: "CardsTableViewCell", bundle: nil), forCellReuseIdentifier: "CardsTableViewCell")

        cardsTableView.register(UINib(nibName: "DayViewCell", bundle: nil), forCellReuseIdentifier: "DayViewCell")
//        self.cardsTableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        cardsTableView.transform = CGAffineTransform(scaleX: 1, y: -1)

        cardsTableView.estimatedRowHeight = 120
        cardsTableView.rowHeight = UITableView.automaticDimension
        cardsTableView.allowsSelection = false
        cardsTableView.separatorColor = COLOURS.TABLE_BACKGROUND_COLOUR
        cardsTableView.backgroundColor = COLOURS.TABLE_BACKGROUND_COLOUR
        //  chatTable.transform = CGAffineTransform(scaleX: 1, y: -1)

        showcameraAudioButton()
        messageTextField.delegate = self
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        titleView.isHidden = true

        navigationItem.hidesBackButton = true
        if openMenuPlusButton.isSelected == false {
            menuItemsStackView.isHidden = true
            popUpViewHeightConst.constant = 0
        }

        listenToEventbus()

        //     let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.tabBarController!.tabBar.frame.height, right: 0)
        //  self.cardsTableView.contentInset = adjustForTabbarInsets
        // self.cardsTableView.scrollIndicatorInsets = adjustForTabbarInsets
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func processDataForAudio(mediaObj: [MediaUploadObject], type _: attachmentType) {
        for imageToSend in mediaObj {
            let sendMessage = ChatMessageProcessor.createImageContextObject(text: imageToSend.messageTextString, channel: (channelDetails?.globalChannelName)!, chanlType: channelType(rawValue: (channelDetails?.channelType)!)!, localSenderId: userLocalId!, localChannelId: (channelDetails?.channelId)!, globalChatId: globalChatId!, mediaType: imageToSend.msgType, mediaObject: imageToSend.localImagePath!, thumbnail: imageToSend.imageName!)
            if topicId != "" {
                sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
            } else {
                sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
            }

            if (channelDetails?.channelType)! == channelType.PUBLIC_GROUP.rawValue || (channelDetails?.channelType)! == channelType.PRIVATE_GROUP.rawValue {
                sentObj = sendMessage
                Loader.show()

                ACBroadcastMessageSenderClass.sendMediaMessage(context: self, messageContext: sendMessage.messageContext!, url: imageToSend.localImagePath!, messageType: (sendMessage.messageItem?.messageType)!, imageObject: imageToSend, messageTextString: imageToSend.messageTextString, other: imageToSend.imageName!, groupName: displayName ?? "", refGroupId: "")
            } else {
                ACMessageSenderClass.sendMediaMessage(messageContext: sendMessage.messageContext!, url: imageToSend.localImagePath!, messageType: (sendMessage.messageItem?.messageType)!, imageObject: imageToSend, messageTextString: imageToSend.messageTextString, other: imageToSend.imageName!, groupName: displayName ?? "", refGroupId: "")
                //                        self.messages .append(sendMessage)
                addNewMessage(chatListItem: sendMessage)
                DefaultSound.sendNewMessage()

                reloadTableViewToIndex()
            }
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
            sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
        } else {
            sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
        }

        if (channelDetails?.channelType)! == channelType.PUBLIC_GROUP.rawValue || (channelDetails?.channelType)! == channelType.PRIVATE_GROUP.rawValue {
            sentObj = sendMessage
            Loader.show()

            ACBroadcastMessageSenderClass.sendPollData(context: self, chatlist: sendMessage, url: data, messageType: (sendMessage.messageItem?.messageType)!, imageObject: [], otherType: type, messageTextString: "", groupName: displayName ?? "", refGroupId: "", attachId: "")

        } else {
            ACMessageSenderClass.sendPollData(chatlist: sendMessage, url: data, messageType: (sendMessage.messageItem?.messageType)!, imageObject: [], otherType: type, messageTextString: "", groupName: displayName ?? "", refGroupId: "", attachId: "")

            addNewMessage(chatListItem: sendMessage)

            reloadTableViewToIndex()
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
                    if message?.globalMsgId == message?.topicId {
                        let readReceipt = ACreadReceiptObjectClass()
                        readReceipt.chnl_name = self.channelDetails?.globalChannelName
                        readReceipt.chnl_typ = self.channelDetails?.channelType
                        readReceipt.receiver = self.globalChatId
                        readReceipt.senderPhone = UserDefaults.standard.value(forKey: UserKeys.userPhoneNumber) as? String
                        readReceipt.senderUUID = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
                        readReceipt.id_last = message?.globalMsgId
                        readReceipt.id_first = message?.globalMsgId

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

                        pubnubClass.sendreceiptsMessageToPubNub(msgObject: pubNubDictionary, channel: readReceipt.chnl_name!, completionHandler: { (status) -> Void in

                            print(status)
                        })

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
                                DefaultSound.eventBusNewMessage()

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
                            }
                        }
                    } else {
                        if let msgs = DatabaseManager.getMessageIndex(globalMsgId: message!.topicId) {
                            let time = Double(msgs.msgTimeStamp)! / 10_000_000
                            let finalDate = time.getDateFromUTC()
                            let dateChatMessages = self.messages.value(forKey: finalDate) as! NSMutableArray
                            for msg in dateChatMessages {
                                let newMessage = msg as! chatListObject

                                if newMessage.messageContext?.globalMsgId == message!.topicId {
                                    DispatchQueue.main.async {
                                        let section = self.datesArray.index(of: finalDate)
                                        let row = dateChatMessages.index(of: newMessage)
                                        let newIndexPaths = IndexPath(row: row, section: section)
                                        self.cardsTableView.reloadRows(at: [newIndexPaths], with: UITableView.RowAnimation.none)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        SwiftEventBus.onBackgroundThread(self, name: "readReceiptsMessage") { notification in

            if self.isViewActive {
                let eventObj: ACReadReceiptEventBusObject = notification!.object as! ACReadReceiptEventBusObject

                if self.channelDetails?.globalChannelName == eventObj.channelName || self.channelDetails?.channelId == eventObj.channelName {
                    if self.datesArray.contains(eventObj.messageDate) {
                        let dateChatMessages = self.messages.value(forKey: eventObj.messageDate) as! NSMutableArray
                        for msg in dateChatMessages {
                            let message = msg as! chatListObject
                            if message.messageContext?.globalMsgId == eventObj.lastMsgId {
                                DispatchQueue.main.async {
                                    let section = self.datesArray.index(of: eventObj.messageDate)
                                    let row = dateChatMessages.index(of: message)
                                    message.messageContext?.messageState = eventObj.messageState

                                    dateChatMessages.removeObject(at: row)
                                    dateChatMessages.insert(message, at: row)

                                    self.messages.removeObject(forKey: eventObj.messageDate)
                                    self.messages.setValue(dateChatMessages, forKey: eventObj.messageDate)

                                    let newIndexPaths = IndexPath(row: row, section: section)
                                    self.cardsTableView.reloadRows(at: [newIndexPaths], with: UITableView.RowAnimation.none)
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

        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.systemMessage) { notification in
            if self.isViewActive {
                let eventObj: eventObject = notification!.object as! eventObject
                let channel = eventObj.channelObject
                let message = eventObj.messages

                if self.channelDetails?.channelId == channel!.id {
                    if message?.globalMsgId == message?.topicId {
                        DispatchQueue.main.async {
                            let item = ChatMessageProcessor.processSingleMessage(message: message!, chatobjectsDictionary: self.messages)
                            //                self.messages .append(item)
                            self.messages = item

                            self.reloadTableViewToIndex(isScrollRequired: false)
                        }
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

        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.publishrights) { notification in
            if self.isViewActive {
                let eventObj: eventObject = notification!.object as! eventObject
                let channel = eventObj.channelObject
                let message = eventObj.messages

                if self.channelDetails?.channelId == channel!.id {
                    DispatchQueue.main.async {
                        if (message?.text.contains("granted Publish rights"))! || (message?.text.contains("made as Super admin"))! {
                            self.bottomKeyboardView.isHidden = false
                            self.noKeyboardView.isHidden = true

                        } else {
                            self.userLocationData(clearChat: false)
                            if (message?.text.contains("has been revoked"))! {
                                self.noKeyboardText.text = "Only admins can post messages"
                            }
                        }
                    }
                }
            }
        }
        
        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.apiFailure) { (notification) in
            if self.isViewActive {
                DispatchQueue.main.async {
                    Loader.close()
                }
            }
        }

        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.messageSent) { _ in
            if self.isViewActive {
                self.sentObj.messageContext?.messageState = messageState.SENDER_SENT
                let sendMessage = self.sentObj

                // to set based on timestamp
                let time = Double(sendMessage.messageContext!.msgTimeStamp)! / 10_000_000
                let finalDate = time.getDateFromUTC()

                let allDates = self.messages.allKeys as NSArray

                if allDates.contains(finalDate) {
                    let dateChatMsgs = self.messages.value(forKey: finalDate) as! NSMutableArray
                    dateChatMsgs.insert(sendMessage, at: 0)

                    self.messages.removeObject(forKey: finalDate)
                    self.messages.setValue(dateChatMsgs, forKey: finalDate)

                } else {
                    let dateChatMsgs = NSMutableArray()
                    dateChatMsgs.insert(sendMessage, at: 0)
                    self.messages.setValue(dateChatMsgs, forKey: finalDate)
                }

                DispatchQueue.main.async {
                    self.reloadTableViewToIndex()
                    self.titleTf.text = ""
                    self.messageTextField.text = ""
                    self.messageTextField.resignFirstResponder()
                    self.textViewHC.constant = 30
                    Loader.close()
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
                scrollToBottom()
                chatKeyboardHeight.constant = keyboardHeight
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.layoutIfNeeded()
                })
                //                chatTableHeight.constant = keyboardHeight
                hideMenu()
                menuItemsStackView.isHidden = false
                menuView.addBorder(toSide: .Top, withColor: UIColor.white.cgColor, andThickness: 10)
                menuView.layoutIfNeeded()
                openMenuPlusButton.isSelected = true
                popUpViewHeightConst.constant = 110
                titleView.isHidden = false
                animate(duration: 0.2)

                chatTableTap.addTarget(self, action: #selector(ACSpeakerCardsViewController.DismissKeyboard))
                cardsTableView.addGestureRecognizer(chatTableTap)
                tapActive = true
            }
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("Keyboard will hide!")
        cardsTableView.removeGestureRecognizer(chatTableTap)
        tapActive = false

        hideMenu()
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            //            chatTableHeight.constant = 0
            hideMenu()
            titleView.isHidden = true
            chatKeyboardHeight.constant = 0
        }
    }

    func scrollToBottom() {
        //        let scrollPoint = CGPoint(x: 0, y: self.chatTable.contentSize.height - self.chatTable.frame.size.height)
        //        self.chatTable.setContentOffset(scrollPoint, animated: false)
        if cardsTableView.contentOffset.y >= (cardsTableView.contentSize.height - cardsTableView.frame.size.height) {
            // you reached end of the table
            if messages.allKeys.count > 0 {
                DispatchQueue.main.async {
                    if self.cardsTableView.numberOfSections > 0 {
                        if self.cardsTableView.numberOfRows(inSection: 0) > 0 {
                            let newIndexPaths = IndexPath(row: 0, section: 0)
                            self.cardsTableView.scrollToRow(at: newIndexPaths, at: .bottom, animated: false)
                        }
                    }
                }
            }
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

    override func viewWillDisappear(_: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        isViewActive = false
    }

    fileprivate func uploadImage(_ attachMentsArray: [MediaUploadObject]) {
        for imageToSend in attachMentsArray {
            let sendMessage = ChatMessageProcessor.createImageContextObject(text: imageToSend.messageTextString, channel: (channelDetails?.globalChannelName)!, chanlType: channelType(rawValue: (channelDetails?.channelType)!)!, localSenderId: userLocalId!, localChannelId: (channelDetails?.channelId)!, globalChatId: globalChatId!, mediaType: imageToSend.msgType, mediaObject: imageToSend.localImagePath!, thumbnail: imageToSend.imageName!)
            if topicId != "" {
                sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
            } else {
                sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
            }

            if (channelDetails?.channelType)! == channelType.PUBLIC_GROUP.rawValue || (channelDetails?.channelType)! == channelType.PRIVATE_GROUP.rawValue {
                sentObj = sendMessage
                Loader.show()
                ACBroadcastMessageSenderClass.sendMediaMessage(context: self, messageContext: sendMessage.messageContext!, url: imageToSend.localImagePath!, messageType: (sendMessage.messageItem?.messageType)!, imageObject: imageToSend, messageTextString: imageToSend.messageTextString, other: imageToSend.imageName!, groupName: displayName ?? "", refGroupId: "", chatlist: sendMessage)

            } else {
                ACMessageSenderClass.sendMediaMessage(messageContext: sendMessage.messageContext!, url: imageToSend.localImagePath!, messageType: (sendMessage.messageItem?.messageType)!, imageObject: imageToSend, messageTextString: imageToSend.messageTextString, other: imageToSend.imageName!, groupName: displayName ?? "", refGroupId: "")

                addNewMessage(chatListItem: sendMessage)
                DefaultSound.sendNewMessage()

                reloadTableViewToIndex()
            }
            //                        self.messages .append(sendMessage)
        }
    }

    fileprivate func uploadImageArray(_ attachMentsArray: [MediaUploadObject]) {
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
            sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
        } else {
            sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
        }

        if (channelDetails?.channelType)! == channelType.PUBLIC_GROUP.rawValue || (channelDetails?.channelType)! == channelType.PRIVATE_GROUP.rawValue {
            sentObj = sendMessage
            Loader.show()

            ACBroadcastMessageSenderClass.sendImageArrayMessage(context: self, messageContext: sendMessage.messageContext!, url: attachmentString, messageType: (sendMessage.messageItem?.messageType)!, imageObject: attachMentsArray, otherType: otherMessageType.MEDIA_ARRAY, messageTextString: attachMentsArray[0].messageTextString, groupName: displayName ?? "", refGroupId: "")

        } else {
            ACMessageSenderClass.sendImageArrayMessage(messageContext: sendMessage.messageContext!, url: attachmentString, messageType: (sendMessage.messageItem?.messageType)!, imageObject: attachMentsArray, otherType: otherMessageType.MEDIA_ARRAY, messageTextString: attachMentsArray[0].messageTextString, groupName: displayName ?? "", refGroupId: "")

            addNewMessage(chatListItem: sendMessage)
            DefaultSound.sendNewMessage()

            reloadTableViewToIndex()
        }
    }

    fileprivate func setUpChatDetails() {
        let userGlobalId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
        
        if (channelDetails?.channelType)! != channelType.ONE_ON_ONE_CHAT.rawValue {
            let GroupMemberIndex = DatabaseManager.getGroupMemberIndex(groupId: channelDetails!.lastSenderPhoneBookContactId, globalUserId: userGlobalId!)
            let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelDetails!.lastSenderPhoneBookContactId)
            
            userLocalId = GroupMemberIndex?.groupMemberId
            
            globalChatId = groupTable?.groupGlobalId
            
            if groupTable?.createdBy != userGlobalId {
                if GroupMemberIndex?.superAdmin == false {
                    if GroupMemberIndex?.publish == false {
                        bottomKeyboardView.isHidden = true
                        userLocationData(clearChat: false)
                        noKeyboardText.text = "Only admins can post messages"
                    }
                }
                
                if groupTable?.groupStatus == groupStats.INACTIVE.rawValue {
                    userLocationData(clearChat: false)
                    noKeyboardText.text = "You are no longer a member of this group"
                }
                
            } else {
                if groupTable?.groupStatus == groupStats.INACTIVE.rawValue {
                    userLocationData(clearChat: false)
                }
            }
            
        } else {
            userLocalId = UserDefaults.standard.value(forKey: UserKeys.userContactIndex) as? String
            globalChatId = channelDetails?.globalChannelName
        }
    }
    
    override func viewWillAppear(_: Bool) {
        isViewActive = true
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.showExceptSpecificChannelId
        delegate?.currentChannelId = channelDetails?.channelId ?? ""

        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false

        DispatchQueue.main.async {
            self.hideMenu()

            if self.isViewFirstTimeLoaded {
                self.isViewFirstTimeLoaded = false
//                self.cardsTableView.bounces = false
                self.cardsTableView.layer.removeAllAnimations()
                self.cardsTableView.layoutIfNeeded()
                self.scrollFloatingButton.tintColor = .darkGray
                self.scrollFloatingButton.extDropShadow(scale: true)
                self.scrollFloatingButton.isHidden = true
                self.cardsTableView.reloadData()
            }

//            let scrollPoint = CGPoint(x: 0, y: self.cardsTableView.contentSize.height - self.cardsTableView.frame.size.height)
//            self.cardsTableView.setContentOffset(scrollPoint, animated: false)
        }
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if delegate.isFromAttachmentView != attachmentType.TEXT {
                let type = delegate.isFromAttachmentView
                delegate.isFromAttachmentView = attachmentType.TEXT
                let attachMentsArray = delegate.attachmentArray
                delegate.attachmentArray.removeAll()
                if globalChatId != nil {
                    switch type {
                    case attachmentType.IMAGE:

                        uploadImage(attachMentsArray)
                    case attachmentType.imageArray:
                        uploadImageArray(attachMentsArray)
                        //                    self.messages .append(sendMessage)

                    case .TEXT:
                        print("Do nothing")
                    case .AUDIO:
                        print("Do nothing")
                    case .VIDEO:
                        print("Do nothing")
                    case .poll:
                        print("Do nothing")
                    }
                }
            } else {
                DatabaseManager.updateChannelTableForChannelId(channelId: (channelDetails?.channelId)!)
                if isViewFirstTime {
                    isViewFirstTime = false

//                    self .getDataForCards()
                    messagesArray = DatabaseManager.getMessagesForChannelIdForSpeakerGroup(channelId: channelId!)
                    setUpChatDetails()

                    messages = ChatMessageProcessor.processMessage(messageObjectArray: messagesArray)

                    let filArray = (messages.allKeys as NSArray).descendingArrayWithData()

                    datesArray = filArray

                    cardsTableView.delegate = self
                    cardsTableView.dataSource = self

                    cardsTableView.reloadData()
                    if messages.allKeys.count > 0 {
                        DispatchQueue.main.async {
                            let newIndexPaths = IndexPath(row: 0, section: 0)
                            self.cardsTableView.scrollToRow(at: newIndexPaths, at: .bottom, animated: false)
                        }
                    }
                }
            }
        }
    }

    func customNavigationBar(name: String, image: String, isSentMessage: Bool = false, showCopy: Bool = false) {
        if isCellSelected == false {
            if currentSelectedIndex != nil {
                let cell = cardsTableView.cellForRow(at: currentSelectedIndex!)
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
            tapRec.addTarget(self, action: #selector(ACSpeakerCardsViewController.back))

            let containView = UIView(frame: CGRect(x: 2, y: 0, width: 250, height: 40))

            let profileImage = UIImageView(frame: CGRect(x: 0, y: 4, width: 32, height: 32))
            profileImage.contentMode = UIView.ContentMode.scaleAspectFill
            if image == "" {
                profileImage.image = UIImage(named: "icon_DefaultGroup")

                //            profileImage.image = LetterImageGenerator.imageWith(name:name, randomColor: .gray)
            } else {
                profileImage.image = getImage(imageName: image)
            }
            profileImage.layer.cornerRadius = 16
            profileImage.layer.borderColor = UIColor.groupTableViewBackground.cgColor
            profileImage.layer.borderWidth = 1
            profileImage.layer.masksToBounds = true
            containView.addSubview(profileImage)

            //title view
            let title = UILabel(frame: CGRect(x: 40, y: 7, width: 200, height: 20))
            title.text = name
            title.textAlignment = .left
            title.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 16)
            containView.addSubview(title)
            containView.addGestureRecognizer(groupDetailtapRec)
            groupDetailtapRec.addTarget(self, action: #selector(ACSpeakerCardsViewController.didTapGroupTitle))

            let backbuttonwithTitle = UIBarButtonItem(image: UIImage(named: "rightBackButton"), style: .plain, target: self, action: #selector(ACSpeakerCardsViewController.back))

            let rightBarButton = UIBarButtonItem(customView: containView)
            navigationItem.leftBarButtonItems = [backbuttonwithTitle, rightBarButton]
            navigationItem.rightBarButtonItem = nil
        } else {
            //            let soundButton   = UIBarButtonItem(image: UIImage(named: "volumeButton"),  style: .plain, target: self, action: #selector(didTapSoundButton))
            let deleteButton = UIBarButtonItem(image: UIImage(named: "unPublish"), style: .plain, target: self, action: #selector(didTapDeleteButton))

            let copyButton = UIBarButtonItem(image: UIImage(named: "copyButton"), style: .plain, target: self, action: #selector(didTapCopyButton))
            let shareButton = UIBarButtonItem(image: UIImage(named: "icon_info"), style: .plain, target: self, action: #selector(didTapShareButton))
            let closeButton = UIBarButtonItem(image: UIImage(named: "closeButton"), style: .plain, target: self, action: #selector(didTapCloseButton))
            navigationItem.rightBarButtonItem = closeButton

            if showCopy {
                navigationItem.leftBarButtonItems = [deleteButton, copyButton]
            } else {
                navigationItem.leftBarButtonItems = [deleteButton]
            }

            if isSentMessage {
                if showCopy {
                    if unPublish{
                        navigationItem.leftBarButtonItems = [copyButton,deleteButton, shareButton]
                    } else {
                        navigationItem.leftBarButtonItems = [copyButton, shareButton]
                    }
                } else {
                    if unPublish{
                    navigationItem.leftBarButtonItems = [deleteButton, shareButton]
                    } else {
                        navigationItem.leftBarButtonItems = [ shareButton]
                    }
                }
            }
            animate(duration: 0.2)
        }
    }

    @objc func didTapDeleteButton() {
        unPublishMessage()
    }

    func unPublishMessage(){
        let data = UnPublishRequestModel()
        data.auth = DefaultDataProcessor().getAuthDetails()
        data.groupId = selectedObject.messageContext?.receiverGlobalId
        data.globalMessageId = selectedObject.messageContext?.globalMsgId
        
        NetworkingManager.unPublishMessage(getGroupModel: data, listener: {
            result, success in if let result = result as? GetMessagesResponseModel, success {
                if success {
                    if result.status == "Success" {
                        DatabaseManager.updateMessageTableforColoumnAndValue(coloumnName: "visibilityStatus", Value: visibilityStatus.deleted.rawValue, localId: (self.selectedObject.messageContext?.localMessageId)!)
                        
                        let time = Double(self.selectedObject.messageContext!.msgTimeStamp)! / 10_000_000
                        let finalDate = time.getDateFromUTC()
                        
                        let dateChatMsgs = self.messages.value(forKey: finalDate) as! NSMutableArray
                        let section = self.datesArray.index(of: finalDate)
                        let row = dateChatMsgs.index(of: self.selectedObject)
                        
                        dateChatMsgs.remove(self.selectedObject)
                        if dateChatMsgs.count == 0 {
                            self.datesArray.remove(finalDate)
                            self.cardsTableView.beginUpdates()
                            let indexSet: IndexSet = [section]
                            self.cardsTableView.deleteSections(indexSet, with: UITableView.RowAnimation.bottom)
                            self.cardsTableView.endUpdates()
                        } else {
                            self.messages.removeObject(forKey: finalDate)
                            self.messages.setValue(dateChatMsgs, forKey: finalDate)
                            
                            self.cardsTableView.beginUpdates()
                            let newIndexPaths = IndexPath(row: row, section: section)
                            self.cardsTableView.deleteRows(at: [newIndexPaths], with: UITableView.RowAnimation.bottom)
                            self.cardsTableView.endUpdates()
                        }
                        self.selectedObject = chatListObject()
                        
                        self.didTapCloseButton()
                        
                    }
                }
            }
        })
    }
    
    @objc func didTapCopyButton() {
        let type = selectedObject.messageItem!.messageType
        switch type! {
        case messagetype.TEXT:
            let pasteBoard = UIPasteboard.general

            var newstring = selectedObject.messageItem!.message as! String
            newstring = newstring + "\n\n" + (selectedObject.messageItem!.messageTextString)
            pasteBoard.string = newstring
        default:

            print("do Nothing")

            alert(message: labelStrings.copyOnlyText)
        }

        didTapCloseButton()
    }

    @objc func didTapShareButton() {
        didTapCloseButton()
        let homeStoryBoard = UIStoryboard(name: "OnBoarding", bundle: nil)
        let nextViewController = homeStoryBoard.instantiateViewController(withIdentifier: "ACTopicMessageStatusViewController") as! ACTopicMessageStatusViewController
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
        customNavigationBar(name: displayName!, image: displayImage)
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

        } else {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "groupDetailsViewController") as? groupDetailsViewController {
                if let navigator = navigationController {
                    nextViewController.hidesBottomBarWhenPushed = true
                    let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelDetails!.lastSenderPhoneBookContactId)
                    nextViewController.groupDetails = groupTable!
                    nextViewController.datadelegate = self
                    nextViewController.photoChangedelegate = self

                    navigator.pushViewController(nextViewController, animated: true)
                }
            }
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

    func reloadTableViewToIndex(isScrollRequired: Bool = true) {
        let filArray = (messages.allKeys as NSArray).descendingArrayWithData()

        if isScrollRequired {
            if filArray.count != datesArray.count {
                datesArray = filArray

                //            self.cardsTableView.reloadData()

                let sectionToReload = 0
                let indexSet: IndexSet = [sectionToReload]
                cardsTableView.beginUpdates()

                cardsTableView.insertSections(indexSet, with: UITableView.RowAnimation.none)
                cardsTableView.endUpdates()
                //            self.cardsTableView.reloadSections(indexSet, with: UITableView.RowAnimation.bottom)

                let newIndexPaths = IndexPath(row: 0, section: 0)
                cardsTableView.scrollToRow(at: newIndexPaths, at: .bottom, animated: false)

            } else {
                let newIndexPaths = IndexPath(row: 0, section: 0)

                cardsTableView.beginUpdates()

                cardsTableView.insertRows(at: [newIndexPaths], with: UITableView.RowAnimation.none)
                cardsTableView.endUpdates()
                cardsTableView.scrollToRow(at: newIndexPaths, at: .bottom, animated: false)
            }

        } else {
            if filArray.count != datesArray.count {
                datesArray = filArray

                //            self.cardsTableView.reloadData()

                let sectionToReload = 0
                let indexSet: IndexSet = [sectionToReload]
                cardsTableView.beginUpdates()

                cardsTableView.insertSections(indexSet, with: UITableView.RowAnimation.none)
                cardsTableView.endUpdates()

            } else {
                let newIndexPaths = IndexPath(row: 0, section: 0)

                cardsTableView.beginUpdates()

                cardsTableView.insertRows(at: [newIndexPaths], with: UITableView.RowAnimation.none)
                cardsTableView.endUpdates()
                cardsTableView.scrollToRow(at: newIndexPaths, at: .bottom, animated: false)
            }
        }
    }

    @objc func back() {
        print("Pressed back button")
        if isfromNotifications {
            let homeStoryBoard = UIStoryboard(name: "OnBoarding", bundle: nil)
            let nextViewController = homeStoryBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
            nextViewController.modalPresentationStyle = .fullScreen
            present(nextViewController, animated: false, completion: nil)

        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: scrollview

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y > scrollView.contentOffset.y + 10 || targetContentOffset.pointee.y < scrollView.contentOffset.y + 10 {
            scrollFloatingButton.isHidden = false
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
        if Int(scrollView.decelerationRate.rawValue) == 0 {
            scrollFloatingButton.isHidden = true
            UIView.animate(withDuration: 1) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @IBAction func scrollFloatingButtonAction(_: Any) {
        let newIndexPaths = IndexPath(row: 0, section: 0)
        cardsTableView.scrollToRow(at: newIndexPaths, at: .bottom, animated: false)

        scrollFloatingButton.isHidden = true
    }

    func rotateTable() {
        //        if messages.count == 0 {
        //            print("CHAT HAVE ZERO MESSAGES!")
        //        } else {
        //            chatTable.transform = CGAffineTransform(scaleX: 1, y: -1)
        //        }
    }

    func getDataForCards() {
        cardsTableView.reloadData()
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
            let cell = cardsTableView.cellForRow(at: indexPath as IndexPath) as! CardsTableViewCell

            if sender.selectedTag == 0 {
                imageView = cell.mediaArrayView?.imageView1 ?? imageView
            } else if sender.selectedTag == 1 {
                imageView = cell.mediaArrayView?.imageView2 ?? imageView
            } else if sender.selectedTag == 2 {
                imageView = cell.mediaArrayView?.imageView3 ?? imageView
            }

            let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) { [weak self] (_, index) -> UIImageView? in
                guard let self = self else { return nil }

                guard let cell = self.cardsTableView.cellForRow(at: indexPath as IndexPath) else { return nil }

                // adjusting the reference view attached to our transition info to allow for contextual animation
                let cardscell = cell as! CardsTableViewCell

                if index == 0 {
                    return (cardscell.mediaArrayView?.imageView1)!
                } else if index == 1 {
                    return (cardscell.mediaArrayView?.imageView2)!
                } else {
                    return (cardscell.mediaArrayView?.imageView3)!
                }
            }
            let dataSource = AXPhotosDataSource(photos: photos, initialPhotoIndex: sender.selectedTag)
            let pagingConfig = AXPagingConfig(loadingViewClass: nil)
            let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: pagingConfig, transitionInfo: transitionInfo)
            photosViewController.delegate = self

            present(photosViewController, animated: true)
        }
    }

    @objc func goToComments(_ recognizer: tableViewtapGesturePress) {
        print("go to speaker groups")
        let position: CGPoint = recognizer.location(in: cardsTableView)
        let indexPath: NSIndexPath = cardsTableView.indexPathForRow(at: position)! as NSIndexPath
        print(indexPath.row)

        let tag = recognizer.myRow
        let dayMessages = messages.value(forKey: datesArray.object(at: recognizer.mySection) as! String) as! NSMutableArray

        let chatList = dayMessages[tag] as! chatListObject

        if (channelDetails?.channelType)! != channelType.PUBLIC_GROUP.rawValue || (channelDetails?.channelType)! != channelType.PRIVATE_GROUP.rawValue {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
                if let navigator = navigationController {
                    let cell = cardsTableView.cellForRow(at: indexPath as IndexPath) as! CardsTableViewCell

                    cell.unreadMsgLabel.text = ""

                    let channelTableList = ChannelDisplayObject()

                    if let channel = DatabaseManager.getChannelIndexbyMessage(contactId: (chatList.messageContext?.localChanelId)!, channelType: (chatList.messageContext?.channelType)!.rawValue) {
                        channelTableList.channelId = channel.id
                        channelTableList.globalChannelName = channel.globalChannelName

                        channelTableList.channelType = channel.channelType
                        channelTableList.unseenCount = channel.unseenCount
                        channelTableList.lastMessageIdOfChannel = channel.lastSavedMsgid
                        channelTableList.lastMessageTime = channel.lastMsgTime
                        channelTableList.lastSenderPhoneBookContactId = channel.contactId

                        let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                        channelTableList.channelDisplayNames = (groupTable?.groupName)!
                        channelTableList.channelImageUrl = (groupTable?.localImagePath)!
                    }
//                    nextViewController.loadTableViewData(chnlDetails: channelTableList)

                    nextViewController.customNavigationBar(name: channelTableList.channelDisplayNames, image: channelTableList.channelImageUrl, channelTyp: channelType(rawValue: channelTableList.channelType)!)
                    nextViewController.displayName = channelTableList.channelDisplayNames
                    nextViewController.displayImage = channelTableList.channelImageUrl
                    nextViewController.isViewFirstTime = true

                    nextViewController.isViewFirstTimeLoaded = true

                    nextViewController.channelDetails = channelTableList
                    nextViewController.topicId = (chatList.messageContext?.globalMsgId)!
                    navigator.pushViewController(nextViewController, animated: true)
                }
            }
        }
    }

    func hideMenu() {
//        if replyView.isHidden == true {
        if tapActive == false {
            cardsTableView.removeGestureRecognizer(chatTableTap)
        }
        menuItemsStackView.isHidden = true
        popUpViewHeightConst.constant = 0

        openMenuPlusButton.isSelected = false
        animate(duration: 0.2)
//        }
    }

    func animate(duration: Double) {
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
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
                nextViewController.isFromTopics = true
                nextViewController.selectedList = assets ?? []
                nextViewController.addedImages = photos ?? []
                nextViewController.modalPresentationStyle = .overFullScreen
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
                nextViewController.isImage = false
                nextViewController.addImageDelegate = self
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
            nextViewController.groupType = groupType
            nextViewController.modalPresentationStyle = .fullScreen
            present(nextViewController, animated: false, completion: nil)
//            self.modalPresentationStyle = .overCurrentContext
        }
    }

    @IBAction func openMenuButtonAction(_: Any) {
        if titleView.isHidden == false {
            if titleTf.isFirstResponder {
                titleTf.resignFirstResponder()
            }
            DismissKeyboard()
            titleView.isHidden = true
            if tapActive == false {
                chatTableTap.addTarget(self, action: #selector(ACSpeakerCardsViewController.DismissMenu))
                cardsTableView.addGestureRecognizer(chatTableTap)
            }
            menuItemsStackView.isHidden = false
            menuView.addBorder(toSide: .Top, withColor: UIColor.white.cgColor, andThickness: 10)
            menuView.layoutIfNeeded()
            openMenuPlusButton.isSelected = true
            popUpViewHeightConst.constant = 110
            animate(duration: 0.2)
        } else {
            if menuItemsStackView.isHidden == true {
                if tapActive == false {
                    chatTableTap.addTarget(self, action: #selector(ACSpeakerCardsViewController.DismissMenu))
                    cardsTableView.addGestureRecognizer(chatTableTap)
                }
                menuItemsStackView.isHidden = false
                menuView.addBorder(toSide: .Top, withColor: UIColor.white.cgColor, andThickness: 10)
                menuView.layoutIfNeeded()
                openMenuPlusButton.isSelected = true
                popUpViewHeightConst.constant = 110
                animate(duration: 0.2)
            } else {
                menuItemsStackView.isHidden = true
                openMenuPlusButton.isSelected = false
                popUpViewHeightConst.constant = 0

                animate(duration: 0.2)
            }
        }

        print("pressed open menuButton")
    }

    @IBAction func onClickOfCloseTitleView(_: Any) {
        hideMenu()
        titleView.isHidden = true
    }

    @IBAction func openCameraButtonAction(_: Any) {
        print("pressed open cameraButtton")
        CameraHandler.shared.showCamera(vc: self)
        CameraHandler.shared.imagePickedBlock = { groupImage in
            DispatchQueue.main.async { () in

                if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "AddImagesViewController") as? AddImagesViewController {
                    //                self.selectedImages = assets
                    nextViewController.addedImages = [groupImage]
                    nextViewController.addImageDelegate = self
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

    var sentObj = chatListObject()

    @IBAction func onClickOfSendButton(_: Any) {
        // Note : for testing purpose , messages are saving wuth audio record button.(send button was not implemented in zeplin designs)
        if !messageTextField.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if (channelDetails?.channelType)! == channelType.PUBLIC_GROUP.rawValue || (channelDetails?.channelType)! == channelType.PRIVATE_GROUP.rawValue {
                if delegate != nil {
                    if (delegate?.isInternetAvailable)! {
                        // saving Message
                        let sendMessage = ChatMessageProcessor.createMessageContextObject(groupType: groupType ?? "", text: messageTextField.text, channel: (channelDetails?.globalChannelName)!, chanlType: channelType(rawValue: (channelDetails?.channelType)!)!, localSenderId: userLocalId!, localChannelId: (channelDetails?.channelId)!, globalChatId: globalChatId!, replyId: replyMessageId, title: titleTf.text ?? "")
                        if topicId != "" {
                            sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
                        } else {
                            sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
                        }
                        sentObj = sendMessage
                        messageTextField.resignFirstResponder()
                        Loader.show()

                        ACBroadcastMessageSenderClass.sendTextMessage(context: self, messageContext: sendMessage.messageContext!, message: messageTextField.text, groupName: displayName ?? "", grpRefId: "", messageTitle: titleTf.text ?? "")

                    } else {
                        alert(message: "Internet is required")
                    }
                }

            } else {
                // saving Message
                let sendMessage = ChatMessageProcessor.createMessageContextObject(groupType: groupType ?? "", text: messageTextField.text, channel: (channelDetails?.globalChannelName)!, chanlType: channelType(rawValue: (channelDetails?.channelType)!)!, localSenderId: userLocalId!, localChannelId: (channelDetails?.channelId)!, globalChatId: globalChatId!, replyId: replyMessageId, title: titleTf.text ?? "")
                if topicId != "" {
                    sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
                } else {
                    sendMessage.messageContext!.topicId = sendMessage.messageContext!.globalMsgId
                }
                ACMessageSenderClass.sendTextMessage(messageContext: sendMessage.messageContext!, message: messageTextField.text, groupName: displayName ?? "", grpRefId: "", messageTitle: titleTf.text ?? "")

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
                titleTf.text = ""
                messageTextField.text = ""
                textViewHC.constant = 30
            }

            print("pressed open audio button")
        } else {
            print("Empty Message")
        }
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

    @objc func btnTapPlay(_ recognizer: tableViewtapGesturePress) {
        let position: CGPoint = recognizer.location(in: cardsTableView)
        let indexPath: NSIndexPath = cardsTableView.indexPathForRow(at: position)! as NSIndexPath
        print(indexPath.row)

        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
        let chatList = dayMessages[indexPath.row] as! chatListObject
        let attName = chatList.messageItem?.message as? String

        if attName != "" {
            if audioPlayer.isPlaying == true {
                let cell = cardsTableView.cellForRow(at: selectedAudioIndex) as! CardsTableViewCell
                audioPlayer.stop()
                isPlayingAudio = false
                cell.Audiocard!.slider.value = Float(0)
                let start = Float(0)

                let total = Float(audioPlayer.duration / 60)
                cell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", start, total) as String
                cell.Audiocard?.BtnPlay.setImage(UIImage(named: "group8"), for: .normal)

                if indexPath as IndexPath != selectedAudioIndex {
                    let cell = cardsTableView.cellForRow(at: indexPath as IndexPath) as! CardsTableViewCell
                    playingAudioObject = chatList
                    selectedAudioIndex = indexPath as IndexPath
                    cell.Audiocard!.slider.value = Float(0)
                    let total = Float(audioPlayer.duration / 60)
                    cell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", start, total) as String
                    cell.Audiocard?.BtnPlay.setImage(UIImage(named: "group8No"), for: .normal)

                    if isTimerFirstTime == false {
                        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayTimer), userInfo: nil, repeats: true)
                        isTimerFirstTime = true
                    }
                    isPlayingAudio = true
                    playAudioFile(attName)
                }
            } else {
                let cell = cardsTableView.cellForRow(at: indexPath as IndexPath) as! CardsTableViewCell
                playingAudioObject = chatList
                selectedAudioIndex = indexPath as IndexPath
                cell.Audiocard!.slider.value = Float(0)
                let total = Float(audioPlayer.duration / 60)
                let start = Float(0)

                cell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", start, total) as String
                cell.Audiocard?.BtnPlay.setImage(UIImage(named: "group8No"), for: .normal)

                if isTimerFirstTime == false {
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayTimer), userInfo: nil, repeats: true)
                    isTimerFirstTime = true
                }
                isPlayingAudio = true
                playAudioFile(attName)
            }

        } else {
            let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: (chatList.messageItem?.cloudReference)!, refernce: (chatList.messageContext?.localMessageId)!, jobType: downLoadType.media, mediaType: mediaDownloadType.audio.rawValue, mediaExtension: ".m4a")

            DispatchQueue.global(qos: .background).async {
                ACImageDownloader.downloadAudio(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                    DatabaseManager.updateMessageTableForLocalImage(localImagePath: path, localId: (chatList.messageContext?.localMessageId)!)

                    chatList.messageItem?.message = path
                    DispatchQueue.main.async { () in
                        self.cardsTableView.reloadRows(at: [indexPath as IndexPath], with: .none)
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
        if !audioPlayer.isPlaying {
            isPlayingAudio = false
            audioPlayer.currentTime = 0
        }
        let total = Float((audioPlayer.duration / 60) / 2)
        let current_time = Float((audioPlayer.currentTime / 60) / 2)

        if let acell = self.cardsTableView.cellForRow(at: selectedAudioIndex) {
            let cell = acell as! CardsTableViewCell

            cell.Audiocard!.slider.setValue(Float(audioPlayer.currentTime), animated: true)
            cell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", current_time, total) as String

            if !audioPlayer.isPlaying {
                cell.Audiocard?.BtnPlay.setImage(UIImage(named: "group8"), for: .normal)
                cell.Audiocard!.slider.setValue(Float(0), animated: true)
            }

        } else {
            audioPlayer.stop()
            isPlayingAudio = false
        }
    }

    @objc func moveSlide(sender: UISlider) {
        if isPlayingAudio {
            if audioPlayer.isPlaying, audioPlayer.isPlaying {
                audioPlayer.currentTime = TimeInterval(sender.value)

                let total = Float((audioPlayer.duration / 60) / 2)
                let current_time = Float((audioPlayer.currentTime / 60) / 2)

                let cell = cardsTableView.cellForRow(at: selectedAudioIndex) as! CardsTableViewCell

                cell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", current_time, total) as String

                if !audioPlayer.isPlaying {
                    cell.Audiocard?.BtnPlay.setImage(UIImage(named: "group8"), for: .normal)
                    cell.Audiocard!.slider.setValue(Float(0), animated: true)
                }
            }
        }
    }

    @objc func goToStories(_ recognizer: tableViewtapGesturePress) {
        print("go to stories")
        messageTextField.resignFirstResponder()
        let position: CGPoint = recognizer.location(in: cardsTableView)
        let indexPath: NSIndexPath = cardsTableView.indexPathForRow(at: position)! as NSIndexPath
        print(indexPath.row)

        let tag = recognizer.myRow
        let dayMessages = messages.value(forKey: datesArray.object(at: recognizer.mySection) as! String) as! NSMutableArray

        let chatList = dayMessages[tag] as! chatListObject
        let type = chatList.messageItem?.messageType

        switch type! {
        case messagetype.TEXT:

            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "StroriesViewController") as? StroriesViewController {
                if let navigator = navigationController {
                    nextViewController.hidesBottomBarWhenPushed = true
                    nextViewController.navigationController?.navigationBar.isHidden = true
                    nextViewController.storyTitleText = (chatList.messageItem?.message as! String)
                    nextViewController.storyText = chatList.messageItem?.messageTextString
                    navigator.pushViewController(nextViewController, animated: true)
                }
            }
        case messagetype.IMAGE:
            let imgData = chatList.messageItem?.message
            let count = 1
            let imageText = chatList.messageItem?.messageTextString
            let cell = cardsTableView.cellForRow(at: indexPath as IndexPath) as! CardsTableViewCell
            let imageView = cell.imageCard?.imageView

            let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) { [weak self] (_, _) -> UIImageView? in
                guard let self = self else { return nil }

                guard let cell = self.cardsTableView.cellForRow(at: indexPath as IndexPath) else { return nil }

                // adjusting the reference view attached to our transition info to allow for contextual animation
                let cardscell = cell as! CardsTableViewCell
                return cardscell.imageCard?.imageView
            }
            let img = getImage(imageName: imgData as! String)
            let str = NSAttributedString(string: imageText ?? "")
            let photos = [AXPhoto(attributedTitle: str, image: img)]

            let dataSource = AXPhotosDataSource(photos: photos)
            let pagingConfig = AXPagingConfig(loadingViewClass: nil)
            let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: pagingConfig, transitionInfo: transitionInfo)
            photosViewController.delegate = self

            present(photosViewController, animated: true)

        case messagetype.AUDIO:
//            let imgData = chatList.messageItem?.message
//            let audioPlayer = KAudioaudioPlayer.shared
//            audioPlayer.play(name: imgData as! String)
//
            break

        case messagetype.VIDEO:

            let attName = chatList.messageItem?.message as? String
            if attName == "" {
                let json = convertJsonStringToDictionary(text: (chatList.messageItem?.cloudReference)!)
                let urlStr = json!["vidurl"]! as! String

                let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: urlStr, refernce: (chatList.messageContext?.localMessageId)!, jobType: downLoadType.media, mediaType: mediaDownloadType.video.rawValue, mediaExtension: "")
                let cardsCell = cardsTableView.cellForRow(at: indexPath as IndexPath) as! CardsTableViewCell
                cardsCell.activityView.isHidden = false
                cardsCell.actIcon.startAnimating()

                DispatchQueue.global(qos: .background).async {
                    ACImageDownloader.downloadVideo(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                        DatabaseManager.updateMessageTableForLocalImage(localImagePath: path, localId: (chatList.messageContext?.localMessageId)!)
                        chatList.messageItem?.message = path
                        DispatchQueue.main.async { () in
                            cardsCell.activityView.isHidden = true
                            cardsCell.actIcon.stopAnimating()

                            self.cardsTableView.reloadRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.none)
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

        case messagetype.OTHER:
            let otherType = chatList.messageItem?.otherMessageType

            if otherType == otherMessageType.MEDIA_ARRAY {
                let text = chatList.messageItem?.message as? String ?? ""
                if text.count > 2, text.contains("attachmentArray") {
                    let json = convertJsonStringToDictionary(text: text)
                    let data = json!["attachmentArray"] as! NSArray

                    let imgData = data
                    let count = data.count
                    let imageText = chatList.messageItem?.messageTextString

                    let cell = cardsTableView.cellForRow(at: indexPath as IndexPath) as! CardsTableViewCell
                    let imageView = cell.mediaArrayView?.imageView1

                    let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) { [weak self] (_, _) -> UIImageView? in
                        guard let self = self else { return nil }

                        guard let cell = self.cardsTableView.cellForRow(at: indexPath as IndexPath) else { return nil }

                        // adjusting the reference view attached to our transition info to allow for contextual animation
                        let cardscell = cell as! CardsTableViewCell
                        return cardscell.mediaArrayView?.imageView1
                    }
                    var photos = [AXPhoto]()
                    for dat in data {
                        let img1 = dat as! NSDictionary

                        let img = getImage(imageName: img1.value(forKey: "imageName") as! String)
                        let str = NSAttributedString(string: imageText ?? "")
                        let photo = AXPhoto(attributedTitle: str, image: img)
                        photos.append(photo)
                    }

                    let dataSource = AXPhotosDataSource(photos: photos)
                    let pagingConfig = AXPagingConfig(loadingViewClass: nil)
                    let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: pagingConfig, transitionInfo: transitionInfo)
                    photosViewController.delegate = self

                    present(photosViewController, animated: true)
                }
            } else if otherType == otherMessageType.TEXT_POLL {
                let pollString = chatList.messageItem?.message as! String
                if let pollDat = self.convertJsonStringToDictionary(text: pollString) {
                    let pollData = pollDat as NSDictionary

                    if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "PollViewController") as? PollViewController {
                        if let navigator = navigationController {
                            nextViewController.hidesBottomBarWhenPushed = true
                            nextViewController.navigationController?.navigationBar.isHidden = true
                            nextViewController.pollData = pollData.mutableCopy() as! NSMutableDictionary
                            nextViewController.localMsgId = chatList.messageContext?.localMessageId!
                            navigator.pushViewController(nextViewController, animated: true)
                        }
                    }
                }
            } else if otherType == otherMessageType.IMAGE_POLL {
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

                            navigator.pushViewController(nextViewController, animated: true)
                        }
                    }
                }
            }
        }
    }

    func getGroupNameForMessage(message: chatListObject) -> String {
        if let channel = DatabaseManager.getChannelIndexbyMessage(contactId: (message.messageContext?.localChanelId)!, channelType: (message.messageContext?.channelType?.rawValue)!) {
            if let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channel.contactId) {
                return groupTable.groupName
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
}

extension ACSpeakerCardsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func numberOfSections(in _: UITableView) -> Int {
        return datesArray.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datesArray.count == 0 {
            return 0
        } else {
            let dateMsgArray = messages.value(forKey: datesArray.object(at: section) as! String) as! NSMutableArray
            return dateMsgArray.count
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "DayViewCell") as! DayViewCell
        headerCell.backgroundColor = UIColor.clear
        let date = datesArray.object(at: section) as! String
        headerCell.dayButton.setTitle(date.checkIfTodayOrYesterday(), for: .normal)
        headerCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)

        return headerCell.contentView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cardsCell = cardsTableView.dequeueReusableCell(withIdentifier: "CardsTableViewCell", for: indexPath) as! CardsTableViewCell
        let cell = UITableViewCell()
        cardsCell.backgroundColor = COLOURS.TABLE_BACKGROUND_COLOUR
        cardsCell.BGView.extCornerRadius = 4
        let tapComments = tableViewtapGesturePress(target: self, action: #selector(goToComments(_:)))
        let taptext = tableViewtapGesturePress(target: self, action: #selector(goToStories(_:)))
        tapComments.myRow = indexPath.row
        taptext.myRow = indexPath.row
        tapComments.mySection = indexPath.section
        taptext.mySection = indexPath.section
        cardsCell.timeLabel.isHidden = true
        cardsCell.bottomTimeLabel.isHidden = false
        cardsCell.bottomTimelabelHeight.constant = 21
        cardsCell.titleLabel.text = ""
        cardsCell.lblcount.text = ""
        cardsCell.titleLabel.isHidden = true
        cardsCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)

        cardsCell.titleLabel.isHidden = true
        cardsCell.imgIcon.isHidden = true
        cardsCell.chaticon.isHidden = true
        cardsCell.chaticon.image = UIImage(named: "ChatHeads")

        cardsCell.activityView.isHidden = true

        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
        let chatList = dayMessages[indexPath.row] as! chatListObject
        if chatList.messageContext?.isMine == true {
            cardsCell.messageStatusImageView.isHidden = false
            cardsCell.messageStatusImageView.image = getMessageStatus(chatObj: chatList)

            let msgcon = chatList.messageContext!
            if msgcon.messageType! != messagetype.TEXT {
                if chatList.messageContext!.messageState == messageState.SENDER_UNSENT, chatList.messageItem?.cloudReference == "" {
                    cardsCell.activityView.isHidden = false
                    cardsCell.actIcon.startAnimating()
                } else {
                    cardsCell.activityView.isHidden = true
                    cardsCell.actIcon.stopAnimating()
                }
            }
        } else {
            cardsCell.messageStatusImageView.isHidden = true
        }

        let longGesture = tableViewLongPress(target: self, action: #selector(onLongTap))
        longGesture.myRow = indexPath.row
        longGesture.mySection = indexPath.section

        cardsCell.addGestureRecognizer(longGesture)

        cardsCell.bottomTimeView.isHidden = true
        cardsCell.bottomTimeViewHeight.constant = 0

        if chatList.messageContext?.channelType! == channelType.PUBLIC_GROUP || chatList.messageContext?.channelType! == channelType.PRIVATE_GROUP {
            cardsCell.bottomTimeView.isHidden = true
            cardsCell.bottomTimeViewHeight.constant = 0
            cardsCell.nameLabel.text = ""
            cardsCell.nameLabel.isHidden = true
            cardsCell.discussButton.isHidden = true
            cardsCell.unreadMsgLabel.isHidden = true
            cardsCell.topStackView.isHidden = true

        } else {
            cardsCell.nameLabel.text = ""
            cardsCell.nameLabel.isHidden = false
            cardsCell.discussButton.isHidden = false
            cardsCell.unreadMsgLabel.isHidden = true

            let name = getUserName(object: chatList)
            cardsCell.nameLabel.text = name + ":"
            cardsCell.discussButton.tag = indexPath.row
            cardsCell.discussButton.superview?.tag = indexPath.section
//            cardsCell.discussButton.addTarget(self, action: #selector(goToDiscuss(_:)), for: .touchUpInside)
            cardsCell.discussButton.addGestureRecognizer(tapComments)

            cardsCell.topStackHeight.constant = 34
            cardsCell.topStackView.isHidden = false
            cardsCell.unreadMsgLabel.isHidden = true

            let mArray = DatabaseManager.getUnreadMessagesFormessageIdOfspeakerGroup(channelId: chatList.messageContext!.localChanelId!, replyMessageId: chatList.messageContext!.globalMsgId!)

            if mArray.count > 0 {
                cardsCell.topStackHeight.constant = 34
                cardsCell.unreadMsgLabel.isHidden = false
                let msgCount = String(mArray.count)
                cardsCell.unreadMsgLabel.text = msgCount

            } else {
                cardsCell.unreadMsgLabel.isHidden = true
            }

            cardsCell.TextCard?.lblText.text = chatList.messageItem!.messageTextString
            cardsCell.TextCard?.lblText.sizeToFit()
        }

        let type = chatList.messageItem?.messageType
        switch type! {
        case messagetype.TEXT:

            cardsCell.cardViewType = VIEWTYPE.TEXT
            cardsCell.initializeViews()

            if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                cardsCell.TextCard?.leftConstaint.constant = 22
                cardsCell.TextCard?.rightConstaint.constant = 22
                cardsCell.TextCard?.topConstraint.constant = 0
                cardsCell.TextCard?.bottomConstraint.constant = -8

            } else {
                cardsCell.TextCard?.leftConstaint.constant = 22
                cardsCell.TextCard?.rightConstaint.constant = 22
                cardsCell.TextCard?.topConstraint.constant = 12
                cardsCell.TextCard?.bottomConstraint.constant = -8
            }

            cardsCell.chaticon.isUserInteractionEnabled = true
            cardsCell.TextCard?.isUserInteractionEnabled = true

            cardsCell.TextCard?.addGestureRecognizer(taptext)

            let msgContext = chatList.messageContext

            // get meesage time
            let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
            cardsCell.bottomTimeLabel.text = time.getTimeStringFromUTC()

            let str = chatList.messageItem?.message as! String
            if str == "" {
                cardsCell.TextCard?.lblTitle.isHidden = true
            } else {
                cardsCell.TextCard?.lblTitle.isHidden = false
                cardsCell.TextCard?.lblTitle.text = str
            }

            cardsCell.TextCard?.lblText.text = chatList.messageItem!.messageTextString
            cardsCell.TextCard?.lblText.sizeToFit()
            cardsCell.TextCard?.lblText.adjustsFontSizeToFitWidth = false
            cardsCell.TextCard?.lblText.lineBreakMode = .byTruncatingTail

            if chatList.messageItem!.messageTextString.count < 80 {
                cardsCell.TextCard?.emptyMsg.isHidden = false
            } else {
                cardsCell.TextCard?.emptyMsg.isHidden = true
            }

            cardsCell.messageCardStackView.addArrangedSubview(cardsCell.TextCard ?? cardsCell.messageCardStackView)

            return cardsCell

        case messagetype.IMAGE:
            cardsCell.cardViewType = VIEWTYPE.IMAGE_CARD
            cardsCell.initializeViews()

            if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                cardsCell.imageCard?.leftConstaint.constant = 10
                cardsCell.imageCard?.rightConstaint.constant = 10
                cardsCell.imageCard?.topConstraint.constant = 4
                cardsCell.imageCard?.bottomConstraint.constant = 10
            } else {
                cardsCell.imageCard?.leftConstaint.constant = 0
                cardsCell.imageCard?.rightConstaint.constant = 0
                cardsCell.imageCard?.topConstraint.constant = 0
                cardsCell.imageCard?.bottomConstraint.constant = 0
            }

            cardsCell.titleLabel.isHidden = false
            cardsCell.imgIcon.isHidden = true
            cardsCell.chaticon.isHidden = false
            DispatchQueue.global(qos: .background).async {
                let imageName = chatList.messageItem?.message
                let image = self.getImage(imageName: imageName! as! String)

                DispatchQueue.main.async { () in
                    cardsCell.imageCard?.imageView.image = image
                    cardsCell.imageCard?.imageView.clipsToBounds = true
                    cardsCell.imageCard?.imageView.layer.cornerRadius = 2
                }
            }

            if chatList.messageItem?.message as! String == "" {
                // addObject TO Array
                let urlStr = chatList.messageItem?.cloudReference

                let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: urlStr!, refernce: (chatList.messageContext?.localMessageId)!, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

                DispatchQueue.global(qos: .background).async {
                    ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                        DatabaseManager.updateMessageTableForLocalImage(localImagePath: path, localId: (chatList.messageContext?.localMessageId)!)
                        chatList.messageItem?.message = path

                        DispatchQueue.main.async { () in
                            cardsCell.imageCard?.imageView.image = self.load(attName: (chatList.messageItem?.message)! as! String)
                            cardsCell.imageCard?.imageView.clipsToBounds = true
                        }

                    })
                }
            }

            let msgContext = chatList.messageContext

            // get meesage time
            let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
            cardsCell.bottomTimeLabel.text = time.getTimeStringFromUTC()

            cardsCell.chaticon.isUserInteractionEnabled = true
            cardsCell.imageCard!.isUserInteractionEnabled = true

            cardsCell.imageCard!.addGestureRecognizer(taptext)

            cardsCell.imageCard?.imageTitle.text = ""
            cardsCell.imageCard?.imageComment?.text = chatList.messageItem?.messageTextString

            cardsCell.messageCardStackView.addArrangedSubview(cardsCell.imageCard ?? cardsCell.messageCardStackView)
            return cardsCell

        case messagetype.VIDEO:
            cardsCell.cardViewType = VIEWTYPE.IMAGE_CARD
            cardsCell.initializeViews()

            if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                cardsCell.imageCard?.leftConstaint.constant = 10
                cardsCell.imageCard?.rightConstaint.constant = 10
                cardsCell.imageCard?.topConstraint.constant = 4
                cardsCell.imageCard?.bottomConstraint.constant = 10
            } else {
                cardsCell.imageCard?.leftConstaint.constant = 0
                cardsCell.imageCard?.rightConstaint.constant = 0
                cardsCell.imageCard?.topConstraint.constant = 0
                cardsCell.imageCard?.bottomConstraint.constant = 0
            }

            cardsCell.titleLabel.isHidden = false
            cardsCell.imgIcon.isHidden = true
            cardsCell.chaticon.isHidden = false
            DispatchQueue.global(qos: .background).async {
                let attName = chatList.messageItem?.thumbnail
                let image = self.getImage(imageName: attName!)
                DispatchQueue.main.async { () in
                    cardsCell.imageCard?.imageView.image = image
                    cardsCell.imageCard?.imageView.clipsToBounds = true
                }
            }

            if chatList.messageItem?.thumbnail == "" {
                let json = convertJsonStringToDictionary(text: (chatList.messageItem?.cloudReference)!)
                if json != nil {
                    let urlStr = json!["imgurl"]! as! String

                    let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: urlStr, refernce: (chatList.messageContext?.localMessageId)!, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

                    DispatchQueue.global(qos: .background).async {
                        ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                            DatabaseManager.updateMessageTableForOtherColoumn(imageData: path, localId: (chatList.messageContext?.localMessageId)!)

                            chatList.messageItem?.thumbnail = path
                            DispatchQueue.main.async { () in
                                cardsCell.imageCard?.imageView.image = self.load(attName: (chatList.messageItem?.thumbnail)!)
                                cardsCell.imageCard?.imageView.clipsToBounds = true
                            }

                        })
                    }
                }
            }
            cardsCell.imageCard?.onClickOfPlayBtn.isHidden = false
            let attName = chatList.messageItem?.message as! String
            if attName == "" {
                cardsCell.imageCard?.onClickOfPlayBtn.setImage(UIImage(named: "download"), for: .normal)
            } else {
                cardsCell.imageCard?.onClickOfPlayBtn.setImage(UIImage(named: "ic_play"), for: .normal)
            }
            if cardsCell.actIcon.isAnimating {
                cardsCell.imageCard?.onClickOfPlayBtn.isHidden = true
            } else {
                cardsCell.imageCard?.onClickOfPlayBtn.isHidden = false
            }

            let msgContext = chatList.messageContext

            // get meesage time
            let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
            cardsCell.bottomTimeLabel.text = time.getTimeStringFromUTC()

            cardsCell.chaticon.isUserInteractionEnabled = true
            cardsCell.imageCard?.onClickOfPlayBtn.isUserInteractionEnabled = true

            cardsCell.imageCard?.onClickOfPlayBtn.addGestureRecognizer(taptext)

            cardsCell.imageCard?.imageTitle.text = ""
            cardsCell.imageCard?.imageComment?.text = chatList.messageItem?.messageTextString

            cardsCell.messageCardStackView.addArrangedSubview(cardsCell.imageCard ?? cardsCell.messageCardStackView)
            return cardsCell

        case messagetype.AUDIO:
            cardsCell.cardViewType = VIEWTYPE.Audio
            cardsCell.initializeViews()

            if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                cardsCell.Audiocard?.leftConstaint.constant = 10
                cardsCell.Audiocard?.rightConstaint.constant = -10
                cardsCell.Audiocard?.topConstraint.constant = 4
                cardsCell.Audiocard?.bottomConstraint.constant = 10

            } else {
                cardsCell.Audiocard?.leftConstaint.constant = 0
                cardsCell.Audiocard?.rightConstaint.constant = 0
                cardsCell.Audiocard?.topConstraint.constant = 0
                cardsCell.Audiocard?.bottomConstraint.constant = 0
            }

//            cardsCell.imageCard?.imageView.image = UIImage(named: "music")
//            cardsCell.imageCard?.onClickOfPlayBtn.isHidden = false
            cardsCell.titleLabel.isHidden = false
            cardsCell.imgIcon.isHidden = true
            cardsCell.chaticon.isHidden = false
            let msgContext = chatList.messageContext

            // get meesage time
            let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
            cardsCell.bottomTimeLabel.text = time.getTimeStringFromUTC()

            cardsCell.chaticon.isUserInteractionEnabled = true
//            cardsCell.imageCard!.isUserInteractionEnabled = true

//            cardsCell.imageCard!.addGestureRecognizer(taptext)

            let chatList = dayMessages[indexPath.row] as! chatListObject
            let attName = chatList.messageItem?.message as? String
            let bundle = getDir().appendingPathComponent(attName!.appending(".m4a"))

            if FileManager.default.fileExists(atPath: bundle.path) {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: bundle)
                    audioPlayer.delegate = self as? AVAudioPlayerDelegate
                    let total = Float((audioPlayer.duration / 60) / 2)
                    let start = Float(0)

                    cardsCell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", start, total) as String
//
//                    let gettime = NSString(format: "%.2f", (audioPlayer.duration/60)) as String
//                    cardsCell.Audiocard!.timeLabel.text = "\(gettime)"
                    cardsCell.Audiocard!.slider.minimumValue = Float(0)
                    cardsCell.Audiocard!.slider.maximumValue = Float(audioPlayer.duration)

                } catch {
                    print("play(with name:), ", error.localizedDescription)
                }

            } else {
                cardsCell.Audiocard?.BtnPlay.setImage(UIImage(named: "download"), for: .normal)
            }
            cardsCell.Audiocard!.slider.setThumbImage(UIImage(named: "ovalCopy3")!, for: .normal)

            if cardsCell.actIcon.isAnimating {
                cardsCell.Audiocard?.BtnPlay.isHidden = true
            } else {
                cardsCell.Audiocard?.BtnPlay.isHidden = false
            }

            let btntap = tableViewtapGesturePress(target: self, action: #selector(btnTapPlay(_:)))
            cardsCell.Audiocard?.BtnPlay.addGestureRecognizer(btntap)
            btntap.myRow = indexPath.row
            btntap.mySection = indexPath.row

            cardsCell.Audiocard!.slider.addTarget(self, action: #selector(moveSlide(sender:)), for: .valueChanged)

            cardsCell.messageCardStackView.addArrangedSubview(cardsCell.Audiocard ?? cardsCell.messageCardStackView)
            return cardsCell

        case messagetype.OTHER:
            if chatList.messageItem?.otherMessageType == otherMessageType.MEDIA_ARRAY {
                cardsCell.cardViewType = VIEWTYPE.MEDIA_ARRAY
                cardsCell.initializeViews()
//                if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
//                    cardsCell.messageStackviewLeadingAnchor.constant = 10
//                    cardsCell.messageStackviewTrailingAnchor.constant = 10
//                    cardsCell.messageStackviewBottomAnchor.constant = 8
//
//                }

                if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                    cardsCell.mediaArrayView?.leftConstaint.constant = 10
                    cardsCell.mediaArrayView?.rightConstaint.constant = 10
                    cardsCell.mediaArrayView?.topConstraint.constant = 4
                    cardsCell.mediaArrayView?.bottomConstraint.constant = 10

                } else {
                    cardsCell.mediaArrayView?.leftConstaint.constant = 0
                    cardsCell.mediaArrayView?.rightConstaint.constant = 0
                    cardsCell.mediaArrayView?.topConstraint.constant = 0
                    cardsCell.mediaArrayView?.bottomConstraint.constant = 0
                }
//
                cardsCell.titleLabel.isHidden = false
                cardsCell.imgIcon.isHidden = true
                cardsCell.chaticon.isHidden = false
                DispatchQueue.global(qos: .background).async {
                    let image1: UIImage?
                    let image2: UIImage?
                    let image3: UIImage?
                    let images: NSArray!

                    if let json = self.convertJsonStringToDictionary(text: chatList.messageItem?.message as! String) {
                        images = json["attachmentArray"] as? NSArray
                        let img1 = images[0] as! NSDictionary
                        let img2 = images[1] as! NSDictionary

                        if img1.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                            let imageName = img1.value(forKey: "thumbnail") as! String
                            let image = self.getImage(imageName: imageName)

                            image1 = image

                        } else {
                            let imageName = img1.value(forKey: "imageName") as! String
                            let image = self.getImage(imageName: imageName)

                            image1 = image
                        }

                        if img2.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                            let imageName = img2.value(forKey: "thumbnail") as! String
                            let image = self.getImage(imageName: imageName)

                            image2 = image

                        } else {
                            let imageName = img2.value(forKey: "imageName") as! String
                            let image = self.getImage(imageName: imageName)

                            image2 = image
                        }

                        if images.count > 2 {
                            let img3 = images[2] as! NSDictionary

                            if img3.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                                let imageName = img3.value(forKey: "thumbnail") as! String
                                let image = self.getImage(imageName: imageName)
                                image3 = image

                            } else {
                                let imageName = img3.value(forKey: "imageName") as! String
                                let image = self.getImage(imageName: imageName)

                                image3 = image
                            }
                        } else {
                            image3 = nil
                        }

                        DispatchQueue.main.async { () in

                            let pollTap1 = pollTapGesture()
                            let pollTap2 = pollTapGesture()
                            let pollTap3 = pollTapGesture()

                            pollTap1.myRow = indexPath.row
                            pollTap2.myRow = indexPath.row
                            pollTap3.myRow = indexPath.row

                            pollTap1.mySection = indexPath.section
                            pollTap2.mySection = indexPath.section
                            pollTap3.mySection = indexPath.section

                            pollTap1.selectedTag = 0
                            pollTap2.selectedTag = 1
                            pollTap3.selectedTag = 2

                            cardsCell.mediaArrayView?.imageView1.isUserInteractionEnabled = true
                            cardsCell.mediaArrayView?.imageView2.isUserInteractionEnabled = true
                            cardsCell.mediaArrayView?.imageView3.isUserInteractionEnabled = true

                            cardsCell.mediaArrayView?.imageView1.addGestureRecognizer(pollTap1)
                            cardsCell.mediaArrayView?.imageView2.addGestureRecognizer(pollTap2)
                            cardsCell.mediaArrayView?.imageView3.addGestureRecognizer(pollTap3)

                            pollTap1.addTarget(self, action: #selector(ACSpeakerCardsViewController.onTapOfMediaArray(sender:)))
                            pollTap2.addTarget(self, action: #selector(ACSpeakerCardsViewController.onTapOfMediaArray(sender:)))
                            pollTap3.addTarget(self, action: #selector(ACSpeakerCardsViewController.onTapOfMediaArray(sender:)))

                            cardsCell.mediaArrayView?.imageView1.image = image1
                            cardsCell.mediaArrayView?.imageView2.image = image2

                            if image3 == nil {
                                cardsCell.mediaArrayView?.imageView3.isHidden = true
                                cardsCell.mediaArrayView?.extraCountLabel.isHidden = true

                            } else {
                                cardsCell.mediaArrayView?.imageView3.image = image3
                                cardsCell.mediaArrayView?.imageView3.isHidden = false
                                let count = String(images.count - 3)
                                if count == "0" {
                                    cardsCell.mediaArrayView?.extraCountLabel.isHidden = true
                                } else {
                                    cardsCell.mediaArrayView?.extraCountLabel.isHidden = false
                                    cardsCell.mediaArrayView?.extraCountLabel.text = "+" + count
                                }
                            }
                        }
                    } else {
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
                                        self.cardsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                                    }
                                }

                            })
                        }
                    }
                }

                let time = Double(chatList.messageContext!.msgTimeStamp)! / 10_000_000
                cardsCell.bottomTimeLabel.text = time.getTimeStringFromUTC()

                cardsCell.chaticon.isUserInteractionEnabled = true
                cardsCell.mediaArrayView!.isUserInteractionEnabled = true

//                cardsCell.mediaArrayView!.addGestureRecognizer(taptext)

                cardsCell.mediaArrayView?.imageTitle.text = ""
                cardsCell.mediaArrayView?.imageComment?.text = chatList.messageItem?.messageTextString

                cardsCell.messageCardStackView.addArrangedSubview(cardsCell.mediaArrayView ?? cardsCell.messageCardStackView)
                return cardsCell

            } else if chatList.messageItem?.otherMessageType == otherMessageType.TEXT_POLL {
                // MARK: Text Poll

                let pollString = chatList.messageItem?.message as! String
                if let pollData = self.convertJsonStringToDictionary(text: pollString) {
                    cardsCell.cardViewType = VIEWTYPE.POLL_CARD
                    cardsCell.initializeViews()

                    if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                        cardsCell.pollCard?.topConstraint.constant = 4
                        cardsCell.pollCard?.bottomConstraint.constant = 4

                    } else {
                        cardsCell.pollCard?.topConstraint.constant = 14
                        cardsCell.pollCard?.bottomConstraint.constant = 4
                    }

                    cardsCell.pollCard?.pollTitle.text = pollData["pollTitle"] as? String
                    let tim = Double(pollData["pollExpireOn"] as! String)! / 1000
                    cardsCell.pollCard?.pollExpireOnLabel.text = "Expires: " + tim.getDateandhours()

                    let data = pollData["pollOPtions"] as? String

                    if data != "" {
                        let oPtionsArray = data!.toJSON() as! NSArray

                        if (pollData["selectedChoice"] as! String) == "" {
                            cardsCell.pollCard?.numberOfVotes.isHidden = true
                            cardsCell.pollCard?.votesBG.isHidden = true

                        } else {
                            var count = 0
                            for option in oPtionsArray {
                                let opt = option as! [String: Any]
                                let vote = opt["numberOfVotes"] as? String
                                count = count + Int(vote!)!
                            }
                            cardsCell.pollCard?.numberOfVotes.isHidden = false
                            cardsCell.pollCard?.numberOfVotes.text = String(count)
                            //                                cardsCell.pollCard?.votesBG.isHidden = false
                            if count == 0 || count == 1 {
                                cardsCell.pollCard?.votesTextLabel.text = "Vote"
                            }
                        }

                        let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                        let opt2 = oPtionsArray.object(at: 1) as! [String: Any]

                        cardsCell.pollCard?.pollOptionOne.text = "1. \(opt1["choiceText"] as? String ?? "")"
                        cardsCell.pollCard?.pollOptionTwo.text = "2. \(opt2["choiceText"] as? String ?? "")"
                        if pollData["pollOPtions"] as? String == opt1["choiceId"] as? String {
                            cardsCell.pollCard?.select1.isHidden = false
                        } else if pollData["pollOPtions"] as? String == opt2["choiceId"] as? String {
                            cardsCell.pollCard?.select2.isHidden = false
                        }

                        if oPtionsArray.count > 2 {
                            if oPtionsArray.count == 3 {
                                let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                                if pollData["pollOPtions"] as? String == opt3["choiceId"] as? String {
                                    cardsCell.pollCard?.pollOptionOne.text = "2. \(opt2["choiceText"] as? String ?? "")"
                                    cardsCell.pollCard?.pollOptionTwo.text = "3. \(opt3["choiceText"] as? String ?? "")"
                                    cardsCell.pollCard?.select2.isHidden = false
                                }
                            } else if oPtionsArray.count == 4 {
                                let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                                let opt4 = oPtionsArray.object(at: 3) as! [String: Any]

                                if pollData["pollOPtions"] as? String == opt3["choiceId"] as? String {
                                    cardsCell.pollCard?.pollOptionOne.text = "3. \(opt3["choiceText"] as? String ?? "")"
                                    cardsCell.pollCard?.pollOptionTwo.text = "4. \(opt4["choiceText"] as? String ?? "")"
                                    cardsCell.pollCard?.select1.isHidden = false
                                } else if pollData["pollOPtions"] as? String == opt4["choiceId"] as? String {
                                    cardsCell.pollCard?.pollOptionOne.text = "3. \(opt3["choiceText"] as? String ?? "")"
                                    cardsCell.pollCard?.pollOptionTwo.text = "4. \(opt4["choiceText"] as? String ?? "")"
                                    cardsCell.pollCard?.select2.isHidden = false
                                }
                            }

                            cardsCell.pollCard?.moreOptions.text = "..."
                        } else {
                            cardsCell.pollCard?.moreOptions.text = "   "
                        }
                    } else {
                        getPollDataForIndexPath(index: indexPath, pollId: pollData["pollId"] as! String)
                    }

                    cardsCell.titleLabel.isHidden = false
                    cardsCell.imgIcon.isHidden = true
                    cardsCell.chaticon.isHidden = false

                    let time = Double(chatList.messageContext!.msgTimeStamp)! / 10_000_000
                    cardsCell.bottomTimeLabel.text = time.getTimeStringFromUTC()

                    cardsCell.chaticon.isUserInteractionEnabled = true
                    cardsCell.pollCard!.isUserInteractionEnabled = true

                    cardsCell.pollCard!.addGestureRecognizer(taptext)

                    cardsCell.messageCardStackView.addArrangedSubview(cardsCell.pollCard ?? cardsCell.messageCardStackView)
                    return cardsCell
                }

            } else if chatList.messageItem?.otherMessageType == otherMessageType.IMAGE_POLL {
                let pollString = chatList.messageItem?.message as! String

                if let pollData = self.convertJsonStringToDictionary(text: pollString) {
                    // MARK: image poll

                    cardsCell.cardViewType = VIEWTYPE.POLL_IMAGE_CARD
                    cardsCell.initializeViews()

                    if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                        cardsCell.imagePollCard?.topConstraint.constant = 4
                        cardsCell.imagePollCard?.bottomConstraint.constant = 20

                    } else {
                        cardsCell.imagePollCard?.topConstraint.constant = 10
                        cardsCell.imagePollCard?.bottomConstraint.constant = 10
                    }

                    cardsCell.imagePollCard?.pollTitle.text = pollData["pollTitle"] as? String
                    let tim = Double(pollData["pollExpireOn"] as! String)! / 1000
                    cardsCell.imagePollCard?.pollExpiresOn.text = "Expires: " + tim.getDateandhours()

                    let data = pollData["pollOPtions"] as? String

                    if data != "" {
                        let oPtionsArray = data!.toJSON() as! NSArray

                        let localData = chatList.messageItem?.localMediaPaths
                        if localData != "" {
                            let locimgData = convertJsonStringToDictionary(text: localData!) as NSDictionary?

                            if (pollData["selectedChoice"] as! String) == "" {
                                //                                    cardsCell.imagePollCard?.numberOfVotes.isHidden = true
                                //                                    cardsCell.imagePollCard?.votesBG.isHidden = true
                                //
                            } else {
                                var count = 0
                                for option in oPtionsArray {
                                    let opt = option as! [String: Any]
                                    let vote = opt["numberOfVotes"] as? String
                                    count = count + Int(vote!)!
                                }
                            }

                            let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                            let opt2 = oPtionsArray.object(at: 1) as! [String: Any]

                            let choiceId1 = opt1["choiceId"] as? String
                            let imgName1 = locimgData![choiceId1!]
                            let img1 = getImage(imageName: imgName1 as! String)
                            cardsCell.imagePollCard?.pollOptionOne.image = img1

                            let choiceId2 = opt2["choiceId"] as? String
                            let imgName2 = locimgData![choiceId2!]
                            let img2 = getImage(imageName: imgName2 as! String)
                            cardsCell.imagePollCard?.pollOptionTwo.image = img2

                            if (pollData["selectedChoice"] as! String) != "" {
                                if (pollData["selectedChoice"] as! String) == opt1["choiceId"] as! String {
                                    cardsCell.imagePollCard?.select1.isHidden = false
                                } else if (pollData["selectedChoice"] as! String) == opt2["choiceId"] as! String {
                                    cardsCell.imagePollCard?.select2.isHidden = false
                                }
                            }

                            cardsCell.imagePollCard?.pollOptionThree.image = nil
                            cardsCell.imagePollCard?.pollOptionFour.image = nil

                            cardsCell.imagePollCard?.pollOptionFour.extBorderWidth = 0
                            cardsCell.imagePollCard?.pollOptionThree.extBorderWidth = 0

                            if oPtionsArray.count == 3 {
                                let opt3 = oPtionsArray.object(at: 2) as! [String: Any]

                                let choiceId3 = opt3["choiceId"] as? String
                                let imgName3 = locimgData![choiceId3!]
                                let img3 = getImage(imageName: imgName3 as! String)
                                cardsCell.imagePollCard?.pollOptionThree.image = img3

                                cardsCell.imagePollCard?.pollOptionThree.isHidden = false
                                cardsCell.imagePollCard?.pollOptionThree.extBorderWidth = 1

                                if (pollData["selectedChoice"] as! String) != "" {
                                    if (pollData["selectedChoice"] as! String) == opt3["choiceId"] as! String {
                                        cardsCell.imagePollCard?.select3.isHidden = false
                                    }
                                }
                            }

                            if oPtionsArray.count == 4 {
                                cardsCell.imagePollCard?.pollOptionThree.isHidden = false
                                cardsCell.imagePollCard?.pollOptionFour.isHidden = false

                                cardsCell.imagePollCard?.pollOptionFour.extBorderWidth = 1
                                cardsCell.imagePollCard?.pollOptionThree.extBorderWidth = 1

                                let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                                let opt4 = oPtionsArray.object(at: 3) as! [String: Any]

                                let choiceId3 = opt3["choiceId"] as? String
                                let imgName3 = locimgData![choiceId3!]
                                let img3 = getImage(imageName: imgName3 as! String)
                                cardsCell.imagePollCard?.pollOptionThree.image = img3

                                let choiceId4 = opt4["choiceId"] as? String
                                let imgName4 = locimgData![choiceId4!]
                                let img4 = getImage(imageName: imgName4 as! String)
                                cardsCell.imagePollCard?.pollOptionFour.image = img4

                                if (pollData["selectedChoice"] as! String) != "" {
                                    if (pollData["selectedChoice"] as! String) == opt3["choiceId"] as! String {
                                        cardsCell.imagePollCard?.select3.isHidden = false
                                    } else if (pollData["selectedChoice"] as! String) == opt4["choiceId"] as! String {
                                        cardsCell.imagePollCard?.select4.isHidden = false
                                    }
                                }
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

                                        DatabaseManager.updateMessageTableForLocalImage(localImagePath: attachmentString, localId: chatList.messageContext!.localMessageId!)

                                        //                                           DatabaseManager.updatePollLocalDataOptions(localData: attachmentString, pollId: pollData.pollId)
                                        // get main thread and reload cell
                                        DispatchQueue.main.async { () in
                                            self.cardsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                                        }
                                    }

                                })
                            }
                        }
                    } else {
                        getPollDataForIndexPath(index: indexPath, pollId: pollData["pollId"] as! String)
                    }

                    let time = Double(chatList.messageContext!.msgTimeStamp)! / 10_000_000
                    cardsCell.bottomTimeLabel.text = time.getTimeStringFromUTC()

                    cardsCell.titleLabel.isHidden = false
                    cardsCell.imgIcon.isHidden = true
                    cardsCell.chaticon.isHidden = false

                    cardsCell.chaticon.isUserInteractionEnabled = true
                    cardsCell.imagePollCard!.isUserInteractionEnabled = true

                    cardsCell.imagePollCard!.addGestureRecognizer(taptext)

                    cardsCell.messageCardStackView.addArrangedSubview(cardsCell.imagePollCard ?? cardsCell.messageCardStackView)
                    return cardsCell
                }

            } else if chatList.messageItem?.otherMessageType == otherMessageType.INFO {
                // MARK: Info

                let headerCell = tableView.dequeueReusableCell(withIdentifier: "DayViewCell") as! DayViewCell
                headerCell.backgroundColor = UIColor.clear

                headerCell.dayButton.setTitle((chatList.messageItem?.messageTextString)!, for: .normal)
                headerCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
                headerCell.selectionStyle = .none

                return headerCell
            }
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}

    func getUserName(object: chatListObject) -> String {
        let chatlistObj = object

        var nameString: String = ""
        if (chatlistObj.messageContext?.isMine)! {
            nameString = "You"
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
        return nameString
    }

    @objc func onLongTap(_ sender: tableViewLongPress) {
        if messageTextField.isFirstResponder {
            messageTextField.resignFirstResponder()
        }

        print("Long press")
        if sender.mySection < datesArray.count {
            let buttonPosition: CGPoint = sender.location(in: cardsTableView)
            if let indexPath = self.cardsTableView.indexPathForRow(at: buttonPosition) {
                let tag = indexPath.row

                let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
                if tag < dayMessages.count {
                    if isCellSelected == true {
                        let cell = cardsTableView.cellForRow(at: currentSelectedIndex!)
                        cell!.backgroundColor = .clear
                    }
                    isCellSelected = true

                    selectedObject = dayMessages[tag] as! chatListObject
                    let indexPaths = indexPath
                    currentSelectedIndex = indexPaths
                    if let msgs = selectedObject.messageContext{
                        let time = Double(msgs.msgTimeStamp)! / 10_000_000
                        if time.isWithinFiveMins(){
                            unPublish = true
                        } else {
                            unPublish = false
                        }
                    }
                    
                    let cell = cardsTableView.cellForRow(at: indexPaths)
                    if cell != nil {
                        cell!.backgroundColor = COLOURS.chatSelectedColor
                    }
                    let type = selectedObject.messageContext?.messageType!
                    if type == messagetype.TEXT {
                        customNavigationBar(name: displayName!, image: displayImage, isSentMessage: selectedObject.messageContext?.isMine ?? false, showCopy: true)

                    } else {
                        customNavigationBar(name: displayName!, image: displayImage, isSentMessage: selectedObject.messageContext?.isMine ?? false, showCopy: false)
                    }
                }
            }
        }
    }

    func getMessageStatus(chatObj: chatListObject) -> UIImage {
        var image: UIImage?

        let seenMembers = chatObj.messageContext?.seenMembers
        let readMembers = chatObj.messageContext?.readMembers

        var seenMembersArray = seenMembers?.components(separatedBy: ",")
        var readMembersArray = readMembers?.components(separatedBy: ",")
        if seenMembersArray != nil || readMembersArray != nil {
            seenMembersArray = Array(Set(seenMembersArray!))
            readMembersArray = Array(Set(readMembersArray!))

            seenMembersArray?.remove(object: "")
            readMembersArray?.remove(object: "")

            let seenCOunt = seenMembersArray?.count
            let readCount = readMembersArray?.count

            var totalMemberCount = Int(chatObj.messageContext!.targetCount ?? "0")
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
            }
        } else {
            let msgContxt = chatObj.messageContext
            let msgState = msgContxt!.messageState as! messageState
            if msgState == messageState.SENDER_SENT {
                image = UIImage(named: "ic_sent_new")!

            } else if msgState == messageState.SENDER_UNSENT {
                image = UIImage(named: "ic_unsent")!
            }
        }

        return image!
    }

    func getDir() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let type = fileName.audiomediaFileName
        let fileURL = paths!.appendingPathComponent(type + "/")
        return fileURL
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
                            self.cardsTableView.reloadRows(at: [index], with: .none)
                        }
                    }
                }
            }
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
                if let loadedImage = load(attName: imageName) {
                    image = loadedImage
                    imageCache.setObject(image, forKey: imageName as AnyObject)
                }
            }
        }
        return image
    }
}

extension ACSpeakerCardsViewController: UITextViewDelegate {
    func textViewDidChange(_: UITextView) {
        let size = CGSize(width: messageTextField.frame.width, height: .infinity)
        let estimatedSize = messageTextField.sizeThatFits(size)
        textViewHC.constant = estimatedSize.height
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text.count > 0 {
//            hideMenu()
//        }

        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)

        if newText.count > 0 {
            showSendButton()
        } else {
            showcameraAudioButton()
        }

        guard let string = textView.text else { return true }
        let newLength = text.count + string.count - range.length
        if newLength <= 250 {
            return true
        } else {
            alert(message: "The maximum length for the text message has been reached.")
            return false
        }
    }
}

class tableViewtapGesturePress: UITapGestureRecognizer {
    var myRow: Int = 0
    var mySection: Int = 0
}

extension ACSpeakerCardsViewController : AddImageDelegate {
    func imageAdded() {
        userLocationData(clearChat: true)
    }
}
