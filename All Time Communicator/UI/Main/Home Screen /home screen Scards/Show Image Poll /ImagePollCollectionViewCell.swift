//
//  ImagePollCollectionViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ImagePollCollectionViewCell: UICollectionViewCell {
    @IBOutlet var pollOptionImage: UIImageView!
    @IBOutlet var pollOptionDescription: UILabel!
    @IBOutlet var checkMark: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
