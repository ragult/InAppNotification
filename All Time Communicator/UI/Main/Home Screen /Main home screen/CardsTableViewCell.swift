//
//  CardsTableViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 29/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class CardsTableViewCell: UITableViewCell {
    @IBOutlet var BGView: UIView!
    @IBOutlet var messageCardStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
//    @IBOutlet weak var messageStackviewBottomAnchor: NSLayoutConstraint!
//    @IBOutlet weak var messageStackviewTopAnchor: NSLayoutConstraint!
//    @IBOutlet weak var messageStackviewLeadingAnchor: NSLayoutConstraint!
//    @IBOutlet weak var messageStackviewTrailingAnchor: NSLayoutConstraint!

    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var lblcount: UILabel!
    @IBOutlet var chaticon: UIImageView!

    @IBOutlet var bottomTimeLabel: UILabel!
    @IBOutlet var bottomTimelabelHeight: NSLayoutConstraint!

    @IBOutlet var messageStatusImageView: UIImageView!

    @IBOutlet var activityView: UIView!

    @IBOutlet var actIcon: UIActivityIndicatorView!

    var cardViewType: String = ""
    var eventsCard: EventsView?
    var imageCard: imageViewAnnouncementCard?
    var joinGroupCard: InvitationToGroupCard?
    var pollCard: PollCardView?
    var imagePollCard: ImagePollCardView?
    var requestCardView: RequestView?
    var mediaArrayView: ImageMediaArrayView?
    var Audiocard: AudioCardView?
    var TextCard: TextCardView?
    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var discussButton: UIButton!

    @IBOutlet var msgCountView: UIView!
    @IBOutlet var unreadMsgLabel: UILabel!

    @IBOutlet var bottomStackView: UIStackView!

    @IBOutlet var topStackView: UIStackView!
    @IBOutlet var topStackHeight: NSLayoutConstraint!

    @IBOutlet var bottomTimeView: UIStackView!

    @IBOutlet var bottomTimeViewHeight: NSLayoutConstraint!

    @IBOutlet var replyTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

//        BGView.addShadowView()

        BGView.dropMediumShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initializeViews() {
        for view in messageCardStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        switch cardViewType {
        case VIEWTYPE.IMAGE_CARD:
//            messageStackviewTopAnchor.constant = 0
//            messageStackviewBottomAnchor.constant = 0
//            messageStackviewLeadingAnchor.constant = 0
//            messageStackviewTrailingAnchor.constant = 0
            if let CustomView = Bundle.main.loadNibNamed("imageViewAnnouncementCard", owner: self, options: nil)?.first as? imageViewAnnouncementCard {
                imageCard?.extCornerRadius = 4
                imageCard = CustomView
            }
        case VIEWTYPE.EVENT_CARD:
//            messageStackviewLeadingAnchor.constant = 24
            if let CustomView = Bundle.main.loadNibNamed("EventsView", owner: self, options: nil)?.first as? EventsView {
                eventsCard = CustomView
                eventsCard?.timeStamp.textColor = COLOURS.DESCRIPTION_COLOUR
                eventsCard?.eventDescription.textColor = COLOURS.DESCRIPTION_COLOUR
            }
        case VIEWTYPE.REQUEST_CARD:
            if let CustomView = Bundle.main.loadNibNamed("RequestView", owner: self, options: nil)?.first as? RequestView {
                requestCardView = CustomView
            }
        case VIEWTYPE.POLL_CARD:
//            messageStackviewTopAnchor.constant = 0
//            messageStackviewBottomAnchor.constant = 0
//            messageStackviewLeadingAnchor.constant = 0
//            messageStackviewTrailingAnchor.constant = 0

            if let CustomView = Bundle.main.loadNibNamed("PollCardView", owner: self, options: nil)?.first as? PollCardView {
                pollCard = CustomView
            }
        case VIEWTYPE.POLL_IMAGE_CARD:
//            messageStackviewTopAnchor.constant = 0
//            messageStackviewBottomAnchor.constant = 0
//            messageStackviewLeadingAnchor.constant = 0
//            messageStackviewTrailingAnchor.constant = 0
            if let CustomView = Bundle.main.loadNibNamed("ImagePollCardView", owner: self, options: nil)?.first as? ImagePollCardView {
                imagePollCard = CustomView
//                self.imagePollCard?.votesBG.dropLightShadow()
            }
        case VIEWTYPE.INVITATION_CARD:
            if let CustomView = Bundle.main.loadNibNamed("InvitationToGroupCard", owner: self, options: nil)?.first as? InvitationToGroupCard {
                joinGroupCard = CustomView
            }

        case VIEWTYPE.MEDIA_ARRAY:
//            messageStackviewTopAnchor.constant = 0
//            messageStackviewBottomAnchor.constant = 0
//            messageStackviewLeadingAnchor.constant = 0
//            messageStackviewTrailingAnchor.constant = 0
//
            if let CustomView = Bundle.main.loadNibNamed("ImageMediaArrayView", owner: self, options: nil)?.first as? ImageMediaArrayView {
                mediaArrayView = CustomView
            }

        case VIEWTYPE.TEXT:
//            messageStackviewTopAnchor.constant = 0
//            messageStackviewBottomAnchor.constant = 0
//            messageStackviewLeadingAnchor.constant = 0
//            messageStackviewTrailingAnchor.constant = 0
//
            if let CustomView = Bundle.main.loadNibNamed("TextCardView", owner: self, options: nil)?.first as? TextCardView {
                TextCard = CustomView
//                self.TextCard?.extCornerRadius = 4
            }

        case VIEWTYPE.Audio:
//            messageStackviewTopAnchor.constant = 0
//            messageStackviewBottomAnchor.constant = 0
//            messageStackviewLeadingAnchor.constant = 0
//            messageStackviewTrailingAnchor.constant = 0
//
            if let CustomView = Bundle.main.loadNibNamed("AudioCardView", owner: self, options: nil)?.first as? AudioCardView {
                Audiocard = CustomView
                Audiocard?.extCornerRadius = 4
            }

        default:
            print("error while switching and rendering announcment cards")
        }
    }
}

struct VIEWTYPE {
    static let IMAGE_CARD: String = "0"
    static let EVENT_CARD: String = "1"
    static let POLL_CARD: String = "2"
    static let POLL_IMAGE_CARD: String = "3"
    static let REQUEST_CARD: String = "4"
    static let INVITATION_CARD: String = "5"
    static let MEDIA_ARRAY: String = "6"
    static let TEXT: String = "7"
    static let Audio: String = "8"
}
