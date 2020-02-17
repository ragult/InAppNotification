//
//  ViewController.swift
//  alltimecommunicator
//
//  Created by Droid5 on 22/08/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import CountryPickerView
import EVReflection
import SafariServices
import UIKit

class ViewController: UIViewController, CountryPickerViewDelegate {
    @IBOutlet var mobileTextField: UITextField?

    let countryPickerView = CountryPickerView()
    var countryPickerControl = CountryPickerControl()
    let indianCountryCode = "IN"
    var selectedCountry: Country?
    var delegate = UIApplication.shared.delegate as? AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        countryPickerView.delegate = self
        countryPickerControl.frame.size = CGSize(width: CGFloat(105), height: CGFloat(36))
        selectedCountry = countryPickerView.getCountryByCode(indianCountryCode)
        countryPickerControl.countryFlagImage.image = selectedCountry?.flag
        countryPickerControl.phoneCodeLabel.text = selectedCountry?.phoneCode
//        countryPickerControl.phoneCodeLabel.font = UIFont.systemFont(ofSize: 10)
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(ViewController.countryPickerClicked))
        countryPickerControl.addGestureRecognizer(tapGestureRecogniser)
        let floatVersion = (UIDevice.current.systemVersion as NSString).floatValue
        if floatVersion >= 13.0 {
            self.mobileTextField?.leftView = self.countryPickerView
        } else {
            self.mobileTextField?.leftView = self.countryPickerControl
        }
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
            alert(message: "Phone number is required")
            Loader.close()

        } else if mobileNumber.count != TextFieldMaxLength.MOBILE {
            print("invalid phone number")
            alert(message: "Enter valid phone number")
            Loader.close()
        } else {
            if delegate != nil {
                if (delegate?.isInternetAvailable)! {
                    Loader.show()

                    NetworkingManager.getOtp(countryIsoCode: selectedCountry?.code ?? "", phoneNumber: countryCode + mobileNumber, listener: {
                        (result: Any, success: Bool) in if let result = result as? SendOtpResponseModel, success {
                            print(result)
                            if success {
                                if result.status == "Success" {
                                    guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "otp_validation_controller") as? OTPValidationController else {
                                        Loader.close()
                                        return print("something went wrong ViewController: onValidateButtonClicked() 2")
                                    }

                                    UserDefaults.standard.set(countryCode, forKey: UserKeys.countryCode)
                                    UserDefaults.standard.set(result.data?.deviceId ?? "", forKey: UserKeys.serverDeviceId)
                                    let user = UserModel()
                                    user.countryCode = self.selectedCountry?.code ?? ""
                                    user.phoneNumber = countryCode + mobileNumber
                                    user.countryISOCode = countryCode
                                    nextViewController.pUser = user
                                    nextViewController.pUserOtp = result.data?.otp?.stringValue ?? ""
                                    nextViewController.pUserDeviceId = result.data?.deviceId ?? ""
                                    self.present(nextViewController, animated: true, completion: nil)
                                } else {
                                    Loader.close()
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
                            } else {
                                Loader.close()
                            }
                        }
                        Loader.close()
                    })
                } else {
                    alert(message: "Internet is required")
                }
            }
        }
    }

    @IBAction func onClickOftermsAndConditionsButton(_: Any) {
        let url = URL(string: "https://www.google.com/")
        let vc = SFSafariViewController(url: url!)
        present(vc, animated: true)
    }
}
