//
//  OTPValidationController.swift
//  alltimecommunicator
//
//  Created by Droid5 on 23/08/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import CountryPickerView
import EVReflection
import UIKit

class ACChangePhoneViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var parentStackView: UIStackView!
    @IBOutlet var otpTextFieldParentStackView: UIStackView!
    @IBOutlet var resendOtpStackView: UIStackView!

    private let OTP_MAX_LENGTH = 6
    internal var pUser = UserModel()
    var delegate = UIApplication.shared.delegate as? AppDelegate

    // TODO: remove this variable, as userOtp must be entered manually
    internal var pUserOtp: String = ""
    internal var pUserDeviceId: String = ""

    private struct OtpTextFieldIndex {
        static let firstTextField = 0
        static let secondTextField = 1
        static let thirdTextField = 2
        static let fourthTextField = 3
        static let fifthTextField = 4
        static let sixthTextField = 5
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroudView = parentStackView.extAddBackground(color: UIColor.white)
        backgroudView.extCornerRadius = 4
        backgroudView.isUserInteractionEnabled = true
        parentStackView.extDropShadow()
        initiatingOtpTextFields()
        initializingResendOtp()
    }

    override func viewWillAppear(_: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications
    }

    private func initializingResendOtp() {
        resendOtpStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resendOtpClicked)))
    }

    @objc private func resendOtpClicked(_: UITapGestureRecognizer) {
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                Loader.show()
                NetworkingManager.getOtp(countryIsoCode: pUser.countryCode, phoneNumber: pUser.phoneNumber, listener: { result, _ in
                    if let result = result as? SendOtpResponseModel {
                        let userOtp: Int = result.data?.otp?.intValue ?? 0
                        self.pUserDeviceId = result.data?.deviceId ?? ""
                        self.showRecievedOtpInTextFields(userOtp: String(userOtp))
                    }
                    Loader.close()
                })
            } else {
                alert(message: "Internet is required")
            }
        }
    }

    private func initiatingOtpTextFields() {
        //        otpTextFieldParentStackView.subviews[OtpTextFieldIndex.firstTextField].becomeFirstResponder()
        otpTextFieldParentStackView.subviews.forEach { view in
            if let view = view as? UITextField {
                view.delegate = self
                view.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
            }
        }
        showRecievedOtpInTextFields(userOtp: pUserOtp)
    }

    // TODO: remove this after testing (it sets the otp by default without manual typing)
    private func showRecievedOtpInTextFields(userOtp: String) {
        otpTextFieldParentStackView.subviews.forEach { view in if let view = view as? UITextField, !userOtp.isEmpty, userOtp.count == 6 {
            let index = (otpTextFieldParentStackView.subviews.firstIndex(of: view) ?? 1) - 1
            view.text = String(userOtp[index])
        } }
        //        otpTextFieldParentStackView.subviews[OtpTextFieldIndex.fifthTextField].becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeClicked(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func verifyClicked(_: UIButton) {
        var userOtp: String = ""
        otpTextFieldParentStackView.subviews.forEach { view in
            if let view = view as? UITextField {
                userOtp.append(view.text ?? "")
            }
        }
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                if !userOtp.isEmpty || userOtp.count < OTP_MAX_LENGTH {
                    Loader.show()
                    let changeModel = ChangeNumberModel()
                    let authDetails = GlobalAuth()
                    authDetails.globalUserId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
                    authDetails.securityCode = UserDefaults.standard.string(forKey: UserKeys.serverSecurityCode)
                    authDetails.deviceId = UserDefaults.standard.string(forKey: UserKeys.serverDeviceId)

                    changeModel.auth = authDetails
                    changeModel.newIsoCode = pUser.countryCode
                    changeModel.newPhoneNumber = pUser.phoneNumber
                    changeModel.newDeviceId = pUserDeviceId
                    changeModel.otp = userOtp

                    NetworkingManager.changePhoneNumber(changeNumbermodel: changeModel, listener: {
                        result, success in
                        if let result = result as? VerifyOtpResponseModel, success {
                            if result.status == "Success" {
                                UserDefaults.standard.set(self.pUserDeviceId, forKey: UserKeys.serverDeviceId)
                                UserDefaults.standard.set(self.pUser.phoneNumber, forKey: UserKeys.userPhoneNumber)
                                let userId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String

                                DatabaseManager.updateMemberPhoneNumber(phoneNumber: self.pUser.phoneNumber, globalUserId: userId!)
                                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

                            } else {
                                // error handling
                                Loader.close()
                                if result.status == "Exception" {
                                    let errorMsg = result.errorMsg[0]
                                    if errorMsg == "IU-100" || errorMsg == "AUT-101" {
                                        self.gotohomePage()
                                    } else if errorMsg == "VO-57" {
                                        self.alert(message: "Please enter a valid OTP")
                                    } else {
                                        self.alert(message: errorMsg)
                                    }
                                }
                            }
                        }
                        Loader.close()
                    })
                }
            } else {
                alert(message: "Internet is required")
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        if touches.first?.view == view {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text
        guard let index = otpTextFieldParentStackView.subviews.firstIndex(of: textField) else {
            return print("err - OTPValidationController:textFieldDidChange() 1")
        }
        if text?.count == 1 {
            switch index {
            case OtpTextFieldIndex.firstTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.secondTextField].becomeFirstResponder()
            case OtpTextFieldIndex.secondTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.thirdTextField].becomeFirstResponder()
            case OtpTextFieldIndex.thirdTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.fourthTextField].becomeFirstResponder()
            case OtpTextFieldIndex.fourthTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.fifthTextField].becomeFirstResponder()
            case OtpTextFieldIndex.fifthTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.sixthTextField].becomeFirstResponder()
            case OtpTextFieldIndex.sixthTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.sixthTextField].becomeFirstResponder()
            default:
                print("err - OTPValidationController:textFieldDidChange() 2")
            }
        } else if text?.count == 0 {
            switch index {
            case OtpTextFieldIndex.firstTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.firstTextField].becomeFirstResponder()
            case OtpTextFieldIndex.secondTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.firstTextField].becomeFirstResponder()
            case OtpTextFieldIndex.thirdTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.secondTextField].becomeFirstResponder()
            case OtpTextFieldIndex.fourthTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.thirdTextField].becomeFirstResponder()
            case OtpTextFieldIndex.fifthTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.fourthTextField].becomeFirstResponder()
            case OtpTextFieldIndex.sixthTextField:
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.fifthTextField].becomeFirstResponder()
            default:
                print("err - OTPValidationController:textFieldDidChange() 3")
            }
        }
    }
}
