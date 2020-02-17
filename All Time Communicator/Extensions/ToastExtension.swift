//
//  ToastExtension.swift
//  alltimecommunicator
//
//  Created by Lokesh on 12/25/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showToast(message: String, font: UIFont) {
        let width = self.view.frame.size.width
        let halfWidth = (width / 2)
        let toastLabel = UILabel(frame: CGRect(x: halfWidth - (halfWidth - 48), y: self.view.frame.size.height - 100, width: width - 96, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
