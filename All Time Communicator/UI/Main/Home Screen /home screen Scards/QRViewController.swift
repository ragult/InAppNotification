//
//  QRViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class QRViewController: UIViewController {
    @IBOutlet var QRImageView: UIImageView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var confirmEmailTextField: UITextField!
    @IBOutlet var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let token = UserDefaults.standard.value(forKey: UserKeys.deviceToken)
        let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!
        let qrPath = UserDefaults.standard.string(forKey: UserKeys.userQrcode)
        if qrPath == "" {
            QRImageView.image = LetterImageGenerator.imageWith(name: "All time QR", randomColor: .gray)
        } else  {
            let name = ACMessageSenderClass.getTimestampForPubnubWithUserId() + ".png"
//            downloadQrforUser(downloadImage: qrPath ?? "", fileName: name, userId: userId ?? "")
            let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: qrPath!, refernce: userId, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")
            DispatchQueue.global(qos: .background).async {
                ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in
                    DatabaseManager.updateMemberQrForId(qr: path)
//                    self.pUser!.localQrcode = path
                    DispatchQueue.main.async { () in
                        self.QRImageView.image = self.load(attName: path)
                    }
                })
            }
        }
    }

    @IBAction func sendButtonAction(_: Any) {
        if (emailTextField.text == confirmEmailTextField.text) && (emailTextField.text != ""){
            
            let sendQrToEmail = SendQRtoEmail()
            sendQrToEmail.auth = DefaultDataProcessor().getAuthDetails()
            sendQrToEmail.email = emailTextField.text!
            
            Loader.show()
            NetworkingManager.sendQrToEmail(emailProfile: sendQrToEmail) { (result: Any, sucess: Bool) in
                if let results = result as? EncryptedBaseResponseModel, sucess {
                    Loader.close()
                    if results.status == "Success" {
                        let storyBoard = UIStoryboard(name: "ContactsImport", bundle: nil)
                        if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ContactsImportViewController") as? ContactsImportViewController {
                            self.present(nextViewController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
    }
    

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
