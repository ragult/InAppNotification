//
//  CreatePollViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 28/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import IQKeyboardManagerSwift
import McPicker
import UIKit

class CreatePollViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var createButton: UIButton!
    @IBOutlet var dismissBtn: UIButton!
    var placeholderImage = UIImage()
    var datetime = ""
    var numberOfOptions = 2
    var selectedDate: Date?

    @IBOutlet var questionTextField: UITextField!

    @IBOutlet var lblExpiresdate: UILabel!
    @IBOutlet var option1Tf: UITextField!
    @IBOutlet var option2Tf: UITextField!
    @IBOutlet var option3Tf: UITextField!
    @IBOutlet var option4Tf: UITextField!

    @IBOutlet var option1Image: UIImageView!

    @IBOutlet var option2Image: UIImageView!

    @IBOutlet var option3Image: UIImageView!

    @IBOutlet var option4Image: UIImageView!

    @IBOutlet var stack3: UIStackView!

    @IBOutlet var stack4: UIStackView!

    @IBOutlet var addMoreStack: UIStackView!

    @IBOutlet var timeBtn: UIButton!

    @IBOutlet var dateBtn: UIButton!

    @IBOutlet var expiryDatePicker: UIDatePicker!

    @IBOutlet var pickerView: UIView!

    @IBOutlet var deleteOption1: UIButton!

    @IBOutlet var deleteOption2: UIButton!

    @IBOutlet var deleteOption3: UIButton!
    @IBOutlet var deleteOption4: UIButton!

    @IBOutlet var addImage1: UIButton!
    @IBOutlet var addImage2: UIButton!
    @IBOutlet var addImage3: UIButton!
    @IBOutlet var addImage4: UIButton!

    var groupType: String?

    weak var pollDelegate: processPollDataDelegate?

    var getDate: String = ""
    var getTime: String = ""

    var delegate = UIApplication.shared.delegate as? AppDelegate

    private struct SECTION {
        static let TITLE_SECTION: Int = 0
        static let POLL_OPTIONS_SECTION: Int = 1
        static let POLL_ADD_OPTIONS_SECTION = 2
        static let POLL_EXPIREON_SECTION: Int = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true

        option1Tf.delegate = self

        // Do any additional setup after loading the view.
    }

    @IBAction func dismissBtnAction(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func createbuttonAction(_: Any) {
        if !(questionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            if dateBtn.titleLabel?.text != "Date" {
                if timeBtn.titleLabel?.text != "Time" {
                    let choices = NSMutableArray()
                    if imageDict.allKeys.count > 0 {
                        if imageDict.allKeys.count >= 2 {
                            for options in imageDict.allValues {
                                Loader.show()
                                if let imgdata = (options as! UIImage).pngData() {
                                    let finalName = ACMessageSenderClass.getTimestampForPubnubWithUserId()

                                    let path = ACImageDownloader.saveImageDocumentDirectory(attachData: imgdata, attachName: finalName, downloadtype: downLoadType.media, extn: ".png")
                                    print(path)
                                    let name = finalName + ".png"
                                    let config = AWSManager.instance.getConfig(
                                        gType: groupType ?? "",
                                        isChat: true,
                                        isProfile: false,
                                        fileName: name,
                                        type: s3BucketName.imageType
                                    )
                                    // s3BucketName.mediaBucketImage
                                    AWSManager.instance.uploadDataS3(config: config, data: imgdata) { (url, error) in
//                                        let fileName = s3BucketName.chatBucketName + "/"  + s3BucketName.mediaBucketImage + name

                                        let data = NSMutableDictionary()
                                        data.setValue("", forKey: "choiceText")
                                        data.setValue(url, forKey: "choiceImage")

                                        choices.add(data)

                                        if choices.count == self.imageDict.allKeys.count {
                                            self.submitCreatePoll(pollType: "2", data: choices)
                                        }
                                    }
                                }
                            }
                        } else {
                            alert(message: "Please choose atleast 2 Images for creating a poll")
                        }

                    } else {
                        for i in 0 ..< numberOfOptions {
                            let data = NSMutableDictionary()

                            if i == 0 {
                                if !(option1Tf.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
                                    data.setValue(option1Tf.text, forKey: "choiceText")
                                    data.setValue("", forKey: "choiceImage")

                                } else {
                                    alert(message: "please enter a valid poll Choice ")
                                }
                            }
                            if i == 1 {
                                if !(option2Tf.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
                                    data.setValue(option2Tf.text, forKey: "choiceText")
                                    data.setValue("", forKey: "choiceImage")

                                } else {
                                    alert(message: "please enter a valid poll Choice ")
                                }
                            }
                            if i == 2 {
                                if !(option3Tf.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
                                    data.setValue(option3Tf.text, forKey: "choiceText")
                                    data.setValue("", forKey: "choiceImage")

                                } else {
                                    alert(message: "please enter a valid poll Choice ")
                                }
                            }
                            if i == 3 {
                                if !(option4Tf.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
                                    data.setValue(option4Tf.text, forKey: "choiceText")
                                    data.setValue("", forKey: "choiceImage")

                                } else {
                                    alert(message: "please enter a valid poll Choice ")
                                }
                            }
                            choices.add(data)
                        }
                        submitCreatePoll(pollType: "1", data: choices)
                    }

                } else {
                    alert(message: "Choose poll end time")
                }
            } else {
                alert(message: "Choose poll end date")
            }
        } else {
            alert(message: "Enter the poll question")
        }
    }

    func submitCreatePoll(pollType: String, data: NSMutableArray) {
        let name = questionTextField.text

        let pollReq = PollCreateRequestObject()
        pollReq.auth = DefaultDataProcessor().getAuthDetails()
        pollReq.choices = data
        pollReq.question = name!
        pollReq.pollEndDate = datetime
        pollReq.pollChoicetyp = pollType

        Loader.show()
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                NetworkingManager.createPoll(getGroupModel: pollReq) { (result: Any, sucess: Bool) in
                    if let results = result as? createPollResponseModel, sucess {
                        Loader.close()
                        if sucess {
                            if results.status == "Success" {
                                let questionId = results.data?.first?.pollId ?? ""
                                print(questionId)

                                let choices = results.data
                                let attch = NSMutableDictionary()

                                var data = [PollTable.PollOptions]()
                                for choice in (choices?.first!.choices)! {
                                    let ch = choice
                                    let option = PollTable.PollOptions()
                                    option.choiceText = ch.choiceText
                                    option.choiceImage = ch.choiceImage
                                    option.choiceId = ch.choiceId

                                    let componentsArray = ch.choiceImage.components(separatedBy: "/")
                                    let nm = componentsArray.last ?? ""
                                    attch.setValue(nm, forKey: ch.choiceId)
                                    data.append(option)
                                }
                                let attachmentString = ACMessageSenderClass.convertDictionaryToJsonString(dict: attch)

                                let obj = data.toJsonString()

                                let polldata = PollTable()
                                polldata.pollId = questionId
                                polldata.messageId = ""

                                polldata.pollTitle = choices?.first?.pollQuestion ?? ""
                                polldata.pollCreatedOn = String(format: "%.0f", self.getcurrentTimeStampFOrPubnub())

                                polldata.pollCreatedBy = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!

                                polldata.pollExpireOn = choices?.first?.pollEndDate ?? ""
                                polldata.pollType = choices?.first?.pollType ?? ""
                                polldata.pollOPtions = obj
                                polldata.selectedChoice = ""
                                polldata.numberOfOptions = data.count
                                polldata.localData = attachmentString
//                                let pollLocalId = DatabaseManager.storePollData(pollTable: polldata)

                                let dataDict = NSMutableDictionary()
                                dataDict.setValue(questionId, forKey: "pollId")
                                dataDict.setValue(polldata.pollType, forKey: "pollType")
                                dataDict.setValue(polldata.pollTitle, forKey: "pollTitle")
                                dataDict.setValue(polldata.pollCreatedBy, forKey: "pollCreatedBy")
                                dataDict.setValue(polldata.pollExpireOn, forKey: "pollEndDate")

                                let attachdict = NSMutableDictionary()
                                attachdict.setValue(dataDict, forKey: "pollData")

                                let str = self.convertDictionaryToJsonString(dict: attachdict)

                                self.pollDelegate?.processDataForPoll(mediaObj: str, pollObj: polldata, type: attachmentType.poll)

                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            } else {
                Loader.close()

                alert(message: "Internet is required")
            }
        }
    }

    @IBAction func onclickOfDOne(_: UIButton) {
        if expiryDatePicker.tag == 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            let year: String = dateFormatter.string(from: expiryDatePicker.date)
            getDate = year
            dateBtn.setTitle(year, for: .normal)
            selectedDate = expiryDatePicker.date
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            let ttext = dateFormatter.string(from: expiryDatePicker.date)
            getTime = ttext
            timeBtn.setTitle(ttext, for: .normal)
            selectedDate = expiryDatePicker.date
        }

        if getDate != "", getTime != "" {
            lblExpiresdate.isHidden = false
            if let date = selectedDate {
                let diffInDays = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: Date(), to: date)
                if diffInDays.hour! == 0, diffInDays.day! == 0, diffInDays.month! == 0, diffInDays.year! == 0, diffInDays.minute! == 0 {
                    lblExpiresdate.isHidden = true
                    getTime = ""
                    timeBtn.setTitle("Time", for: .normal)
                    alert(message: "Choose some other time")
                } else if diffInDays.hour! <= 24, diffInDays.hour! == 0, diffInDays.day! == 0, diffInDays.month! == 0, diffInDays.year! == 0 {
                    let da = diffInDays.minute! == 1 ? "Min" : "Mins"
                    lblExpiresdate.text = "Expires : \(String(describing: diffInDays.minute!)) \(da)"
                } else if diffInDays.hour! <= 24, diffInDays.hour! > 0, diffInDays.day! == 0, diffInDays.month! == 0, diffInDays.year! == 0 {
                    let da = diffInDays.hour! == 1 ? "hr" : "hrs"
                    let min = diffInDays.minute! == 1 ? "min" : "mins"

                    lblExpiresdate.text = "Expires : \(String(describing: diffInDays.hour!)) \(da), \(String(describing: diffInDays.minute!)) \(min) "
                } else if diffInDays.hour! <= 24, diffInDays.day! > 0, diffInDays.day! <= 30, diffInDays.month! == 0, diffInDays.year! == 0 {
                    if diffInDays.hour! > 0 {
                        let da = diffInDays.day! == 1 ? "day" : "days"
                        let h = diffInDays.hour! == 1 ? "hr" : "hrs"
                        lblExpiresdate.text = "Expires : \(String(describing: diffInDays.day!)) \(da) \(String(describing: diffInDays.hour!)) \(h)"
                    } else {
                        let da = diffInDays.day! == 1 ? "day" : "days"
                        lblExpiresdate.text = "Expires : \(String(describing: diffInDays.day!)) \(da)"
                    }
                } else if diffInDays.month! > 0, diffInDays.month! <= 12, diffInDays.year! == 0 {
                    if diffInDays.day! > 0 {
                        let da = diffInDays.day! == 1 ? "day" : "days"
                        let mo = diffInDays.month! == 1 ? "month" : "months"
                        lblExpiresdate.text = "Expires :  \(String(describing: diffInDays.month!)) \(mo) \(String(describing: diffInDays.day!)) \(da)"
                    } else {
                        let mo = diffInDays.month! == 1 ? "month" : "months"
                        lblExpiresdate.text = "Expires :  \(String(describing: diffInDays.month!)) \(mo)"
                    }
                } else if diffInDays.year! > 0, diffInDays.month! > 0 {
                    let mo = diffInDays.month! == 1 ? "month" : "months"
                    lblExpiresdate.text = "Expires : \(String(describing: diffInDays.year!)) y \(String(describing: diffInDays.month!)) \(mo)"
                } else {
                    lblExpiresdate.text = "Expires : \(String(describing: diffInDays.year!)) y"
                }
                print(diffInDays as Any)
            }
        }

        let endTime = expiryDatePicker.date.timeIntervalSince1970 * 1000
        datetime = String(format: "%.0f", endTime)
        pickerView.isHidden = true
    }

    @IBAction func onClickOfCLose(_: Any) {
        datetime = ""
        pickerView.isHidden = true
    }

    @IBAction func onClickOfDatePicker(_ sender: UIButton) {
        view.endEditing(true)
        if sender.tag == 0 {
            expiryDatePicker.tag = 0
            expiryDatePicker.date = Date()
            expiryDatePicker.minimumDate = Date()
            expiryDatePicker.datePickerMode = .date
            pickerView.isHidden = false

        } else {
            if selectedDate == nil {
                alert(message: "Please Choose poll End Date")

            } else {
                expiryDatePicker.tag = 1
                expiryDatePicker.date = selectedDate!
                expiryDatePicker.datePickerMode = .time
                pickerView.isHidden = false
            }
        }
    }

    @objc func onClickClose(sender _: UIButton) {}

    @objc func onClickDone(sender _: UIButton) {
//        let cell = self.createPollTable.cellForRow(at: indexPath!) as! PollExpiresOnTableViewCell
        ////        cell.containView.isHidden = true
//
//        //set date
//
//        if cell.datePicker.isHidden == false
//        {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy MMMM DD"
//            let year: String = dateFormatter.string(from: cell.datePicker.date)
//
//            cell.lblDate.text = year
//
//        }
//        else
//        {
//            let formatter = DateFormatter()
//            formatter.timeStyle = .short
//            cell.lblTime.text = formatter.string(from: cell.datePicker.date)
//        }
//
//        self.datetime = String(cell.datePicker.date.timeIntervalSince1970 * 10000000)
//
//        cell.datePicker.isHidden = true
//        cell.timePicker.isHidden = true
//        cell.BtnClose.isHidden = true
//        cell.BtnDone.isHidden = true
//
    }

    @objc func tapOnDate(_: UIGestureRecognizer) {
//        cell.BtnClose.isHidden = false
//        cell.BtnDone.isHidden = false
//        cell.containView.isHidden = false
//        if cell.timePicker.isHidden == false
//        {
//            cell.timePicker.isHidden = true
//        }
//        cell.datePicker.isHidden = false
    }

    @objc func tapOnTime(_: UIGestureRecognizer) {
//
//        cell.BtnClose.isHidden = false
//        cell.BtnDone.isHidden = false
//        cell.containView.isHidden = false
//        if cell.datePicker.isHidden == false
//        {
//            cell.datePicker.isHidden = true
//        }
//        cell.timePicker.isHidden = false
    }

    func addLineToView(view: UIView, position: LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        view.addSubview(lineView)

        let metrics = ["width": NSNumber(value: width)]
        let views = ["lineView": lineView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: views))

        switch position {
        case .LINE_POSITION_TOP:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: views))
        case .LINE_POSITION_BOTTOM:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: views))
        default:
            break
        }
    }

    @IBAction func addOption(sender _: UIButton) {
        if stack3.isHidden {
            stack3.isHidden = false
            numberOfOptions = 3
        } else {
            if stack4.isHidden {
                stack4.isHidden = false
                addMoreStack.isHidden = true
                numberOfOptions = 4
            }
        }
    }

    @IBAction func deleteOptionImage(sender: UIButton) {
        imageDict.setValue(placeholderImage, forKey: String(sender.tag))

        if sender.tag == 0 {
            option1Tf.text = ""
            option1Tf.textColor = .black

            option1Tf.isUserInteractionEnabled = true
            option2Tf.isHidden = false
            option3Tf.isHidden = false
            option4Tf.isHidden = false
            imageDict = NSMutableDictionary()
            option1Image.image = nil
            option2Image.image = nil
            option3Image.image = nil
            option4Image.image = nil
            addImage1.isHidden = false
            addImage2.isHidden = false
            addImage3.isHidden = false
            addImage4.isHidden = false
            deleteOption1.isHidden = true
            deleteOption2.isHidden = true
            deleteOption3.isHidden = true
            deleteOption4.isHidden = true
        } else if sender.tag == 1 {
            option2Image.image = nil
            addImage2.isHidden = false
            deleteOption2.isHidden = true

        } else if sender.tag == 2 {
            option3Image.image = nil
            addImage3.isHidden = false
            deleteOption3.isHidden = true

        } else if sender.tag == 3 {
            option4Image.image = nil
            addImage4.isHidden = false
            deleteOption4.isHidden = true
        }
    }

    var imageDict = NSMutableDictionary()

    @IBAction func didTapInserImage(sender: UIButton) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { profileImage in
            let resizedImage = profileImage.resizedTo300Kb()
            self.imageDict.setValue(resizedImage!, forKey: String(sender.tag))
            if sender.tag == 0 {
                self.option1Image.isHidden = false
                self.option1Image.image = resizedImage
                self.option1Tf.text = " "
                self.option1Tf.textColor = .lightGray
                self.option1Tf.isUserInteractionEnabled = false
                self.option2Tf.isHidden = true
                self.option3Tf.isHidden = true
                self.option4Tf.isHidden = true
                self.deleteOption1.isHidden = false
                self.addImage1.isHidden = true

            } else if sender.tag == 1 {
                self.option2Image.isHidden = false
                self.option2Image.image = resizedImage
                self.deleteOption2.isHidden = false
                self.addImage2.isHidden = true

            } else if sender.tag == 2 {
                self.option3Image.isHidden = false
                self.option3Image.image = resizedImage
                self.deleteOption3.isHidden = false
                self.addImage3.isHidden = true

            } else if sender.tag == 3 {
                self.option4Image.isHidden = false

                self.option4Image.image = resizedImage
                self.deleteOption4.isHidden = false
                self.addImage4.isHidden = true
            }
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == option1Tf {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            if newLength == 0 {
                imageDict = NSMutableDictionary()
                option1Image.image = nil
                option2Image.image = nil
                option3Image.image = nil
                option4Image.image = nil
                addImage1.isHidden = false
                addImage2.isHidden = false
                addImage3.isHidden = false
                addImage4.isHidden = false
                deleteOption1.isHidden = true
                deleteOption2.isHidden = true
                deleteOption3.isHidden = true
                deleteOption4.isHidden = true
            } else {
                imageDict = NSMutableDictionary()
                option1Image.image = nil
                option2Image.image = nil
                option3Image.image = nil
                option4Image.image = nil
                addImage1.isHidden = true
                addImage2.isHidden = true
                addImage3.isHidden = true
                addImage4.isHidden = true
                deleteOption1.isHidden = true
                deleteOption2.isHidden = true
                deleteOption3.isHidden = true
                deleteOption4.isHidden = true
            }
        }

        if textField == questionTextField {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            if newLength <= 65 {
                return true
            } else {
                alert(message: "The maximum length for the question has been reached.")
                return false
            }
        } else {
            return true
        }
    }
}

enum LINE_POSITION {
    case LINE_POSITION_TOP
    case LINE_POSITION_BOTTOM
}
