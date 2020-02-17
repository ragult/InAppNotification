//
//  AppDelegate.swift
//  alltimecommunicator
//
//  Created by Droid5 on 22/08/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import Crashlytics
import Fabric
import FacebookCore
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import InsideAppNotification
import IQKeyboardManagerSwift
import PubNub
import SwiftEventBus
import UIKit
import UserNotifications
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var initialViewController: UIViewController?
    var client: PubNub!
//    var config : PNConfiguration!
//
//    private var pubNubPublishKey: String = UserDefaults.standard.string(forKey: UserKeys.serverPubNubPublish) ?? ""
//    private var pubNubSubscribeKey: String =  UserDefaults.standard.string(forKey: UserKeys.serverPubNubSubscribe) ?? ""

    //    dev
//    private var pubNubPublishKey: String = "pub-c-1ea1da33-7f88-4cae-9b98-2162d9dfccf2"
//    private var pubNubSubscribeKey: String = "sub-c-e5fbf750-4fb9-11e9-bc27-728c10c631fc"

//
    // playground
//    private var pubNubSubscribeKey: String = "sub-c-244373c2-38df-11e9-9010-ca52b265d058"
//    private var pubNubPublishKey: String = "pub-c-ae72470e-171f-4df1-a1b7-283e3cac0ad7"

    var userId: String = ""
    var isFromAttachmentView: attachmentType = attachmentType.TEXT
    var attachmentArray: [MediaUploadObject] = []
    var attachmentData: Any?
    var attachId: String?

    var isInternetAvailable: Bool = true
    var displayLabel: UILabel!
    var contactsClass = ACContactsProcessor()
    var currentChannelId: String = ""
    var notificationStatus: NotificationEnum = NotificationEnum.ShowAllNotifications
    var appIsStarting = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        KeyManager.clear()

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardAppearance = .default
        IQKeyboardManager.shared.shouldPlayInputClicks = true
        DatabaseManager.initDatabase(application: application)
        createCustomFolders()
        InternetHandlerClass.sharedInstance.observeReachability()

        let user = UserDefaults.standard.string(forKey: UserKeys.userGlobalId) ?? ""
        GMSPlacesClient.provideAPIKey("AIzaSyA-RXgPPr5pvhI2Yfk8DyToyiPG9tU-NH4")
        GMSServices.provideAPIKey("AIzaSyA-RXgPPr5pvhI2Yfk8DyToyiPG9tU-NH4")

//        DatabaseManager.deleteGroupTable()
//        DatabaseManager.deleteChannelTable()
//        DatabaseManager.deleteGroupMembersTable()
//        DatabaseManager.deleteMessagesTable()
//
//        DatabaseManager.deleteContactsTable()

//        let index = DatabaseManager.storeSelfConatct(profileTable: user!)
//        UserDefaults.standard.set(index, forKey: UserKeys.userContactIndex)

        Fabric.with([Crashlytics.self])

        window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryBoard = UIStoryboard(name: "OnBoarding", bundle: nil)

        if user == "" {
            initialViewController = mainStoryBoard.instantiateViewController(withIdentifier: "ViewController")
        } else {
            initialViewController = mainStoryBoard.instantiateViewController(withIdentifier: "HomeTabBarController")

            subscribeToPubNub()
        }

        if (launchOptions?[.remoteNotification] as? [String: AnyObject]) != nil {
            // If your app wasn’t running and the user launches it by tapping the push notification, the push notification is passed to your app in the launchOptions

            UIApplication.shared.applicationIconBadgeNumber = 0
            let center = UNUserNotificationCenter.current()
            center.removeAllDeliveredNotifications() // To remove all delivered notifications
            center.removeAllDeliveredNotifications() // To remove all delivered notifications
        }

        registerForPushNotifications()

        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        return true
    }

    func subscribeToPubNub() {
        let pubNubPublishKey: String = UserDefaults.standard.string(forKey: UserKeys.serverPubNubPublish) ?? ""
        let pubNubSubscribeKey: String = UserDefaults.standard.string(forKey: UserKeys.serverPubNubSubscribe) ?? ""

        let userGlobalId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)

        let configuration = PNConfiguration(publishKey: pubNubPublishKey, subscribeKey: pubNubSubscribeKey)
        configuration.uuid = userGlobalId!
        configuration.authKey = UserDefaults.standard.string(forKey: UserKeys.pubnubAccessKey)
//        configuration.TLSEnabled = true
        client = PubNub.clientWithConfiguration(configuration)
        client.addListener(self)
        client.subscribeToChannelGroups([userGlobalId! + "-INB"], withPresence: false)
        userId = userGlobalId!

        client.logger.enabled = true
        let version = PubNub.information().version
        print("pubnub Version: ", version)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let str = url.absoluteString
        if str.contains("fb") {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
        } else {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
//            return GIDSignIn.sharedInstance()!.handle(url as URL?, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        appIsStarting = false
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        appIsStarting = false
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.\
        appIsStarting = true
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        if !self.isInternetAvailable {
//            self.showAlertForNoInternet()
//        }
        let user = UserDefaults.standard.string(forKey: UserKeys.userGlobalId) ?? ""
        if user != "" {
            checkActiveUsers()
            DispatchQueue.main.async {
                ACPubnubClass().getHistoryChannels()
                BroadcastDataProcessor().getLastMessageIdForGroups()
            }
        }
        appIsStarting = false
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func checkActiveUsers() {
        let contactsFromDB = DatabaseManager.getAppContacts()
        let contactsArr = NSMutableArray()
        for contact in contactsFromDB! {
            contactsArr.add(contact.globalUserId)
        }

        let findMemberModel = ActiveNumberSearch()

        findMemberModel.auth = DefaultDataProcessor().getAuthDetails()
        findMemberModel.globalUserId = contactsArr.mutableCopy() as! NSArray

        NetworkingManager.activeUsersSearch(activeNumbers: findMemberModel, listener: {
            result, success in if let result = result as? FindMemberProfilesResponseModel, success {
                if result.status == "Success" {}
            }
        })
    }

    func createCustomFolders() {
        _ = URL.extCreateFolder(folderName: fileName.globalFileName)

        _ = URL.extCreateFolder(folderName: fileName.profileFileName)
        _ = URL.extCreateFolder(folderName: fileName.contactProfileFileName)
        _ = URL.extCreateFolder(folderName: fileName.groupProfileFileName)
        _ = URL.extCreateFolder(folderName: fileName.groupMemberProfileFileName)
        _ = URL.extCreateFolder(folderName: fileName.mediaFileName)
        _ = URL.extCreateFolder(folderName: fileName.imagemediaFileName)
        _ = URL.extCreateFolder(folderName: fileName.videomediaFileName)
        _ = URL.extCreateFolder(folderName: fileName.audiomediaFileName)
        _ = URL.extCreateFolder(folderName: fileName.filesmediaFileName)
    }

    func showCustomAlert() {
        displayLabel = UILabel(frame: CGRect(x: (window?.frame.size.width)! / 2 - 100, y: (window?.frame.size.height)! - 150, width: 200, height: 21))

        displayLabel.textAlignment = .center
        displayLabel.text = "Internet Unvailable"
        displayLabel.backgroundColor = UIColor.gray
        displayLabel.textColor = UIColor.white
        displayLabel.layer.cornerRadius = 5

        displayLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 12)
        window?.addSubview(displayLabel)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.hideAlert()
        }
    }

    func hideAlert() {
        displayLabel.isHidden = true

        displayLabel.removeFromSuperview()
    }

    func showAlertForNoInternet() {
        let alertController = UIAlertController(title: "Alert", message: errorStrings.noInterent, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            _ in
            NSLog("OK Pressed")
        }

        alertController.addAction(okAction)
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    // Handle new message from one of channels on which client has been subscribed.
    func client(_: PubNub, didReceiveMessage message: PNMessageResult) {
        // Handle new message stored in message.data.message

        if message.data.publisher == userId {
            print("own message \(message.data.publisher)")
            print("Received message: \(message.data.message ?? "") on channel \(message.data.channel) " +
                "at \(message.data.timetoken)")
        } else {
            print("Received message: \(message.data.message ?? "") on channel \(message.data.channel) " +
                "at \(message.data.timetoken)")

            if let userId: String = UserDefaults.standard.string(forKey: UserKeys.userGlobalId) {
                if userId == message.data.channel {
                    UserDefaults.standard.set(message.data.timetoken, forKey: UserKeys.lastMessageTime)
                }
            }

            let dataToProcess = ACFeedProcessorObjectClass()
            let DataDict: NSDictionary = message.data.message as! NSDictionary
            dataToProcess.checkTypeOfDataReceived(dataDictionary: DataDict)
        }
    }

    // New presence event handling.
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        // Handle presence event event.data.presenceEvent (one of: join, leave, timeout, state-change).
        print("subscribed")
        if event.data.channel != event.data.subscription {
            // Presence event has been received on channel group stored in event.data.subscription.\
//            print(event.data)
        } else {
            // Presence event has been received on channel stored in event.data.channel.
            print(event.data)
        }

        if event.data.presenceEvent != "state-change" {
            print("\(String(describing: event.data.presence.uuid)) \"\(event.data.presenceEvent)'ed\"\n" +
                "at: \(event.data.presence.timetoken) on \(event.data.channel) " +
                "(Occupancy: \(event.data.presence.occupancy))")

            if event.data.presenceEvent == "join" {
                print("online")
            }
        } else {
            print("\(String(describing: event.data.presence.uuid)) changed state at: " +
                "\(event.data.presence.timetoken) on \(event.data.channel) to:\n" +
                "\(String(describing: event.data.presence.state))")

            let stringToRetry = event.data.presence.state

            if let str = stringToRetry?["status"] {
                let strTypeValue = str as! Bool
                let struuid = stringToRetry?["uuid"] as! String

                if strTypeValue == true, struuid != client.uuid() {
                    let acTypingobj = ACTypingStatusObject(uuid: struuid, channelName: stringToRetry?["channelName"] as! String, time: stringToRetry?["time"] as! String, status: stringToRetry?["status"] as! Bool, topic: stringToRetry?["topic"] as! String)
                    ACEventBusManager.postToEventBusWithTypingObject(eventBusChannelObject: acTypingobj, notificationName: eventBusHandler.typingStatus)
                }
            }
        }
    }

    // Handle subscription status change.
    func client(_: PubNub, didReceive status: PNStatus) {
        if status.operation == .subscribeOperation {
            // Check whether received information about successful subscription or restore.
            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
                if subscribeStatus.category == .PNConnectedCategory {
                    // This is expected for a subscribe, this means there is no error or issue whatsoever.
                } else {
                    /**
                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
                     an error but there is no longer any issue.
                     */
                }
            } else if status.category == .PNUnexpectedDisconnectCategory {
                /**
                 This is usually an issue with the internet connection, this is an error, handle
                 appropriately retry will be called automatically.
                 */
            }
            // Looks like some kind of issues happened while client tried to subscribe or disconnected from
            // network.
            else {
                let errorStatus: PNErrorStatus = status as! PNErrorStatus
                if errorStatus.category == .PNAccessDeniedCategory {
                    /**
                     This means that PAM does allow this client to subscribe to this channel and channel group
                     configuration. This is another explicit error.
                     */
                } else {
                    /**
                     More errors can be directly specified by creating explicit cases for other error categories
                     of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                     `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                     or `PNNetworkIssuesCategory`
                     */
                }
            }
        }
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func showNotification(displayImage: String, title: String, subtitle: String, channelData: ChannelTable) {
        switch notificationStatus {
        case NotificationEnum.ShowAllNotifications:
            displayNotification(displayImage: displayImage, title: title, subtitle: subtitle, channelData: channelData)
        case NotificationEnum.showNoNotificatons:
            print("do nothing")
        case NotificationEnum.ShowAllGroupChatsNotification:
            let chType = channelData.value(forKey: "channelType") as! String
            if chType == channelType.ONE_ON_ONE_CHAT.rawValue || chType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                displayNotification(displayImage: displayImage, title: title, subtitle: subtitle, channelData: channelData)
            }
        case NotificationEnum.showExceptSpecificChannelId:
            let chId = channelData.value(forKey: "id") as! String
            if currentChannelId != chId {
                displayNotification(displayImage: displayImage, title: title, subtitle: subtitle, channelData: channelData)
            }
        case NotificationEnum.showRecentChatNotifications:
            let chType = channelData.value(forKey: "channelType") as! String
            if chType == channelType.PUBLIC_GROUP.rawValue || chType == channelType.PRIVATE_GROUP.rawValue || chType == channelType.TOPIC_GROUP.rawValue {
                displayNotification(displayImage: displayImage, title: title, subtitle: subtitle, channelData: channelData)
            }
        }
    }

    fileprivate func processMessageOnClickOfData(channelTypeData: String, channelContactId: String) {
        let chType = channelTypeData
        let chContactId = channelContactId
        let mainStoryBoard = UIStoryboard(name: "OnBoarding", bundle: nil)
        let initialViewController = mainStoryBoard.instantiateViewController(withIdentifier: "HomeTabBarController")
        window?.rootViewController = initialViewController
        let navigationController = window?.rootViewController

        if chType == channelType.ONE_ON_ONE_CHAT.rawValue || chType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue || chType == channelType.GROUP_CHAT.rawValue || chType == channelType.ADHOC_CHAT.rawValue {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
                let channelObject = ChannelDisplayObject()

                if chType == channelType.ONE_ON_ONE_CHAT.rawValue {
                    let channel = DatabaseManager.getChannelIndex(contactId: chContactId, channelType: channelType.ONE_ON_ONE_CHAT.rawValue)

                    channelObject.channelId = channel!.id
                    channelObject.globalChannelName = channel!.globalChannelName

                    channelObject.channelType = channel!.channelType
                    channelObject.unseenCount = channel!.unseenCount
                    channelObject.lastMessageIdOfChannel = channel!.lastSavedMsgid
                    channelObject.lastMessageTime = channel!.lastMsgTime
                    channelObject.lastSenderPhoneBookContactId = channel!.contactId

                    let contactDetails = DatabaseManager.getContactDetails(phoneNumber: channelObject.lastSenderPhoneBookContactId)
                    channelObject.channelDisplayNames = (contactDetails?.fullName)!
                    channelObject.channelImageUrl = (contactDetails?.localImageFilePath)!

                } else if chType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                    let channel = DatabaseManager.getChannelIndex(contactId: chContactId, channelType: channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue)

                    channelObject.channelId = channel!.id
                    channelObject.globalChannelName = channel!.globalChannelName

                    channelObject.channelType = channel!.channelType
                    channelObject.unseenCount = channel!.unseenCount
                    channelObject.lastMessageIdOfChannel = channel!.lastSavedMsgid
                    channelObject.lastMessageTime = channel!.lastMsgTime
                    channelObject.lastSenderPhoneBookContactId = channel!.contactId

                    let contactDetails = DatabaseManager.getGroupMemberIndexForMemberId(groupId: channelObject.lastSenderPhoneBookContactId)
                    channelObject.channelDisplayNames = (contactDetails?.memberName)!
                    channelObject.channelImageUrl = (contactDetails?.localImagePath)!
                } else if chType == channelType.GROUP_CHAT.rawValue {
                    let channel = DatabaseManager.getChannelIndex(contactId: chContactId, channelType: channelType.GROUP_CHAT.rawValue)

                    channelObject.channelId = channel!.id
                    channelObject.globalChannelName = channel!.globalChannelName

                    channelObject.channelType = channel!.channelType
                    channelObject.unseenCount = channel!.unseenCount
                    channelObject.lastMessageIdOfChannel = channel!.lastSavedMsgid
                    channelObject.lastMessageTime = channel!.lastMsgTime
                    channelObject.lastSenderPhoneBookContactId = channel!.contactId

                    let contactDetails = DatabaseManager.getGroupDetail(groupGlobalId: channelObject.lastSenderPhoneBookContactId)
                    channelObject.channelDisplayNames = (contactDetails?.groupName)!
                    channelObject.channelImageUrl = (contactDetails?.localImagePath)!
                } else if chType == channelType.ADHOC_CHAT.rawValue {
                    let channel = DatabaseManager.getChannelIndex(contactId: chContactId, channelType: channelType.ADHOC_CHAT.rawValue)

                    channelObject.channelId = channel!.id
                    channelObject.globalChannelName = channel!.globalChannelName

                    channelObject.channelType = channel!.channelType
                    channelObject.unseenCount = channel!.unseenCount
                    channelObject.lastMessageIdOfChannel = channel!.lastSavedMsgid
                    channelObject.lastMessageTime = channel!.lastMsgTime
                    channelObject.lastSenderPhoneBookContactId = channel!.contactId

                    let contactDetails = DatabaseManager.getGroupDetail(groupGlobalId: channelObject.lastSenderPhoneBookContactId)
                    channelObject.channelDisplayNames = (contactDetails?.groupName)!
                    channelObject.channelImageUrl = (contactDetails?.localImagePath)!
                }

                nextViewController.hidesBottomBarWhenPushed = true
                nextViewController.navigationController?.navigationBar.isHidden = true
//                nextViewController.loadTableViewData(chnlDetails: channelObject)
                nextViewController.customNavigationBar(name: channelObject.channelDisplayNames, image: channelObject.channelImageUrl, channelTyp: channelType(rawValue: channelObject.channelType)!)
                nextViewController.displayName = channelObject.channelDisplayNames
                nextViewController.displayImage = channelObject.channelImageUrl

                nextViewController.channelDetails = channelObject
                nextViewController.channelId = channelObject.channelId

                nextViewController.isViewFirstTime = true
                nextViewController.isViewFirstTimeLoaded = true
                nextViewController.isfromNotifications = true
                nextViewController.isScrollToBottom = true

                let navController = UINavigationController(rootViewController: nextViewController)
                let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
                navController.navigationBar.tintColor = color3
                navigationController!.show(navController, sender: self)
            }
        } else {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACSpeakerCardsViewController") as? ACSpeakerCardsViewController {
                let channelObject = ChannelDisplayObject()

                if let channel = DatabaseManager.getChannelIndex(contactId: chContactId, channelType: chType) {
                    channelObject.channelId = channel.id
                    channelObject.globalChannelName = channel.globalChannelName

                    channelObject.channelType = channel.channelType
                    channelObject.unseenCount = channel.unseenCount
                    channelObject.lastMessageIdOfChannel = channel.lastSavedMsgid
                    channelObject.lastMessageTime = channel.lastMsgTime
                    channelObject.lastSenderPhoneBookContactId = channel.contactId

                    let contactDetails = DatabaseManager.getGroupDetail(groupGlobalId: channelObject.lastSenderPhoneBookContactId)
                    channelObject.channelDisplayNames = (contactDetails?.groupName)!
                    channelObject.channelImageUrl = (contactDetails?.localImagePath)!
                    nextViewController.groupType = (contactDetails?.groupType)!
                    nextViewController.hidesBottomBarWhenPushed = true
                    nextViewController.navigationController?.navigationBar.isHidden = true
                    nextViewController.customNavigationBar(name: channelObject.channelDisplayNames, image: channelObject.channelImageUrl)

                    nextViewController.channelDetails = channelObject
                    nextViewController.channelId = channelObject.channelId

                    nextViewController.isViewFirstTime = true
                    nextViewController.isViewFirstTimeLoaded = true
                    nextViewController.isfromNotifications = true

                    let navController = UINavigationController(rootViewController: nextViewController)
                    let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
                    navController.navigationBar.tintColor = color3
                    navigationController!.show(navController, sender: self)
                }
            }
        }
    }

    func displayNotification(displayImage: String, title: String, subtitle: String, channelData: ChannelTable) {
        let data: NSDictionary = channelData.toDictionary()
        let resource: String = displayImage

        let notification: InAppNotification = InAppNotification(
            resource: load(attName: resource),
            title: title,
            subtitle: subtitle,
            data: data as! [String: Any]
        )

        DefaultSound.inappNotification()
        InAppNotificationDispatcher.shared.show(
            notification: notification,
            clickCallback: { _notification in
                print("Notification clicked. Data: \(_notification.data)")

                self.processMessageOnClickOfData(channelTypeData: _notification.data["channelType"] as! String, channelContactId: _notification.data["contact_id"] as! String)
            }
        )
    }
    
    func load(attName: String) -> UIImage? {
        let type = fileName.imagemediaFileName
        
        var documentsUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsUrl.appendingPathComponent(type + "/" + attName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
            return UIImage(named: "group_profile")
        }
        return nil
    }

}

extension AppDelegate {
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, _ in
                print("Permission granted: \(granted)")
//                let replyAction = UNTextInputNotificationAction(identifier: "ReplyAction", title: "Reply", options: [])
                ////                let openAppAction = UNNotificationAction(identifier: "OpenAppAction", title: "Open app", options: [.foreground])
//                let quickReplyCategory = UNNotificationCategory(identifier: "CHAT", actions: [replyAction], intentIdentifiers: [], options: [])
//                UNUserNotificationCenter.current().setNotificationCategories([quickReplyCategory])

                guard granted else {
                    print("Please enable \"Notifications\" from App Settings.")
                    self?.showPermissionAlert()
                    return
                }

                self?.getNotificationSettings()
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    @available(iOS 10.0, *)
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            String(format: "%02.2hhx", data)
        }

        let token = tokenParts.joined() as String
        print("Device Token: \(token)")
        var checkToken: Bool = false
        if let oldtoken = UserDefaults.standard.value(forKey: UserKeys.deviceToken) {
            if oldtoken as! String != token {
                checkToken = true
            }
        } else {
            checkToken = true
        }

        if checkToken == true {
            UserDefaults.standard.setValue(deviceToken, forKey: UserKeys.deviceTokenData)
            UserDefaults.standard.setValue(token, forKey: UserKeys.deviceToken)
        }

        if UserDefaults.standard.value(forKey: UserKeys.userGlobalId) != nil {
            let pubnub = ACPubnubClass()
            pubnub.subscribeToPubnubNotification(token: deviceToken)
        }
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If your app was running and in the foreground
        // Or
        // If your app was running or suspended in the background and the user brings it to the foreground by tapping the push notification
        print("didReceiveRemoteNotification \(userInfo)")

        if let aps = userInfo["aps"] as? NSDictionary {
            if let data = aps["data"] as? NSDictionary {
                if UIApplication.shared.applicationState == .active {
                    if let src = data.value(forKey: "src") {
                        if (src as! String) == source.authentication.rawValue {
                            let sysDataDictionary = data.value(forKey: source.authentication.rawValue)

                            if let type = (sysDataDictionary as AnyObject).value(forKey: "channeltype") {
                                if (type as! String) == channelType.PRIVATE_GROUP.rawValue || (type as! String) == channelType.PUBLIC_GROUP.rawValue {
                                    let dataToProcess = ACFeedProcessorObjectClass()
                                    dataToProcess.checkTypeOfDataReceived(dataDictionary: data)
                                }
                            }
                        }
                    }
                } else {
                    let state = UIApplication.shared.applicationState
                    if state == .background ||
                        (state == .inactive && !appIsStarting) {
                        let dataToProcess = ACFeedProcessorObjectClass()
                        dataToProcess.checkTypeOfDataReceived(dataDictionary: data)

                        if let src = data.value(forKey: "src") {
                            if (src as! String) == source.authentication.rawValue {
                                let sysDataDictionary = data.value(forKey: source.authentication.rawValue)

                                if let type = (sysDataDictionary as AnyObject).value(forKey: "channeltype") {
                                    if (type as! String) == channelType.GROUP_CHAT.rawValue {
                                        let obj = ACGroupChatCommunicationProcessor()
                                        let notify = obj.getDataForNotification(dataDict: sysDataDictionary as! NSMutableDictionary)
                                        let content = UNMutableNotificationContent()

                                        content.categoryIdentifier = "CHAT"

                                        content.title = notify.title
                                        content.body = notify.body
                                        content.sound = UNNotificationSound.default

                                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

                                        let uuidString = UUID().uuidString
                                        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                                    }
                                }
                            }
                        }

                        completionHandler(.newData)

                    } else if state == .inactive,
                        appIsStarting {
//                        self.sendNotificationButtonTapped()

                        let dataToProcess = ACFeedProcessorObjectClass()
                        dataToProcess.checkTypeOfDataReceived(dataDictionary: data)
                        if let src = data.value(forKey: "src") {
                            if (src as! String) == source.authentication.rawValue {
                                let sysDataDictionary = data.value(forKey: source.authentication.rawValue)

                                if let type = (sysDataDictionary as AnyObject).value(forKey: "channeltype") {
                                    if (type as! String) == channelType.ONE_ON_ONE_CHAT.rawValue {
                                        var msgObject = ACCommunicationMsgObject()
                                        msgObject = msgObject.mapDataValues(dataDict: sysDataDictionary as! NSDictionary)

                                        if let contactId = DatabaseManager.getContactIndex(globalUserId: msgObject.senderUUID!) {
                                            processMessageOnClickOfData(channelTypeData: type as! String, channelContactId: contactId.id)
                                        }
                                    } else if (type as! String) == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                                        var msgObject = ACCommunicationMsgObject()
                                        msgObject = msgObject.mapDataValues(dataDict: sysDataDictionary as! NSDictionary)

                                        if let groupIndex = DatabaseManager.getGroupIndex(groupGlobalId: msgObject.refGroupId!) {
                                            if let profile = DatabaseManager.getGroupMemberIndex(groupId: groupIndex.id, globalUserId: msgObject.senderUUID!) {
                                                processMessageOnClickOfData(channelTypeData: type as! String, channelContactId: profile.groupMemberId)
                                            }
                                        }

                                    } else {
                                        var msgObject = ACCommunicationMsgObject()
                                        msgObject = msgObject.mapDataValues(dataDict: sysDataDictionary as! NSDictionary)
                                        if let groupDetails = DatabaseManager.getGroupIndex(groupGlobalId: msgObject.receiver!) {
                                            processMessageOnClickOfData(channelTypeData: type as! String, channelContactId: groupDetails.id)
                                        }
                                    }
                                }
                            }
                        }
                        completionHandler(.newData)
                    }
                }
            }
        } else {
            print("Notification Parsing Error")
            return
        }
    }

    func showPermissionAlert() {
        let alert = UIAlertController(title: "WARNING", message: labelStrings.allowNotification, preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { [weak self] _ in
            self?.gotoAppSettings()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)

        DispatchQueue.main.async {
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    private func gotoAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.openURL(settingsUrl)
        }
    }

    @available(iOS 10.0, *)
//    func didReceiveNotificationRequest(request: UNNotificationRequest, withContentHandler contentHandler: (UNNotificationContent) -> Void) {
//        print("message received")
//    }
//
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let user = DatabaseManager.getUser()
        if response.actionIdentifier == "CHAT" {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "HomeScreenViewController") as? HomeScreenViewController {
                nextViewController.navigationController?.pushViewController(nextViewController, animated: true)
                user?.globalUserId = nextViewController.getGlobeID!
            }
            print("Handle text action identifier")
        }
        // Make sure completionHandler method is at the bottom of this func
        completionHandler()
    }

//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert, .sound])
//    }
//

    func sendNotificationButtonTapped() {
        // find out what are the user's notification preferences
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            // we're only going to create and schedule a notification
            // if the user has kept notifications authorized for this app
            guard settings.authorizationStatus == .authorized else { return }

            // create the content and style for the local notification
            let content = UNMutableNotificationContent()

            // #2.1 - "Assign a value to this property that matches the identifier
            // property of one of the UNNotificationCategory objects you
            // previously registered with your app."
            content.categoryIdentifier = "CHAT"

            // create the notification's content to be presented
            // to the user
            content.title = "DEBIT OVERDRAFT NOTICE!"
            content.subtitle = "Exceeded balance by $300.00."
            content.body = "One-time overdraft fee is $25. Should we cover transaction?"
            content.sound = UNNotificationSound.default

            // #2.2 - create a "trigger condition that causes a notification
            // to be delivered after the specified amount of time elapses";
            // deliver after 10 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)

            // create a "request to schedule a local notification, which
            // includes the content of the notification and the trigger conditions for delivery"
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

            // "Upon calling this method, the system begins tracking the
            // trigger conditions associated with your request. When the
            // trigger condition is met, the system delivers your notification."
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        } // end getNotificationSettings
    } // end func sendNotificationButtonTapped
}
