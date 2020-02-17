import UIKit

protocol Bluring {
    func addBlur(_ alpha: CGFloat)
}

extension UITabBar {
    static let height: CGFloat = 41.5

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        if #available(iOS 11.0, *) {
            sizeThatFits.height = UITabBar.height + window.safeAreaInsets.bottom
        } else {
            sizeThatFits.height = UITabBar.height
        }
        return sizeThatFits
    }
}

extension Bluring where Self: UIView {
    func addBlur(_ alpha: CGFloat = 0.5) {
        // create effect

        if #available(iOS 10.0, *) {
            let effect = UIBlurEffect(style: .regular)
            let effectView = UIVisualEffectView(effect: effect)
            // set boundry and alpha
            effectView.frame = self.bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            effectView.alpha = alpha
            self.addSubview(effectView)
        } else {
            let effect = UIBlurEffect(style: .dark)
            let effectView = UIVisualEffectView(effect: effect)
            // set boundry and alpha
            effectView.frame = bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            effectView.alpha = alpha
            addSubview(effectView)
        }
    }

    func removeBlur() {
        for subview in subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
}

extension UIView: Bluring {}

extension UIView {
    func addShadowView() {
        // Remove previous shadow views
        superview?.viewWithTag(119_900)?.removeFromSuperview()

        // Create new shadow view with frame
        let shadowView = UIView(frame: frame)
        shadowView.tag = 119_900
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.masksToBounds = false

        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 5
        shadowView.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shouldRasterize = true

        insertSubview(shadowView, belowSubview: self)
    }

    func dropLightShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    func dropMediumShadow(scale: Bool = true) {
        layer.masksToBounds = false
        clipsToBounds = false

        layer.shadowColor = UIColor.red.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 2, height: 1)

        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    func copyConstraints(fromView sourceView: UIView) {
        guard let sourceViewSuperview = sourceView.superview else {
            return
        }
        for constraint in sourceViewSuperview.constraints {
            if constraint.firstItem as? UIView == sourceView {
                sourceViewSuperview.addConstraint(NSLayoutConstraint(item: self, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
            } else if constraint.secondItem as? UIView == sourceView {
                sourceViewSuperview.addConstraint(NSLayoutConstraint(item: constraint.firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: self, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
            }
        }
    }

    func extLoadNib() -> UIView {
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        return Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?.first as! UIView
    }

    func extDropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0.3, height: 0.5)
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    @IBInspectable var extCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var extBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var extBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    func extRoundCornersWithLayerMask(cornerRadii: CGFloat, corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: cornerRadii, height: cornerRadii))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }

    @IBInspectable var dropShadow: Bool {
        set {
            if newValue {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.4
                layer.shadowRadius = 1
                layer.shadowOffset = CGSize.zero
            } else {
                layer.shadowColor = UIColor.clear.cgColor
                layer.shadowOpacity = 0
                layer.shadowRadius = 0
                layer.shadowOffset = CGSize.zero
            }
        }
        get {
            return layer.shadowOpacity > 0
        }
    }
}

extension CALayer {
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0
    ) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

@IBDesignable extension UIView {
    // Example use: myView.addBorder(toSide: .Left, withColor: UIColor.redColor().CGColor, andThickness: 1.0)

    enum ViewSide {
        case Left, Right, Top, Bottom
    }

    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness _: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color
        layer.addSublayer(border)
    }
}

extension UIStackView {
    func extAddBackground(color: UIColor) -> UIView {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
        return subView
    }
}

private var maxLengths = NSMapTable<UITextField, NSNumber>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)
private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var extMaxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(extFix), for: .editingChanged)
        }
    }

    @objc func extFix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.extSafelyLimitedTo(length: extMaxLength)
    }
}

extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }

    func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard count > limit else { return self }

        switch position {
        case .head:
            return leader + suffix(limit)
        case .middle:
            let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))

            let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))

            return "\(prefix(headCharactersCount))\(leader)\(suffix(tailCharactersCount))"
        case .tail:
            return prefix(limit) + leader
        }
    }

    func extSafelyLimitedTo(length n: Int) -> String {
        if count <= n {
            return self
        }
        return String(Array(self).prefix(upTo: n))
    }
}

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}

extension UIColor {
    convenience init(r: Int, g: Int, b: Int, alpha: Int = 1) {
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(alpha))
    }

    var extGetPrimaryColor: UIColor {
        return UIColor(r: 18, g: 151, b: 147)
    }
}

extension UIImageView {
    public func extTintColor(color: UIColor) {
        UIGraphicsBeginImageContextWithOptions((image?.size)!, false, (image?.scale)!)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRect(origin: CGPoint.zero, size: (image?.size)!)
        color.setFill()
        image?.draw(in: rect)
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        image = resultImage
    }
    func loadWithUrl(url : String){
        if url != "" {
            let url = URL(string: url)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    if data != nil {
                        self.image = UIImage(data: data!)
                    }
                }
            }
        }
    }
}

extension StringProtocol {
    var string: String { return String(self) }

    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }

    subscript(_ range: CountableRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }

    subscript(range: CountableClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }

    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }

    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }

    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}

extension String {
    func extParseInt() -> Int? {
        return Int(components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }

    func extParsePhoneNumber() -> String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    var extStrippedSpecialCharactersFromCharacters: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return filter { okayChars.contains($0) }
    }

    var extStrippedSpecialCharactersFromNumbers: String {
        let okayChars = Set("1234567890")
        return filter { okayChars.contains($0) }
    }
}

extension UITextField {
    func addPaddingToTextField() {
        let leftPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 20))
        let rightPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        leftView = leftPaddingView
        leftViewMode = .always
        rightView = rightPaddingView
        rightViewMode = .always
    }

    func setBottomBorder() {
        borderStyle = .none
        layer.backgroundColor = UIColor.white.cgColor

        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.3)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 0.0
    }
}

extension UIAlertController {
    func AlertWithTextField(_ view: UIViewController) -> UIAlertController {
        let actionSheetController: UIAlertController = UIAlertController(title: "Action Sheet", message: message, preferredStyle: UIAlertController.Style.actionSheet)

        actionSheetController.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in

        }))
        actionSheetController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in

        }))

        view.present(actionSheetController, animated: true, completion: {
            print("completion block")
        })
        return actionSheetController
    }
}

extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)

        present(alertController, animated: true, completion: nil)
        UILabel.appearance(whenContainedInInstancesOf:
            [UIAlertController.self]).numberOfLines = 0

        UILabel.appearance(whenContainedInInstancesOf:
            [UIAlertController.self]).lineBreakMode = .byWordWrapping
    }

    func convertJsonStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.replacingOccurrences(of: "\n", with: "").data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func convertDictionaryToJsonString(dict: NSMutableDictionary) -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())
        if let jsonString = NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue) {
            return "\(jsonString)"
        }
        return ""
    }

    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func load(attName: String) -> UIImage? {
        let type = fileName.imagemediaFileName
        let fileURL = documentsUrl.appendingPathComponent(type + "/" + attName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
            return UIImage(named: "group_profile")
        }
        return nil
    }

    func getAudioFileName(attName: String) -> UIImage? {
        let type = fileName.audiomediaFileName
        let fileURL = documentsUrl.appendingPathComponent(type + "/" + attName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
            return nil
        }
        return nil
    }

    //testing
    func loadI(attName: String) -> UIImage? {
        let type = fileName.audiomediaFileName
        let fileURL = documentsUrl.appendingPathComponent(type + "/" + attName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }

    public func dateFormatting(date: String) -> String {
        // String to date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Your date format
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent // Current time zone
        // according to date format your date string
        guard let date = dateFormatter.date(from: date) else {
            fatalError()
        }
        // Date to String
        dateFormatter.dateFormat = "dd/MM/yyyy" // Your New Date format as per requirement change it own
        let newDate = dateFormatter.string(from: date) // pass Date here
        print(newDate) // New formatted Date string
        return newDate
    }

    public func extRemoveTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }

    func ExtpopupAlert(title: String?, message: String?, actionTitles: [String?], actions: [((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        present(alert, animated: true, completion: nil)
    }

    func checkifTimeDiffGreaterThan5Mins(currentMsgTime: Int, previousMsgTime: Int) -> Bool {
        let diff = currentMsgTime - previousMsgTime

        let hours = diff / 3600
        let minutes = (diff - hours * 3600) / 60
        if minutes > 5 {
            return true
        } else {
            return false
        }
    }

    func checkIfDateExpired(timeStamp: Double) -> Bool {
        let selectedDate = Date(timeIntervalSince1970: timeStamp)

        let date1 = Date()
        let date2 = selectedDate

        if date1 == date2 {
            return true
        } else if date1 > date2 {
            return false
        } else if date1 < date2 {
            return true
        } else {
            return true
        }
    }

    func gotohomePage() {
        if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            let navigationController = UINavigationController(rootViewController: nextViewController)
            //to removeDatafrom userdefaults
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }

            // delete all table contents
            DatabaseManager.deleteGroupTable()
            DatabaseManager.deleteChannelTable()
            DatabaseManager.deleteGroupMembersTable()
            DatabaseManager.deleteMessagesTable()
            DatabaseManager.deleteContactsTable()
            DatabaseManager.deleteUserTable()

            self.navigationController?.navigationBar.isHidden = true
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.window!.rootViewController = navigationController
        }
    }

    func getcurrentTimeStampFOrPubnub() -> TimeInterval {
        return NSDate().timeIntervalSince1970 * 10_000_000
    }

    func getcurrentTimeStamp() -> TimeInterval {
        return NSDate().timeIntervalSince1970
    }
}

extension ChatMessageProcessor {
    func getcurrentTimeStampFOrPubnub() -> TimeInterval {
        return NSDate().timeIntervalSince1970 * 10_000_000
    }
}

extension NSObject {
//    var navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
//    navController?.pushViewController(pushtoVC, animated: true)

    func gotohomePagefromobject() {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            let navigationController = UINavigationController(rootViewController: nextViewController)
            //to removeDatafrom userdefaults
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }

            // delete all table contents
            DatabaseManager.deleteGroupTable()
            DatabaseManager.deleteChannelTable()
            DatabaseManager.deleteGroupMembersTable()
            DatabaseManager.deleteMessagesTable()
            DatabaseManager.deleteContactsTable()
            DatabaseManager.deleteUserTable()

//            var navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
//            navController = navigationController
            navigationController.isNavigationBarHidden = true
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.window!.makeKeyAndVisible()
            appdelegate.window!.rootViewController = navigationController
        }
    }
}

extension ACGroupsProcessingObjectClass {
    func gotohomePagefromGroup() {
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            let navigationController = UINavigationController(rootViewController: nextViewController)
            //to removeDatafrom userdefaults
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
            }

            // delete all table contents
            DatabaseManager.deleteGroupTable()
            DatabaseManager.deleteChannelTable()
            DatabaseManager.deleteGroupMembersTable()
            DatabaseManager.deleteMessagesTable()
            DatabaseManager.deleteContactsTable()
            DatabaseManager.deleteUserTable()

            var navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController

            navController!.navigationController?.navigationBar.isHidden = true
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.window!.rootViewController = navigationController
        }
    }
}

extension UIImage {
    static func resizedCroppedImage(image: UIImage, newSize: CGSize) -> UIImage? {
        // This function returns a newImage, based on image
        // - image is scaled uniformaly to fit into a rect of size newSize
        // - if the newSize rect is of a different aspect ratio from the source image
        //     the new image is cropped to be in the center of the source image
        //     (the excess source image is removed)

        var ratio: CGFloat = 0
        var delta: CGFloat = 0
        var drawRect = CGRect()

        if newSize.width > newSize.height {
            ratio = newSize.width / image.size.width
            delta = (ratio * image.size.height) - newSize.height
            drawRect = CGRect(x: 0, y: -delta / 2, width: newSize.width, height: newSize.height + delta)

        } else {
            ratio = newSize.height / image.size.height
            delta = (ratio * image.size.width) - newSize.width
            drawRect = CGRect(x: -delta / 2, y: 0, width: newSize.width + delta, height: newSize.height)
        }

        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        image.draw(in: drawRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resizeImageTo() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }

        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1024 // ! Or devide for 1024 if you need KB but not kB

        while imageSizeKB > 1024 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = resizedImage.pngData()
            else { return nil }

            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1024
            // ! Or devide for 1024 if you need KB but not kB
        }

        return resizingImage
    }

    func resizedTo500Kb() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }

        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1024 // ! Or devide for 1024 if you need KB but not kB

        while imageSizeKB > 512 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.5),
                let imageData = resizedImage.pngData()
            else { return nil }

            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1024 // ! Or devide for 1024 if you need KB but not kB
        }

        return resizingImage
    }

    func resizedTo300Kb() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }

        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1024 // ! Or devide for 1024 if you need KB but not kB

        while imageSizeKB > 300 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.8),
                let imageData = resizedImage.pngData()
            else { return nil }

            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1024 // ! Or devide for 1024 if you need KB but not kB
        }

        return resizingImage
    }

    func resize(withPercentage percentage: CGFloat) -> UIImage? {
        var newRect = CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage))
        UIGraphicsBeginImageContextWithOptions(newRect.size, true, 1)
        draw(in: newRect)
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    

    
}

extension UIColor {
    static var extRandomColor: UIColor {
        return UIColor(red: .random(in: 0 ... 1),
                       green: .random(in: 0 ... 1),
                       blue: .random(in: 0 ... 1),
                       alpha: 0.6)
    }
}

extension NSObject {
    class LetterImageGenerator: NSObject {
        class func imageWith(name: String?, randomColor: UIColor?, textColor: UIColor? = .white) -> UIImage? {
            let frame = CGRect(x: 0, y: 0, width: 64, height: 64)
            let nameLabel = UILabel(frame: frame)
            nameLabel.textAlignment = .center
            nameLabel.backgroundColor = randomColor
            nameLabel.textColor = textColor
            nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
            var initials = ""
            if let initialsArray = name?.components(separatedBy: " ") {
                if let firstWord = initialsArray.first {
                    if let firstLetter = firstWord.first {
                        initials += String(firstLetter).capitalized
                    }
                }
                if initialsArray.count > 1, let lastWord = initialsArray.last {
                    if let lastLetter = lastWord.first {
                        initials += String(lastLetter).capitalized
                    }
                }
            } else {
                return nil
            }
            nameLabel.text = initials
            UIGraphicsBeginImageContext(frame.size)
            if let currentContext = UIGraphicsGetCurrentContext() {
                nameLabel.layer.render(in: currentContext)
                let nameImage = UIGraphicsGetImageFromCurrentImageContext()
                return nameImage
            }
            return nil
        }
    }
}

extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        self.init(x: x, y: y, width: w, height: h)
    }
}

extension UITableView {
    func scrollToBottom(animated: Bool) {
        let y = contentSize.height - frame.size.height
        setContentOffset(CGPoint(x: 0, y: (y < 0) ? 0 : y), animated: animated)
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension PaddedLabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }

    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    open override func draw(_ rect: CGRect) {
        if let insets = padding {
            drawText(in: rect.inset(by: insets))
        } else {
            drawText(in: rect)
        }
    }

    open override var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }

        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        var insetsWidth: CGFloat = 0.0

        if let insets = padding {
            insetsWidth += insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
            textWidth -= insetsWidth
        }

        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: self.font], context: nil)

        contentSize.height = ceil(newSize.size.height) + insetsHeight
        contentSize.width = ceil(newSize.size.width) + insetsWidth

        return contentSize
    }
}

public extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
}

extension Int {
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180.0
    }
}

extension Double {
    var toTimeString: String {
        let seconds: Int = Int(truncatingRemainder(dividingBy: 60.0))
        let minutes: Int = Int(self / 60.0)
        return String(format: "%d:%02d", minutes, seconds)
    }

    func getDateFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd, MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    func isWithinFiveMins() -> Bool {

        let cal = Calendar.current
        let d1 = Date()
        let d2 = Date.init(timeIntervalSince1970: self) // April 27, 2018 12:00:00 AM
        let components = cal.dateComponents([.minute], from: d2, to: d1)
        let diff = components.minute!
        if diff < 5 {
            return true
        }
        return false
    }
}

extension Date {
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date().noon)!
    }
    
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date().noon)!
    }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

@IBDesignable class GradientView: UIView {
    private var gradientLayer: CAGradientLayer!

    @IBInspectable var topColor: UIColor = .red {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var bottomColor: UIColor = .yellow {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowY: CGFloat = -3 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowBlur: CGFloat = 3 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var startPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var startPointY: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var endPointX: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var endPointY: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override func layoutSubviews() {
        gradientLayer = layer as? CAGradientLayer
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
        layer.shadowRadius = shadowBlur
        layer.shadowOpacity = 1
    }

    func animate(duration: TimeInterval, newTopColor: UIColor, newBottomColor: UIColor) {
        let fromColors = gradientLayer?.colors
        let toColors: [AnyObject] = [newTopColor.cgColor, newBottomColor.cgColor]
        gradientLayer?.colors = toColors
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        gradientLayer?.add(animation, forKey: "animateGradient")
    }
}

@IBDesignable class ButtonGradientView: UIButton {
    private var gradientLayer: CAGradientLayer!

    @IBInspectable var topColor: UIColor = .red {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var bottomColor: UIColor = .yellow {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowY: CGFloat = -3 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowBlur: CGFloat = 3 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var startPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var startPointY: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var endPointX: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var endPointY: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override func layoutSubviews() {
        gradientLayer = layer as? CAGradientLayer
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
        layer.shadowRadius = shadowBlur
        layer.shadowOpacity = 1
    }

    func animate(duration: TimeInterval, newTopColor: UIColor, newBottomColor: UIColor) {
        let fromColors = gradientLayer?.colors
        let toColors: [AnyObject] = [newTopColor.cgColor, newBottomColor.cgColor]
        gradientLayer?.colors = toColors
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        gradientLayer?.add(animation, forKey: "animateGradient")
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }
    
    var isValidURL: Bool {
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension UITableView {
    func hasRowAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.section < numberOfSections && indexPath.row < numberOfRows(inSection: indexPath.section)
    }
}

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}

class PaddedTextField: UITextField {
    @IBInspectable var padding: CGFloat = 0

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + padding, y: bounds.origin.y, width: bounds.width - padding * 2, height: bounds.height)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + padding, y: bounds.origin.y, width: bounds.width - padding * 2, height: bounds.height)
    }
}
extension URL {
    var queryDictionary: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
        
//        guard let query = self.query else { return nil}
//
//        var queryStrings = [String: String]()
//        for pair in query.components(separatedBy: "&") {
//
//            let key = pair.components(separatedBy: "=")[0]
//
//            let value = pair
//                .components(separatedBy:"=")[1]
//                .replacingOccurrences(of: "+", with: " ")
//                .removingPercentEncoding ?? ""
//
//            queryStrings[key] = value
//        }
//        return queryStrings
    }
}

/* usage
 let urlString = "http://www.youtube.com/video/4bL4FI1Gz6s?hl=it_IT&iv_logging_level=3&ad_flags=0&endscreen_module=http://s.ytimg.com/yt/swfbin/endscreen-vfl6o3XZn.swf&cid=241&cust_gender=1&avg_rating=4.82280613104"
 let url = URL(string: urlString)
 print(url!.queryDictionary ?? "NONE")
 */
