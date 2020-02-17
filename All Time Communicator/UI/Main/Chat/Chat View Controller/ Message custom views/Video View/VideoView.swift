//
//  VideoView.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 18/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import AVKit
import UIKit

class VideoView: UIView {
    var player: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    @IBOutlet var playButton: TableViewButton!
    @IBOutlet var videoThumbnail: UIImageView!
    @IBOutlet var activityView: UIView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var previewButton: UIButton!
}
