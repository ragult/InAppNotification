//
//  incomingMessageCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 17/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import AVKit
import UIKit

class IncomingMessageCell: UITableViewCell {
    @IBOutlet var profileName: PaddedLabel!
    @IBOutlet var messageStackView: UIStackView!
    @IBOutlet var backGroundView: UIView!

    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var messageTimeStamp: UILabel!
    @IBOutlet var messageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var messageWidthConstraint: NSLayoutConstraint!
    var PhotosView: PhotosView?
    var ReplyToMessageView: ReplyToMessageView?
    var EventsView: EventsView?
    var VideoView: VideoView?
    var PollView: PollView?
    var RequestView: RequestView?
    var PollwithImages: PollwithImages?
    var PDFView: PDFView?
    var ImageCollection: ImageCollection?
    var musicView: MusicPlayerView?
    var textView: ChatTextView?

    @IBOutlet var bubbleWidth: NSLayoutConstraint!

    @IBOutlet var innerViewLeading: NSLayoutConstraint!
    var viewType: String = ""

    @IBOutlet var mainViewLeading: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));

        backGroundView.extDropShadow()
        profileName.padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
//        messageTimeStamp.text  = getTodayDateString()
        bgImageView.image = UIImage(named: "bgMessage-1")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26))
    }

    func isLastMessage(status: Bool) {
        if status == false {
            bgImageView.image = UIImage(named: "rectangle54")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26))
            mainViewLeading.constant = 26
            innerViewLeading.constant = 5

        } else {
            bgImageView.image = UIImage(named: "bgMessage-1")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26))
            mainViewLeading.constant = 16
            innerViewLeading.constant = 16
        }
    }

    func initializeViews() {
        for view in messageStackView.arrangedSubviews {
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
        case TYPE_OF_MESSAGE.REPLY_TO_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("ReplyToMessageView", owner: self, options: nil)?.first as? ReplyToMessageView {
                ReplyToMessageView = CustomView
                ReplyToMessageView?.extDropShadow()
            }
        case TYPE_OF_MESSAGE.EVENT_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("EventsView", owner: self, options: nil)?.first as? EventsView {
                EventsView = CustomView
            }
        case TYPE_OF_MESSAGE.VIDEO_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("VideoView", owner: self, options: nil)?.first as? VideoView {
                VideoView = CustomView
            }
        case TYPE_OF_MESSAGE.REQUEST_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("RequestView", owner: self, options: nil)?.first as? RequestView {
                RequestView = CustomView
            }
        case TYPE_OF_MESSAGE.POLL_MESSAGE_WITH_IMAGES:
            if let CustomView = Bundle.main.loadNibNamed("PollwithImages", owner: self, options: nil)?.first as? PollwithImages {
                PollwithImages = CustomView
                // self.PollwithImages?.addBorder(toSide: .Top, withColor: UIColor.lightGray.cgColor, andThickness: 1)
            }
        case TYPE_OF_MESSAGE.DOCUMENT_MESSAGE:
            if let CustomView = Bundle.main.loadNibNamed("PDFView", owner: self, options: nil)?.first as? PDFView {
                PDFView = CustomView
                PDFView?.dropLightShadow()
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
