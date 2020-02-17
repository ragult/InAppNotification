//
//  CameraHandler.swift
//  alltimecommunicator
//
//  Created by Droid5 on 06/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import Foundation
import UIKit

class CameraHandler: NSObject {
    static let shared = CameraHandler()

    fileprivate var currentVC: UIViewController!

    // MARK: Internal Properties

    var imagePickedBlock: ((UIImage) -> Void)?

    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        } else {
            print("CAMERA NOT AVAILABLE IN THIS DEVICE")
        }
    }

    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
    }

    func showActionSheet(vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_: UIAlertAction!) -> Void in
//             DispatchQueue.main.async
//                {
            self.camera()
//            }

        }))

        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (_: UIAlertAction!) -> Void in

            self.photoLibrary()

        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        vc.present(actionSheet, animated: true, completion: nil)
    }

    func showCamera(vc: UIViewController) {
        currentVC = vc
        camera()
    }

    func showGallery(vc: UIViewController) {
        currentVC = vc
        photoLibrary()
    }
}

extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            imagePickedBlock?(image)
        } else {
            print("Something went wrong")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension URL {
    static func extCreateFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    return nil
                }
            }
            return folderURL
        }
        return nil
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
