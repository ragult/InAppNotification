//
//  HomeScreenViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 18/10/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import AVKit
import AXPhotoViewer
import Crashlytics
import GooglePlaces
import LocalAuthentication
import SwiftEventBus
import UIKit

class HomeScreenViewController: UIViewController, AXPhotosViewControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    // Reference Outlets
    var profileImages = ["image1", "image2", "image3", "image4", "image5", "image1", "image2", "image3", "image4", "image5"]
    var typeOfCards = ["0", "1", "2", "3", "5"]

    var searchBar = UISearchBar()

    @IBOutlet var searchBarIcon: UIBarButtonItem!

    @IBOutlet var profilebarIcon: UIBarButtonItem!

    @IBOutlet var homeTabBar: UITabBar!
    @IBOutlet var tabBarItem4: UITabBarItem!
    @IBOutlet var statusCollectionView: UICollectionView!
//    @IBOutlet weak var searchBar: UITextField!
    var channels = [ChannelDisplayObject]()
    var delegate = UIApplication.shared.delegate as? AppDelegate
    var messages = NSMutableDictionary()
    var messagesArray = [MessagesTable]()
    var datesArray = NSMutableArray()
    var getGlobeID: String?

    var isFromChatNotification: Bool!
    @IBOutlet var cardsTableView: UITableView!
    let imageCache = NSCache<AnyObject, AnyObject>()
    private let OTP_MAX_LENGTH = 4
    var selectedList = ChannelDisplayObject()
    var isViewActive: Bool = false
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()

    var isPlayingAudio = false
    var selectedAudioIndex = IndexPath()
    var playingAudioObject = chatListObject()
    var isTimerFirstTime = false
    var timer: Timer!
    var isReloadRequired = true

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.showsCancelButton = true

        showNavButtons()

        let image = UIImage(named: "alltimeWordGrey")
        navigationItem.titleView = UIImageView(image: image)
//        navigationItem.titleView?.tintColor = UIColor(r: 33, g: 140, b: 141)
        navigationItem.titleView?.tintColor = UIColor(r: 33, g: 140, b: 141)

        statusCollectionView.allowsSelection = true
        statusCollectionView.showsHorizontalScrollIndicator = false

        cardsTableView.register(UINib(nibName: "CardsTableViewCell", bundle: nil), forCellReuseIdentifier: "CardsTableViewCell")
        cardsTableView.register(UINib(nibName: "DayViewCell", bundle: nil), forCellReuseIdentifier: "DayViewCell")
        cardsTableView.separatorStyle = .none

        cardsTableView.estimatedRowHeight = 120
        cardsTableView.rowHeight = UITableView.automaticDimension
        cardsTableView.allowsSelection = false
        cardsTableView.separatorColor = COLOURS.TABLE_BACKGROUND_COLOUR
        cardsTableView.backgroundColor = COLOURS.TABLE_BACKGROUND_COLOUR

        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController!.tabBar.frame.height, right: 0)
        cardsTableView.contentInset = adjustForTabbarInsets
        cardsTableView.scrollIndicatorInsets = adjustForTabbarInsets

//        DatabaseManager.updateMemberUUID(phoneNumber: "919655653929", globalUserId: "45")

        // for new message received
        listenToEventBus()
    }


    func showSearchBar() {
        searchBar.alpha = 0
        navigationItem.titleView = searchBar
        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)

        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.alpha = 1
        }, completion: { _ in
            self.searchBar.becomeFirstResponder()
        })
    }

    func hideSearchBar() {
        showNavButtons()
        UIView.animate(withDuration: 0.3, animations: {
            let image = UIImage(named: "alltimeWordGrey")
            self.navigationItem.titleView = UIImageView(image: image)
            self.navigationItem.titleView?.tintColor = UIColor(r: 33, g: 140, b: 141)

        }, completion: { _ in

        })
    }

    func showNavButtons() {
        let addButton = UIBarButtonItem(image: UIImage(named: "contactTab"), style: .plain, target: self, action: #selector(onClickOfUserProfiles(_:)))
        addButton.tintColor = .lightGray
        navigationItem.leftBarButtonItems = [addButton]

        let rightButton = UIBarButtonItem(image: UIImage(named: "NavbarSearchIcon"), style: .plain, target: self, action: #selector(onClickSearch(_:)))
        rightButton.tintColor = .lightGray
        navigationItem.rightBarButtonItems = [rightButton]
    }

    // MARK: UISearchBarDelegate

    func searchBarCancelButtonClicked(_: UISearchBar) {
        hideSearchBar()
    }

    func listenToEventBus() {
        SwiftEventBus.onBackgroundThread(self, name: eventBusHandler.channelUpdated) { notification in

            let eventObj: eventObject = notification!.object as! eventObject
            let channel = eventObj.channelObject

            if self.isViewActive {
                if self.channels.contains(where: { $0.channelId == channel!.id }) {
                    // found
                    let results = self.channels.filter { $0.channelId == channel!.id }
                    if results.isEmpty == false {
                        if (channel?.channelType)! == channelType.ONE_ON_ONE_CHAT.rawValue || (channel?.channelType)! == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue || (channel?.channelType)! == channelType.GROUP_CHAT.rawValue || (channel?.channelType)! == channelType.ADHOC_CHAT.rawValue {
                            if channel?.channelStatus != "-1" {
                                self.channels.remove(object: results[0])
                                let channelObject = ChannelDisplayObject()

                                channelObject.channelId = channel!.id
                                channelObject.channelType = channel!.channelType
                                channelObject.unseenCount = channel!.unseenCount
                                channelObject.lastMessageIdOfChannel = channel!.lastSavedMsgid
                                channelObject.lastMessageTime = channel!.lastMsgTime
                                channelObject.lastSenderPhoneBookContactId = channel!.contactId
                                channelObject.globalChannelName = channel!.globalChannelName

                                DispatchQueue.main.async {
                                    DefaultSound.eventBusNewMessage()

                                    self.channels.insert(channelObject, at: 0)
                                    self.statusCollectionView.reloadData()
                                }
                            }
                        }
                    }

                } else {
                    if channel!.channelType < channelType.TOPIC_GROUP.rawValue {
                        let channelObject = ChannelDisplayObject()
                        channelObject.channelId = channel!.id
                        channelObject.channelType = channel!.channelType
                        channelObject.unseenCount = channel!.unseenCount
                        channelObject.lastMessageIdOfChannel = channel!.lastSavedMsgid
                        channelObject.lastMessageTime = channel!.lastMsgTime
                        channelObject.lastSenderPhoneBookContactId = channel!.contactId
                        channelObject.globalChannelName = channel!.globalChannelName

                        DefaultSound.eventBusNewMessage()

                        self.channels.insert(channelObject, at: 0)
                    } else {
                        DefaultSound.newBroadcastMessage()
                        self.getDataForCards()
                    }
                }
                DispatchQueue.main.async {
                    self.statusCollectionView.reloadData()
                }
            }
        }
    }

    override func viewWillAppear(_: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.showNoNotificatons
        isViewActive = true
        getChannelDetails()
        if isReloadRequired {
            getDataForCards()
        } else {
            isReloadRequired = true
        }
    }

    override func viewWillDisappear(_: Bool) {
        isViewActive = false
    }

    @objc func onClickSearch(_: Any) {
        showSearchView()
//        self.showSearchBar()
    }

    func getDataForCards() {
        let yesterday = Date.yesterday
        let lastTime = "\(yesterday.timeIntervalSince1970 * 10_000_000)"
        messagesArray = DatabaseManager.getMessagesForHomeScreenNotifications(timestamp: lastTime)!

        if messages.count < 6 {
            messagesArray = DatabaseManager.getRecentMessagesForHomeScreenNotifications()!
        }
        messages = ChatMessageProcessor.processMessage(messageObjectArray: messagesArray)

        let filArray = (messages.allKeys as NSArray).descendingArrayWithData()

        datesArray = filArray

        DispatchQueue.main.async {
            self.cardsTableView.reloadData()
        }
    }

    @objc func goToComments(_ recognizer: UIGestureRecognizer) {
        print("go to speaker groups")
        let position: CGPoint = recognizer.location(in: cardsTableView)
        let indexPath: NSIndexPath = cardsTableView.indexPathForRow(at: position)! as NSIndexPath
        print(indexPath.row)
        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray

        let chatList = dayMessages[indexPath.row] as! chatListObject

        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACSpeakerCardsViewController") as? ACSpeakerCardsViewController {
            if let navigator = navigationController {
                nextViewController.hidesBottomBarWhenPushed = true

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
                    nextViewController.groupType = (groupTable?.groupType)!
                }
                nextViewController.channelId = chatList.messageContext?.localChanelId
                nextViewController.channelDetails = channelTableList
                nextViewController.isViewFirstTime = true
                nextViewController.isViewFirstTimeLoaded = true

                nextViewController.customNavigationBar(name: channelTableList.channelDisplayNames, image: channelTableList.channelImageUrl)
                nextViewController.displayName = channelTableList.channelDisplayNames
                let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
                navigator.navigationBar.tintColor = color3
                navigator.pushViewController(nextViewController, animated: true)
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
                let total = Float((audioPlayer.duration / 60) / 2)
                let start = Float(0)

                cell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", start, total) as String
                cell.Audiocard?.BtnPlay.setImage(UIImage(named: "group8"), for: .normal)

                if indexPath as IndexPath != selectedAudioIndex {
                    let cell = cardsTableView.cellForRow(at: indexPath as IndexPath) as! CardsTableViewCell
                    playingAudioObject = chatList
                    selectedAudioIndex = indexPath as IndexPath
                    cell.Audiocard!.slider.value = Float(0)
                    let total = Float((audioPlayer.duration / 60) / 2)
                    cell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", start, total) as String
                    cell.Audiocard?.BtnPlay.setImage(UIImage(named: "group8No"), for: .normal)

                    if isTimerFirstTime == false {
                        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayTimer), userInfo: nil, repeats: true)
                        isTimerFirstTime = true
                    }
                    isPlayingAudio = true
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
            } else {
                let cell = cardsTableView.cellForRow(at: indexPath as IndexPath) as! CardsTableViewCell
                playingAudioObject = chatList
                selectedAudioIndex = indexPath as IndexPath
                cell.Audiocard!.slider.value = Float(0)
                let total = Float((audioPlayer.duration / 60) / 2)
                let start = Float(0)

                cell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", start, total) as String
                cell.Audiocard?.BtnPlay.setImage(UIImage(named: "group8No"), for: .normal)

                if isTimerFirstTime == false {
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayTimer), userInfo: nil, repeats: true)
                    isTimerFirstTime = true
                }
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
                isPlayingAudio = true
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
//            recorder.isPlaying = false
        }
    }

    @objc func moveSlide(sender: UISlider) {
        if isPlayingAudio {
            if audioPlayer.isPlaying {
                audioPlayer.currentTime = TimeInterval(sender.value)

                let total = Float(audioPlayer.duration / 60)
                let current_time = Float(audioPlayer.currentTime / 60)

                let cell = cardsTableView.cellForRow(at: selectedAudioIndex) as! CardsTableViewCell

                cell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", current_time, total) as String

                if !audioPlayer.isPlaying {
                    cell.Audiocard?.BtnPlay.setImage(UIImage(named: "group8"), for: .normal)
                    cell.Audiocard!.slider.setValue(Float(0), animated: true)
                }
            }
        }
    }

    @objc func goToDiscuss(_ sender: UIButton) {
        print("go to stories")
        let rows = sender.tag
        let sections = sender.superview?.tag

        let dayMessages = messages.value(forKey: datesArray.object(at: sections!) as! String) as! NSMutableArray

        let chatList = dayMessages[rows] as! chatListObject

        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
            if let navigator = navigationController {
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
                //                        nextViewController.loadTableViewData(chnlDetails: channelTableList)

                nextViewController.customNavigationBar(name: channelTableList.channelDisplayNames, image: channelTableList.channelImageUrl, channelTyp: channelType(rawValue: channelTableList.channelType)!)
                nextViewController.displayName = channelTableList.channelDisplayNames
                nextViewController.displayImage = channelTableList.channelImageUrl
                nextViewController.isViewFirstTime = true

                nextViewController.isViewFirstTimeLoaded = true
                nextViewController.hidesBottomBarWhenPushed = true
                nextViewController.navigationController?.navigationBar.isHidden = true
                let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
                navigator.navigationBar.tintColor = color3

                nextViewController.channelDetails = channelTableList
                nextViewController.topicId = (chatList.messageContext?.globalMsgId)!
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    @objc func goToStories(_ recognizer: UIGestureRecognizer) {
        print("go to stories")
        let position: CGPoint = recognizer.location(in: cardsTableView)
        let indexPath: NSIndexPath = cardsTableView.indexPathForRow(at: position)! as NSIndexPath
        print(indexPath.row)

        let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray

        let chatList = dayMessages[indexPath.row] as! chatListObject
        let type = chatList.messageItem?.messageType

        switch type! {
        case messagetype.IMAGE:
            let imgData = chatList.messageItem?.message
            let count = 1
            let imageText = chatList.messageItem?.messageTextString
//            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "imagePreviewViewController") as? imagePreviewViewController  {
//                nextViewController.imagesData = imgData
//                nextViewController.imagesCount = count
//                nextViewController.imageText = imageText
//
//                self.present(nextViewController, animated: true, completion:nil)
//            }

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
            isReloadRequired = false
            present(photosViewController, animated: true)

        case messagetype.AUDIO:
//            let imgData = chatList.messageItem?.message
//            let recorder = KAudioRecorder.shared
//            recorder.play(name: imgData as! String)

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
                isReloadRequired = false

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
                    isReloadRequired = false

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

                            let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
                            navigator.navigationBar.tintColor = color3

                            isReloadRequired = false

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

                            let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
                            isReloadRequired = false

                            navigator.navigationBar.tintColor = color3
                            navigator.pushViewController(nextViewController, animated: true)
                        }
                    }
                }
            }
        case .TEXT:
            print("TEXT")
        }
    }

    @objc func onClickOfUserProfiles(_: Any) {
        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "ACProfileViewController") as? ACProfileViewController
        nextViewController?.pUser = DatabaseManager.getSelfContactDetails()!
        nextViewController?.isSelf = true
        present(nextViewController!, animated: true, completion: nil)
    }

    func getChannelDetails() {
        let channelList = DatabaseManager.fetchChannelForHome()
        channels.removeAll()
        if channelList != nil {
            for channel in channelList! {
                let channelObject = ChannelDisplayObject()
                channelObject.channelId = channel.id
                channelObject.channelType = channel.channelType
                channelObject.unseenCount = channel.unseenCount
                channelObject.lastMessageIdOfChannel = channel.lastSavedMsgid
                channelObject.lastMessageTime = channel.lastMsgTime
                channelObject.lastSenderPhoneBookContactId = channel.contactId
                channelObject.globalChannelName = channel.globalChannelName
                channels.append(channelObject)
            }
        }
        statusCollectionView.reloadData()
    }

    @IBAction func QRButtonAction(_: Any) {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "QRViewController") as? QRViewController {
            nextViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }

    func getGroupNameForMessage(message: ACMessageContextObject) -> GroupTable {
        let group = GroupTable()
        if let channel = DatabaseManager.getChannelIndexbyMessage(contactId: message.localChanelId!, channelType: message.channelType!.rawValue) {
            if let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channel.contactId) {
                return groupTable
            } else {
                return group
            }
        } else {
            return group
        }
    }

    func getImage(imageName: String) -> UIImage {
        var image = UIImage()
        if let cachedimage = self.imageCache.object(forKey: imageName as AnyObject) as? UIImage {
            image = cachedimage
        } else {
            if imageName != "" {
                image = load(attName: imageName)!
                imageCache.setObject(image, forKey: imageName as AnyObject)
            }
        }
        return image
    }

    var searchView = ACSearchView()
    func showSearchView() {
        searchView = Bundle.main.loadNibNamed("ACSearchView", owner: self, options: nil)?[0] as! ACSearchView
        searchView.frame = CGRect(x: 0, y: 0, width: delegate!.window!.frame.width, height: delegate!.window!.frame.height)

        searchView.selectCityBtn.addTarget(self, action: #selector(onClickOfSelectCity(_:)), for: .touchUpInside)
        searchView.openCitySearch.addTarget(self, action: #selector(onClickOfSelectCity(_:)), for: .touchUpInside)

        searchView.selectCityTF.isHidden = true

        searchView.resultTableview.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")

        searchView.resultTableview.register(UINib(nibName: "DayViewCell", bundle: nil), forCellReuseIdentifier: "DayViewCell")

        searchView.groupSearch.delegate = self
        searchView.resultTableview.tableFooterView = UIView()
        searchView.resultTableview.isHidden = false

        if let city = UserDefaults.standard.string(forKey: "usercity") {
            if let cityid = UserDefaults.standard.string(forKey: "usercityid") {
                searchView.selectCityTF.text = city
                searchView.searchView.isHidden = false
                searchView.cityView.isHidden = false

                searchView.changeLabel.isHidden = false
                searchView.selectCityTF.isHidden = false
                searchView.nocityView.isHidden = true

                searchView.cityBackButton.setImage(UIImage(named: "location-1"), for: .normal)
                searchView.backButton.addTarget(self, action: #selector(closeSearchButton(_:)), for: .touchUpInside)

            } else {
                searchView.searchView.isHidden = true
                searchView.changeLabel.isHidden = true
                searchView.selectCityTF.isHidden = true
                searchView.nocityView.isHidden = false
                searchView.cityView.isHidden = true

                searchView.cityBackButton.setImage(UIImage(named: "rightBackButton"), for: .normal)
                searchView.cityBackButton.addTarget(self, action: #selector(closeSearchButton(_:)), for: .touchUpInside)
            }

        } else {
            searchView.searchView.isHidden = true
            searchView.changeLabel.isHidden = true
            searchView.selectCityTF.isHidden = true
            searchView.nocityView.isHidden = false
            searchView.cityView.isHidden = true

            searchView.cityBackButton.setImage(UIImage(named: "rightBackButton"), for: .normal)
            searchView.cityBackButton.addTarget(self, action: #selector(closeSearchButton(_:)), for: .touchUpInside)
        }

        searchView.bringSubviewToFront(searchView.selectCityBtn)

        delegate!.window!.addSubview(searchView)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString _: String) -> Bool {
        searchLocationBasedOnKeyword(keywird: textField.text!)

        return true
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        if searchView.groupSearch.text!.count >= 6 {
            searchLocationBasedOnCode(keywird: searchView.groupSearch.text!)
        }
        searchView.groupSearch.resignFirstResponder()

        return true
    }

    var searchResult = [ACSearchResult]()
    func searchLocationBasedOnKeyword(keywird: String) {
        let requestModel = GroupSearch()
        requestModel.auth = DefaultDataProcessor().getAuthDetails()
        requestModel.keyword = keywird
        requestModel.cityId = UserDefaults.standard.string(forKey: "usercityid")!

        NetworkingManager.searchByName(getGroupModel: requestModel) { (result: Any, sucess: Bool) in
            if let result = result as? GroupNameSearchResponse, sucess {
                if result.status == "Success" {
                    let data = result.data
                    self.searchResult = [ACSearchResult]()
                    for res in data! {
                        let search = ACSearchResult()

                        search.groupId = res.groupId ?? ""
                        search.groupName = res.groupName ?? ""
                        search.address = res.address ?? ""
                        search.groupPublicId = res.groupPublicId ?? ""
                        search.thumbnailUrl = res.fullImageUrl ?? ""
                        search.fullImageUrl = res.fullImageUrl ?? ""
                        search.groupDescription = res.desc ?? ""
                        self.searchResult.append(search)
                    }

                    self.searchView.resultTableview.isHidden = false

                    self.searchView.resultTableview.reloadData()
                } else {
                    self.searchView.resultTableview.isHidden = true
                }
            }
        }
    }

    func searchLocationBasedOnCode(keywird: String) {
        let requestModel = GroupCodeSearch()
        requestModel.auth = DefaultDataProcessor().getAuthDetails()
        requestModel.groupCode = keywird

        NetworkingManager.searchByKeyword(getGroupModel: requestModel) { (result: Any, sucess: Bool) in
            if let result = result as? GroupCodeSearchResponse, sucess {
                if result.status == "Success" {
                    let data = result.data
                    self.searchResult = [ACSearchResult]()
                    for res in data! {
                        let search = ACSearchResult()

                        search.groupId = res.groupId ?? ""
                        search.groupName = res.groupName ?? ""
                        search.fullImageUrl = res.fullImageUrl ?? ""
                        search.thumbnailUrl = res.fullImageUrl ?? ""
                        search.groupType = res.groupType ?? ""
                        search.groupPublicId = res.groupPublicId ?? ""
                        search.groupDescription = res.groupDescription ?? ""

                        self.searchResult.append(search)
                    }

                    self.searchView.resultTableview.isHidden = false

                    self.searchView.resultTableview.reloadData()
                } else {
                    self.searchView.resultTableview.isHidden = true
                }
            }
        }
    }

     func GetPublicGroupDetails(publicGroupId: String, address : String) {
        let requestModel = GetPublicGroupRequestModel()
        requestModel.publicGroupId = publicGroupId
        requestModel.auth = DefaultDataProcessor().getAuthDetails()
        
        NetworkingManager.getPublicGroup(getGroupModel: requestModel) { (result: Any, sucess: Bool) in
            if let result = result as? GetPublicGroupResponseModel, sucess {
                if result.status == "Success" {
                    self.showSearchResultView(groupMember: result.data!, address: address)
                } else {}
            }
        }
    }

    @objc func onClickOfSelectCity(_: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.country = "IN"
        filter.type = .city
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
//        self.navigationController?.pushViewController(autocompleteController, animated: true)
        present(autocompleteController, animated: true, completion: nil)
        searchView.removeFromSuperview()
    }

    @objc func closeSearchButton(_ sender: UIButton) {
        print("\(sender)")
        searchView.removeFromSuperview()
    }

    @objc func onClickCloseGroupView() {
        searchResultView.removeFromSuperview()
    }
    
    var selectedGroupPublicId = ""
    @objc func onClickOfJoinGroup(_: UIButton) {
        Loader.show()
        let addGroupmembers = JoinGroupMemberRequest()

        addGroupmembers.auth = DefaultDataProcessor().getAuthDetails()
        addGroupmembers.publicGroupId = selectedGroupPublicId

        NetworkingManager.joinGroupMember(addGroupMemberModel: addGroupmembers) { (result: Any, sucess: Bool) in

            if let result = result as? AddGroupMemberResponse, sucess {
                print(result)
                let status = result.status ?? ""
                Loader.close()
                if status == "Success"{
                    if result.successMsg[1] == "No valid users to add. Possibility of attempted duplicate record addition"{
                        self.alert(message: "No valid users to add. Possibility of attempted duplicate record addition")
                        return
                    }
                }
                
                let dataToProcess = ACFeedProcessorObjectClass()
            
                let dataDict: NSDictionary = result.data?.toDictionary() as! NSDictionary
                dataToProcess.checkTypeOfDataReceived(dataDictionary: dataDict)
                if status != "Exception" {
                    let alert = UIAlertController(title: "", message: "Group list is updated", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                        self.onClickCloseGroupView()
                    }))
                    self.present(alert, animated: true, completion: nil)
                    Loader.close()
                    self.searchResultView.joinButton.setTitle("Joined", for: .normal)
                    self.searchResultView.joinButton.isUserInteractionEnabled = false
                }
            }
        }
    }

    var searchResultView = ACSearchResultView()

    func showSearchResultView(groupMember: PublicGroupModel, address : String) {
        searchResultView = Bundle.main.loadNibNamed("ACSearchResultView", owner: self, options: nil)?[0] as! ACSearchResultView
        searchResultView.frame = CGRect(x: 0, y: 0, width: delegate!.window!.frame.width, height: delegate!.window!.frame.height)
        searchResultView.joinButton.isUserInteractionEnabled = true
        searchResultView.closeButton.isUserInteractionEnabled = true
        searchResultView.closeButton.addTarget(self, action: #selector(onClickCloseGroupView), for: .touchUpInside)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tap))  //Tap function will call when user tap on button
//        searchResultView.closeButton.addGestureRecognizer(tapGesture)
        searchResultView.joinButton.addTarget(self, action: #selector(onClickOfJoinGroup(_:)), for: .touchUpInside)
        searchResultView.joinButton.setTitle("Connect", for: .normal)
//        //Create Attachment
//                  let imageAttachment =  NSTextAttachment()
//                  imageAttachment.image = UIImage(named:"groupIcon")
//
//                  //Set bound to reposition
//                  let imageOffsetY:CGFloat = -5.0;
//                  imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
//                  //Create string with attachment
//                  let attachmentString = NSAttributedString(attachment: imageAttachment)
//                  //Initialize mutable string
//                  let completeText = NSMutableAttributedString(string: groupMember.totalMembers! + " Members")
//                  //Add image to mutable string
//                  completeText.append(attachmentString)
//                  //Add your text to mutable string
//                  let  textAfterIcon = NSMutableAttributedString(string: "Using attachment.bounds!")
//                  completeText.append(textAfterIcon)
//                  searchResultView.membersCountLabel.textAlignment = .center;
//                  searchResultView.membersCountLabel.attributedText = completeText;
        searchResultView.membersCountLabel.text = groupMember.totalMembers! + " Members"
        searchResultView.groupNameLabel.text = groupMember.name!
        if address == ""{
            searchResultView.addressStack.isHidden = true
        }else {
            searchResultView.addressStack.isHidden = false
            searchResultView.address.text = address
        }
        if groupMember.groupdescription == "" {
            searchResultView.descripStack.isHidden = true
        } else {
            searchResultView.descripStack.isHidden = false
            searchResultView.groupDescription.text = groupMember.groupdescription
        }
        if let smallImageUrl = groupMember.thumbnailUrl {
            searchResultView.groupSmallImage.loadWithUrl(url: smallImageUrl)
        }
        if let imageUrl = groupMember.fullImageUrl {
            searchResultView.groupImage.loadWithUrl(url: imageUrl)
        }
        selectedGroupPublicId = groupMember.groupPublicId!
        var count = -1
        for member in groupMember.members! {
            count = count + 1
            let groupMember = Bundle.main.loadNibNamed("GroupMemberListView", owner: self, options: nil)?[0] as! GroupMemberListView
            groupMember.tag = count
//            groupMember.groupMemName.text = member.name
            let imageName = member.thumbUrl
            let image = getImage(imageName: imageName!)
            groupMember.groupMemberProfileImage.image = image

            groupMember.memberTitle.text = member.memberTitle
//            groupMember.groupMemName.text = member.name
//            searchResultView.memberStack.addArrangedSubview(groupMember)
        }

        delegate!.window!.addSubview(searchResultView)
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
}

extension HomeScreenViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return channels.count + 1
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = statusCollectionView.dequeueReusableCell(withReuseIdentifier: "HomeScreenCollectionViewCell", for: indexPath) as! HomeScreenCollectionViewCell
        if indexPath.row == channels.count {
            cell.setStartChat()
        } else {
            cell.setChannelData(channelTableList: channels[indexPath.row], indexPath: indexPath, saveToDisk: { indexPath, url, id in
                self.downLoadImagesforIndexPath(index: indexPath, downloadImage: url, groupId: id)
            }) { indexPath, confidentialFlag in
                self.channels[indexPath.row].isConfidential = confidentialFlag
            }

            if channels[indexPath.row].channelImageUrl != "" {
                cell.avatarImage.image = load(attName: channels[indexPath.row].channelImageUrl)
            }
        }
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == channels.count {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ContactsViewController") as? ContactsViewController {
                if let navigator = navigationController {
                    let backItem = UIBarButtonItem()
                    backItem.title = "Contacts"
                    navigationItem.backBarButtonItem = backItem
                    nextViewController.hidesBottomBarWhenPushed = true
                    navigator.pushViewController(nextViewController, animated: true)
                }
            }
        } else {
            if channels[indexPath.row].isConfidential == "1" {
                selectedList = channels[indexPath.row]

                showPinView()

            } else {
                let channelTableList = channels[indexPath.row]
                goToNextView(channelTableList: channelTableList)
            }
            print(indexPath.row)
        }
    }

    func goToNextView(channelTableList: ChannelDisplayObject, isConfidential: Bool = false) {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
            if let navigator = navigationController {
                nextViewController.hidesBottomBarWhenPushed = true
                nextViewController.navigationController?.navigationBar.isHidden = true

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
                nextViewController.getIsConfidential = isConfidential

                nextViewController.channelDetails = channelTableList
                let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
                navigator.navigationBar.tintColor = color3
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    func downLoadImagesforIndexPath(index: IndexPath, downloadImage: String, groupId: String) {
        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: downloadImage, refernce: groupId, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

        DispatchQueue.global(qos: .background).async {
            ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in

                DatabaseManager.updateGroupLocalImagePath(localImagePath: path, localId: success.refernce)

                self.channels[index.row].channelImageUrl = path
                DispatchQueue.main.async { () in
                    self.statusCollectionView.reloadItems(at: [index])
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
                    self.statusCollectionView.reloadItems(at: [index])
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
                    self.statusCollectionView.reloadItems(at: [index])
                }

            })
        }
    }
}

extension HomeScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == searchView.resultTableview {
            return 1
        } else {
            if datesArray.count > 4 {
                return 4
            } else {
                return datesArray.count
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchView.resultTableview {
            return searchResult.count
        } else {
            if datesArray.count == 0 {
                return 0
            } else {
                let dateMsgArray = messages.value(forKey: datesArray.object(at: section) as! String) as! NSMutableArray
                return dateMsgArray.count
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView != searchView.resultTableview {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "DayViewCell") as! DayViewCell
            headerCell.backgroundColor = UIColor.clear
            let date = datesArray.object(at: section) as! String
            headerCell.dayButton.setTitle(date.checkIfTodayOrYesterday(), for: .normal)
//            headerCell.dayButton.backgroundColor = tableView.backgroundColor!.withAlphaComponent(0.75)

            //        headerCell.dayButton.setTitleColor(COLOURS.APP_MEDIUM_GREEN_COLOR, for: .normal)
            headerCell.dayButton.setTitleColor(.darkGray, for: .normal)

            return headerCell
        } else {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "DayViewCell") as! DayViewCell
            headerCell.backgroundColor = UIColor.clear
            headerCell.dayButton.setTitle("Search Results", for: .normal)
//            headerCell.dayButton.backgroundColor = tableView.backgroundColor!.withAlphaComponent(0.75)

            //        headerCell.dayButton.setTitleColor(COLOURS.APP_MEDIUM_GREEN_COLOR, for: .normal)
            headerCell.dayButton.setTitleColor(.darkGray, for: .normal)

            return headerCell
        }
    }

//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 36
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchView.resultTableview {
            let cell = searchView.resultTableview.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
            cell.groupName.text = searchResult[indexPath.row].groupName
            cell.selectionStyle = .none
            if searchResult[indexPath.row].thumbnailUrl == "" {
                cell.groupProfileImage.isHidden = true
            } else {
                cell.groupProfileImage.loadWithUrl(url: searchResult[indexPath.row].thumbnailUrl)
                cell.groupProfileImage.isHidden = false
            }

            if searchResult[indexPath.row].address == "" {
                cell.createdByAndDate.text = searchResult[indexPath.row].groupDescription
            } else {
                cell.createdByAndDate.text = searchResult[indexPath.row].address
            }
            return cell

        } else {
            let cardsCell = cardsTableView.dequeueReusableCell(withIdentifier: "CardsTableViewCell", for: indexPath) as! CardsTableViewCell
            let cell = UITableViewCell()
            cell.backgroundColor = COLOURS.TABLE_BACKGROUND_COLOUR
            cardsCell.backgroundColor = COLOURS.TABLE_BACKGROUND_COLOUR
            cardsCell.activityView.isHidden = true

            cardsCell.BGView.extCornerRadius = 4
            let tapComments = tableViewtapGesturePress(target: self, action: #selector(goToComments(_:)))
            let taptext = tableViewtapGesturePress(target: self, action: #selector(goToStories(_:)))
            tapComments.myRow = indexPath.row
            taptext.myRow = indexPath.row
            tapComments.mySection = indexPath.section
            taptext.mySection = indexPath.section

            let dayMessages = messages.value(forKey: datesArray.object(at: indexPath.section) as! String) as! NSMutableArray
            let chatList = dayMessages[indexPath.row] as! chatListObject

            cardsCell.chaticon.isHidden = true
            cardsCell.lblcount.isHidden = true
            cardsCell.titleLabel.isUserInteractionEnabled = true
            let group = getGroupNameForMessage(message: chatList.messageContext!)
            cardsCell.titleLabel.text = group.groupName
            //        cardsCell.backgroundColor = .red
            if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                let name = getUserName(object: chatList)
                cardsCell.nameLabel.text = name + ":"
                cardsCell.discussButton.tag = indexPath.row
                cardsCell.discussButton.superview?.tag = indexPath.section
                cardsCell.discussButton.addTarget(self, action: #selector(goToDiscuss(_:)), for: .touchUpInside)
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

            } else {
                cardsCell.topStackHeight.constant = 0
                cardsCell.topStackView.isHidden = true
            }

            if group.fullImageUrl == "" {
                cardsCell.imgIcon.image = UIImage(named: "icon_DefaultGroup")
            } else {
                if group.localImagePath == "" {
                    let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: group.fullImageUrl, refernce: group.id, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

                    DispatchQueue.global(qos: .background).async {
                        ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                            DatabaseManager.updateGroupLocalImagePath(localImagePath: path, localId: group.id)

                            group.localImagePath = path
                            DispatchQueue.main.async { () in
                                cardsCell.imgIcon.image = self.load(attName: group.localImagePath)
                            }

                        })
                    }
                } else {
                    cardsCell.imgIcon.image = load(attName: group.localImagePath)
                }
            }

            cardsCell.imgIcon.layer.cornerRadius = cardsCell.imgIcon.frame.height / 2
            cardsCell.imgIcon.layer.masksToBounds = true

            let type = chatList.messageItem?.messageType
            switch type! {
            case messagetype.TEXT:
                //            for view in cardsCell.messageCardStackView.arrangedSubviews {
                //                view.removeFromSuperview()
                //            }
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

                cardsCell.TextCard?.isUserInteractionEnabled = true

                cardsCell.bottomStackView.addGestureRecognizer(tapComments)
                cardsCell.TextCard?.addGestureRecognizer(taptext)

                let msgContext = chatList.messageContext

                // get meesage time
                let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
                cardsCell.timeLabel.text = time.getTimeStringFromUTC()

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

                if chatList.messageItem!.messageTextString.count < 100 {
                    cardsCell.TextCard?.emptyMsg.isHidden = false
                } else {
                    cardsCell.TextCard?.emptyMsg.isHidden = true
                }

                cardsCell.messageCardStackView.addArrangedSubview(cardsCell.TextCard ?? cardsCell.messageCardStackView)
                //            cardsCell.messageCardStackView.addArrangedSubview(textMessageLabel)
                return cardsCell

            case messagetype.IMAGE:
                cardsCell.cardViewType = VIEWTYPE.IMAGE_CARD
                cardsCell.initializeViews()

                if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                    cardsCell.imageCard?.leftConstaint.constant = 10
                    cardsCell.imageCard?.rightConstaint.constant = 10
                    cardsCell.imageCard?.topConstraint.constant = 6
                    cardsCell.imageCard?.bottomConstraint.constant = 4

                } else {
                    cardsCell.imageCard?.leftConstaint.constant = 0
                    cardsCell.imageCard?.rightConstaint.constant = 0
                    cardsCell.imageCard?.topConstraint.constant = 0
                    cardsCell.imageCard?.bottomConstraint.constant = 0
                }
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
                            }

                        })
                    }
                }

                let msgContext = chatList.messageContext

                // get meesage time
                let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
                cardsCell.timeLabel.text = time.getTimeStringFromUTC()

                cardsCell.imageCard!.isUserInteractionEnabled = true

                cardsCell.bottomStackView.addGestureRecognizer(tapComments)
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
                    cardsCell.imageCard?.topConstraint.constant = 6
                    cardsCell.imageCard?.bottomConstraint.constant = 4

                } else {
                    cardsCell.imageCard?.leftConstaint.constant = 0
                    cardsCell.imageCard?.rightConstaint.constant = 0
                    cardsCell.imageCard?.topConstraint.constant = 0
                    cardsCell.imageCard?.bottomConstraint.constant = 0
                }

                DispatchQueue.global(qos: .background).async {
                    let attName = chatList.messageItem?.thumbnail
                    let image = self.getImage(imageName: attName!)
                    DispatchQueue.main.async { () in
                        cardsCell.imageCard?.imageView.image = image
                        cardsCell.imageCard?.imageView.clipsToBounds = true
                    }
                }

                if chatList.messageItem?.thumbnail == "" {
                    // addObject TO Array
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
                let msgContext = chatList.messageContext

                // get meesage time
                let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
                cardsCell.timeLabel.text = time.getTimeStringFromUTC()

                cardsCell.imageCard?.onClickOfPlayBtn.isUserInteractionEnabled = true

                cardsCell.bottomStackView.addGestureRecognizer(tapComments)
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
                    cardsCell.Audiocard?.bottomConstraint.constant = 4

                } else {
                    cardsCell.Audiocard?.leftConstaint.constant = 0
                    cardsCell.Audiocard?.rightConstaint.constant = 0
                    cardsCell.Audiocard?.topConstraint.constant = 0
                    cardsCell.Audiocard?.bottomConstraint.constant = 0
                }

                //
                //            if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                //                cardsCell.messageStackviewLeadingAnchor.constant = 10
                //                cardsCell.messageStackviewTrailingAnchor.constant = 10
                //                cardsCell.messageStackviewTopAnchor.constant = 6
                //
                //            }
                //
                let msgContext = chatList.messageContext

                let time = Double(msgContext!.msgTimeStamp)! / 10_000_000
                cardsCell.timeLabel.text = time.getTimeStringFromUTC()

                cardsCell.bottomStackView.addGestureRecognizer(tapComments)

                let chatList = dayMessages[indexPath.row] as! chatListObject
                let attName = chatList.messageItem?.message as? String
                let bundle = getDir().appendingPathComponent(attName!.appending(".m4a"))
                cardsCell.Audiocard!.slider.setThumbImage(UIImage(named: "ovalCopy3")!, for: .normal)
                cardsCell.Audiocard!.slider.minimumValue = Float(0)

                if FileManager.default.fileExists(atPath: bundle.path) {
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: bundle)
                        audioPlayer.delegate = self as? AVAudioPlayerDelegate
                        let start = Float(0)

                        let total = Float((audioPlayer.duration / 60) / 2)
                        cardsCell.Audiocard!.timeLabel.text = NSString(format: "%.2f/%.2f", start, total) as String

                        //                    let gettime = NSString(format: "%.2f", (audioPlayer.duration/60)) as String
                        //                    cardsCell.Audiocard!.timeLabel.text = "\(gettime)"
                        cardsCell.Audiocard!.slider.minimumValue = Float(0)
                        cardsCell.Audiocard!.slider.maximumValue = Float(audioPlayer.duration)
                        cardsCell.Audiocard?.BtnPlay.setImage(UIImage(named: "ic_play"), for: .normal)

                    } catch {
                        print("play(with name:), ", error.localizedDescription)
                    }

                } else {
                    cardsCell.Audiocard?.BtnPlay.setImage(UIImage(named: "download"), for: .normal)
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
                    // MARK: media Array

                    cardsCell.chaticon.isHidden = true
                    cardsCell.lblcount.isHidden = true
                    cardsCell.cardViewType = VIEWTYPE.MEDIA_ARRAY
                    cardsCell.initializeViews()

                    if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                        cardsCell.mediaArrayView?.leftConstaint.constant = 10
                        cardsCell.mediaArrayView?.rightConstaint.constant = 10
                        cardsCell.mediaArrayView?.topConstraint.constant = 4
                        cardsCell.mediaArrayView?.bottomConstraint.constant = 4
                    }

                    //                if chatList.messageContext?.channelType! == channelType.TOPIC_GROUP {
                    //                    cardsCell.messageStackviewLeadingAnchor.constant = 10
                    //                    cardsCell.messageStackviewTrailingAnchor.constant = 10
                    //                    cardsCell.messageStackviewTopAnchor.constant = 6
                    //                }

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

                                pollTap1.addTarget(self, action: #selector(HomeScreenViewController.onTapOfMediaArray(sender:)))
                                pollTap2.addTarget(self, action: #selector(HomeScreenViewController.onTapOfMediaArray(sender:)))
                                pollTap3.addTarget(self, action: #selector(HomeScreenViewController.onTapOfMediaArray(sender:)))

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
                            //                        let images = json!["mediaArray"] as! NSArray
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
                    cardsCell.timeLabel.text = time.getTimeStringFromUTC()

                    cardsCell.mediaArrayView!.isUserInteractionEnabled = true

                    cardsCell.bottomStackView.addGestureRecognizer(tapComments)
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

                        cardsCell.chaticon.isHidden = true
                        cardsCell.lblcount.isHidden = true

                        let time = Double(chatList.messageContext!.msgTimeStamp)! / 10_000_000
                        cardsCell.timeLabel.text = time.getTimeStringFromUTC()

                        cardsCell.pollCard!.isUserInteractionEnabled = true

                        cardsCell.bottomStackView.addGestureRecognizer(tapComments)
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
                            cardsCell.imagePollCard?.bottomConstraint.constant = 5

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

                        cardsCell.chaticon.isHidden = true
                        cardsCell.lblcount.isHidden = true

                        let time = Double(chatList.messageContext!.msgTimeStamp)! / 10_000_000
                        cardsCell.timeLabel.text = time.getTimeStringFromUTC()

                        cardsCell.imagePollCard!.isUserInteractionEnabled = true

                        cardsCell.bottomStackView.addGestureRecognizer(tapComments)
                        cardsCell.imagePollCard!.addGestureRecognizer(taptext)

                        cardsCell.messageCardStackView.addArrangedSubview(cardsCell.imagePollCard ?? cardsCell.messageCardStackView)
                        return cardsCell
                    }
                }
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchView.resultTableview {
            searchView.groupSearch.resignFirstResponder()
            if DatabaseManager.checkGroupExsists(publicGroupId: searchResult[indexPath.row].groupPublicId){
                if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "groupDetailsViewController") as? groupDetailsViewController {
                    if let navigator = navigationController {
                        nextViewController.hidesBottomBarWhenPushed = true
                        let groupTable = DatabaseManager.getGroupTableWith(publicGroupId: searchResult[indexPath.row].groupPublicId)
                        nextViewController.groupDetails = groupTable!
//                        nextViewController.datadelegate = self
//                        nextViewController.photoChangedelegate = self
                        nextViewController.channelName = searchResult[indexPath.row].groupName
                        navigator.pushViewController(nextViewController, animated: true)
                        searchView.removeFromSuperview()
                    }
                }
            } else {
                GetPublicGroupDetails(publicGroupId: searchResult[indexPath.row].groupPublicId, address : searchResult[indexPath.row].address)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        if tableView == searchView.resultTableview {
            return 70
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        if tableView == searchView.resultTableview {
            return 0
        } else {
            return 28
        }
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

    func getDir() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let type = fileName.audiomediaFileName
        let fileURL = paths!.appendingPathComponent(type + "/")
        return fileURL
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
            isReloadRequired = false

            present(photosViewController, animated: true)
        }
    }

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
}

// MARK: - Alerts

extension HomeScreenViewController {
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

extension HomeScreenViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")

        UserDefaults.standard.setValue(place.name, forKey: "usercity")
        UserDefaults.standard.setValue(place.placeID, forKey: "usercityid")

        showSearchView()
        dismiss(animated: true, completion: nil)
    }

    func viewController(_: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        showSearchView()
        print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_: GMSAutocompleteViewController) {
        showSearchView()

        dismiss(animated: true, completion: nil)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
