//
//  GroupsController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/10/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import LocalAuthentication
import SwiftEventBus
import UIKit

class GroupChatsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    struct GroupTypes {
        static var chatGroup = "2"
        static var privateGroup: String = "1"
        static var publicGroup: String = "3"
    }

    var groups = [GroupTable]()
    let user = DatabaseManager.getUser() ?? nil
    @IBOutlet var groupsTableview: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var isViewActive: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        groupsTableview.reloadData()
        groupsTableview.tableFooterView = UIView()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        groupsTableview.register(UINib(nibName: "GroupTableviewCell", bundle: nil), forCellReuseIdentifier: "cell")
        groupsTableview.register(UINib(nibName: "ConfidentialGroupCell", bundle: nil), forCellReuseIdentifier: "cell2")
        let pluseButton = UIImage(named: "pluseButtonSmall")!
        let searchImage = UIImage(named: "NavSearch")!
        let pluseBarButton = UIBarButtonItem(image: pluseButton, style: .plain, target: self, action: #selector(didTapPlusButton))
        let searchButton = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(didTapSearchButton))
        navigationItem.rightBarButtonItems = [pluseBarButton, searchButton]
        SwiftEventBus.onMainThread(target as AnyObject, name: eventBusHandler.groupAdded) { _ in
            // UI thread
            if self.isViewActive {
                self.viewWillAppear(false)
            }
        }
    }

    @objc func didTapPlusButton() {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "CreateGroup_BroadcastsViewController") as? CreateGroup_BroadcastsViewController {
            if let navigator = navigationController {
                let backItem = UIBarButtonItem()
                backItem.title = "Create group"
                navigationItem.backBarButtonItem = backItem
                nextViewController.hidesBottomBarWhenPushed = true
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    @objc func didTapSearchButton() {
        groupsTableview.tableHeaderView = searchController.searchBar
    }

    override func viewWillAppear(_: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllGroupChatsNotification
        isViewActive = true
        groups = DatabaseManager.getGroups()

        groupsTableview.reloadData()
    }

    override func viewWillDisappear(_: Bool) {
        isViewActive = false
    }

    // MARK: TableViews

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return groups.count
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupCell = groupsTableview.dequeueReusableCell(withIdentifier: "cell") as! GroupTableviewCell
        groupCell.groupName.text = groups[indexPath.row].groupName

        groupCell.groupProfileImage.image = UIImage(named: "icon_DefaultGroup")

        if groups[indexPath.row].fullImageUrl == "" {
            groupCell.groupProfileImage.image = UIImage(named: "icon_DefaultGroup")
        } else {
            if groups[indexPath.row].localImagePath == "" {
                let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: groups[indexPath.row].fullImageUrl, refernce: groups[indexPath.row].id, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

                DispatchQueue.global(qos: .background).async {
                    ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                        if path != "" {
                            DatabaseManager.updateGroupLocalImagePath(localImagePath: path, localId: self.groups[indexPath.row].id)
                            self.groups[indexPath.row].localImagePath = path
                            DispatchQueue.main.async { () in
                                groupCell.groupProfileImage.image = self.load(attName: self.groups[indexPath.row].localImagePath)
                            }
                        }

                    })
                }
            } else {
                groupCell.groupProfileImage.image = load(attName: groups[indexPath.row].localImagePath)
            }
//            if let imageUrl = URL(string: groups[indexPath.row].fullImageUrl) {
//                groupCell.groupProfileImage.af_setImage(withURL: imageUrl)
//            }
        }
        groupCell.confidentialImage.isHidden = true
        groupCell.selectionStyle = .none

        if groups[indexPath.row].confidentialFlag == "1" {
            groupCell.confidentialImage.isHidden = false
        }

        if groups[indexPath.row].groupType == groupType.ADHOC_CHAT.rawValue || groups[indexPath.row].groupType == groupType.GROUP_CHAT.rawValue {
            groupCell.typeOfChatIcon.image = UIImage(named: "group7")
        } else {
            groupCell.typeOfChatIcon.image = UIImage(named: "broadCastIconSmall")
        }

//        groupCell.typeOfChatIcon.image = UIImage(named: "groupIconSmall")
        let date = groups[indexPath.row].createdOn

        var dateString = ""
        if date.contains("-") {
            let dString = dateFormatting(date: date)
            dateString = dString
        } else {
            if date != "" {
                let time = Double(date)
                dateString = time?.getDateFromUTC() ?? ""
            }
        }

        let groupMembersList = DatabaseManager.getGroupMembers(globalGroupId: groups[indexPath.row].id)
        let adminUser = DatabaseManager.getContactIndex(globalUserId: groups[indexPath.row].createdBy)
        var name = ""
        if adminUser != nil {
            name = adminUser?.fullName ?? ""
        } else {
            for grp in groupMembersList {
                if grp.globalUserId == groups[indexPath.row].createdBy {
                    name = grp.memberName
                }
            }
        }

        if dateString != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            if let myDate = dateFormatter.date(from: dateString) {

                dateFormatter.dateFormat = "dd/MM/yyyy"
                let somedateString = dateFormatter.string(from: myDate)
                groupCell.createdByAndDate.text = "By \(name) (\(somedateString)) "
            } else {
                groupCell.createdByAndDate.text = "By \(name)"
            }
            groupCell.numberOfContacts.text = "\(groupMembersList.count) Contacts"
        } else {
            groupCell.createdByAndDate.text = "By \(name)"

            groupCell.numberOfContacts.text = "\(groupMembersList.count) Contacts"
        }

        return groupCell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if groups[indexPath.row].groupType == groupType.TOPIC_GROUP.rawValue || groups[indexPath.row].groupType == groupType.PUBLIC_GROUP.rawValue || groups[indexPath.row].groupType == groupType.PRIVATE_GROUP.rawValue {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACSpeakerCardsViewController") as? ACSpeakerCardsViewController {
                if let navigator = navigationController {
                    nextViewController.hidesBottomBarWhenPushed = true
                    nextViewController.navigationController?.navigationBar.isHidden = true
                    nextViewController.customNavigationBar(name: groups[indexPath.row].groupName, image: groups[indexPath.row].localImagePath)

                    let channelDIspObj = ChannelDisplayObject()
                    let chnl = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: groups[indexPath.row].groupType)

                    if let chTable = DatabaseManager.getChannelIndex(contactId: groups[indexPath.row].id, channelType: chnl) {
                        channelDIspObj.channelId = chTable.id
                        channelDIspObj.globalChannelName = chTable.globalChannelName
                        channelDIspObj.channelType = chTable.channelType
                        channelDIspObj.lastSenderPhoneBookContactId = chTable.contactId
                    } else {
                        fatalError("Please check the logic here for Correct channel Id implementation to query from channel table")
//                        let chTable = DatabaseManager.getChannelIndex(contactId: groups[indexPath.row].id, channelType: "1")
//                        channelDIspObj.channelId = (chTable?.id)!
//                        channelDIspObj.globalChannelName = (chTable?.globalChannelName)!
//                        channelDIspObj.channelType = (chTable?.channelType)!
//                        channelDIspObj.lastSenderPhoneBookContactId = (chTable?.contactId)!
                    }
                    nextViewController.displayName = groups[indexPath.row].groupName
                    nextViewController.groupType = groups[indexPath.row].groupType
                    nextViewController.channelDetails = channelDIspObj
//                    nextViewController.displayName = groups[indexPath.row].groupName
//                    nextViewController.displayImage = groups[indexPath.row].fullImageUrl
                    nextViewController.channelId = channelDIspObj.channelId

                    nextViewController.isViewFirstTime = true
                    nextViewController.isViewFirstTimeLoaded = true
                    nextViewController.modalPresentationStyle = .fullScreen
                    navigator.pushViewController(nextViewController, animated: true)
                }
            }
        } else {
            if groups[indexPath.row].confidentialFlag == "1" {
                selectedIndex = indexPath
                showPinView()
            } else {
                goToNextViewController(indexPath: indexPath)
            }
        }
    }

    func filterContentForSearchText(searchText _: String, scope _: String = "All") {
        // do some stuff
    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    func updateSearchResults(for _: UISearchController) {}

    func goToNextViewController(indexPath: IndexPath, isConfidential: Bool = false) {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "deleteVC") as? ChatViewController {
            if let navigator = navigationController {
                nextViewController.hidesBottomBarWhenPushed = true
                nextViewController.navigationController?.navigationBar.isHidden = true
                nextViewController.getIsConfidential = isConfidential
                let channelDIspObj = ChannelDisplayObject()
                let chnl = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: groups[indexPath.row].groupType)

                if let chTable = DatabaseManager.getChannelIndex(contactId: groups[indexPath.row].id, channelType: chnl) {
                    channelDIspObj.channelId = chTable.id
                    channelDIspObj.globalChannelName = chTable.globalChannelName
                    channelDIspObj.channelType = chTable.channelType
                    channelDIspObj.lastSenderPhoneBookContactId = chTable.contactId
                } else {
                    let chTable = DatabaseManager.getChannelIndex(contactId: groups[indexPath.row].id, channelType: "1")
                    channelDIspObj.channelId = (chTable?.id)!
                    channelDIspObj.globalChannelName = (chTable?.globalChannelName)!
                    channelDIspObj.channelType = (chTable?.channelType)!
                    channelDIspObj.lastSenderPhoneBookContactId = (chTable?.contactId)!
                }
                nextViewController.customNavigationBar(name: groups[indexPath.row].groupName, image: groups[indexPath.row].localImagePath, channelTyp: channelType(rawValue: channelDIspObj.channelType)!)

//                nextViewController.loadTableViewData(chnlDetails: channelDIspObj)

                nextViewController.channelDetails = channelDIspObj
                nextViewController.displayName = groups[indexPath.row].groupName
                nextViewController.displayImage = groups[indexPath.row].localImagePath
                nextViewController.isViewFirstTime = true
                nextViewController.isViewFirstTimeLoaded = true
                nextViewController.isScrollToBottom = true

                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    // show pinview
    var pinView = ACPinView()
    private let OTP_MAX_LENGTH = 4
    var selectedIndex: IndexPath?
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
                    goToNextViewController(indexPath: selectedIndex!, isConfidential: true)

                } else {
                    alert(message: "The app PIN is incorrect")
                    print("not verified")
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

// MARK: - Alerts

extension GroupChatsController {
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
                        self.goToNextViewController(indexPath: self.selectedIndex!, isConfidential: true)
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
