//
//  ACActiveGroupProcessor.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 07/03/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACActiveGroupProcessor: NSObject {
    func processDataForGroups(groups: [ActiveGroupModelResponse]) {
        for grp in groups {
            let group = GroupTable()

            group.groupGlobalId = grp.groupId ?? ""
            group.groupName = grp.name ?? ""
            group.groupType = grp.type ?? "2"
            group.groupDescription = grp.desc ?? ""
            group.confidentialFlag = grp.confidentialFlag ?? "0"
            group.fullImageUrl = grp.fullImageUrl ?? ""
            group.thumbnailUrl = ""
            group.groupStatus = groupStats.ACTIVE.rawValue
            group.createdBy = grp.createdBy ?? ""
            group.createdOn = grp.createdOn ?? ""
            group.createdByThumbnailUrl = grp.createdByThumbUrl ?? ""
            group.createdByMobileNumber = grp.createdByMobileNo ?? ""
            group.localImagePath = ""
            group.address = grp.address ?? ""
            
            group.qrCode = grp.qrCode ?? ""
            group.publicGroupCode = grp.publicGroupCode ?? ""
            group.groupCode = grp.groupCode ?? ""
            group.webUrl = grp.webUrl ?? ""
            group.groupPublicId = grp.groupPublicId ?? ""
            let groupId = DatabaseManager.storeGroup(groupTable: group)
            group.id = String(groupId)

            if group.fullImageUrl != "" {
                downloadImageForGroup(groupDetails: group)
            }
            for member in grp.groupMembers {
                let getMember = GroupMemberTable()
                getMember.globalUserId = member.globalUserId ?? ""
                let contactId = DatabaseManager.getContactIndex(globalUserId: getMember.globalUserId)
                if contactId != nil {
                    getMember.groupMemberContactId = (contactId?.id)!
                } else {
                    getMember.groupMemberContactId = "0"
                }
                getMember.groupId = String(groupId)
                getMember.memberName = member.name ?? ""
                getMember.thumbUrl = member.thumbUrl ?? ""
                getMember.phoneNumber = member.mobileNo ?? ""
                getMember.memberStatus = "1"
                getMember.createdBy = member.createdBy ?? ""
                getMember.createdOn = member.createdOn ?? ""
                getMember.memberTitle = member.memberTitle ?? ""

                getMember.addMember = member.addMember?.bool ?? false
                getMember.superAdmin = member.superAdmin?.bool ?? false
                getMember.events = member.events?.bool ?? false
                getMember.album = member.album?.bool ?? false
                getMember.publish = member.publish?.bool ?? false

                _ = DatabaseManager.storeGroupMembers(groupMemebrsTable: getMember)
            }

            let type = ACGroupsProcessingObjectClass.getChannelTypeForGroup(grpType: grp.type ?? "")
            if DatabaseManager.getChannelIndex(contactId: String(groupId), channelType: type) == nil {
                //to store to channel table

                let channel = ChannelTable()
                channel.contactId = String(groupId)
                //        channel.ID = group.groupId
                channel.channelType = type
                channel.globalChannelName = grp.channelName ?? ""
                channel.channelStatus = "0"
                channel.unseenCount = "0"
                let chnlId = DatabaseManager.storeChannelData(channelTable: channel)
                channel.id = String(chnlId)
                ACGroupsProcessingObjectClass.saveUserSystemMessageToMessageTable(channelType: channelType(rawValue: type)!, messageType: messagetype.OTHER, messageText: "Group has been restored", messageOtherType: otherMessageType.INFO, senderId: group.createdBy, channelId: String(chnlId), channel: channel)
            }
        }
    }

    func downloadImageForGroup(groupDetails: GroupTable) {
        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: groupDetails.fullImageUrl, refernce: groupDetails.id, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")

        DispatchQueue.global(qos: .background).async {
            ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in

                DatabaseManager.updateGroupLocalImagePath(localImagePath: path, localId: success.refernce)

            })
        }
    }
}

extension String {
    var bool: Bool? {
        switch lowercased() {
        case "true", "t", "yes", "y", "1", "YES":
            return true
        case "false", "f", "no", "n", "0", "NO":
            return false
        default:
            return nil
        }
    }
}
