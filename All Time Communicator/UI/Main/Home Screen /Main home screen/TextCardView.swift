//
//  TextCardView.swift
//  alltimecommunicator
//
//  Created by new1 on 20/03/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class TextCardView: UIView {
    @IBOutlet var lblText: UILabel!

    @IBOutlet var lblTitle: UILabel!

    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!

    @IBOutlet var rightConstaint: NSLayoutConstraint!
    @IBOutlet var leftConstaint: NSLayoutConstraint!

    @IBOutlet var emptyMsg: UIView!
}
