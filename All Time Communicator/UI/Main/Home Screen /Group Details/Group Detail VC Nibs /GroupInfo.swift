//
//  GroupInfo.swift
//  alltimecommunicator
//
//  Created by Lokesh on 12/29/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Foundation
import UIKit

class GroupInfo: UIView {
    
    @IBOutlet weak var groupCodeView: UIView!
    @IBOutlet weak var onTheWebView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoDetailView: UIView!
    
    @IBOutlet weak var infoArrow: UIImageView!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var groupCode: UILabel!
    
    @IBOutlet weak var groupCodeViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var onTheWebLink: UILabel!
    @IBOutlet weak var infoDetailHeight: NSLayoutConstraint!
    
    @IBOutlet weak var copyView: UIView!
    @IBOutlet weak var webUrlHeight: NSLayoutConstraint!
    @IBOutlet weak var groupInfo: NSLayoutConstraint!
    
    static func initWith() -> GroupInfo {
        return Bundle.main.loadNibNamed("GroupInfo", owner: self, options: nil)?.first as! GroupInfo
    }
    
    func showPrivateBroadCastInfo() {
        self.groupCodeView.isHidden = true
        self.groupCodeViewHeight.constant = 0
        self.groupInfo.constant = 24
    }
    
    func showUrl() {
        self.onTheWebView.isHidden = false
        self.webUrlHeight.constant = 36
        self.groupInfo.constant = 12
    }
    
    func hideUrl() {
        self.onTheWebView.isHidden = true
        self.webUrlHeight.constant = 0
        self.groupInfo.constant = 0
    }
    
    func showPublicProcastInfo() {
        self.groupCodeView.isHidden = false
        self.groupCodeViewHeight.constant = 64
    }
    
    func setGroupCode(code: String) {
        self.groupCode.text = code
    }
    
    func setWebLink(link: String) {
        self.onTheWebLink.text = link
    }
    
    func setQRImage(image: UIImage) {
        self.qrImage.image = image
    }
    
    func showInfoDetail() {
        self.infoDetailView.isHidden = false
//        self.infoDetailHeight.constant = 204
        UIView.animate(withDuration: 2) {
            self.infoArrow.transform = CGAffineTransform.identity
        }
    }
    
    func hideInfoDetail() {
        self.infoDetailView.isHidden = true
//        self.infoDetailHeight.constant = 0
        UIView.animate(withDuration: 2) {
            self.infoArrow.transform = CGAffineTransform(rotationAngle: .pi)
        }
    }
}
