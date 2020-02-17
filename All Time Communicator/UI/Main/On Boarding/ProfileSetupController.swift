import AlamofireImage
import CoreTelephony
import CountryPickerView
import IQKeyboardManagerSwift
import McPicker
import UIKit

class ProfileSetupController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var genderStackView: UIStackView!
    @IBOutlet var maleStackView: UIStackView!
    @IBOutlet var femaleStackView: UIStackView!
    @IBOutlet var genderOthers: UIStackView!
    @IBOutlet var maleImageView: UIImageView!
    @IBOutlet var femaleImageView: UIImageView!
    @IBOutlet var maleLabel: UILabel!
    @IBOutlet var femaleLabel: UILabel!
    @IBOutlet var genderOthersLabel: UILabel!
    @IBOutlet var monthTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var uploadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var submitBtn: UIButton!

    private let selectedGenderTint = UIColor.white
    private let unSelectedGenderTint = UIColor(r: 153, g: 153, b: 153)
    private let selectedGenderLabelTextColor = UIColor.white
    private let unSelectedGenderLabelTextColor = UIColor(r: 81, g: 81, b: 81)
    private let selectedGenderBackgroundColor = UIColor().extGetPrimaryColor
    private let unSelectedGenderBackgroundColor = UIColor.clear

    private var maleStackViewBackgroundView: UIView!
    private var femaleStackViewBackgroundView: UIView!
    private var genderOthersStackViewBackgroundView: UIView!
    var cloudinaryImageUrl: String?
    var awsConfig: AWSConfigGenarator?
    var imageData: Data?
    
    var isManualLogin : Bool = false
    @IBOutlet var nameTextField: UITextField!
    var delegate = UIApplication.shared.delegate as? AppDelegate

    @IBOutlet var datePicView: UIView!

    @IBOutlet var picker: UIPickerView!

    @IBOutlet var datPic: UIDatePicker!

    private let monthsAndDateData: [(month: String, days: Int)] = [("January", 31), ("February", 29), ("March", 31), ("April", 30), ("May", 31), ("June", 30), ("July", 31), ("August", 31), ("September", 30), ("October", 31), ("November", 30), ("December", 31)]
    var datesData: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    private var selectedGender: Gender = .male

    private enum Picker {
        case MONTH
        case DATE
    }

    private enum Gender: Int {
        case unknown = 0
        case male = 1
        case female = 2
        case genderOthers = 3
        case wontSpecify = 4
    }

    private var profileImageData: Data?

    // Note: making January as defult month
    private var selectedMonthIndex: Int = 0
    internal var pUser = UserModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let calendar = Calendar(identifier: .gregorian)

        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar

        components.year = -18
        components.month = 12
        let maxDate = calendar.date(byAdding: components, to: currentDate)!

        components.year = -150
        let minDate = calendar.date(byAdding: components, to: currentDate)!

        datPic.minimumDate = minDate
        datPic.maximumDate = maxDate

//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy"
//        let year: String = dateFormatter.string(from: datPic.date)
//        dateFormatter.dateFormat = "MMM"
//        let month: String = dateFormatter.string(from: datPic.date)
//        dateFormatter.dateFormat = "dd"
//        let day: String = dateFormatter.string(from: datPic.date)
//        monthTextField.text = month
//        dateTextField.text = day

        initializingGenderStackView()
        uploadActivityIndicator.hidesWhenStopped = true
        uploadActivityIndicator.color = UIColor(r: 33, g: 140, b: 141)
        femaleImageView.extTintColor(color: unSelectedGenderTint)

//        initializingDatesPickerView(days: monthsAndDateData.first?.days ?? 0)
        initializingTextFields()
        initializingCamera()
        initializingData()

        let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR
        navigationController?.navigationBar.tintColor = color3
        navigationController?.navigationBar.topItem?.title = ""
    }

    func initializingData() {
        pUser.gender = ""
        nameTextField.text = pUser.fullName
        if let imageUrl = URL(string: pUser.picture) {
            profileImageView.af_setImage(withURL: imageUrl)

            do {
                let data = try Data(contentsOf: imageUrl, options: [])
                profileImageData = data as Data
                uploadImageToCloud()
            } catch {
                print(error)
            }
        }
        if pUser.gender == "1" {
            selectMale(true)
        } else if pUser.gender == "2" {
            selectFemale(true)
        } else if pUser.gender == "3" {
            selectGenderOthers(true)
        }
        dateTextField.text = pUser.dateofBirth
        monthTextField.text = pUser.monthYearOfBirth
    }

    func uploadImageToCloud() {
        uploadActivityIndicator.startAnimating()
        submitBtn.isEnabled = false
        submitBtn.backgroundColor = .gray
        if let data = self.profileImageData {
            self.awsConfig = AWSManager.instance.getConfig(
                gType: groupType.PRIVATE_GROUP.rawValue,
                isChat: false,
                isProfile: true,
                fileName: ACMessageSenderClass.getTimestampForPubnubWithUserId() + ".png",
                type: s3BucketName.imageType
            )

            AWSManager.instance.uploadDataS3(config: awsConfig!, data: data, completionHandler: { url, error  in
                if error == nil {
                    // s3BucketName.profileBucketName
                    // s3BucketName.profileBucketName + "/"  + s3BucketName.profileUserProfile + name
                    self.imageData = data
                    self.cloudinaryImageUrl = url
                    self.uploadActivityIndicator.stopAnimating()
                    self.submitBtn.backgroundColor = UIColor(r: 33, g: 140, b: 141)
                    self.submitBtn.isEnabled = true
                } else {
                    self.profileImageView.image = UIImage(named: "imagePlaceholder")
                    self.alert(message: errorStrings.unKnownAlert)
                    self.uploadActivityIndicator.stopAnimating()
                    self.submitBtn.backgroundColor = UIColor(r: 33, g: 140, b: 141)
                    self.submitBtn.isEnabled = true
                }
            })
        }
    }

    private func initializingCamera() {
        cameraView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraClicked)))
    }

    @objc private func cameraClicked(sender _: UITapGestureRecognizer) {
        if datePicView.isHidden == false {
            datePicView.isHidden = true
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_: UIAlertAction!) -> Void in
            DispatchQueue.main.async {
//                    CameraHandler.shared.camera()
                self.camera()
            }

        }))

        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (_: UIAlertAction!) -> Void in
            DispatchQueue.main.async {
                self.photoLibrary()
            }

        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        present(actionSheet, animated: true, completion: nil)

//            CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { profileImage in
            self.profileImageView.image = UIImage.resizedCroppedImage(image: profileImage, newSize: CGSize(width: self.profileImageView.frame.width, height: self.profileImageView.frame.height))
            let resizedImage: UIImage? = profileImage.resizedTo500Kb()
            self.profileImageData = resizedImage?.pngData()
            self.uploadImageToCloud()
            print("clicked")
        }
    }

    @IBAction func onclickDone(_: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year: String = dateFormatter.string(from: datPic.date)
        dateFormatter.dateFormat = "MMMM"
        let month: String = dateFormatter.string(from: datPic.date)
        dateFormatter.dateFormat = "dd"
        let day: String = dateFormatter.string(from: datPic.date)
        monthTextField.text = month + " \(day)"
        dateTextField.text = day
        datePicView.isHidden = true
    }

    @IBAction func onclickCancel(_: Any) {
        datePicView.isHidden = true
    }

    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
//            currentVC.present(myPickerController, animated: true, completion: nil)
            present(myPickerController, animated: true, completion: nil)
        } else {
            print("CAMERA NOT AVAILABLE IN THIS DEVICE")
        }
    }

    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
//            currentVC.present(myPickerController, animated: true, completion: nil)
            present(myPickerController, animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
//            self.imagePickedBlock?(image)
            CameraHandler.shared.imagePickedBlock!(image)
        } else {
            print("Something went wrong")
        }
        picker.dismiss(animated: true, completion: nil)
    }

    @objc private func genderSelected(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            switch view {
            case maleStackViewBackgroundView:
                selectMale(true)
                selectFemale(false)
                selectGenderOthers(false)
            case femaleStackViewBackgroundView:
                selectFemale(true)
                selectMale(false)
                selectGenderOthers(false)
            case genderOthersStackViewBackgroundView:
                selectGenderOthers(true)
                selectMale(false)
                selectFemale(false)
            default:
                break
            }
        }
    }

    private func initializingTextFields() {
        // Note: making January 1st as defult date
//        monthTextField.text = monthsAndDateData.first?.month
//        dateTextField.text = datesData.first

        var imageView = UIImageView(image: UIImage(named: "ic_black_down_arrow"))
        // Note: Setting padding for the imageView by increasing width
        if let size = imageView.image?.size {
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        imageView.contentMode = UIView.ContentMode.center
        monthTextField?.rightView = imageView
        monthTextField?.rightViewMode = .always

        imageView = UIImageView(image: UIImage(named: "ic_black_down_arrow"))
        // Note: Setting padding for the imageView by increasing width
        if let size = imageView.image?.size {
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        imageView.contentMode = UIView.ContentMode.center
        dateTextField?.rightView = imageView
        dateTextField?.rightViewMode = .always

        monthTextField.delegate = self
        dateTextField.delegate = self
    }

    private func initializingGenderStackView() {
        let genderStackViewBackgroundView = genderStackView.extAddBackground(color: UIColor.white)
        genderStackViewBackgroundView.extCornerRadius = 4
        genderStackViewBackgroundView.extBorderWidth = 0.5
        genderStackViewBackgroundView.extBorderColor = UIColor(r: 151, g: 151, b: 151)

        maleStackViewBackgroundView = maleStackView.extAddBackground(color: UIColor.clear)
//        maleStackViewBackgroundView.extRoundCornersWithLayerMask(cornerRadii: 4, corners: [.topLeft, .bottomLeft])
        maleStackViewBackgroundView.isUserInteractionEnabled = true
        maleStackViewBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(genderSelected(_:))))

        femaleStackViewBackgroundView = femaleStackView.extAddBackground(color: UIColor.clear)
        femaleStackViewBackgroundView.isUserInteractionEnabled = true
        femaleStackViewBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(genderSelected(_:))))

        genderOthersStackViewBackgroundView = genderOthers.extAddBackground(color: UIColor.clear)
//        genderOthersStackViewBackgroundView.extRoundCornersWithLayerMask(cornerRadii: 0, corners: [.topRight, .bottomRight])
        genderOthersStackViewBackgroundView.isUserInteractionEnabled = true
        genderOthersStackViewBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(genderSelected(_:))))

        // making female as default selected
//        selectFemale(true)
    }

    private func selectMale(_ selected: Bool) {
        if selected {
            maleLabel.textColor = selectedGenderLabelTextColor
            maleImageView.extTintColor(color: selectedGenderTint)
            maleStackViewBackgroundView.backgroundColor = selectedGenderBackgroundColor
        } else {
            maleLabel.textColor = unSelectedGenderLabelTextColor
            maleImageView.extTintColor(color: unSelectedGenderTint)
            maleStackViewBackgroundView.backgroundColor = unSelectedGenderBackgroundColor
        }
        selectedGender = .male
    }

    private func selectFemale(_ selected: Bool) {
        if selected {
            femaleLabel.textColor = selectedGenderLabelTextColor
            femaleImageView.extTintColor(color: selectedGenderTint)
            femaleStackViewBackgroundView.backgroundColor = selectedGenderBackgroundColor
        } else {
            femaleLabel.textColor = unSelectedGenderLabelTextColor
            femaleImageView.extTintColor(color: unSelectedGenderTint)
            femaleStackViewBackgroundView.backgroundColor = unSelectedGenderBackgroundColor
        }
        selectedGender = .female
    }

    private func selectGenderOthers(_ selected: Bool) {
        if selected {
            genderOthersLabel.textColor = selectedGenderLabelTextColor
            genderOthersStackViewBackgroundView.backgroundColor = selectedGenderBackgroundColor
        } else {
            genderOthersLabel.textColor = unSelectedGenderLabelTextColor
            genderOthersStackViewBackgroundView.backgroundColor = unSelectedGenderBackgroundColor
        }
        selectedGender = .genderOthers
    }


    private func showPickerView(picker: Picker, days _: Int = 0) {
        switch picker {
        case .DATE:
//            initializingDatesPickerView(days: days)
//            McPicker.show(data: [datesData], doneHandler: { [weak self] (selections: [Int : String]) -> Void in
//                if let date = selections.first?.value {
//                    self?.dateTextField.text = date
//                }
//            })

            datePicView.layer.shadowColor = UIColor.darkGray.cgColor
            datePicView.layer.shadowOpacity = 0.5
            datePicView.layer.shadowOffset = CGSize.zero
            datePicView.layer.shadowRadius = 8
            datePicView.isHidden = false

        case .MONTH:

            datePicView.layer.shadowColor = UIColor.darkGray.cgColor
            datePicView.layer.shadowOpacity = 0.5
            datePicView.layer.shadowOffset = CGSize.zero
            datePicView.layer.shadowRadius = 8
            datePicView.isHidden = false
        }
    }

    let personRegisterRequest = PersonRegistrationRequestModel()
    let authDetails = RegistrationAuth()
    @IBAction func submitAction(_: UIButton) {
        Loader.show()
        //      Note: January will be set as the default month if nothing exists
//        let month: Int = (self.monthsAndDateData.index { (month, days) -> Bool in
//            month == self.monthTextField.text
//            } ?? 0) + 1
        //      Note: 1 will be set as the default date if nothing exists

        let month = monthTextField.text
//        let date: Int = self.dateTextField.text?.extParseInt() ?? 1
        let date = dateTextField.text
        // Setup the Network Info and create a CTCarrier object
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider

        // Get carrier name
        let carrierName = carrier?.carrierName ?? ""

        // SAVING
//        if self.pUser.picture == "" {
        pUser.picture = cloudinaryImageUrl ?? ""
//        }
        pUser.fullName = nameTextField.text ?? ""
        pUser.dateofBirth = date!
        pUser.monthYearOfBirth = month!
        pUser.gender = String(selectedGender.rawValue)
        pUser.tokenIdentifier = String(NSDate().timeIntervalSince1970 * 1000)
//        self.pUser.registerType = RegisterType.NEVER_REGISTERED
        if let deviceToken = UserDefaults.standard.value(forKey: UserKeys.deviceToken) {
            pUser.deviceApn = deviceToken as! String
            pUser.deviceApnType = UserKeys.deviceType
        } else {
            pUser.deviceApn = ""
            pUser.deviceApnType = UserKeys.deviceType
        }
        // REQUEST
        authDetails.isoCode = pUser.countryCode
        authDetails.phoneNumber = pUser.phoneNumber
        authDetails.fg = UserDefaults.standard.string(forKey: UserKeys.serverDeviceId)
        authDetails.jq = UserDefaults.standard.string(forKey: UserKeys.loginSession)
        personRegisterRequest.auth = authDetails
        personRegisterRequest.fullName = pUser.fullName
        personRegisterRequest.dateofBirth = pUser.dateofBirth
        personRegisterRequest.picture = pUser.picture
        personRegisterRequest.monthYearOfBirth = pUser.monthYearOfBirth
        personRegisterRequest.gender = pUser.gender
        personRegisterRequest.registerType = pUser.registerType
        personRegisterRequest.deviceApn = pUser.deviceApn
        personRegisterRequest.deviceApnType = pUser.deviceApnType
        personRegisterRequest.socialId = pUser.emailId
        personRegisterRequest.mobileServiceProvider = carrierName
        personRegisterRequest.deviceMake = UIDevice.current.modelName

        if nameTextField.text?.isEmpty ?? false {
            print("Please enter Name")
            alert(message: "Name field should not be Empty")
            Loader.close()
        } else if (monthTextField.text?.isEmpty)!, (dateTextField.text?.isEmpty)! {
            alert(message: "DOB is required")
            Loader.close()
        } else {
            saveUserInfo(completed: { success, userId  in
                if success {
                    if let url = self.cloudinaryImageUrl {
                        self.isManualLogin = false
                        self.downLoadImagesforIndexPathforUser(downloadImage: url, fileName: self.awsConfig?.fileName ?? "", userId: userId, data: self.imageData!)
                    } else {
                        self.isManualLogin = true
                        self.showNextVC()
                    }
                    // }
                }
            })
        }
    }
    
    func showNextVC() {
        if isManualLogin {
            if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "QRViewController") as? QRViewController {
                nextViewController.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(nextViewController, animated: true)
            }
        } else {
            let storyBoard = UIStoryboard(name: "ContactsImport", bundle: nil)
                   if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ContactsImportViewController") as? ContactsImportViewController {
                       self.present(nextViewController, animated: true, completion: nil)
                   }
        }

    }

    func downLoadImagesforIndexPathforUser(downloadImage: String, fileName: String, userId: String, data: Data) {
        ACImageDownloader.downloadImageForLocalPath(imageData: data, ref: fileName) { (success, _) in
            let localPath = success
            DatabaseManager.updateUserPhotoForId(picture: localPath)
            self.showNextVC()
        }
    }
    
    private func saveUserInfo(completed: @escaping (Bool, String) -> Void) {
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                NetworkingManager.personRegister(registrationModel: personRegisterRequest, listener: {
                    result, success in if let result = result as? PersonRegisterResponseModel, success {
                        if success {
                            if result.status == "Success" {
//                            let result  = result.data?.first?.globalId ?? ""
                                self.pUser.globalUserId = result.data?.first?.globalId ?? ""
                                let pubSubKey = result.data?.first?.pubnubSubscriberKey ?? ""
                                let pubpublishKey = result.data?.first?.pubnubPublisherKey ?? ""
                                let pubnubaccessKey = result.data?.first?.pubnubaccessKey

                                let securityCode = result.data?.first?.securityCode ?? ""
                                self.pUser.securityCode = securityCode

                                if let deviceID = UserDefaults.standard.string(forKey: UserKeys.serverDeviceId) {
                                    KeyManager.setSharedSecretKey(key: deviceID, iv: securityCode)
                                }

                                let userQRCode = result.data?.first?.userQRCode ?? ""
                                let awsAccessKey = result.data?.first?.awsAccessKey ?? ""
                                let awsSecretKey = result.data?.first?.awsSecretKey ?? ""
                                let defaultGroupAdminTitle = result.data?.first?.defaultGroupAdminTitle ?? ""
                                let googleApiKey = result.data?.first?.googleApiKey ?? ""

                                UserDefaults.standard.set(securityCode, forKey: UserKeys.serverSecurityCode)
                                UserDefaults.standard.set(pubSubKey, forKey: UserKeys.serverPubNubSubscribe)
                                UserDefaults.standard.set(pubpublishKey, forKey: UserKeys.serverPubNubPublish)
                                UserDefaults.standard.set(pubnubaccessKey, forKey: UserKeys.pubnubAccessKey)


                                UserDefaults.standard.set(userQRCode, forKey: UserKeys.serverUserQRCode)
                                UserDefaults.standard.set(awsAccessKey, forKey: UserKeys.serverAWSAccessKey)
                                UserDefaults.standard.set(awsSecretKey, forKey: UserKeys.serverAWSSecretKey)
                                UserDefaults.standard.set(defaultGroupAdminTitle, forKey: UserKeys.serverDefaultGroupAdminTitle)
                                UserDefaults.standard.set(googleApiKey, forKey: UserKeys.serverGoogleApiKey)

                                self.pUser.userQrcode = result.data?.first?.userQRCode ?? ""
                            UserDefaults.standard.set(result.data?.first?.userQRCode, forKey: UserKeys.userQrcode)
                                print(result)
                                self.saveToUserDefaults()
                                self.createChannelForSystemNotifications()
                                DatabaseManager.storeUserInfo(userModel: self.pUser)
                                self.subscribeToPubNub()
                                Loader.close()

                                completed(true, self.pUser.globalUserId)

                            } else {
                                Loader.close()

                                completed(false, "")
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
                            self.alert(message: errorStrings.unKnownAlert)
                        }
                    }
                })
            } else {
                alert(message: "Internet is required")
            }
        }
    }

    func insertContactToDB(user: UserModel) -> String {
        let index = DatabaseManager.storeSelfConatct(profileTable: user)
        return String(index)
    }

    func saveToUserDefaults() {
        let userIndex = insertContactToDB(user: pUser)

        UserDefaults.standard.set(userIndex, forKey: UserKeys.userContactIndex)
        UserDefaults.standard.set(pUser.globalUserId, forKey: UserKeys.userGlobalId)
        UserDefaults.standard.set(pUser.phoneNumber, forKey: UserKeys.userPhoneNumber)
        UserDefaults.standard.set(pUser.fullName, forKey: UserKeys.userName)
        UserDefaults.standard.set(pUser.securityCode, forKey: UserKeys.userSecurityCode)
        UserDefaults.standard.set(pUser.registerType, forKey: UserKeys.userRegistrationType)
        UserDefaults.standard.set(pUser.tokenIdentifier, forKey: UserKeys.userTokenIdentifier)
        UserDefaults.standard.set(pUser.gender, forKey: UserKeys.gender)

        let timestamp = getcurrentTimeStampFOrPubnub()
        let startDate = NSNumber(value: timestamp)
        UserDefaults.standard.set(startDate, forKey: UserKeys.lastSigninTime)
        let tstamp = getcurrentTimeStamp()
        let stDate = NSNumber(value: tstamp)
        UserDefaults.standard.set(stDate, forKey: UserKeys.lastBroadcastSigninTime)
    }

    func createChannelForSystemNotifications() {
        let channel = ACDatabaseMethods.createChannelTable(conatctId: "-99", channelType: channelType.NOTIFICATIONS.rawValue, globalChannelName: GlobalStrings.systemChannelName)

        let channelIndex = DatabaseManager.storeChannelData(channelTable: channel)
        let id = String(channelIndex)
        UserDefaults.standard.set(id, forKey: UserKeys.userSystemChannelId)
    }

    func subscribeToPubNub() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.subscribeToPubNub()
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case monthTextField:
            showPickerView(picker: Picker.MONTH, days: monthsAndDateData[selectedMonthIndex].days)
        case dateTextField:
            showPickerView(picker: Picker.DATE, days: monthsAndDateData[selectedMonthIndex].days)
        case nameTextField:
            if datePicView.isHidden == false {
                datePicView.isHidden = true
            }
            return true
        default:
            print("err - ProfileSetupController:textFieldShouldBeginEditing()")
        }
        return false
    }
}

public extension UIDevice {
    /// pares the deveice name as the standard name
    var modelName: String {
        #if targetEnvironment(simulator)
            let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        #endif

        switch identifier {
        case "iPod5,1": return "iPod Touch 5"
        case "iPod7,1": return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad6,11", "iPad6,12": return "iPad 5"
        case "iPad7,5", "iPad7,6": return "iPad 6"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad Mini 3"
        case "iPad5,1", "iPad5,2": return "iPad Mini 4"
        case "iPad6,3", "iPad6,4": return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8": return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2": return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro (12.9-inch) (3rd generation)"
        case "AppleTV5,3": return "Apple TV"
        case "AppleTV6,2": return "Apple TV 4K"
        case "AudioAccessory1,1": return "HomePod"
        default: return identifier
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
