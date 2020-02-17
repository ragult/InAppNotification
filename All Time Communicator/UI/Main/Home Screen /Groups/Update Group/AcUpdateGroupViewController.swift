//
//  CreateNewGroupViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 01/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class AcUpdateGroupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var groupProfileImage: UIImageView!
    @IBOutlet var groupNameTextfield: UITextField!
    @IBOutlet var groupTopicTextField: UITextField!
    @IBOutlet var uploadingImageIndicator: UIActivityIndicatorView!
    @IBOutlet var addContactBtnRef: UIButton!
    var groupInfo: GroupTable?
    var getGroupImage: UIImage?
    var groupImageData: Data?
    let user = DatabaseManager.getUser()
    var cloudinaryImageUrl: String?
    var delegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        groupProfileImage.backgroundColor = .black
        uploadingImageIndicator.hidesWhenStopped = true
        uploadingImageIndicator.color = UIColor(r: 33, g: 140, b: 141)
//        confidentialTriggeringSwitch.transform = CGAffineTransform(scaleX: 0.72 , y: 0.72 )
        groupNameTextfield.borderStyle = .roundedRect
        groupTopicTextField.borderStyle = .roundedRect
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        groupProfileImage.isUserInteractionEnabled = true
        groupProfileImage.addGestureRecognizer(tapGestureRecognizer)
        groupNameTextfield.text = groupInfo!.groupName
        groupTopicTextField.text = groupInfo!.groupDescription

        if groupInfo!.localImagePath == "" {
            if groupInfo!.fullImageUrl != "" {
                let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: groupInfo!.fullImageUrl, refernce: groupInfo!.id, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

                DispatchQueue.global(qos: .background).async {
                    ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in

                        DatabaseManager.updateGroupLocalImagePath(localImagePath: path, localId: self.groupInfo!.id)

                        self.groupInfo?.localImagePath = path
                        DispatchQueue.main.async { () in
                            self.groupProfileImage.image = self.load(attName: self.groupInfo!.localImagePath)
                        }

                    })
                }
            }
        } else {
            groupProfileImage.image = load(attName: groupInfo!.localImagePath)
        }
    }

    override func viewWillAppear(_: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications
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
                    //            self.uploadingImageIndicator.startAnimating()
                    self.addContactBtnRef.isEnabled = false
                    self.addContactBtnRef.backgroundColor = .gray
                    // self.groupProfileImage.addBlur()
                    self.groupProfileImage.alpha = 0.1
                    if self.delegate != nil {
                        if (self.delegate?.isInternetAvailable)! {
                            Loader.show()
                            if let data = self.groupImageData {
                                ACImageDownloader.downloadImageForLocalPath(imageData: data, ref: "", completionHandler: { (success, _) -> Void in

                                    print(success)
                                    let localPath = success

                                    if let data = self.groupImageData {
                                        let config = AWSManager.instance.getConfig(
                                            gType: self.groupInfo?.groupType ?? "",
                                            isChat: false,
                                            isProfile: true,
                                            isGroup: true,
                                            fileName: success,
                                            type: s3BucketName.imageType
                                        )

                                        AWSManager.instance.uploadDataS3(config: config, data: data, completionHandler: {  (url, error) in

                                            if error == nil {
                                                self.cloudinaryImageUrl = url
                                                //                            self.uploadingImageIndicator.stopAnimating()
                                                self.groupProfileImage.alpha = 1
                                                // self.groupProfileImage.removeBlur()

                                                let auth = NSMutableDictionary()
                                                auth.setValue(UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as! String, forKey: "globalUserId")
                                                auth.setValue(UserDefaults.standard.value(forKey: UserKeys.userSecurityCode) as! String, forKey: "securityCode")

                                                auth.setValue(UserDefaults.standard.value(forKey: UserKeys.serverDeviceId) as! String, forKey: "deviceId")

                                                let updateDict = NSMutableDictionary()
                                                updateDict.setValue(auth, forKey: "auth")
                                                updateDict.setValue(self.groupInfo?.groupGlobalId, forKey: "groupId")
                                                updateDict.setValue(url, forKey: "fullImageUrl")
                                                self.groupInfo?.fullImageUrl = url
                                                NetworkingManager.updateGroupImage(updateDictionary: updateDict) { (result: Any, sucess: Bool) in
                                                    if let result = result as? UpdateGroupResponse, sucess {
                                                        if sucess {
                                                            if result.status == "Success" {
                                                                DatabaseManager.updateCloudImageInGroupTable(groupTable: self.groupInfo!)
                                                                DatabaseManager.updateGroupLocalImagePath(localImagePath: localPath, localId: self.groupInfo!.id)

                                                                self.alert(message: "Group image updated")

                                                            } else {
                                                                Loader.close()
                                                                if result.status == "Exception" {
                                                                    let errorMsg = result.errorMsg[0]
                                                                    if errorMsg == "IU-100" || errorMsg == "AUT-101" {
                                                                        self.gotohomePage()
                                                                    } else {
                                                                        self.alert(message: errorStrings.unKnownAlert)
                                                                    }
                                                                }
                                                            }

                                                        } else {
                                                            self.alert(message: errorStrings.unKnownAlert)
                                                        }
                                                        Loader.close()
                                                    }
                                                }
                                                self.addContactBtnRef.backgroundColor = UIColor(r: 33, g: 140, b: 141)
                                                self.addContactBtnRef.isEnabled = true

                                                Loader.close()
                                            }

                                        })
                                    }

                                })
                            }
                        } else {
                            self.alert(message: "Internet is required")
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
        if groupNameTextfield.text == groupInfo?.groupName, groupTopicTextField.text == groupInfo?.groupDescription {
            alert(message: "There were no changes to update")

        } else {
            if !groupNameTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if delegate != nil {
                    if (delegate?.isInternetAvailable)! {
                        Loader.show()

                        let auth = NSMutableDictionary()
                        auth.setValue(UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as! String, forKey: "globalUserId")
                        auth.setValue(UserDefaults.standard.value(forKey: UserKeys.userSecurityCode) as! String, forKey: "securityCode")

                        auth.setValue(UserDefaults.standard.value(forKey: UserKeys.serverDeviceId) as! String, forKey: "deviceId")

                        let updateDict = NSMutableDictionary()
                        updateDict.setValue(auth, forKey: "auth")
                        updateDict.setValue(groupInfo?.groupGlobalId, forKey: "groupId")

                        if groupNameTextfield.text != groupInfo?.groupName {
                            updateDict.setValue(groupNameTextfield.text, forKey: "name")
                            groupInfo?.groupName = groupNameTextfield.text!
                        }
                        if groupTopicTextField.text != groupInfo?.groupDescription {
                            updateDict.setValue(groupTopicTextField.text, forKey: "description")
                            groupInfo?.groupDescription = groupTopicTextField.text!
                        }

                        NetworkingManager.updateGroupData(updateDictionary: updateDict) { (result: Any, sucess: Bool) in
                            if let result = result as? UpdateGroupResponse, sucess {
                                if sucess {
                                    if result.status == "Success" {
                                        DatabaseManager.UpdategroupTable(groupTable: self.groupInfo!)
                                        self.alert(message: "Group profile has been updated")
                                    } else {
                                        Loader.close()
                                        if result.status == "Exception" {
                                            let errorMsg = result.errorMsg[0]
                                            if errorMsg == "IU-100" || errorMsg == "AUT-101" {
                                                self.gotohomePage()
                                            } else {
                                                self.alert(message: errorStrings.unKnownAlert)
                                            }
                                        }
                                    }

                                } else {
                                    self.alert(message: errorStrings.unKnownAlert)
                                }
                            }
                            Loader.close()
                        }
                    } else {
                        alert(message: "Internet is required")
                    }
                }

            } else {
                alert(message: "Name cannot be empty")
            }
        }
    }
}
