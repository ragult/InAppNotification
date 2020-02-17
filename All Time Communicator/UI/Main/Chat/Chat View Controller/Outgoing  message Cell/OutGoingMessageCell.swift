//
//  OutGoingMessageCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 17/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class OutGoingMessageCell: UITableViewCell {
    @IBOutlet var messageView: UIStackView!
    @IBOutlet var messageTimeStamp: UILabel!
    @IBOutlet var backgroundViewForCustumViews: OutgoingMessegeViewHelperWhiteLayer!
    @IBOutlet var backgroundVIew: outGoingMessageHelperView!

    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet var mainViewTrailingConstraint: NSLayoutConstraint!

    @IBOutlet var topSPaceCOnstraint: NSLayoutConstraint!

    @IBOutlet var leadingCOnstraint: NSLayoutConstraint!

    @IBOutlet var whitebackgroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet var trailingConstraint: NSLayoutConstraint!
    @IBOutlet var seenStatusMessageView: UIImageView!
    var PhotosView: PhotosView?
    var VideoView: VideoView?
    var ImageCollection: ImageCollection?
    var viewType: String = ""
    var musicView: MusicPlayerView?
    var PollView: PollView?
    var PollwithImages: PollwithImages?
    var textView: ChatTextView?

    @IBOutlet var bubbleWidth: NSLayoutConstraint!

    @IBOutlet var timeStampTrailingConstant: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundVIew.extDropShadow()
        messageTimeStamp.text = getTodayDateString()
        topSPaceCOnstraint.constant = 8
        bottomSpaceConstraint.constant = 8
        leadingCOnstraint.constant = 6
        trailingConstraint.constant = 18

        bgImageView.image = UIImage(named: "bgMessageCopy")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26))
        bubbleWidth.constant = 270

//        self.bgImageView.tintColor = COLOURS.APP_MEDIUM_GREEN_COLOR
    }

    func isLastMessage(status: Bool) {
        if status == false {
            bgImageView.image = UIImage(named: "rectangle54Copy")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26))
            mainViewTrailingConstraint.constant = 26
            timeStampTrailingConstant.constant = -6
        } else {
            bgImageView.image = UIImage(named: "bgMessageCopy")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26))
            mainViewTrailingConstraint.constant = 16
            timeStampTrailingConstant.constant = -16
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func getTodayDateString() -> String {
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.hour, .minute, .second], from: date)
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        let today_string = String(hour!) + ":" + String(minute!) + ":" + String(second!)
        return today_string
    }

    func initializeViews() {
        for view in messageView.arrangedSubviews {
            view.removeFromSuperview()
        }
        switch viewType {
        case TYPE_OF_MESSAGE.TEXT_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("ChatTextView", owner: self, options: nil)?.first as? ChatTextView {
                textView = CustomView
                //  self.PollView?.addBorder(toSide: .Top, withColor: UIColor.lightGray.cgColor, andThickness: 1)
                //   self.PhotosView?.setNeedsDisplay(self.bounds)
            }

        case TYPE_OF_MESSAGE.POLL_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("PollView", owner: self, options: nil)?.first as? PollView {
                PollView = CustomView
                //  self.PollView?.addBorder(toSide: .Top, withColor: UIColor.lightGray.cgColor, andThickness: 1)
                //   self.PhotosView?.setNeedsDisplay(self.bounds)
            }

        case TYPE_OF_MESSAGE.PHOTO_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("PhotosView", owner: self, options: nil)?.first as? PhotosView {
                PhotosView = CustomView
//                self.PhotosView?.backgroundColor = .red
            }

        case TYPE_OF_MESSAGE.POLL_MESSAGE_WITH_IMAGES:
            if let CustomView = Bundle.main.loadNibNamed("PollwithImages", owner: self, options: nil)?.first as? PollwithImages {
                PollwithImages = CustomView
                // self.PollwithImages?.addBorder(toSide: .Top, withColor: UIColor.lightGray.cgColor, andThickness: 1)
            }

        case TYPE_OF_MESSAGE.VIDEO_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("VideoView", owner: self, options: nil)?.first as? VideoView {
                VideoView = CustomView
            }
        case TYPE_OF_MESSAGE.PHOTO_COLLECTION_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("ImageCollection", owner: self, options: nil)?.first as? ImageCollection {
                ImageCollection = CustomView
            }
        case TYPE_OF_MESSAGE.AUDIO_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("MusicPlayerView", owner: self, options: nil)?.first as? MusicPlayerView {
                musicView = CustomView
            }
        default:
            print("unable to switch and add data")
        }
    }
}
