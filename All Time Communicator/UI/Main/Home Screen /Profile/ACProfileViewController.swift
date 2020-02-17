import AlamofireImage
import CountryPickerView
import McPicker
import UIKit

class ACProfileViewController: UIViewController, UITextFieldDelegate, CountryPickerViewDelegate {
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
    @IBOutlet var closeBtn: UIButton!

    @IBOutlet var termsLable: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
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
    @IBOutlet var nameTextField: UITextField!
    var delegate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet var changeNumberView: UIView!
    @IBOutlet var changeNumberHeightContraint: NSLayoutConstraint!
    @IBOutlet var mobileNumberTextField: UIView!
    @IBOutlet var mobileTextField: UITextField?
    @IBOutlet var editButton: UIButton!

    let countryPickerView = CountryPickerView()
    var countryPickerControl = CountryPickerControl()
    let indianCountryCode = "IN"
    var selectedCountry: Country?

    @IBOutlet var qrStack: UIStackView!
    @IBOutlet var genderStack: UIStackView!
    @IBOutlet var dobStack: UIStackView!
    private let monthsAndDateData: [(month: String, days: Int)] = [("January", 31), ("February", 29), ("March", 31), ("April", 30), ("May", 31), ("June", 30), ("July", 31), ("August", 31), ("September", 30), ("October", 31), ("November", 30), ("December", 31)]
    private var datesData: [String] = []

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
    var pUser: ProfileTable?
    var isSelf: Bool?
    @IBOutlet var qrImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        genderStack.isHidden = true
        dobStack.isHidden = true
        initializingGenderStackView()
        uploadActivityIndicator.hidesWhenStopped = true
        uploadActivityIndicator.color = UIColor(r: 33, g: 140, b: 141)
        initializingDatesPickerView(days: monthsAndDateData.first?.days ?? 0)
        initializingTextFields()
        initializingCamera()
        initializingData()
        submitBtn.isHidden = false
        phoneNumberLabel.text = pUser?.phoneNumber

        if !isSelf! {
//            submitBtn.isHidden = true
            termsLable.isHidden = true
            closeBtn.isHidden = true
            editButton.isHidden = true
        }
        submitBtn.isHidden = true
    }

    override func viewWillAppear(_: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications
    }

    func updateUserProfile(picture: String, fileName: String, data: Data) {
        let updateUserProfile = UpdateUserProfile()
        updateUserProfile.auth = DefaultDataProcessor().getAuthDetails()
        updateUserProfile.picture = picture
        updateUserProfile.fullName = nameTextField.text ?? ""
        updateUserProfile.quote = ""

        NetworkingManager.updateUserProfile(updateUserProfile: updateUserProfile) { (result: Any, sucess: Bool) in
            if let results = result as? EncryptedBaseResponseModel, sucess {
                if results.status == "Success" {
                    self.downLoadImagesforIndexPathforUser(downloadImage: picture, fileName: fileName, userId: self.pUser!.id, data: data)
                    self.alert(message: "Profile updated successfully")
                }
            }
        }
    }

    func initializingData() {
        nameTextField.text = pUser!.fullName

        profileImageView.image = LetterImageGenerator.imageWith(name: pUser!.fullName, randomColor: .gray)
        if isSelf ?? false {
            qrStack.isHidden = false
            let qrPath = UserDefaults.standard.string(forKey: UserKeys.userQrcode)
            if qrPath == "" {
                qrImageView.image = LetterImageGenerator.imageWith(name: "All time QR", randomColor: .gray)
            } else if pUser?.localQrcode != "" {
                qrImageView.image = load(attName: pUser!.localQrcode)
            } else if pUser?.localQrcode == "" {
                let name = ACMessageSenderClass.getTimestampForPubnubWithUserId() + ".png"
                downloadQrforUser(downloadImage: qrPath ?? "", fileName: name, userId: pUser?.id ?? "")
            }
        } else {
            qrStack.isHidden = true
        }

        if pUser!.picture == "" {
            profileImageView.image = LetterImageGenerator.imageWith(name: pUser!.fullName, randomColor: .gray)
        } else if pUser!.localImageFilePath == "" {
            let name = ACMessageSenderClass.getTimestampForPubnubWithUserId() + ".png"
            downloadImageforUser(downloadImage: pUser!.picture, fileName: name, userId: pUser!.id)
        } else {
            profileImageView.image = load(attName: pUser!.localImageFilePath)
        }

        if let getid = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String {
            if getid == pUser?.globalUserId {
                if let puser1 = UserDefaults.standard.value(forKey: UserKeys.gender) as? String, puser1 == "1" {
                    selectMale(true)
                } else if let puser2 = UserDefaults.standard.value(forKey: UserKeys.gender) as? String, puser2 == "2" {
                    selectFemale(true)
                } else if let puser3 = UserDefaults.standard.value(forKey: UserKeys.gender) as? String, puser3 == "3" {
                    selectGenderOthers(true)
                }
            }
        }

        dateTextField.text = pUser?.dateOfBirth
    }

    func downloadQrforUser(downloadImage: String, fileName _: String, userId: String) {
        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: downloadImage, refernce: userId, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")
        DispatchQueue.global(qos: .background).async {
            ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in
                DatabaseManager.updateMemberQrForId(qr: path)
                self.pUser!.localQrcode = path
                DispatchQueue.main.async { () in
                    self.qrImageView.image = self.load(attName: self.pUser!.localQrcode)
                }
            })
        }
    }

    func downloadImageforUser(downloadImage: String, fileName _: String, userId: String) {
        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: downloadImage, refernce: userId, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")
        DispatchQueue.global(qos: .background).async {
            ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in
                if path != "" {
                    DatabaseManager.updateUserPhotoForId(picture: path)
                    self.pUser!.localImageFilePath = path
                    DispatchQueue.main.async { () in
                        self.profileImageView.image = self.load(attName: self.pUser!.localImageFilePath)
                    }
                }
            })
        }
    }
    
    func downLoadImagesforIndexPathforUser(downloadImage _: String, fileName: String, userId: String, data: Data) {
        ACImageDownloader.downloadImageForLocalPath(imageData: data, ref: fileName) { success, _ in
            let localPath = success
            DatabaseManager.updateMemberPhotoForId(picture: localPath, userId: userId)

            self.pUser!.localImageFilePath = localPath
            DispatchQueue.main.async { () in
                self.profileImageView.image = self.load(attName: self.pUser!.localImageFilePath)
            }
        }
    }

    private func initializingCamera() {
        cameraView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraClicked)))
    }

    @IBAction func dismissView(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onClickOfSendButton(_: Any) {
        changeNumberHeightContraint.constant = 0
        changeNumberView.isHidden = true

        var countryCode: String = selectedCountry?.phoneCode ?? ""
        if countryCode.first == "+" {
            countryCode.removeFirst()
        }
        let mobileNumber: String = mobileTextField?.text ?? ""
        let mobNineOne: String = "91" + (mobileTextField?.text)!
        if mobileNumber.isEmpty {
            alert(message: "Please enter Phone number")
            Loader.close()
        } else if mobNineOne == phoneNumberLabel.text! {
            alert(message: "Please enter some other number")
            Loader.close()
        } else if mobileNumber.count != TextFieldMaxLength.MOBILE {
            print("invalid phone number")
            alert(message: "enter valid Phone number")
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
                                    guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ACChangePhoneViewController") as? ACChangePhoneViewController else {
                                        Loader.close()
                                        return print("something went wrong ViewController: onValidateButtonClicked() 2")
                                    }
//                                    UserDefaults.standard.set(result.data?.deviceId ?? "", forKey: UserKeys.serverDeviceId)
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

    @IBAction func onClickOfEdit(_: Any) {
        setUI()
        changeNumberView.isHidden = false
        changeNumberHeightContraint.constant = 220
    }

    func setUI() {
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

    @IBAction func onClickOfCloseButton(_: Any) {
        changeNumberView.isHidden = true
        changeNumberHeightContraint.constant = 0
    }

    @objc private func cameraClicked(sender _: UITapGestureRecognizer) {
        if isSelf! {
            CameraHandler.shared.showActionSheet(vc: self)
            CameraHandler.shared.imagePickedBlock = { profileImage in
                self.profileImageView.image = UIImage.resizedCroppedImage(image: profileImage, newSize: CGSize(width: self.profileImageView.frame.width, height: self.profileImageView.frame.height))
                let resizedImage: UIImage? = profileImage.resizedTo500Kb()
                self.profileImageData = resizedImage?.pngData()
                self.uploadActivityIndicator.startAnimating()
                self.submitBtn.isEnabled = false
                self.submitBtn.backgroundColor = .gray
                if let data = self.profileImageData {
                    let name = ACMessageSenderClass.getTimestampForPubnubWithUserId() + ".png"
                    let config = AWSManager.instance.getConfig(
                        gType: groupType.PRIVATE_GROUP.rawValue,
                        isChat: false,
                        isProfile: true,
                        fileName: name,
                        type: s3BucketName.imageType
                    )

                    AWSManager.instance.uploadDataS3(config: config, data: data, completionHandler: { url, error in
                        if error == nil {
                            self.cloudinaryImageUrl = url
                            self.uploadActivityIndicator.stopAnimating()
                            self.submitBtn.backgroundColor = UIColor(r: 33, g: 140, b: 141)
                            self.submitBtn.isEnabled = true
                            self.updateUserProfile(picture: url, fileName: name, data: data)
                        }
                    })
                }
                print("clicked")
            }
        }
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
        monthTextField.text = monthsAndDateData.first?.month
        dateTextField.text = datesData.first

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
        femaleImageView.extTintColor(color: unSelectedGenderTint)

        genderOthersStackViewBackgroundView = genderOthers.extAddBackground(color: UIColor.clear)
//        genderOthersStackViewBackgroundView.extRoundCornersWithLayerMask(cornerRadii: 4, corners: [.topRight, .bottomRight])
        genderOthersStackViewBackgroundView.isUserInteractionEnabled = true
        genderOthersStackViewBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(genderSelected(_:))))

        // making female as default selected
//                selectMale(true)
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

    private func initializingDatesPickerView(days: Int) {
        datesData.removeAll()
        for i in 1 ... days {
            datesData.append(String(i))
        }
    }

    private func showPickerView(picker: Picker, days: Int = 0) {
        switch picker {
        case .DATE:
            initializingDatesPickerView(days: days)
            McPicker.show(data: [datesData], doneHandler: { [weak self] (selections: [Int: String]) -> Void in
                if let date = selections.first?.value {
                    self?.dateTextField.text = date
                }
            })
        case .MONTH:
            McPicker.show(data: [monthsAndDateData.map { (month: String, _: Int) -> String in month }], doneHandler: {
                [weak self] (selections: [Int: String]) -> Void in

                if let month = selections.first?.value {
                    self?.monthTextField.text = month
                    self?.selectedMonthIndex = self?.monthsAndDateData.firstIndex(where: { (monthString: String, _: Int) -> Bool in
                        month == monthString
                    }) ?? 0

                    // Note: Changing DATE to default value after every MONTH change
                    self?.dateTextField.text = self?.datesData.first
                }
            })
        }
    }

    let personRegisterRequest = PersonRegistrationRequestModel()
    let authDetails = RegistrationAuth()
    @IBAction func submitAction(_: UIButton) {
        Loader.show()
    }

    private func saveUserInfo(completed _: @escaping (Bool) -> Void) {}

    func insertContactToDB(user: UserModel) -> String {
        let index = DatabaseManager.storeSelfConatct(profileTable: user)
        return String(index)
    }

    func saveToUserDefaults() {
//        let userIndex = insertContactToDB(user: pUser)
//
//        UserDefaults.standard.set(userIndex, forKey: UserKeys.userContactIndex)
//        UserDefaults.standard.set(self.pUser.globalUserId, forKey: UserKeys.userGlobalId)
//        UserDefaults.standard.set(self.pUser.phoneNumber, forKey: UserKeys.userPhoneNumber)
//        UserDefaults.standard.set(self.pUser.fullName, forKey: UserKeys.userName)
//        UserDefaults.standard.set(self.pUser.securityCode, forKey: UserKeys.userSecurityCode)
//        UserDefaults.standard.set(self.pUser.registerType, forKey: UserKeys.userRegistrationType)
//        UserDefaults.standard.set(self.pUser.tokenIdentifier, forKey: UserKeys.userTokenIdentifier)
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
            showPickerView(picker: Picker.MONTH)
        case dateTextField:
            showPickerView(picker: Picker.DATE, days: monthsAndDateData[selectedMonthIndex].days)
        default:
            print("err - ProfileSetupController:textFieldShouldBeginEditing()")
        }
        return false
    }
}

extension ACProfileViewController: AddImageDelegate {
    func imageAdded() {}
}
