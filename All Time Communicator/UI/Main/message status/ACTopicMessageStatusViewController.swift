//
//  ACTopicMessageStatusViewController.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 18/05/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import AVKit
import UIKit

class ACTopicMessageStatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet var topSPaceCOnstraint: NSLayoutConstraint!

    @IBOutlet var messageDisplayView: UIView!

    @IBOutlet var BGView: UIView!
    @IBOutlet var messageCardStackView: UIStackView!

    @IBOutlet var bottomTimeLabel: UILabel!
    @IBOutlet var bottomTimelabelHeight: NSLayoutConstraint!

    @IBOutlet var messageStatusImageView: UIImageView!

    var cardViewType: String = ""
    var eventsCard: EventsView?
    var imageCard: imageViewAnnouncementCard?
    var joinGroupCard: InvitationToGroupCard?
    var pollCard: PollCardView?
    var imagePollCard: ImagePollCardView?
    var requestCardView: RequestView?
    var mediaArrayView: ImageMediaArrayView?
    var Audiocard: AudioCardView?
    var TextCard: TextCardView?

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
            case otherMessageType.TEXT_POLL:

                text = "Poll"
                image = UIImage(named: "poll")
                if let pollData = DatabaseManager.getPollDataForId(localPollId: chatListObj.messageItem?.message as! String) {
                    text = pollData.pollTitle
                }

            case otherMessageType.IMAGE_POLL:

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

    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    func getDir() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let type = fileName.audiomediaFileName
        let fileURL = paths!.appendingPathComponent(type + "/")
        return fileURL
    }

    func setDataForView(chatList: chatListObject) {
        BGView.dropLightShadow()
        BGView.extCornerRadius = 4

        bottomTimeLabel.isHidden = false
        bottomTimelabelHeight.constant = 21

        if chatList.messageContext?.isMine == true {
            messageStatusImageView.isHidden = false
            messageStatusImageView.image = getMessageStatus(chatObj: chatList)

            let msgcon = chatList.messageContext!
            if msgcon.messageType! != messagetype.TEXT {}
        } else {
            messageStatusImageView.isHidden = true
        }

        var msgCount = ""

//        let mArray = DatabaseManager.getUnreadMessagesFormessageIdOfspeakerGroup(channelId:  chatList.messageContext!.localChanelId!, replyMessageId: chatList.messageContext!.globalMsgId!)
//        if (mArray.count - 1) > 0 {
//            msgCount = String(mArray.count - 1)
//            self.titleLabel.text = "Discuss (" + msgCount + ")"
//            self.chaticon.image = UIImage(named: "chatFillColour")
//        }

        for view in messageCardStackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        let type = chatList.messageItem?.messageType
        switch type! {
        case messagetype.IMAGE:

            if let CustomView = Bundle.main.loadNibNamed("imageViewAnnouncementCard", owner: self, options: nil)?.first as? imageViewAnnouncementCard {
                imageCard?.extCornerRadius = 4
                imageCard = CustomView

                if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                    imageCard?.leftConstaint.constant = 10
                    imageCard?.rightConstaint.constant = 10
                    imageCard?.topConstraint.constant = 4
                    imageCard?.bottomConstraint.constant = 10
                } else {
                    imageCard?.leftConstaint.constant = 0
                    imageCard?.rightConstaint.constant = 0
                    imageCard?.topConstraint.constant = 0
                    imageCard?.bottomConstraint.constant = 0
                }

                DispatchQueue.global(qos: .background).async {
                    let imageName = chatList.messageItem?.message
                    let image = self.getImage(imageName: imageName! as! String)

                    DispatchQueue.main.async { () in
                        self.imageCard?.imageView.image = image
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
                                self.imageCard?.imageView.image = self.load(attName: (chatList.messageItem?.message)! as! String)
                            }

                        })
                    }
                }

                let msgContext = chatList.messageContext

                // get meesage time
                let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
                bottomTimeLabel.text = time.getTimeStringFromUTC()

                imageCard!.isUserInteractionEnabled = true

                imageCard?.imageTitle.text = ""
                imageCard?.imageComment?.text = chatList.messageItem?.messageTextString

                messageCardStackView.addArrangedSubview(imageCard ?? messageCardStackView)
            }

        case messagetype.VIDEO:

            if let CustomView = Bundle.main.loadNibNamed("imageViewAnnouncementCard", owner: self, options: nil)?.first as? imageViewAnnouncementCard {
                imageCard?.extCornerRadius = 4
                imageCard = CustomView

                if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                    imageCard?.leftConstaint.constant = 10
                    imageCard?.rightConstaint.constant = 10
                    imageCard?.topConstraint.constant = 4
                    imageCard?.bottomConstraint.constant = 10
                } else {
                    imageCard?.leftConstaint.constant = 0
                    imageCard?.rightConstaint.constant = 0
                    imageCard?.topConstraint.constant = 0
                    imageCard?.bottomConstraint.constant = 0
                }

                DispatchQueue.global(qos: .background).async {
                    let attName = chatList.messageItem?.thumbnail
                    let image = self.getImage(imageName: attName!)
                    DispatchQueue.main.async { () in
                        self.imageCard?.imageView.image = image
                    }
                }

                if chatList.messageItem?.thumbnail == "" {
                    let json = convertJsonStringToDictionary(text: (chatList.messageItem?.cloudReference)!)
                    let urlStr = json!["imgurl"]! as! String

                    let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: urlStr, refernce: (chatList.messageContext?.localMessageId)!, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

                    DispatchQueue.global(qos: .background).async {
                        ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                            DatabaseManager.updateMessageTableForOtherColoumn(imageData: path, localId: (chatList.messageContext?.localMessageId)!)

                            chatList.messageItem?.thumbnail = path
                            DispatchQueue.main.async { () in
                                self.imageCard?.imageView.image = self.load(attName: (chatList.messageItem?.thumbnail)!)
                            }

                        })
                    }
                }
                imageCard?.onClickOfPlayBtn.isHidden = false
                let attName = chatList.messageItem?.message as! String
                if attName == "" {
                    imageCard?.onClickOfPlayBtn.setImage(UIImage(named: "download"), for: .normal)
                } else {
                    imageCard?.onClickOfPlayBtn.setImage(UIImage(named: "ic_play"), for: .normal)
                }

                let msgContext = chatList.messageContext

                // get meesage time
                let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
                bottomTimeLabel.text = time.getTimeStringFromUTC()

                imageCard?.onClickOfPlayBtn.isUserInteractionEnabled = true

                imageCard?.imageTitle.text = ""
                imageCard?.imageComment?.text = chatList.messageItem?.messageTextString

                messageCardStackView.addArrangedSubview(imageCard ?? messageCardStackView)
            }

        case messagetype.TEXT:

            if let CustomView = Bundle.main.loadNibNamed("TextCardView", owner: self, options: nil)?.first as? TextCardView {
                TextCard = CustomView

                TextCard?.isUserInteractionEnabled = true

                if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                    TextCard?.leftConstaint.constant = 22
                    TextCard?.rightConstaint.constant = 22
                    TextCard?.topConstraint.constant = 0
                    TextCard?.bottomConstraint.constant = -8

                } else {
                    TextCard?.leftConstaint.constant = 22
                    TextCard?.rightConstaint.constant = 22
                    TextCard?.topConstraint.constant = 12
                    TextCard?.bottomConstraint.constant = -8
                }

                let msgContext = chatList.messageContext

                // get meesage time
                let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
                bottomTimeLabel.text = time.getTimeStringFromUTC()

                let str = chatList.messageItem?.message as! String
                if str == "" {
                    TextCard?.lblTitle.isHidden = true
                } else {
                    TextCard?.lblTitle.isHidden = false
                    TextCard?.lblTitle.text = str
                }

                TextCard?.lblText.text = chatList.messageItem!.messageTextString
                TextCard?.lblText.sizeToFit()

                messageCardStackView.addArrangedSubview(TextCard ?? messageCardStackView)
            }

        case messagetype.AUDIO:

            if let CustomView = Bundle.main.loadNibNamed("AudioCardView", owner: self, options: nil)?.first as? AudioCardView {
                Audiocard = CustomView

                if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                    Audiocard?.leftConstaint.constant = 10
                    Audiocard?.rightConstaint.constant = -10
                    Audiocard?.topConstraint.constant = 4
                    Audiocard?.bottomConstraint.constant = 10

                } else {
                    Audiocard?.leftConstaint.constant = 0
                    Audiocard?.rightConstaint.constant = 0
                    Audiocard?.topConstraint.constant = 0
                    Audiocard?.bottomConstraint.constant = 0
                }

                let msgContext = chatList.messageContext

                // get meesage time
                let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
                bottomTimeLabel.text = time.getTimeStringFromUTC()

                //            self.imageCard!.isUserInteractionEnabled = true

                //            self.imageCard!.addGestureRecognizer(taptext)

                let attName = chatList.messageItem?.message as? String
                let bundle = getDir().appendingPathComponent(attName!.appending(".m4a"))

                if FileManager.default.fileExists(atPath: bundle.path) {
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: bundle)
                        audioPlayer.delegate = self as? AVAudioPlayerDelegate

                        let gettime = NSString(format: "%.2f", audioPlayer.duration / 60) as String
                        Audiocard!.timeLabel.text = "\(gettime)"
                        Audiocard!.slider.minimumValue = Float(0)
                        Audiocard!.slider.maximumValue = Float(audioPlayer.duration)

                    } catch {
                        print("play(with name:), ", error.localizedDescription)
                    }

                } else {
                    Audiocard?.BtnPlay.setImage(UIImage(named: "download"), for: .normal)
                }
                Audiocard!.slider.setThumbImage(UIImage(named: "ovalCopy3")!, for: .normal)

                messageCardStackView.addArrangedSubview(Audiocard ?? messageCardStackView)
            }

        case messagetype.OTHER:
            if chatList.messageItem?.otherMessageType == otherMessageType.MEDIA_ARRAY {
                if let CustomView = Bundle.main.loadNibNamed("ImageMediaArrayView", owner: self, options: nil)?.first as? ImageMediaArrayView {
                    mediaArrayView = CustomView

                    if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                        mediaArrayView?.leftConstaint.constant = 10
                        mediaArrayView?.rightConstaint.constant = 10
                        mediaArrayView?.topConstraint.constant = 4
                        mediaArrayView?.bottomConstraint.constant = 10

                    } else {
                        mediaArrayView?.leftConstaint.constant = 0
                        mediaArrayView?.rightConstaint.constant = 0
                        mediaArrayView?.topConstraint.constant = 0
                        mediaArrayView?.bottomConstraint.constant = 0
                    }

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

//                            pollTap1.myRow = indexPath.row
//                            pollTap2.myRow = indexPath.row
//                            pollTap3.myRow = indexPath.row
//
//                            pollTap1.mySection = indexPath.section
//                            pollTap2.mySection = indexPath.section
//                            pollTap3.mySection = indexPath.section

                                pollTap1.selectedTag = 0
                                pollTap2.selectedTag = 1
                                pollTap3.selectedTag = 2

                                self.mediaArrayView?.imageView1.isUserInteractionEnabled = true
                                self.mediaArrayView?.imageView2.isUserInteractionEnabled = true
                                self.mediaArrayView?.imageView3.isUserInteractionEnabled = true

                                self.mediaArrayView?.imageView1.addGestureRecognizer(pollTap1)
                                self.mediaArrayView?.imageView2.addGestureRecognizer(pollTap2)
                                self.mediaArrayView?.imageView3.addGestureRecognizer(pollTap3)

                                self.mediaArrayView?.imageView1.image = image1
                                self.mediaArrayView?.imageView2.image = image2

                                if image3 == nil {
                                    self.mediaArrayView?.imageView3.isHidden = true
                                    self.mediaArrayView?.extraCountLabel.isHidden = true

                                } else {
                                    self.mediaArrayView?.imageView3.image = image3
                                    self.mediaArrayView?.imageView3.isHidden = false
                                    let count = String(images.count - 3)
                                    if count == "0" {
                                        self.mediaArrayView?.extraCountLabel.isHidden = true
                                    } else {
                                        self.mediaArrayView?.extraCountLabel.isHidden = false
                                        self.mediaArrayView?.extraCountLabel.text = "+" + count
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
//                                        self.cardsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                                        }
                                    }

                                })
                            }
                        }
                    }

                    let time = Double(chatList.messageContext!.msgTimeStamp)! / 10_000_000
                    bottomTimeLabel.text = time.getTimeStringFromUTC()

                    mediaArrayView!.isUserInteractionEnabled = true

                    //                self.mediaArrayView!.addGestureRecognizer(taptext)

                    mediaArrayView?.imageTitle.text = ""
                    mediaArrayView?.imageComment?.text = chatList.messageItem?.messageTextString

                    messageCardStackView.addArrangedSubview(mediaArrayView ?? messageCardStackView)
                }
            } else if chatList.messageItem?.otherMessageType == otherMessageType.TEXT_POLL {
                // MARK: Text Poll

                if let pollData = DatabaseManager.getPollDataForId(localPollId: chatList.messageItem?.message as! String) {
                    if let CustomView = Bundle.main.loadNibNamed("PollCardView", owner: self, options: nil)?.first as? PollCardView {
                        pollCard = CustomView

                        if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                            pollCard?.topConstraint.constant = 4
                            pollCard?.bottomConstraint.constant = 4

                        } else {
                            pollCard?.topConstraint.constant = 14
                            pollCard?.bottomConstraint.constant = 4
                        }

                        pollCard?.pollTitle.text = pollData.pollTitle
                        let tim = Double(pollData.pollExpireOn)! / 10_000_000
                        pollCard?.pollExpireOnLabel.text = "Expires: " + tim.getDateandhours()

                        let data = pollData.pollOPtions

                        if data != "" {
                            let oPtionsArray = data.toJSON() as! NSArray

                            if pollData.selectedChoice == "" {
                                pollCard?.numberOfVotes.isHidden = true
                                pollCard?.votesBG.isHidden = true

                            } else {
                                var count = 0
                                for option in oPtionsArray {
                                    let opt = option as! [String: Any]
                                    let vote = opt["numberOfVotes"] as? String
                                    count = count + Int(vote!)!
                                }
                                pollCard?.numberOfVotes.isHidden = false
                                pollCard?.numberOfVotes.text = String(count)
                                //                                self.pollCard?.votesBG.isHidden = false
                                if count == 0 || count == 1 {
                                    pollCard?.votesTextLabel.text = "Vote"
                                }
                            }

                            let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                            let opt2 = oPtionsArray.object(at: 1) as! [String: Any]

                            pollCard?.pollOptionOne.text = "1. \(opt1["choiceText"] as? String ?? "")"
                            pollCard?.pollOptionTwo.text = "2. \(opt2["choiceText"] as? String ?? "")"
                            if pollData.selectedChoice == opt1["choiceId"] as? String {
                                pollCard?.select1.isHidden = false
                            } else if pollData.selectedChoice == opt2["choiceId"] as? String {
                                pollCard?.select2.isHidden = false
                            }

                            if oPtionsArray.count > 2 {
                                if oPtionsArray.count == 3 {
                                    let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                                    if pollData.selectedChoice == opt3["choiceId"] as? String {
                                        pollCard?.pollOptionOne.text = "2. \(opt2["choiceText"] as? String ?? "")"
                                        pollCard?.pollOptionTwo.text = "3. \(opt3["choiceText"] as? String ?? "")"
                                        pollCard?.select2.isHidden = false
                                    }
                                } else if oPtionsArray.count == 4 {
                                    let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                                    let opt4 = oPtionsArray.object(at: 3) as! [String: Any]

                                    if pollData.selectedChoice == opt3["choiceId"] as? String {
                                        pollCard?.pollOptionOne.text = "3. \(opt3["choiceText"] as? String ?? "")"
                                        pollCard?.pollOptionTwo.text = "4. \(opt4["choiceText"] as? String ?? "")"
                                        pollCard?.select1.isHidden = false
                                    } else if pollData.selectedChoice == opt4["choiceId"] as? String {
                                        pollCard?.pollOptionOne.text = "3. \(opt3["choiceText"] as? String ?? "")"
                                        pollCard?.pollOptionTwo.text = "4. \(opt4["choiceText"] as? String ?? "")"
                                        pollCard?.select2.isHidden = false
                                    }
                                }

                                pollCard?.moreOptions.text = "..."
                            } else {
                                pollCard?.moreOptions.text = "   "
                            }
                        } else {
                            //                            self.getPollDataForIndexPath(index: indexPath, pollId: pollData.pollId)
                        }

                        let time = Double(chatList.messageContext!.msgTimeStamp)! / 10_000_000
                        bottomTimeLabel.text = time.getTimeStringFromUTC()

                        pollCard!.isUserInteractionEnabled = true

                        messageCardStackView.addArrangedSubview(pollCard ?? messageCardStackView)
                    }
                }

            } else if chatList.messageItem?.otherMessageType == otherMessageType.IMAGE_POLL {
                if let pollData = DatabaseManager.getPollDataForId(localPollId: chatList.messageItem?.message as! String) {
                    // MARK: image poll

                    if let CustomView = Bundle.main.loadNibNamed("ImagePollCardView", owner: self, options: nil)?.first as? ImagePollCardView {
                        imagePollCard = CustomView

                        if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                            imagePollCard?.topConstraint.constant = 4
                            imagePollCard?.bottomConstraint.constant = 20

                        } else {
                            imagePollCard?.topConstraint.constant = 10
                            imagePollCard?.bottomConstraint.constant = 10
                        }

                        imagePollCard?.pollTitle.text = pollData.pollTitle
                        let tim = Double(pollData.pollExpireOn)! / 10_000_000
                        imagePollCard?.pollExpiresOn.text = "Expires: " + tim.getDateandhours()

                        let data = pollData.pollOPtions

                        if data != "" {
                            let oPtionsArray = data.toJSON() as! NSArray

                            let localData = pollData.localData
                            if localData != "" {
                                let locimgData = convertJsonStringToDictionary(text: localData) as NSDictionary?

//                                if pollData.selectedChoice == "" {
//                                    self.imagePollCard?.numberOfVotes.isHidden = true
//                                    self.imagePollCard?.votesBG.isHidden = true
//
//                                } else {
//                                    var count = 0
//                                    for option in oPtionsArray {
//                                        let opt = option as! Dictionary<String, Any>
//                                        let vote = opt["numberOfVotes"] as? String
//                                        count = count + Int(vote!)!
//                                    }
//                                    self.imagePollCard?.numberOfVotes.text = String(count)
//
//                                    if count == 0 || count == 1  {
//                                        self.imagePollCard?.voteTextLabel.text = "Vote"
//                                    }
//                                    //                                self.imagePollCard?.numberOfVotes.isHidden = false
//                                    //                                self.imagePollCard?.votesBG.isHidden = false
//                                }

                                let opt1 = oPtionsArray.object(at: 0) as! [String: Any]
                                let opt2 = oPtionsArray.object(at: 1) as! [String: Any]

                                let choiceId1 = opt1["choiceId"] as? String
                                let imgName1 = locimgData![choiceId1!]
                                let img1 = getImage(imageName: imgName1 as! String)
                                imagePollCard?.pollOptionOne.image = img1

                                let choiceId2 = opt2["choiceId"] as? String
                                let imgName2 = locimgData![choiceId2!]
                                let img2 = getImage(imageName: imgName2 as! String)
                                imagePollCard?.pollOptionTwo.image = img2

                                if pollData.selectedChoice != "" {
                                    if pollData.selectedChoice == opt1["choiceId"] as! String {
                                        imagePollCard?.select1.isHidden = false
                                    } else if pollData.selectedChoice == opt2["choiceId"] as! String {
                                        imagePollCard?.select2.isHidden = false
                                    }
                                }

                                imagePollCard?.pollOptionThree.image = nil
                                imagePollCard?.pollOptionFour.image = nil

                                imagePollCard?.pollOptionFour.extBorderWidth = 0
                                imagePollCard?.pollOptionThree.extBorderWidth = 0

                                if oPtionsArray.count == 3 {
                                    let opt3 = oPtionsArray.object(at: 2) as! [String: Any]

                                    let choiceId3 = opt3["choiceId"] as? String
                                    let imgName3 = locimgData![choiceId3!]
                                    let img3 = getImage(imageName: imgName3 as! String)
                                    imagePollCard?.pollOptionThree.image = img3

                                    imagePollCard?.pollOptionThree.isHidden = false
                                    imagePollCard?.pollOptionThree.extBorderWidth = 1

                                    if pollData.selectedChoice != "" {
                                        if pollData.selectedChoice == opt3["choiceId"] as! String {
                                            imagePollCard?.select3.isHidden = false
                                        }
                                    }
                                }

                                if oPtionsArray.count == 4 {
                                    imagePollCard?.pollOptionThree.isHidden = false
                                    imagePollCard?.pollOptionFour.isHidden = false

                                    imagePollCard?.pollOptionFour.extBorderWidth = 1
                                    imagePollCard?.pollOptionThree.extBorderWidth = 1

                                    let opt3 = oPtionsArray.object(at: 2) as! [String: Any]
                                    let opt4 = oPtionsArray.object(at: 3) as! [String: Any]

                                    let choiceId3 = opt3["choiceId"] as? String
                                    let imgName3 = locimgData![choiceId3!]
                                    let img3 = getImage(imageName: imgName3 as! String)
                                    imagePollCard?.pollOptionThree.image = img3

                                    let choiceId4 = opt4["choiceId"] as? String
                                    let imgName4 = locimgData![choiceId4!]
                                    let img4 = getImage(imageName: imgName4 as! String)
                                    imagePollCard?.pollOptionFour.image = img4

                                    if pollData.selectedChoice != "" {
                                        if pollData.selectedChoice == opt3["choiceId"] as! String {
                                            imagePollCard?.select3.isHidden = false
                                        } else if pollData.selectedChoice == opt4["choiceId"] as! String {
                                            imagePollCard?.select4.isHidden = false
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

                                            // get main thread and reload cell
                                            DispatchQueue.main.async { () in
//                                                self.cardsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                                            }
                                        }

                                    })
                                }
                            }
                        } else {
//                            self.getPollDataForIndexPath(index: indexPath, pollId: pollData.pollId)
                        }

                        let time = Double(chatList.messageContext!.msgTimeStamp)! / 10_000_000
                        bottomTimeLabel.text = time.getTimeStringFromUTC()

                        imagePollCard!.isUserInteractionEnabled = true

//                        self.bottomStackView.addGestureRecognizer(tapComments)
//                        self.imagePollCard!.addGestureRecognizer(taptext)

                        messageCardStackView.addArrangedSubview(imagePollCard ?? messageCardStackView)
                    }
                }
            }
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
