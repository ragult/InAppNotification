//
//  DetailViewController.swift
//  G-Scanner
//
//  Created by Nikhil Gohil on 23/01/2019.
//  Copyright © 2019 Gohil. All rights reserved.
//

import AVFoundation
import UIKit
protocol LoginQRDelegate : class
{
    func sendQRSecretCode(st: String)
}

class ACShowQRScan: UIViewController {
    private var codes: [AVMetadataObject.ObjectType]?

    var captureSession = AVCaptureSession()
    weak var qrDelegate : LoginQRDelegate?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var codeFrameView: UIView?

    func configureView() {
        // Update the user interface for the detail item.

//            self.title = "Scan QR"

        codes = [AVMetadataObject.ObjectType.upce,
                 AVMetadataObject.ObjectType.code39,
                 AVMetadataObject.ObjectType.code39Mod43,
                 AVMetadataObject.ObjectType.code93,
                 AVMetadataObject.ObjectType.code128,
                 AVMetadataObject.ObjectType.ean8,
                 AVMetadataObject.ObjectType.ean13,
                 AVMetadataObject.ObjectType.aztec,
                 AVMetadataObject.ObjectType.pdf417,
                 AVMetadataObject.ObjectType.itf14,
                 AVMetadataObject.ObjectType.dataMatrix,
                 AVMetadataObject.ObjectType.interleaved2of5,
                 AVMetadataObject.ObjectType.qr]

        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)

            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = codes

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(cameraPreviewLayer!)

        captureSession.startRunning()

        codeFrameView = UIView()

        if let qrCodeFrameView = codeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications

        configureView()
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if captureSession.isRunning == false {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    func stopScanning() {
        if captureSession.isRunning == true {
            captureSession.stopRunning()
        }
    }

    func launchApp(decodedURL: String) {
        if presentedViewController != nil {
            return
        }
        if let url = URL(string: decodedURL) {
            let param = url.params()
            if let app : String = param["app"] as? String {
                let decodedData = app.base64Decoded()
                let qrResponse : ScanQrResponse = ScanQrResponse(json: decodedData)
                print(qrResponse)
                if let pubid = qrResponse.data?.objData?.webData?.pubid {
                    
                    if DatabaseManager.checkGroupExsists(publicGroupId: pubid){
                        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "groupDetailsViewController") as? groupDetailsViewController {
                            if let navigator = navigationController {
                                nextViewController.hidesBottomBarWhenPushed = true
                                let groupTable = DatabaseManager.getGroupTableWith(publicGroupId: pubid)
                                nextViewController.groupDetails = groupTable!
                                //                        nextViewController.datadelegate = self
                                //                        nextViewController.photoChangedelegate = self
                                nextViewController.channelName = groupTable?.groupName ?? ""
                                navigator.pushViewController(nextViewController, animated: true)
                            }
                        }
                    } else {
                        getPublicGroupDetails(publicGroupId: pubid)
                    }
                    
                    
                    
//                    if let group : GroupTable = DatabaseManager.getGroupWithPublicId(groupPublicId: pubid) {
//                        self.showGroupChat(group: group)
//                    }
                }
            }
        }
    }
    
    func getPublicGroupDetails(publicGroupId: String) {
        let requestModel = GetPublicGroupRequestModel()
        requestModel.publicGroupId = publicGroupId
        requestModel.auth = DefaultDataProcessor().getAuthDetails()
        
        NetworkingManager.getPublicGroup(getGroupModel: requestModel) { (result: Any, sucess: Bool) in
            if let result = result as? GetPublicGroupResponseModel, sucess {
                if result.status == "Success" {
                    self.showSearchResultView(groupMember: result.data!, address: "")
                } else {}
            }
        }
    }
    
    func showGroupChat(group: GroupTable) {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACSpeakerCardsViewController") as? ACSpeakerCardsViewController {
            if let navigator = navigationController {
                nextViewController.hidesBottomBarWhenPushed = true
                nextViewController.navigationController?.navigationBar.isHidden = false
                nextViewController.customNavigationBar(name: group.groupName, image: group.localImagePath)
                
                let channelDIspObj = ChannelDisplayObject()
                let chnl = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: group.groupType)
                
                if let chTable = DatabaseManager.getChannelIndex(contactId: group.id, channelType: chnl) {
                    channelDIspObj.channelId = chTable.id
                    channelDIspObj.globalChannelName = chTable.globalChannelName
                    channelDIspObj.channelType = chTable.channelType
                    channelDIspObj.lastSenderPhoneBookContactId = chTable.contactId
                } else {
                    fatalError("Please check the logic here for Correct channel Id implementation to query from channel table")
                }
                nextViewController.displayName = group.groupName
                nextViewController.groupType = group.groupType
                nextViewController.channelDetails = channelDIspObj
                nextViewController.channelId = channelDIspObj.channelId
                
                nextViewController.isViewFirstTime = true
                nextViewController.isViewFirstTimeLoaded = true
                nextViewController.modalPresentationStyle = .fullScreen
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }
        var searchResultView = ACSearchResultView()
        var delegate = UIApplication.shared.delegate as? AppDelegate
        var selectedGroupPublicId = ""

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
//            //Create Attachment
//            let imageAttachment =  NSTextAttachment()
//            imageAttachment.image = UIImage(named:"groupIcon")
//
//            //Set bound to reposition
//            let imageOffsetY:CGFloat = -5.0;
//            imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
//            //Create string with attachment
//            let attachmentString = NSAttributedString(attachment: imageAttachment)
//            //Initialize mutable string
//            let completeText = NSMutableAttributedString(string: groupMember.totalMembers! + " Members")
//            //Add image to mutable string
//            completeText.append(attachmentString)
//            //Add your text to mutable string
//            let  textAfterIcon = NSMutableAttributedString(string: "Using attachment.bounds!")
//            completeText.append(textAfterIcon)
//            searchResultView.membersCountLabel.textAlignment = .center;
//            searchResultView.membersCountLabel.attributedText = completeText;
//            
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
//            for member in groupMember.members! {
//                count = count + 1
//                let groupMember = Bundle.main.loadNibNamed("GroupMemberListView", owner: self, options: nil)?[0] as! GroupMemberListView
//                groupMember.tag = count
//    //            groupMember.groupMemName.text = member.name
//                let imageName = member.thumbUrl
////                let image = getImage(imageName: imageName!)
//                groupMember.groupMemberProfileImage.image = image
//
//                groupMember.memberTitle.text = member.memberTitle
//    //            groupMember.groupMemName.text = member.name
//    //            searchResultView.memberStack.addArrangedSubview(groupMember)
//            }

            delegate!.window!.addSubview(searchResultView)
        }
    @objc func onClickCloseGroupView() {
        searchResultView.removeFromSuperview()
        self.tabBarController?.selectedIndex = 0
    }
    
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
                if result.successMsg[1] == "No valid users to add. Possibility of attempted duplicate record addition"{
                    self.alert(message: "No valid users to add. Possibility of attempted duplicate record addition")
                    return
                }
                let dataToProcess = ACFeedProcessorObjectClass()
            
                let dataDict: NSDictionary = result.data?.toDictionary() as! NSDictionary
                dataToProcess.checkTypeOfDataReceived(dataDictionary: dataDict)
                if status != "Exception" {
                    //   self.alert(message: "Group list is updated")
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
}

extension ACShowQRScan: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from _: AVCaptureConnection) {
        stopScanning()

        if metadataObjects.count == 0 {
            codeFrameView?.frame = CGRect.zero
//            statusLabel.text = "No code detected :( Try Again."
            return
        }

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if codes?.contains(metadataObj.type) ?? false {
            let barCodeObject = cameraPreviewLayer?.transformedMetadataObject(for: metadataObj)
            codeFrameView?.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
//                launchApp(decodedURL: metadataObj.stringValue!)
//                statusLabel.text = metadataObj.stringValue
//                let urlString = metadataObj.stringValue!
//                let url = URL(string: urlString)
//                print(url!.queryDictionary ?? "NONE")
//                let baseEncodedJson = url!.queryDictionary?["api"]
                
//                let dummyData = "http://13.127.187.72/services?typ=1&objid=%7B2615FCDD-8D8C-F3F3-7C77-0167967E9EC5%7D&app=eyJkYXRhIjp7Im9ialR5cGUiOiIxIiwib2JqVmVyIjoiMS4wIiwib2JqRGF0YSI6eyJlbnRpdHkiOnsibmFtZSI6IkVhcnRoIiwidHlwZSI6IjEiLCJzZXJ2aWNlcyI6IjEifSwid2ViRGF0YSI6eyJwdWJpZCI6InsyNjE1RkNERC04RDhDLUYzRjMtN0M3Ny0wMTY3OTY3RTlFQzV9IiwicHVidHlwIjoiNSJ9fX19"
                let urlString =  metadataObj.stringValue!
                let url = URL(string: urlString)!
                //print(url!.queryDictionary ?? "NONE")
                if let appData = url.queryDictionary?["app"] {
                    let decodedData = appData.base64Decoded()
                    if let data = decodedData {
                        do{
                            let myStruct = try JSONDecoder().decode(QrJSONData.self, from: data.data(using: .utf8)!)
                            
                            if let pubid = myStruct.data.objData.webData?.pubid{
                                if DatabaseManager.checkGroupExsists(publicGroupId: pubid){
                                    if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "groupDetailsViewController") as? groupDetailsViewController {
                                        if let navigator = navigationController {
                                            nextViewController.hidesBottomBarWhenPushed = true
                                            let groupTable = DatabaseManager.getGroupTableWith(publicGroupId: pubid)
                                            nextViewController.groupDetails = groupTable!
                                            //                        nextViewController.datadelegate = self
                                            //                        nextViewController.photoChangedelegate = self
                                            nextViewController.channelName = groupTable?.groupName ?? ""
                                            navigator.pushViewController(nextViewController, animated: true)
                                        }
                                    }
                                } else {
                                    self.tabBarController?.selectedIndex = 0
                                    getPublicGroupDetails(publicGroupId: pubid)
                                }

                            }
                            
                        } catch {
                            print(error)
                        }
                    } else {
                        self.alert(message: "Error decoding data")

                    }
                } else {
                    if  let decodedData = urlString.base64Decoded(){
                        if let loginQR = try? JSONDecoder().decode(LoginQR.self, from: decodedData.data(using: .utf8)!){
                            if let secretCode = loginQR.data?.objData.st{
                                if qrDelegate != nil {
                                    qrDelegate?.sendQRSecretCode(st: secretCode)
                                    self.dismiss(animated: true) {
                                    }
                                }
                            }
                        }

                    }

                }
            }
        }
    }
    
}

extension URL {
    func params() -> [String: Any] {
        var dict = [String: Any]()

        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            if let queryItems = components.queryItems {
                for item in queryItems {
                    dict[item.name] = item.value!
                }
            }
            return dict
        } else {
            return [:]
        }
    }
}

//extension String {
//    func base64Encoded() -> String? {
//        return data(using: .utf8)?.base64EncodedString()
//    }
//
//    func base64Decoded() -> String? {
//        guard let data = Data(base64Encoded: self) else { return nil }
//        return String(data: data, encoding: .utf8)
//    }
//}
