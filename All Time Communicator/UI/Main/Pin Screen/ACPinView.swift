//
//  ACPinView.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 11/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACPinView: UIView, UITextFieldDelegate {
    @IBOutlet var parentStackView: UIStackView!
    @IBOutlet var otpTextFieldParentStackView: UIStackView!
    @IBOutlet var resendOtpStackView: UIStackView!

    @IBOutlet var iphonePassCodeBtn: UIButton!
    @IBOutlet var setButton: UIButton!
    @IBOutlet var enterPinLabel: UILabel!
    @IBOutlet var pinDescriptionLabel: UILabel!
    @IBOutlet var closeButton: UIButton!

    private let OTP_MAX_LENGTH = 4

    private struct OtpTextFieldIndex {
        static let firstTextField = 0
        static let secondTextField = 1
        static let thirdTextField = 2
        static let fourthTextField = 3
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_: CGRect) {
        // Drawing code
        let backgroudView = parentStackView.extAddBackground(color: UIColor.white)
        backgroudView.extCornerRadius = 4
        backgroudView.isUserInteractionEnabled = true
        parentStackView.extDropShadow()
        initiatingOtpTextFields()
    }

    private func initiatingOtpTextFields() {
//        otpTextFieldParentStackView.subviews[OtpTextFieldIndex.firstTextField].becomeFirstResponder()
        otpTextFieldParentStackView.subviews.forEach { view in
            if let view = view as? UITextField {
                view.delegate = self
                view.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
            }
        }
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if touches.first?.view == self.view {
//            dismiss(animated: true, completion: nil)
//        }
//    }

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
                otpTextFieldParentStackView.subviews[OtpTextFieldIndex.fourthTextField].becomeFirstResponder()

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

            default:
                print("err - OTPValidationController:textFieldDidChange() 3")
            }
        }
    }
}
