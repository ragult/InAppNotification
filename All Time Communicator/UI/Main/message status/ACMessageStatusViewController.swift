//
//  ACMessageStatusViewController.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 09/04/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACMessageStatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet var messageView: UIStackView!
    @IBOutlet var messageTimeStamp: UILabel!
    @IBOutlet var backgroundViewForCustumViews: OutgoingMessegeViewHelperWhiteLayer!
    @IBOutlet var backgroundVIew: outGoingMessageHelperView!

    @IBOutlet var bottomSpaceConstraint: NSLayoutConstraint!

    @IBOutlet var topSPaceCOnstraint: NSLayoutConstraint!

    @IBOutlet var leadingCOnstraint: NSLayoutConstraint!

    @IBOutlet var messageDisplayView: UIView!
    @IBOutlet var whitebackgroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet var trailingConstraint: NSLayoutConstraint!
    @IBOutlet var seenStatusMessageView: UIImageView!

    @IBOutlet var groupsTableview: UITableView!

    var msgSTatusArray = [messageStatus]()
    var selectedObject = chatListObject()
    var groupTable = GroupTable()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        groupsTableview.register(UINib(nibName: "messageStatuscell", bundle: nil), forCellReuseIdentifier: "cell")

        let msgContext = selectedObject.messageContext
        let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
        messageTimeStamp.text = time.getTimeStringFromUTC()
        seenStatusMessageView.image = getMessageStatus(chatObj: selectedObject)

        setDataForView(chatList: selectedObject)
        groupsTableview.tableFooterView = UIView()
    }

    func getImage(imageName: String) -> UIImage {
        var image = UIImage()

        if imageName != "" {
            if let img = self.load(attName: imageName) {
                image = img
            }
        }
        return image
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
                text = "Video"
            }
            image = load(attName: (chatListObj.messageItem?.thumbnail)!)

        case messagetype.IMAGE:
            text = (chatListObj.messageItem?.messageTextString)!

            if text == "" {
                text = "Image"
            }
            image = load(attName: (chatListObj.messageItem?.message)! as! String)

        case messagetype.AUDIO:
            text = (chatListObj.messageItem?.messageTextString)!

            if text == "" {
                text = "Voice Recording"
            }
            image = UIImage(named: "microphone")

        case messagetype.OTHER:
            text = (chatListObj.messageItem?.messageTextString)!
            if text == "" {
                text = "Media"
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
            case otherMessageType.IMAGE_POLL:

                text = "Poll"
                image = UIImage(named: "poll")
                if let pollData = DatabaseManager.getPollDataForId(localPollId: chatListObj.messageItem?.message as! String) {
                    text = pollData.pollTitle
                }

            case otherMessageType.TEXT_POLL:

                text = "Poll"
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

    func setDataForView(chatList: chatListObject) {
        let msgContext = chatList.messageContext
        let type = chatList.messageItem?.messageType

        switch type! {
        case messagetype.TEXT:

            // MARK: messageType REPLY

            if chatList.messageContext?.action == useractionType.REPLY {
                if let CustomView = Bundle.main.loadNibNamed("ReplyToMessageView", owner: self, options: nil)?.first as? ReplyToMessageView {
                    CustomView.extDropShadow()
                    CustomView.messageSender.text = getUserName(object: chatList, isFromDisplay: true)
                    let dict = getImageForChatListObject(object: chatList, isFromDisplay: true)
                    CustomView.messageLabel.text = dict.value(forKey: "text") as? String
                    CustomView.imageView.image = dict.value(forKey: "image") as? UIImage

                    let commentLabel = PaddedLabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 20))
                    commentLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
                    commentLabel.lineBreakMode = .byClipping
                    commentLabel.numberOfLines = 0
                    commentLabel.text = "Hello there , All time! Hello there , All time! Hello there , All time!"
                    commentLabel.textAlignment = .left
                    commentLabel.textColor = .white
//                    self.backgroundViewForCustumViews.isHidden = true

                    commentLabel.textColor = .white
                    commentLabel.text = chatList.messageItem?.messageTextString

                    messageView.addArrangedSubview(CustomView)
                    messageView.addArrangedSubview(commentLabel)
                    commentLabel.padding = UIEdgeInsets(top: 12, left: 5, bottom: 5, right: 5)
                }

            } else {
                let txtMessageLabel = UILabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 20))
                txtMessageLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
                txtMessageLabel.lineBreakMode = .byWordWrapping
                txtMessageLabel.numberOfLines = 0
                txtMessageLabel.textAlignment = .left
                txtMessageLabel.textColor = .black

                txtMessageLabel.textColor = .white
                txtMessageLabel.text = selectedObject.messageItem?.messageTextString ?? ""
                messageView.addArrangedSubview(txtMessageLabel)
            }
        case messagetype.AUDIO:

            if let CustomView = Bundle.main.loadNibNamed("MusicPlayerView", owner: self, options: nil)?.first as? MusicPlayerView {
                messageView.addArrangedSubview(CustomView)

                CustomView.playButton.setImage(UIImage(named: "shape"), for: .normal)
                CustomView.playImage.image = UIImage(named: "nounAudio2112009Copy2")
                CustomView.songSlider.thumbTintColor = UIColor.white
                CustomView.songSlider.minimumTrackTintColor = UIColor.lightGray
                CustomView.songSlider.maximumTrackTintColor = UIColor.white
                CustomView.lblTime.textColor = UIColor.white
                CustomView.songSlider.setThumbImage(UIImage(named: "slider-white")!, for: .normal)
                CustomView.lblTime.isHidden = true
            }

        case messagetype.VIDEO:

            // MARK: messageType VIDEO

            let textMessageLabel = PaddedLabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 200))
            textMessageLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
            textMessageLabel.lineBreakMode = .byWordWrapping
            textMessageLabel.numberOfLines = 0
            textMessageLabel.textAlignment = .left
            textMessageLabel.textColor = .black
            textMessageLabel.text = "label"

            if let CustomView = Bundle.main.loadNibNamed("PhotosView", owner: self, options: nil)?.first as? PhotosView {
                CustomView.playButton.isHidden = false

                let imageName = chatList.messageItem?.thumbnail
                let image = getImage(imageName: imageName!)
                CustomView.Photo.image = image

                let attName = chatList.messageItem?.message as! String
                if attName == "" {
                    CustomView.playButton.setImage(UIImage(named: "download"), for: .normal)
                } else {
                    CustomView.playButton.setImage(UIImage(named: "ic_play"), for: .normal)
                }

                CustomView.activityView.isHidden = true
                CustomView.activityIndicatorView.stopAnimating()
//                self.whitebackgroundHeightConstraint.constant = 195

                messageView.addArrangedSubview(CustomView)
                if chatList.messageItem?.messageTextString != "" {
                    textMessageLabel.textColor = .white
                    textMessageLabel.text = chatList.messageItem?.messageTextString
                    messageView.addArrangedSubview(textMessageLabel)
                }
            }

        case messagetype.IMAGE:
            // for handling image

            let textMessageLabel = PaddedLabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 200))
            textMessageLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
            textMessageLabel.lineBreakMode = .byWordWrapping
            textMessageLabel.numberOfLines = 0
            textMessageLabel.textAlignment = .left
            textMessageLabel.textColor = .black
            textMessageLabel.text = "label"

            if let CustomView = Bundle.main.loadNibNamed("PhotosView", owner: self, options: nil)?.first as? PhotosView {
                CustomView.playButton.isHidden = true

                DispatchQueue.global(qos: .background).async {
                    let imageString = chatList.messageItem?.message as! String
                    let image = self.getImage(imageName: imageString)

                    DispatchQueue.main.async { () in
                        CustomView.Photo.image = image
                    }
                }

                messageView.addArrangedSubview(CustomView)

                if chatList.messageItem?.messageTextString != "" {
                    textMessageLabel.padding = UIEdgeInsets(top: 12, left: 5, bottom: 5, right: 5)

                    textMessageLabel.textColor = .white
                    textMessageLabel.text = chatList.messageItem?.messageTextString
                    messageView.addArrangedSubview(textMessageLabel)
                }
            }

        case messagetype.OTHER:
            let otherType = chatList.messageItem?.otherMessageType
            switch otherType! {
            case otherMessageType.MEDIA_ARRAY:
                // handling image
                if let CustomView = Bundle.main.loadNibNamed("ImageCollection", owner: self, options: nil)?.first as? ImageCollection {
                    let text = chatList.messageItem?.message as! String
                    DispatchQueue.global(qos: .background).async {
                        let image1: UIImage?
                        let image2: UIImage?
                        let image3: UIImage?
                        let image4: UIImage?
                        let images: NSArray!

                        if let json = self.convertJsonStringToDictionary(text: text) {
                            images = json["attachmentArray"] as? NSArray
                            let img1 = images[0] as! NSDictionary
                            let img2 = images[1] as! NSDictionary
                            let img3 = images[2] as! NSDictionary
                            let img4 = images[3] as! NSDictionary

                            if img1.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                                let imageString = img1.value(forKey: "thumbnail") as! String
                                let image = self.getImage(imageName: imageString)

                                image1 = image

                            } else {
                                let imageString = img1.value(forKey: "imageName") as! String
                                let image = self.getImage(imageName: imageString)

                                image1 = image
                            }

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

                            DispatchQueue.main.async { () in

                                CustomView.image1.image = image1
                                CustomView.image2.image = image2
                                CustomView.image3.image = image3
                                CustomView.image4.image = image4

                                let count = String(images.count - 4)
                                if count == "0" {
                                    CustomView.extraImageCount.isHidden = true
                                } else {
                                    CustomView.extraImageCount.isHidden = false
                                    CustomView.extraImageCount.text = "+" + count
                                }
                            }
                        }
                    }

                    let textMessageLabel = PaddedLabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 200))
                    textMessageLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
                    textMessageLabel.lineBreakMode = .byWordWrapping
                    textMessageLabel.numberOfLines = 0
                    textMessageLabel.textAlignment = .left
                    textMessageLabel.textColor = .black
                    textMessageLabel.text = "label"

//                   self.backgroundViewForCustumViews.isHidden = false
//                    self.whitebackgroundHeightConstraint.constant = 204

                    messageView.addArrangedSubview(CustomView)

                    if chatList.messageItem?.messageTextString != "" {
                        textMessageLabel.padding = UIEdgeInsets(top: 12, left: 5, bottom: 5, right: 5)

                        textMessageLabel.textColor = .white
                        textMessageLabel.text = (chatList.messageItem?.messageTextString)!
                        messageView.addArrangedSubview(textMessageLabel)
                    }
                }

            case otherMessageType.TEXT_POLL:

                if let pollData = DatabaseManager.getPollDataForId(localPollId: chatList.messageItem?.message as! String) {
                    // MARK: TEXT Poll

                    if let CustomView = Bundle.main.loadNibNamed("PollView", owner: self, options: nil)?.first as? PollView {
                        CustomView.pollTitle.text = pollData.pollTitle
                        let tim = Double(pollData.pollExpireOn)! / 10_000_000
                        CustomView.pollTime.text = tim.getDateandhours()

                        let count = pollData.numberOfOptions
                        if pollData.selectedChoice == "" {
                            CustomView.numberOfVotesForOptionOne.isHidden = true
                            CustomView.numberOfVotesForOptionTwo.isHidden = true
                            CustomView.numberOfVotesForOptionThree.isHidden = true
                            CustomView.numberOfVotesForOptionFour.isHidden = true

                            CustomView.pollOptionThreeCheckMark.isHidden = true
                            CustomView.pollOptionTwoCheckMark.isHidden = true
                            CustomView.pollOptionourCheckMark.isHidden = true
                            CustomView.pollOptionOneCheckMark.isHidden = true

                            CustomView.pollBtn.isHidden = true

                        } else {
                            CustomView.numberOfVotesForOptionOne.isHidden = false
                            CustomView.numberOfVotesForOptionTwo.isHidden = false
                            CustomView.numberOfVotesForOptionThree.isHidden = false
                            CustomView.numberOfVotesForOptionFour.isHidden = false

                            CustomView.pollBtn.isHidden = true
                        }

                        let data = pollData.pollOPtions
                        if data != "" {
                            let oPtionsArray = data.toJSON() as! NSArray

                            if count == 2 {
                                let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                                let opt2 = oPtionsArray.object(at: 1) as! [String: Any]

                                CustomView.pollOptionOneLabel.text = "1. \(opt1["choiceText"] as? String ?? "")"
                                CustomView.pollOptionTwoLabel.text = "2. \(opt2["choiceText"] as? String ?? "")"
                                CustomView.numberOfVotesForOptionOne.text = opt1["numberOfVotes"] as? String
                                CustomView.numberOfVotesForOptionTwo.text = opt2["numberOfVotes"] as? String

                                if pollData.selectedChoice != "" {
                                    if pollData.selectedChoice == opt1["choiceId"] as! String {
                                        CustomView.pollOptionOneCheckMark.isHidden = false
                                    } else {
                                        CustomView.pollOptionTwoCheckMark.isHidden = false
                                    }
                                }

                                CustomView.optionStack3.isHidden = true
                                CustomView.optionStack4.isHidden = true

                            } else if count == 3 {
                                let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                                let opt2 = oPtionsArray.object(at: 1) as! [String: Any]
                                let opt3 = oPtionsArray.object(at: 2) as! [String: Any]

                                CustomView.pollOptionOneLabel.text = "1. \(opt1["choiceText"] as? String ?? "")"
                                CustomView.pollOptionTwoLabel.text = "2. \(opt2["choiceText"] as? String ?? "")"
                                CustomView.pollOptionLabelThree.text = "3. \(opt3["choiceText"] as? String ?? "")"

                                CustomView.numberOfVotesForOptionOne.text = opt1["numberOfVotes"] as? String
                                CustomView.numberOfVotesForOptionTwo.text = opt2["numberOfVotes"] as? String
                                CustomView.numberOfVotesForOptionThree
                                    .text = opt3["numberOfVotes"] as? String
                                CustomView.optionStack4.isHidden = true

                                if pollData.selectedChoice != "" {
                                    if pollData.selectedChoice == opt1["choiceId"] as! String {
                                        CustomView.pollOptionOneCheckMark.isHidden = false
                                    } else if pollData.selectedChoice == opt2["choiceId"] as! String {
                                        CustomView.pollOptionTwoCheckMark.isHidden = false
                                    } else {
                                        CustomView.pollOptionThreeCheckMark.isHidden = false
                                    }
                                }

                            } else {
                                let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                                let opt2 = oPtionsArray.object(at: 1) as! [String: Any]
                                let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                                let opt4 = oPtionsArray.object(at: 3) as! [String: Any]

                                CustomView.pollOptionOneLabel.text = "1. \(opt1["choiceText"] as? String ?? "")"
                                CustomView.pollOptionTwoLabel.text = "2. \(opt2["choiceText"] as? String ?? "")"
                                CustomView.pollOptionLabelThree.text = "3. \(opt3["choiceText"] as? String ?? "")"
                                CustomView.pollOptionLabelFour.text = "4. \(opt4["choiceText"] as? String ?? "")"

                                CustomView.numberOfVotesForOptionOne.text = opt1["numberOfVotes"] as? String
                                CustomView.numberOfVotesForOptionTwo.text = opt2["numberOfVotes"] as? String
                                CustomView.numberOfVotesForOptionThree
                                    .text = opt3["numberOfVotes"] as? String

                                CustomView.numberOfVotesForOptionFour
                                    .text = opt4["numberOfVotes"] as? String

                                if pollData.selectedChoice != "" {
                                    if pollData.selectedChoice == opt1["choiceId"] as! String {
                                        CustomView.pollOptionOneCheckMark.isHidden = false
                                    } else if pollData.selectedChoice == opt2["choiceId"] as! String {
                                        CustomView.pollOptionTwoCheckMark.isHidden = false
                                    } else if pollData.selectedChoice == opt3["choiceId"] as! String {
                                        CustomView.pollOptionThreeCheckMark.isHidden = false
                                    } else {
                                        CustomView.pollOptionourCheckMark.isHidden = false
                                    }
                                }
                            }
                        }

                        //                            self.backgroundViewForCustumViews.isHidden = false
                        messageView.addArrangedSubview(CustomView)
                        //                            self.whitebackgroundHeightConstraint.constant = 0

                        if chatList.messageItem?.messageTextString != "" {
                            let textMessageLabel = PaddedLabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 200))
                            textMessageLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
                            textMessageLabel.lineBreakMode = .byWordWrapping
                            textMessageLabel.numberOfLines = 0
                            textMessageLabel.textAlignment = .left
                            textMessageLabel.textColor = .black
                            textMessageLabel.text = "label"

                            textMessageLabel.padding = UIEdgeInsets(top: 12, left: 5, bottom: 5, right: 5)

                            textMessageLabel.textColor = .white
                            textMessageLabel.text = (chatList.messageItem?.messageTextString)!
                            messageView.addArrangedSubview(textMessageLabel)
                        }
                    }
                }
            case otherMessageType.IMAGE_POLL:

                if let pollData = DatabaseManager.getPollDataForId(localPollId: chatList.messageItem?.message as! String) {
                    // MARK: Image Poll

                    if let CustomView = Bundle.main.loadNibNamed("PollwithImages", owner: self, options: nil)?.first as? PollwithImages {
                        CustomView.pollQuestion.text = pollData.pollTitle
                        let tim = Double(pollData.pollExpireOn)! / 10_000_000
                        CustomView.timeForPollLabel.text = tim.getDateandhours()
                        let count = pollData.numberOfOptions
                        if pollData.selectedChoice == "" {
                            CustomView.pollOptionOneVotes.isHidden = true
                            CustomView.pollOptionViewVotes.isHidden = true
                            CustomView.pollOptionThreeVotes.isHidden = true
                            CustomView.pollOptionFourVotes.isHidden = true

                            CustomView.image1Selected.isHidden = true
                            CustomView.image2Selected.isHidden = true
                            CustomView.image3Selected.isHidden = true
                            CustomView.image4Selected.isHidden = true

                            CustomView.pollImage1.isUserInteractionEnabled = true
                            CustomView.pollOptionTwo.isUserInteractionEnabled = true
                            CustomView.pollOptionThree.isUserInteractionEnabled = true
                            CustomView.pollOptionFour.isUserInteractionEnabled = true

                            CustomView.pollSubmit.isHidden = true

                        } else {
                            CustomView.image1Selected.isHidden = true
                            CustomView.image2Selected.isHidden = true
                            CustomView.image3Selected.isHidden = true
                            CustomView.image4Selected.isHidden = true

                            CustomView.pollOptionOneVotes.isHidden = false
                            CustomView.pollOptionViewVotes.isHidden = false

                            CustomView.pollSubmit.isHidden = true
                        }

                        let data = pollData.pollOPtions
                        if data != "" {
                            let oPtionsArray = data.toJSON() as! NSArray

                            let locData = pollData.localData
                            if locData != "" {
                                let locimgData = convertJsonStringToDictionary(text: locData) as NSDictionary?
                                if count == 2 {
                                    let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                                    let opt2 = oPtionsArray.object(at: 1) as! [String: Any]

                                    let choiceId1 = opt1["choiceId"] as? String
                                    let imgName1 = locimgData![choiceId1!]
                                    let img1 = getImage(imageName: imgName1 as! String)
                                    CustomView.pollImage1.image = img1

                                    let choiceId2 = opt2["choiceId"] as? String
                                    let imgName2 = locimgData![choiceId2!]
                                    let img2 = getImage(imageName: imgName2 as! String)
                                    CustomView.pollOptionTwo.image = img2

                                    CustomView.pollOptionOneVotes.text = opt1["numberOfVotes"] as? String
                                    CustomView.pollOptionViewVotes.text = opt2["numberOfVotes"] as? String

                                    if pollData.selectedChoice != "" {
                                        if pollData.selectedChoice == opt1["choiceId"] as! String {
                                            CustomView.image1Selected.isHidden = false
                                        } else {
                                            CustomView.image2Selected.isHidden = false
                                        }
                                    }
                                    CustomView.pollOptionThreeVotes.isHidden = true
                                    CustomView.pollOptionFourVotes.isHidden = true

                                    CustomView.BottomImageHeightConstraint.constant = 0

                                } else if count == 3 {
                                    let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                                    let opt2 = oPtionsArray.object(at: 1) as! [String: Any]
                                    let opt3 = oPtionsArray.object(at: 2) as! [String: Any]

                                    let choiceId1 = opt1["choiceId"] as? String
                                    let imgName1 = locimgData![choiceId1!]
                                    let img1 = getImage(imageName: imgName1 as! String)
                                    CustomView.pollImage1.image = img1

                                    let choiceId2 = opt2["choiceId"] as? String
                                    let imgName2 = locimgData![choiceId2!]
                                    let img2 = getImage(imageName: imgName2 as! String)
                                    CustomView.pollOptionTwo.image = img2

                                    let choiceId3 = opt3["choiceId"] as? String
                                    let imgName3 = locimgData![choiceId3!]
                                    let img3 = getImage(imageName: imgName3 as! String)
                                    CustomView.pollOptionThree.image = img3

                                    CustomView.pollOptionOneVotes.text = opt1["numberOfVotes"] as? String
                                    CustomView.pollOptionViewVotes.text = opt2["numberOfVotes"] as? String
                                    CustomView.pollOptionThreeVotes.text = opt3["numberOfVotes"] as? String

                                    if pollData.selectedChoice != "" {
                                        if pollData.selectedChoice == opt1["choiceId"] as! String {
                                            CustomView.image1Selected.isHidden = false
                                        } else if pollData.selectedChoice == opt2["choiceId"] as! String {
                                            CustomView.image2Selected.isHidden = false
                                        } else {
                                            CustomView.image3Selected.isHidden = false
                                        }
                                    }
                                    CustomView.pollOptionThreeVotes.isHidden = false
                                    CustomView.pollOptionFourVotes.isHidden = true

                                    CustomView.pollOptionFour.isHidden = true

                                } else {
                                    let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                                    let opt2 = oPtionsArray.object(at: 1) as! [String: Any]
                                    let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                                    let opt4 = oPtionsArray.object(at: 3) as! [String: Any]

                                    let choiceId1 = opt1["choiceId"] as? String
                                    let imgName1 = locimgData![choiceId1!]
                                    let img1 = getImage(imageName: imgName1 as! String)
                                    CustomView.pollImage1.image = img1

                                    let choiceId2 = opt2["choiceId"] as? String
                                    let imgName2 = locimgData![choiceId2!]
                                    let img2 = getImage(imageName: imgName2 as! String)
                                    CustomView.pollOptionTwo.image = img2

                                    let choiceId3 = opt3["choiceId"] as? String
                                    let imgName3 = locimgData![choiceId3!]
                                    let img3 = getImage(imageName: imgName3 as! String)
                                    CustomView.pollOptionThree.image = img3

                                    let choiceId4 = opt4["choiceId"] as? String
                                    let imgName4 = locimgData![choiceId4!]
                                    let img4 = getImage(imageName: imgName4 as! String)
                                    CustomView.pollOptionFour.image = img4

                                    CustomView.pollOptionOneVotes.text = opt1["numberOfVotes"] as? String
                                    CustomView.pollOptionViewVotes.text = opt2["numberOfVotes"] as? String
                                    CustomView.pollOptionThreeVotes.text = opt3["numberOfVotes"] as? String
                                    CustomView.pollOptionFourVotes.text = opt4["numberOfVotes"] as? String

                                    if pollData.selectedChoice != "" {
                                        if pollData.selectedChoice == opt1["choiceId"] as! String {
                                            CustomView.image1Selected.isHidden = false
                                        } else if pollData.selectedChoice == opt2["choiceId"] as! String {
                                            CustomView.image2Selected.isHidden = false
                                        } else if pollData.selectedChoice == opt3["choiceId"] as! String {
                                            CustomView.image3Selected.isHidden = false
                                        } else {
                                            CustomView.image4Selected.isHidden = false
                                        }
                                    }
                                    CustomView.pollOptionThreeVotes.isHidden = false
                                    CustomView.pollOptionFourVotes.isHidden = false
                                }
                            }
                        }

//                            self.backgroundViewForCustumViews.isHidden = false
                        messageView.addArrangedSubview(CustomView)
//                            self.whitebackgroundHeightConstraint.constant = 0

                        if chatList.messageItem?.messageTextString != "" {
                            let textMessageLabel = PaddedLabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 200))
                            textMessageLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 16)
                            textMessageLabel.lineBreakMode = .byWordWrapping
                            textMessageLabel.numberOfLines = 0
                            textMessageLabel.textAlignment = .left
                            textMessageLabel.textColor = .black
                            textMessageLabel.text = "label"

                            textMessageLabel.padding = UIEdgeInsets(top: 12, left: 5, bottom: 5, right: 5)

                            textMessageLabel.textColor = .white
                            textMessageLabel.text = (chatList.messageItem?.messageTextString)!
                            messageView.addArrangedSubview(textMessageLabel)
                        }
                    }
                }

            default:
                print("Error while fetching type of message \(String(describing: chatList.messageItem?.messageType?.rawValue))")
            }

        case .AUDIO:
            print("do nothing")
        }
    }

    override func viewWillAppear(_: Bool) {
//        let msg = DatabaseManager.getMessageIndex(globalMsgId: selectedObject.messageContext?.globalMsgId ?? "")
        let userID = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)
        let groupMembersList = DatabaseManager.getGroupMembers(globalGroupId: groupTable.id)
        let seenMembers = selectedObject.messageContext?.seenMembers
        let readMembers = selectedObject.messageContext?.readMembers

        var seenMembersArray = seenMembers?.components(separatedBy: ",")
        var readMembersArray = readMembers?.components(separatedBy: ",")
        if seenMembersArray != nil || readMembersArray != nil {
            seenMembersArray = Array(Set(seenMembersArray!))
            readMembersArray = Array(Set(readMembersArray!))

            seenMembersArray?.remove(object: "")
            readMembersArray?.remove(object: "")
        }

        for member in groupMembersList {
            let msgStatusObject = messageStatus()
            msgStatusObject.name = member.memberName

            if seenMembersArray != nil || readMembersArray != nil {
                if (seenMembersArray?.contains(member.groupMemberId))! {
                    msgStatusObject.messageSentState = UIImage(named: "lastSeen")!
                } else if (readMembersArray?.contains(member.groupMemberId))! {
                    msgStatusObject.messageSentState = UIImage(named: "lastDelivered")!
                }
            }
            if userID != member.globalUserId {
                msgSTatusArray.append(msgStatusObject)
            }
        }
        groupsTableview.reloadData()

        topSPaceCOnstraint.constant = messageDisplayView.frame.height + 2
        animate(duration: 0.2)
    }

    override func viewDidAppear(_: Bool) {
        topSPaceCOnstraint.constant = messageDisplayView.frame.height + 2
        animate(duration: 0.2)
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

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return msgSTatusArray.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupsTableview.dequeueReusableCell(withIdentifier: "cell") as! GroupTableviewCell

        cell.groupName.text = msgSTatusArray[indexPath.row].name
        cell.groupProfileImage.image = msgSTatusArray[indexPath.row].userImage
        cell.messageStatus.image = msgSTatusArray[indexPath.row].messageSentState

        cell.selectionStyle = .none
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let sectionOne = UIView(frame: CGRect(x: 0, y: 0, width: groupsTableview.frame.width, height: 48))
        sectionOne.layer.borderWidth = 1
        sectionOne.layer.borderColor = UIColor.lightGray.cgColor
        sectionOne.backgroundColor = .lightGray
        sectionOne.layer.borderWidth = 0.0

        sectionOne.backgroundColor = .white
        // title
        let headerTitle = UILabel(frame: CGRect(x: 25, y: 14, width: tableView.bounds.size.width, height: 20))
        headerTitle.text = "Delivery Status"
        headerTitle.textColor = .gray

        sectionOne.addSubview(headerTitle)
        return sectionOne
    }

    // we set a variable to hold the contentOffSet before scroll view scrolls
    var lastContentOffset: CGFloat = 0

    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }

    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if lastContentOffset < scrollView.contentOffset.y {
            topSPaceCOnstraint.constant = 50
            animate(duration: 0.2)

            // did move up
        } else if lastContentOffset > scrollView.contentOffset.y {
            // did move down
            topSPaceCOnstraint.constant = messageDisplayView.frame.height + 10
            animate(duration: 0.2)
        } else {
            // didn't move
        }
    }

    func animate(duration: Double) {
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

class messageStatus: NSObject {
    var name: String = ""
    var messageSentState: UIImage = UIImage(named: "ic_sent_new")!
    var userImage: UIImage = UIImage(named: "icon_DefaultMutual")!
}
