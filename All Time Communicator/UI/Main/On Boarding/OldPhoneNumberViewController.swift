//
//  OldPhoneNumberViewController.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 21/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import CountryPickerView
import EVReflection
import SafariServices
import UIKit

class OldPhoneNumberViewController: UIViewController, CountryPickerViewDelegate {
    @IBOutlet var mobileTextField: UITextField?
    @IBOutlet var parentStackView: UIStackView!
    internal var pUser = UserModel()
    internal var challengeId: String?
    internal var socialId: String?

    let countryPickerView = CountryPickerView()
    var countryPickerControl = CountryPickerControl()
    let indianCountryCode = "IN"
    var selectedCountry: Country?
    var delegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroudView = parentStackView.extAddBackground(color: UIColor.white)
        backgroudView.extCornerRadius = 4
        backgroudView.isUserInteractionEnabled = true
        parentStackView.extDropShadow()

        countryPickerView.delegate = self
        countryPickerControl.frame.size = CGSize(width: CGFloat(105), height: CGFloat(36))
        selectedCountry = countryPickerView.getCountryByCode(indianCountryCode)
        countryPickerControl.countryFlagImage.image = selectedCountry?.flag
        countryPickerControl.phoneCodeLabel.text = selectedCountry?.phoneCode
        //        countryPickerControl.phoneCodeLabel.font = UIFont.systemFont(ofSize: 10)
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(ViewController.countryPickerClicked))
        countryPickerControl.addGestureRecognizer(tapGestureRecogniser)
        mobileTextField?.leftView = countryPickerControl
        mobileTextField?.leftViewMode = .always
    }

    @objc
    func countryPickerClicked(sender _: UITapGestureRecognizer) {
        countryPickerView.showCountriesList(from: self)
    }

    func countryPickerView(_: CountryPickerView, didSelectCountry country: Country) {
        countryPickerControl.countryFlagImage?.image = country.flag
        countryPickerControl.phoneCodeLabel.text = country.phoneCode
        selectedCountry = country
        countryPickerControl.setNeedsLayout()
    }

    @IBAction func onValidateButtonClicked(_: UIButton) {
        var countryCode: String = selectedCountry?.phoneCode ?? ""
        if countryCode.first == "+" {
            countryCode.removeFirst()
        }
        let mobileNumber: String = mobileTextField?.text ?? ""
        if mobileNumber.isEmpty {
            alert(message: "Please enter Phone number")
            Loader.close()

        } else if mobileNumber.count != TextFieldMaxLength.MOBILE {
            print("invalid phone number")
            alert(message: "enter valid Phone number")
            Loader.close()
        } else {
            if delegate != nil {
                if (delegate?.isInternetAvailable)! {
                    Loader.show()

                    signInMethod(oldPhoneNumber: countryCode + mobileNumber, oldIsoCode: selectedCountry?.code ?? "") {
                        result, success in if let result = result as? SignInResponseModel, success {
                            print("result: \(result)")

                            Loader.close()

                            if result.status == "Success" {
                                self.processDataForSuccessfullSignIn(result: result)

                            } else {
                                if result.status == "Exception" {
                                    let errorMsg = result.errorMsg[0]
                                    if errorMsg == "C909" {
                                        self.alert(message: "The phone numbers do not match")
                                    } else if errorMsg == "C910" {
                                        self.alert(message: "This is the last attempt to verify the phone number. Your account will be locked if incorrect number entered")
                                    } else if errorMsg == "C911" {
                                        self.alert(message: "The phone numbers do not match. Your account is locked")
                                        if let appDomain = Bundle.main.bundleIdentifier {
                                            UserDefaults.standard.removePersistentDomain(forName: appDomain)
                                        }
                                        if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                                            let navigationController = UINavigationController(rootViewController: nextViewController)
                                            self.navigationController?.navigationBar.isHidden = true
                                            let appdelegate = UIApplication.shared.delegate as! AppDelegate
                                            appdelegate.window!.rootViewController = navigationController
                                        }

                                    } else {
                                        print("Login error:", errorMsg)
                                    }
                                }
                            }

                            Loader.close()
                        }
                    }
                } else {
                    alert(message: "Internet is required")
                }
            }
        }
    }

    @IBAction func closeClicked(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    private func signInMethod(oldPhoneNumber: String, oldIsoCode: String, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                let signInModel = SigninChallengeRequestModel()
                signInModel.phoneNumber = pUser.phoneNumber
                signInModel.countryIsoCode = pUser.countryCode
                signInModel.deviceId = UserDefaults.standard.string(forKey: UserKeys.serverDeviceId)!
                signInModel.loginSessionId = UserDefaults.standard.string(forKey: UserKeys.loginSession)!
                signInModel.phoneNoChallengeId = challengeId!
                signInModel.oldIsoCode = oldIsoCode
                signInModel.oldPhoneNumber = oldPhoneNumber
                signInModel.registerType = pUser.registerType
                signInModel.socialId = socialId!
                if let deviceToken = UserDefaults.standard.value(forKey: UserKeys.deviceToken) {
                    signInModel.deviceToken = deviceToken as! String
                    signInModel.deviceType = UserKeys.deviceType
                } else {
                    signInModel.deviceToken = "4ff45834dddd3abc1faeb0e3e9dc9de8506e1472b2baa6af6dcd6d230a1f4d44"
                    signInModel.deviceType = UserKeys.deviceType
                }
                NetworkingManager.signInWithChallenge(signInrequest: signInModel, listener: listener)

            } else {
                alert(message: "Internet is required")
            }
        }
    }

    func processDataForSuccessfullSignIn(result: SignInResponseModel) {
        let pubSubKey = result.data?.pubnubSubscriberKey
        let pubpublishKey = result.data?.pubnubPublisherKey
        let pubnubaccessKey = result.data?.pubnubaccessKey
        
        let securityCode = result.data?.securityCode
        let globalUserId = result.data?.globalUserId

        pUser.securityCode = securityCode ?? ""
        pUser.globalUserId = globalUserId ?? ""

        pUser.fullName = result.data?.profileData?.name ?? ""
        pUser.picture = result.data?.profileData?.picture ?? ""
        pUser.gender = result.data?.profileData?.gender ?? ""
        pUser.dateofBirth = result.data?.profileData?.dateOfBirth ?? ""
        pUser.monthYearOfBirth = result.data?.profileData?.monthYearOfBirth ?? ""

        UserDefaults.standard.set(globalUserId, forKey: UserKeys.userGlobalId)
        UserDefaults.standard.set(securityCode, forKey: UserKeys.serverSecurityCode)

        UserDefaults.standard.set(pubSubKey, forKey: UserKeys.serverPubNubSubscribe)
        UserDefaults.standard.set(pubpublishKey, forKey: UserKeys.serverPubNubPublish)
        UserDefaults.standard.set(pubnubaccessKey, forKey: UserKeys.pubnubAccessKey)

        
        let awsAccessKey = result.data?.awsAccessKey ?? ""
        let awsSecretKey = result.data?.awsSecretKey ?? ""
        
        UserDefaults.standard.set(awsAccessKey, forKey: UserKeys.serverAWSAccessKey)
        UserDefaults.standard.set(awsSecretKey, forKey: UserKeys.serverAWSSecretKey)
        pUser.userQrcode = result.data?.profileData?.userQrcode ?? ""
        UserDefaults.standard.set(result.data?.profileData?.userQrcode, forKey: UserKeys.userQrcode)
        
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
        UserDefaults.standard.set(startDate, forKey: UserKeys.lastSigninTime)

        let tstamp = getcurrentTimeStamp()
        let stDate = NSNumber(value: tstamp)
        UserDefaults.standard.set(stDate, forKey: UserKeys.lastBroadcastSigninTime)

        let storyBoard = UIStoryboard(name: "ContactsImport", bundle: nil)
        if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ContactsImportViewController") as? ContactsImportViewController {
            present(nextViewController, animated: true, completion: nil)
        }

        print(result)
    }

    func subscribeToPubNub() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.subscribeToPubNub()
        }
    }
}
