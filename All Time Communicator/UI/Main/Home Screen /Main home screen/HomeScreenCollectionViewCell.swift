//
//  HomeScreenCollectionViewCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 18/10/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class HomeScreenCollectionViewCell: UICollectionViewCell {
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var avatarLabel: UILabel!
    @IBOutlet var avatarBadge: UIView!
    @IBOutlet var badgeCountLabel: UILabel!
    @IBOutlet var confidentialFlag: UIImageView!

    func customization() {
        avatarImage.contentMode = .scaleAspectFill
    }
    
    func setStartChat() {
        self.avatarImage.image = LetterImageGenerator.imageWith(name: "+", randomColor: UIColor(r: 243, g: 243, b: 243), textColor: UIColor().extGetPrimaryColor)
        self.avatarLabel.text = "Start a chat"
        self.confidentialFlag.isHidden = true
        self.avatarBadge.isHidden = true
        self.badgeCountLabel.isHidden = true
    }
    
    func setChannelData(channelTableList: ChannelDisplayObject, indexPath : IndexPath, saveToDisk: ((IndexPath, String, String) -> Void)?, setConfidentiality: ((IndexPath, String) -> Void)?) {
        self.confidentialFlag.isHidden = true
        self.avatarBadge.isHidden = true
        self.badgeCountLabel.isHidden = true
        if channelTableList.channelDisplayNames == "" {
            // find channel type
            switch channelTableList.channelType {
                case channelType.GROUP_CHAT.rawValue:
                    let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                    channelTableList.channelDisplayNames = (groupTable?.groupName)!
                    
                    if groupTable?.localImagePath == "" {
                        channelTableList.channelImageUrl = ""
                        
                        if groupTable?.fullImageUrl != "" {
                            saveToDisk?(indexPath,(groupTable?.fullImageUrl)!, (groupTable?.id)!)
                        }
                        
                    } else {
                        channelTableList.channelImageUrl = (groupTable?.localImagePath)!
                    }
                    self.avatarImage.image = UIImage(named: "icon_DefaultGroup")
                    
                    if groupTable?.confidentialFlag == "1" {
                        setConfidentiality?(indexPath, (groupTable?.confidentialFlag)!)
                        //                    self.confidentialFlag.isHidden = false
                        
                        //                    self.avatarBadge.isHidden = true
                }
                
                case channelType.ONE_ON_ONE_CHAT.rawValue:
                    let contactDetails = DatabaseManager.getContactDetails(phoneNumber: channelTableList.lastSenderPhoneBookContactId)
                    channelTableList.channelDisplayNames = (contactDetails?.fullName)!
                    if contactDetails?.localImageFilePath == "" {
                        channelTableList.channelImageUrl = ""
                        if contactDetails?.picture != "" {
                            saveToDisk?(indexPath,(contactDetails?.picture)!, (contactDetails?.id)!)
                        }
                    } else {
                        channelTableList.channelImageUrl = (contactDetails?.localImageFilePath)!
                    }
                    self.avatarImage.image = UIImage(named: "icon_DefaultMutual")
                
                case channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue:
                    
                    let contactDetails = DatabaseManager.getGroupMemberIndexForMemberId(groupId: channelTableList.lastSenderPhoneBookContactId)
                    let groupDetail = DatabaseManager.getGroupDetail(groupGlobalId: (contactDetails?.groupId)!)
                    
                    channelTableList.channelDisplayNames = (contactDetails?.memberName)! + "( via \(groupDetail?.groupName ?? ""))"
                    
                    if contactDetails?.localImagePath == "" {
                        channelTableList.channelImageUrl = ""
                        if contactDetails?.thumbUrl != "" {
                            saveToDisk?(indexPath,(contactDetails?.thumbUrl)!, (contactDetails?.globalUserId)!)
                        }
                    } else {
                        channelTableList.channelImageUrl = (contactDetails?.localImagePath)!
                    }
                    self.avatarImage.image = UIImage(named: "icon_DefaultMutual")
                
                case channelType.ADHOC_CHAT.rawValue:
                    let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                    channelTableList.channelDisplayNames = (groupTable?.groupName)!
                    
                    if groupTable?.localImagePath == "" {
                        channelTableList.channelImageUrl = ""
                        if groupTable?.fullImageUrl != "" {
                            saveToDisk?(indexPath,(groupTable?.fullImageUrl)!, (groupTable?.id)!)
                        }
                    } else {
                        channelTableList.channelImageUrl = (groupTable?.localImagePath)!
                    }
                    
                    self.avatarImage.image = UIImage(named: "icon_DefaultGroup")
                case channelType.TOPIC_GROUP.rawValue:
                    let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelTableList.lastSenderPhoneBookContactId)
                    channelTableList.channelDisplayNames = (groupTable?.groupName)!
                    
                    if groupTable?.localImagePath == "" {
                        channelTableList.channelImageUrl = ""
                        
                        if groupTable?.fullImageUrl != "" {
                            saveToDisk?(indexPath,(groupTable?.fullImageUrl)!, (groupTable?.id)!)
                        }
                        
                    } else {
                        channelTableList.channelImageUrl = (groupTable?.localImagePath)!
                    }
                    self.avatarImage.image = UIImage(named: "icon_DefaultGroup")
                
                default:
                    print("do nothing")
                    self.avatarImage.image = UIImage(named: "icon_DefaultGroup")
            }
        }
        
        self.avatarLabel.text = channelTableList.channelDisplayNames
        if let count = Int(channelTableList.unseenCount) {
            if count > 0 {
                self.avatarBadge.isHidden = false
                self.badgeCountLabel.isHidden = false
                self.badgeCountLabel.text = channelTableList.unseenCount
                //            self.avatarImage.layer.borderColor = UIColor.clear.cgColor
                
            } else {
                self.avatarBadge.isHidden = true
                self.badgeCountLabel.isHidden = true
                //            self.avatarImage.layer.borderColor = UIColor.clear.cgColor
            }
        } else {
            self.avatarBadge.isHidden = true
            self.badgeCountLabel.isHidden = true
        }
    }
}
