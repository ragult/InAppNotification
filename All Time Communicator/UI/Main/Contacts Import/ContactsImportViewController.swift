//
//  ContactsImportViewController.swift
//  alltimecommunicator
//
//  Created by Droid5 on 10/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import Contacts
import ContactsUI
import EVReflection
import UIKit

class ContactsImportViewController: UIViewController {
    let contactsStore = CNContactStore()
    let user = DatabaseManager.getUser()
    var contactsToVerify = [ProfileTable]()
    var contactsClass = ACContactsProcessor()

    @IBOutlet var validatingContactsLabel: UILabel!
    @IBOutlet weak var importContactsLabel: UILabel!
    
    @IBOutlet weak var okayLetsGoIn: UIButton!
    let validatingContacts = "Validating Contacts..."
    let validatingContactsNoDot = "Validating Contacts"
    let contactBookReady = "The contact book is ready!"
    
    let importingContacts = "Importing Contacts..."
    let importContacts = "Importing Contacts"

    
    @IBOutlet weak var validatingTick: UIImageView!
    @IBOutlet weak var importTick: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setImportingContacts()
        self.setValidatingContactsNoDot()
        contactsStore.requestAccess(for: .contacts) { success, _ in
            if success {
                print("Authuorized")
                DispatchQueue.main.async {
                    Loader.show()
                    self.getContacts()
                    self.setImportedContacts()
                    self.setValidatingContacts()
                }
            } else {
                print("Un Authorized contacts ")
            }
        }
    }
    
    func setImportingContacts() {
        self.importContactsLabel.text = importingContacts
        self.importTick.isHidden = true
        self.okayLetsGoIn.isHidden = true
    }
    
    func setImportedContacts() {
        self.importContactsLabel.text = importContacts
        self.importTick.isHidden = false
        self.okayLetsGoIn.isHidden = true
    }
    
    func setValidatingContacts() {
        self.validatingContactsLabel.text = validatingContacts
        self.validatingTick.isHidden = true
        self.okayLetsGoIn.isHidden = true
    }
    
    func setValidatingContactsNoDot() {
        self.validatingContactsLabel.text = validatingContactsNoDot
        self.validatingTick.isHidden = true
        self.okayLetsGoIn.isHidden = true
    }
    
    func setValidatedContacts() {
        self.validatingContactsLabel.text = contactBookReady
        self.validatingTick.isHidden = false
        self.okayLetsGoIn.isHidden = false
    }
    
    
    @IBAction func onButtonAction(_ sender: Any) {
        self.showHome()
    }
    
    func getContacts() {
        contactsClass.getContactsAndUpdate(notify: true, completionHandler: { (_) -> Void in
            DispatchQueue.main.async {
                Loader.close()
                self.setValidatedContacts()
            }
        })
    }
    
    func showHome() {
        DispatchQueue.main.async {
            let homeStoryBoard = UIStoryboard(name: "OnBoarding", bundle: nil)
            let nextViewController = homeStoryBoard.instantiateViewController(withIdentifier: "HomeTabBarController") as! HomeTabBarController
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated: true, completion: nil)
        }
    }

    // mark: downLoadImages

    static func downloadImagesFromArray(downloadObjectArray: [MediaRefernceHolderObject]) {
        for downloadObject in downloadObjectArray {
            ACImageDownloader.downloadImage(downloadObject: downloadObject, completionHandler: { (success, path) -> Void in

                print(success)
                print(path)

            })
        }
    }
}
