//
//  SocialLoginController.swift
//  alltimecommunicator
//
//  Created by Droid5 on 23/08/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import CoreTelephony
import CountryPickerView
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import UIKit

class SocialLoginController: UIViewController, GIDSignInDelegate, LoginQRDelegate {
    @IBOutlet var facebookLoginButton: UIStackView!
    @IBOutlet var googleLoginButton: UIStackView!
    @IBOutlet var mobileLoginButton: UIStackView!
    @IBOutlet var qrLoginButton: UIStackView!
    @IBOutlet var topViewWithLogo: UIStackView!
    @IBOutlet var topViewWithQR: UIStackView!
    @IBOutlet var dividerLineForMobileLoginButton: UIStackView!
    @IBOutlet var qrLoginButtonParentView: UIStackView!
    @IBOutlet var continuesWithDifferentProfileLabel: UILabel!

    var delegate = UIApplication.shared.delegate as? AppDelegate

//    final let googleLoginId = "314530795814-3o23inh98a0eeosg9tbr1rihn651b6p2.apps.googleusercontent.com"
    final let googleLoginId = "217363838420-gvbvt2d2l05pn28g77g9f87t8aobtdq4.apps.googleusercontent.com"

    internal var pUser = UserModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().clientID = googleLoginId
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance().uiDelegate = self

        customizeLoginButtons()
        alterTopLayout(registerType: pUser.registerType)
        navigationController?.navigationBar.isHidden = true
    }

    @IBAction func onClickOfBack(_: Any) {
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    private func customizeLoginButtons() {
        let qrLoginButtonBackgroundView = qrLoginButton.extAddBackground(color: UIColor(r: 107, g: 107, b: 107))
        qrLoginButtonBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(qrLogin(_:))))
        qrLoginButtonBackgroundView.extDropShadow()

        let facebookLoginButtonBackgroundView = facebookLoginButton.extAddBackground(color: UIColor(r: 34, g: 54, b: 123))
        facebookLoginButtonBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(facebookLogin(_:))))
        facebookLoginButtonBackgroundView.extDropShadow()

        let googleLoginButtonBackgroundView = googleLoginButton.extAddBackground(color: UIColor(r: 211, g: 72, b: 54))
        googleLoginButtonBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(googleLogin(_:))))
        googleLoginButtonBackgroundView.extDropShadow()

        let mobileLoginButtonBackgroundView = mobileLoginButton.extAddBackground(color: UIColor().extGetPrimaryColor)
        mobileLoginButtonBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(manualLogin(_:))))
        mobileLoginButtonBackgroundView.extDropShadow()
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    @objc
    private func qrLogin(_: UITapGestureRecognizer) {
    if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ACShowQRScan") as? ACShowQRScan {
        nextViewController.qrDelegate = self
        navigationController?.present(nextViewController, animated: true)
        }
    }

    @objc
    private func manualLogin(_: UITapGestureRecognizer) {
        pUser.gender = ""
        pUser.registerType = RegisterType.MANUAL

        let phone = UserDefaults.standard.string(forKey: UserKeys.userPhoneNumber) ?? ""
        let deviceID = UserDefaults.standard.string(forKey: UserKeys.serverDeviceId) ?? ""
        KeyManager.setSharedSecretKey(key: deviceID, iv: phone)

        initiateNextViewController()
    }

    @objc
    private func googleLogin(_: UITapGestureRecognizer) {
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance().signIn()
    }

    @objc
    private func facebookLogin(_: UITapGestureRecognizer) {
        let loginManager = LoginManager()
        // .userBirthday, .userGender
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { loginResult in

            switch loginResult {
            case let .failed(error):
                // TODO: need to implement
                print("FB login error: \(error.localizedDescription)")
            case .cancelled:
                // TODO: need to implement
                print("User cancelled login.")
            case .success:
                self.getFacebookUserInfo(completion: { userInfo, error in
                    if let error = error { print("FB login error: \(error.localizedDescription)") }
                    if let userInfo = userInfo, let id = userInfo["id"] as? String, let name = userInfo["name"] as? String {
                        let email: String = id
                        let birthday: String = userInfo["birthday"] as? String ?? ""
                        let gender: String = userInfo["gender"] as? String ?? ""

                        let accessToken = AccessToken.current?.tokenString ?? ""
                        let phone = UserDefaults.standard.string(forKey: UserKeys.userPhoneNumber) ?? ""

                        Loader.show()

                        KeyManager.setSharedSecretKey(key: email, iv: phone)

                        self.signInMethod(emailId: email, registerType: RegisterType.FACEBOOK, accessToken: accessToken) {
                            result, success in
                            if let result = result as? SignInResponseModel, success {
                                print("result: \(result)")

//                                self.checkAndChangeMobileNumber(result: result)
                                Loader.close()

                                if result.status == "Success" {
                                    if result.data?.doRegister == "true" {
                                        // TODO: changing picture as profile_pic for testing
                                        if let pictureDictionary = userInfo["picture"] as? [String: Any], let data = pictureDictionary["data"] as? [String: Any], let photo = data["url"] as? String {
                                            print("Got fb profile image")
                                            self.pUser.registerType = RegisterType.FACEBOOK
                                            self.initiateNextViewController(name: name, emailId: id, dateOfBirth: birthday, photo: photo, gender: gender)
                                        } else {
                                            print("Can't get fb profile image")
                                            self.pUser.registerType = RegisterType.FACEBOOK
                                            self.initiateNextViewController(name: name, emailId: email, dateOfBirth: birthday, gender: gender)
                                        }
                                    } else if result.data?.phoneNoChallengeId != "" {
                                        self.pUser.registerType = RegisterType.FACEBOOK
                                        self.goToPhoneNumberVerify(challengeId: (result.data?.phoneNoChallengeId)!, socialId: id)
                                    } else if result.data?.securityCode != "" {
                                        self.processDataForSuccessfullSignIn(result: result)
                                    }

                                } else {
                                    if result.status == "Exception" {
                                        let errorMsg = result.errorMsg[0]
                                        if errorMsg == "CM-55" {
                                            print("Login error:", errorMsg)
                                        } else if errorMsg == "CM-56" {
                                            self.alert(message: errorStrings.invalidPhone)
                                        } else if errorMsg == "IU-100" {
                                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                        } else {
                                            print("Login error:", errorMsg)

                                            self.alert(message: errorStrings.unKnownAlert)
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }

    private func getFacebookUserInfo(completion: @escaping (_: [String: Any]?, _: Error?) -> Void) {
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large)"]) // gender, birthday
        request.start { _, result, error in
            if error != nil {
                NSLog(error.debugDescription)
                return
            }
            completion(result as? [String: Any], nil)
        }
    }

    private func alterTopLayout(registerType: String) {
        switch registerType {
        case RegisterType.NEVER_REGISTERED:
            topViewWithQR.isHidden = true
            topViewWithLogo.isHidden = false
            continuesWithDifferentProfileLabel.isHidden = true
        case RegisterType.MANUAL:
            topViewWithQR.isHidden = false
            topViewWithLogo.isHidden = true
            continuesWithDifferentProfileLabel.isHidden = false
        case RegisterType.GOOGLE:
            topViewWithQR.isHidden = false
            topViewWithLogo.isHidden = true
            continuesWithDifferentProfileLabel.isHidden = false
            dividerLineForMobileLoginButton.removeFromSuperview()

            googleLoginButton.removeFromSuperview()
            qrLoginButtonParentView?.addArrangedSubview(googleLoginButton)
            qrLoginButton.removeFromSuperview()
        case RegisterType.FACEBOOK:
            topViewWithQR.isHidden = false
            topViewWithLogo.isHidden = true
            continuesWithDifferentProfileLabel.isHidden = false
            dividerLineForMobileLoginButton.removeFromSuperview()

            facebookLoginButton.removeFromSuperview()
            qrLoginButtonParentView?.addArrangedSubview(facebookLoginButton)
            qrLoginButton.removeFromSuperview()
        default:
            print("err - SocialLoginController:alterTopLayout()")
        }
    }

    func sign(_: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            let email = user.profile.email ?? ""
            let fullName = user.profile.name ?? ""
            let accessToken = user.authentication.idToken ?? ""
            let phone = UserDefaults.standard.string(forKey: UserKeys.userPhoneNumber) ?? ""

            KeyManager.setSharedSecretKey(key: email, iv: phone)

            Loader.show()

            signInMethod(emailId: email, registerType: RegisterType.GOOGLE, accessToken: accessToken) {
                result, success in if let result = result as? SignInResponseModel, success {
                    print("result: \(result)")

                    Loader.close()

                    if result.status == "Success" {
                        if result.data?.doRegister == "true" {
                            if user.profile.hasImage, let photo = user.profile.imageURL(withDimension: UInt(800)) {
                                self.pUser.registerType = RegisterType.GOOGLE
                                self.initiateNextViewController(name: fullName, emailId: email, photo: photo.absoluteString)
                            } else {
                                print("Can't get g+ profile image & user has profileImage: \(user.profile.hasImage ? "Yes" : "No")")
                                self.pUser.registerType = RegisterType.GOOGLE
                                self.initiateNextViewController(name: fullName, emailId: email)
                            }
                        } else if result.data?.phoneNoChallengeId != "" {
                            self.pUser.registerType = RegisterType.GOOGLE

                            self.goToPhoneNumberVerify(challengeId: (result.data?.phoneNoChallengeId)!, socialId: email)

                        } else if result.data?.securityCode != "" {
                            self.processDataForSuccessfullSignIn(result: result)
                        }

                    } else {
                        if result.status == "Exception" {
                            let errorMsg = result.errorMsg[0]
                            if errorMsg == "CM-55" {
                                print("Login error:", errorMsg)
                            } else if errorMsg == "CM-56" {
                                self.alert(message: errorStrings.invalidPhone)
                            } else {
                                print("Login error:", errorMsg)
                                self.alert(message: errorStrings.unKnownAlert)
                            }
                        }
                    }
                }
            }
        }
    }

    private func checkAndChangeMobileNumber(result: GetMemberProfileResponseModel) {
        if let globalUserId = result.data?.globalUserId, !globalUserId.isEmpty,
            let phoneNumber = result.data?.phoneNumber, !phoneNumber.isEmpty,
            let countryIsoCode = result.data?.countryCode {
            if pUser.phoneNumber != phoneNumber {
                let deviceToken = UserDefaults.standard.value(forKey: UserKeys.deviceToken)
                let changeNumberModel = ChangeNumberRequestModel(
                    securityCode: pUser.securityCode,
                    globalId: pUser.globalUserId,
                    oldNumber: PhoneNumber(countryIsoCode: pUser.countryCode, phoneNumber: pUser.phoneNumber),
                    newNumber: PhoneNumber(countryIsoCode: countryIsoCode, phoneNumber: phoneNumber), deviceApn: deviceToken as! String, deviceApnType: UserKeys.deviceType
                )

                NetworkingManager.changeNumber(changeNumberModel: changeNumberModel, listener: { result, success in
                    if let _ = result as? ChangeNumberResponseModel, success {
                        let updateLastLoginModel = UpdatelastLoginModel(
                            securityCode: self.pUser.securityCode,
                            globalId: self.pUser.globalUserId
                        )

                        NetworkingManager.updateLastLogin(changeNumberModel: updateLastLoginModel, listener: { _, _ in

                        })
                    }
                })
            }
        }
    }

    private func getMemberProfile(emailId: String, registerType: String, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        let getMemberProfile = GetMemberProfileRequestModel()
        getMemberProfile.auth.isoCode = pUser.countryCode
        getMemberProfile.auth.phoneNumber = pUser.phoneNumber
//        getMemberProfile.auth.securityCode = self.pUser.securityCode
//        getMemberProfile.globalUserId = ""
//        getMemberProfile.phoneNumber = ""
        getMemberProfile.registrationReference = emailId
        getMemberProfile.registerType = registerType
        NetworkingManager.getMemberProfileByNonMember(getMemberProfileModel: getMemberProfile, listener: listener)
    }

    private func signInMethod(emailId: String, registerType: String, accessToken: String, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        UserDefaults.standard.set(accessToken, forKey: UserKeys.socialAccessToken)

        let phone = UserDefaults.standard.string(forKey: UserKeys.userPhoneNumber) ?? ""
        if emailId != "" {
            KeyManager.setSharedSecretKey(key: emailId, iv: phone)
        } else {
            KeyManager.setSharedSecretKey(key: UserDefaults.standard.string(forKey: UserKeys.serverDeviceId)!, iv: phone)
        }

        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                let signInModel = signinRequestModel()
                signInModel.phoneNumber = pUser.phoneNumber
                signInModel.countryIsoCode = pUser.countryCode
                signInModel.socialType = registerType
                signInModel.socialAccessToken = accessToken
                signInModel.deviceId = UserDefaults.standard.string(forKey: UserKeys.serverDeviceId)!
                signInModel.loginSessionId = UserDefaults.standard.string(forKey: UserKeys.loginSession)!
                if let deviceToken = UserDefaults.standard.value(forKey: UserKeys.deviceToken) {
                    signInModel.deviceToken = deviceToken as! String
                    signInModel.deviceType = UserKeys.deviceType
                } else {
                    signInModel.deviceToken = ""
                    signInModel.deviceType = UserKeys.deviceType
                }
                NetworkingManager.signIn(signInrequest: signInModel, listener: listener)
            }
        } else {
            alert(message: "Internet is required")
        }
    }

    // Note: Should set pRegisterType before calling this method
    private func initiateNextViewController(name: String = "", emailId: String = "", dateOfBirth _: String = "", photo: String = "", gender: String = "") {
        if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "profile_setup_controller") as? ProfileSetupController {
            // TODO:
//            if let day = dateOfBirth.toDate()?.day, let month = dateOfBirth.toDate()?.month {
//                pUser.dateofBirth = String(day)
//                pUser.monthYearOfBirth = String(month)
//            }
            pUser.fullName = name
            pUser.picture = photo
            pUser.emailId = emailId
            pUser.gender = getGenderType(gender: gender)
            nextViewController.pUser = pUser
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }

    func processDataForSuccessfullSignIn(result: SignInResponseModel) {
        let pubSubKey = result.data?.pubnubSubscriberKey
        let pubpublishKey = result.data?.pubnubPublisherKey
        let pubnubaccessKey = result.data?.pubnubaccessKey
        
        let securityCode = result.data?.securityCode
        let globalUserId = result.data?.globalUserId

        let awsAccessKey = result.data?.awsAccessKey ?? ""
        let awsSecretKey = result.data?.awsSecretKey ?? ""

        pUser.securityCode = securityCode ?? ""
        pUser.globalUserId = globalUserId ?? ""
        pUser.fullName = result.data?.profileData?.name ?? ""
        pUser.picture = result.data?.profileData?.picture ?? ""
        pUser.gender = result.data?.profileData?.gender ?? ""
        pUser.dateofBirth = result.data?.profileData?.dateOfBirth ?? ""
        pUser.monthYearOfBirth = result.data?.profileData?.monthYearOfBirth ?? ""
        pUser.userQrcode = result.data?.profileData?.userQrcode ?? ""
        UserDefaults.standard.set(result.data?.profileData?.userQrcode, forKey: UserKeys.userQrcode)
        UserDefaults.standard.set(globalUserId, forKey: UserKeys.userGlobalId)
        UserDefaults.standard.set(securityCode, forKey: UserKeys.serverSecurityCode)
  
        UserDefaults.standard.set(pubSubKey, forKey: UserKeys.serverPubNubSubscribe)
        UserDefaults.standard.set(pubpublishKey, forKey: UserKeys.serverPubNubPublish)
        UserDefaults.standard.set(pubnubaccessKey, forKey: UserKeys.pubnubAccessKey)
        
        UserDefaults.standard.set(awsAccessKey, forKey: UserKeys.serverAWSAccessKey)
        UserDefaults.standard.set(awsSecretKey, forKey: UserKeys.serverAWSSecretKey)

        UserDetailsProcessingClass.saveToUserDefaults(pUser: pUser)
        UserDetailsProcessingClass.createChannelForSystemNotifications()
        DatabaseManager.storeUserInfo(userModel: pUser)
        subscribeToPubNub()
        DispatchQueue.global(qos: .background).async {
            let activeGroupProcessor = ACActiveGroupProcessor()
            activeGroupProcessor.processDataForGroups(groups: result.data?.activeGroupModel ?? [])
        }
        let timestamp = getcurrentTimeStampFOrPubnub()
        let startDate = NSNumber(value: timestamp)

        let tstamp = getcurrentTimeStamp()
        let stDate = NSNumber(value: tstamp)
        UserDefaults.standard.set(stDate, forKey: UserKeys.lastBroadcastSigninTime)
        UserDefaults.standard.set(startDate, forKey: UserKeys.lastSigninTime)
        let storyBoard = UIStoryboard(name: "ContactsImport", bundle: nil)
        if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ContactsImportViewController") as? ContactsImportViewController {
            nextViewController.modalPresentationStyle = .fullScreen
            present(nextViewController, animated: true, completion: nil)
        }

        print(result)
    }

    // Note: Google login delegate methods
    func sign(_: GIDSignIn!, didDisconnectWith _: GIDGoogleUser!, withError _: Error!) {}

    func sign(_: GIDSignIn!, present _: UIViewController!) {}

    func sign(_: GIDSignIn!, dismiss _: UIViewController!) {}

    func sign(inWillDispatch _: GIDSignIn!, error _: Error!) {}

    override func viewWillDisappear(_: Bool) {
        navigationController?.navigationBar.isHidden = false
    }

    func getGenderType(gender: String) -> String {
        if gender == "male" {
            return "1"
        } else if gender == "female" {
            return "2"
        } else {
            return "3"
        }
    }

    func subscribeToPubNub() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.subscribeToPubNub()
            let user = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String

            let pubnubNotication = ACPubnubClass()
            pubnubNotication.subscribeToPubnubNotificationForGroup(groupChannelId: user!)
        }
    }

    func goToPhoneNumberVerify(challengeId: String, socialId: String) {
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "OldPhoneNumberViewController") as? OldPhoneNumberViewController else {
            Loader.close()
            return print("something went wrong ViewController: onValidateButtonClicked() 2")
        }

        nextViewController.pUser = pUser

        nextViewController.challengeId = challengeId
        nextViewController.socialId = socialId

        present(nextViewController, animated: true, completion: nil)
    }
    // :- LoginQRDelegate
    
    func sendQRSecretCode(st: String) {
        
        self.signInMethod(emailId: "", registerType: RegisterType.MANUAL, accessToken: st) {
            result, success in
            if let result = result as? SignInResponseModel, success {
                print("result: \(result)")
                
                //                                self.checkAndChangeMobileNumber(result: result)
                Loader.close()
                
                if result.status == "Success" {
                    if result.data?.doRegister == "true" {
                        self.alert(message: "Please register")
                        return
                    }
//                        // TODO: changing picture as profile_pic for testing
//                        if let pictureDictionary = userInfo["picture"] as? [String: Any], let data = pictureDictionary["data"] as? [String: Any], let photo = data["url"] as? String {
//                            print("Got fb profile image")
//                            self.pUser.registerType = RegisterType.FACEBOOK
//                            self.initiateNextViewController(name: name, emailId: id, dateOfBirth: birthday, photo: photo, gender: gender)
//                        } else {
//                            print("Can't get fb profile image")
//                            self.pUser.registerType = RegisterType.FACEBOOK
//                            self.initiateNextViewController(name: name, emailId: email, dateOfBirth: birthday, gender: gender)
//                        }
//                    } else if result.data?.phoneNoChallengeId != "" {
//                        self.pUser.registerType = RegisterType.FACEBOOK
//                        self.goToPhoneNumberVerify(challengeId: (result.data?.phoneNoChallengeId)!, socialId: id)
//                    } else if result.data?.securityCode != "" {
                        self.processDataForSuccessfullSignIn(result: result)
//                    }
                    
                } else {
                    if result.status == "Exception" {
                        let errorMsg = result.errorMsg[0]
                        if errorMsg == "CM-55" {
                            print("Login error:", errorMsg)
                        } else if errorMsg == "CM-56" {
                            self.alert(message: errorStrings.invalidPhone)
                        } else if errorMsg == "IU-100" {
                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        } else {
                            print("Login error:", errorMsg)
                            
                            self.alert(message: errorStrings.unKnownAlert)
                        }
                    }
                }
            }
        }
    }
}


