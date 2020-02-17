//
//  ACGroupsProcessingObjectClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 26/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class ACGroupsProcessingObjectClass {
    static func processDataForGroupIntro(dataDict: NSDictionary, channelType _: String) {
        var downloadArray = [MediaRefernceHolderObject]()

        let user = DatabaseManager.getUser()
        let groupIntro: ACGroupIntroObject = mapDataValues(finalDataDict: dataDict)
        var groupId: String = ""
        let group = GroupTable()
        if DatabaseManager.getGroupIndex(groupGlobalId: groupIntro.grp_glbId) != nil {
            let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: groupIntro.grp_glbId)
            groupId = (groupIdTable?.id)!
            group.id = groupId
        }

        group.groupName = groupIntro.name
        group.groupGlobalId = groupIntro.grp_glbId
        group.groupType = groupIntro.typ
        group.groupStatus = groupStats.ACTIVE.rawValue
        group.fullImageUrl = groupIntro.thumb_url
        group.confidentialFlag = groupIntro.conf
        group.createdBy = groupIntro.adm_glbId

        DatabaseManager.checkIfGroupExistsOrUpdateTheSummary(groupTable: group)

        if group.id == "" {
            if DatabaseManager.getGroupIndex(groupGlobalId: groupIntro.grp_glbId) != nil {
                let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: groupIntro.grp_glbId)
                groupId = (groupIdTable?.id)!
                group.id = groupId
            }
        }

        // addObject TO Array
        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: groupIntro.thumb_url, refernce: groupId, jobType: downLoadType.group, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")
        downloadArray.append(mediaDownloadObject)

//        //delete all group members
//        DatabaseManager.deleteFromMembersTable(globalGroupId: group.id)
//
        let admName = groupIntro.adm_name
        // for adding admin to group member table
        var groupMem = GroupMemberTable()
//        groupMem.groupMemberId = group.groupId

        groupMem.globalUserId = groupIntro.adm_glbId
        groupMem.memberName = groupIntro.adm_name

        groupMem.album = false
        groupMem.superAdmin = groupIntro.super_admin.boolValue
        groupMem.addMember = !groupIntro.super_admin.boolValue
        groupMem.phoneNumber = groupIntro.adm_phone
        groupMem.thumbUrl = groupIntro.adm_imgUrl
        groupMem.groupId = group.id
        groupMem.memberStatus = "1"
        _ = DatabaseManager.updateGroupMmembers(groupMemebrsTable: groupMem)

        // for adding self to group member table
        groupMem = GroupMemberTable()
//        groupMem.groupMemberId = group.groupId
        groupMem.globalUserId = (user?.globalUserId)!
        groupMem.superAdmin = false
        groupMem.addMember = false
        groupMem.phoneNumber = (user?.phoneNumber)!
        groupMem.memberName = (user?.fullName)!
        groupMem.groupId = group.id
        groupMem.memberStatus = "1"
        _ = DatabaseManager.updateGroupMmembers(groupMemebrsTable: groupMem)

        let chnl = getChannelTypeForGroup(grpType: groupIntro.typ)
        var channel = ChannelTable()
        if DatabaseManager.getChannelIndex(contactId: groupId, channelType: chnl) == nil {
            //to store to channel table
            channel = ACDatabaseMethods.createChannelTable(conatctId: group.id, channelType: chnl, globalChannelName: groupIntro.channel)
            let chnId = DatabaseManager.storeChannelData(channelTable: channel)
            channel.id = String(chnId)
        }

//        let dat = dataDict.value(forKey: "data") as! NSDictionary
        if let ref = dataDict.value(forKey: "uniq_ref") {
            let reference = ref as! String
            _ = DatabaseManager.SaveUniqueRef(ref: reference)
        }

        // to get groups
        var groupMembers: [GroupMemberTable] = []

        let getGroup = GetGroupRequestModel()

        getGroup.groupId = groupIntro.grp_glbId
        getGroup.auth = DefaultDataProcessor().getAuthDetails()
        getGroup.groupType = "2"

        NetworkingManager.getGroup(getGroupModel: getGroup) { (result: Any, sucess: Bool) in
            if let result = result as? GetGroupResponseModel, sucess {
                // change to global user id and set refresh to 0
//                        group.groupId = groupId
                if result.status == "Success" {
                    group.id = groupId
                    group.groupGlobalId = result.data.groupGlobalId ?? ""
                    group.groupName = result.data.groupName ?? ""
                    group.groupType = result.data.groupType ?? ""
                    group.groupDescription = result.data.groupDescription ?? ""
                    group.address = result.data.address ?? ""
                    group.confidentialFlag = result.data.confidentialFlag ?? ""
                    group.fullImageUrl = result.data.fullImageUrl ?? ""
                    group.thumbnailUrl = result.data.thumnailIUrl ?? ""
                    group.groupStatus = result.data.groupStatus ?? "1"
                    group.createdBy = result.data.createdBy ?? ""
                    group.createdOn = result.data.createdOn ?? ""
                    group.createdByThumbnailUrl = result.data.createdByThumbnailUrl ?? ""
                    group.createdByMobileNumber = result.data.createdByMobileNumber ?? ""
                    group.mapLocationId = result.data.mapLocationId ?? ""
                    group.mapServiceProvider = result.data.mapServiceProvider ?? ""
                    group.qrURL = result.data.qrurl ?? ""

                    
                    group.qrCode = result.data.qrCode ?? ""
                    group.publicGroupCode = result.data.publicGroupCode ?? ""
                    group.groupCode = result.data.groupCode ?? ""
                    group.webUrl = result.data.webUrl ?? ""
                    group.groupPublicId = result.data.groupPublicId ?? ""
                    let lat = result.data.latitude ?? ""
                    let long = result.data.longitude ?? ""

                    if lat != "" || long != "" {
                        let latDict = NSMutableDictionary()
                        latDict.setValue(lat, forKey: "lat")
                        latDict.setValue(long, forKey: "long")

                        let coordinates = ACGroupChatCommunicationProcessor().convertDictionaryToJsonString(dict: latDict)
                        group.coordinates = coordinates
                    }

                    for member in result.data.groupMembers {
                        let getMember = GroupMemberTable()
                        getMember.loadValues(result: member)
                        let contactId = DatabaseManager.getContactIndex(globalUserId: getMember.globalUserId)
                        if contactId != nil {
                            getMember.groupMemberContactId = (contactId?.id)!
                        } else {
                            getMember.groupMemberContactId = "0"
                        }
                        getMember.groupId = groupId
                        let memebrIndex = DatabaseManager.updateGroupMmembers(groupMemebrsTable: getMember)
                        groupMembers.append(getMember)

                        // addObject TO Array
                        let mediaDownloadObjectN = MediaRefernceHolderObject(mediaUrl: getMember.thumbUrl, refernce: String(memebrIndex), jobType: downLoadType.groupMember, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")
                        downloadArray.append(mediaDownloadObjectN)
                    }
                    let chnltyp = self.getChannelForGroup(grpType: groupIntro.typ)

                    let newmsg = self.saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(admName) has added you to the group", messageOtherType: otherMessageType.INFO, senderId: group.createdBy, channelId: channel.id, channel: channel)

                    //to pass to eventBus
                    let eventBusObj = eventObject.init(chnlObj: channel, msg: newmsg)

                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)

                    DispatchQueue.main.async {
                        if (user?.globalUserId) != group.createdBy {
                            let delegate = UIApplication.shared.delegate as? AppDelegate

                            delegate?.showNotification(displayImage: "", title: group.groupName, subtitle: "\(admName) created a group and has added you", channelData: channel)
                        }
                    }

                    DatabaseManager.checkIfGroupExistsOrUpdate(groupTable: group)
                    ACEventBusManager.postNotificationWithoutObject(notificationName: eventBusHandler.groupAdded)

                } else {
                    if result.status == "Exception" {
                        let errorMsg = result.errorMsg[0]
                        if errorMsg == "IU-100" || errorMsg == "AUT-101" {
//                                    self.gotohomePagefromGroup()
                        }
                    }
                }
            }

//                    group.groupMembers = groupMembers
        }
    }

    static func processDataForGroupMemberAdded(dataDict: NSDictionary) {
        let data = dataDict.value(forKey: "data") as! NSDictionary

        if DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "grp_glbId") as? String)!) != nil {
            let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "grp_glbId") as? String)!)
            let groupId = (groupIdTable?.id)!

            let groupMembersArray = (data.value(forKey: "grp_members") as? NSArray)!
            if groupMembersArray.count == 1 {
//                let memb = groupMembersArray[0] as? NSArray

                let memberDictionary = groupMembersArray[0] as? NSDictionary

                if let groupmemberTable = DatabaseManager.getGroupMemberIndex(groupId: groupId, globalUserId: (memberDictionary?.value(forKey: "globalId")! as? String)!) {
                    let groupMem = GroupMemberTable()
                    groupMem.globalUserId = memberDictionary?.value(forKey: "globalId") as? String ?? ""
                    groupMem.album = false
                    groupMem.phoneNumber = memberDictionary?.value(forKey: "phone") as? String ?? ""
                    groupMem.thumbUrl = memberDictionary?.value(forKey: "thumbnailUrl") as? String ?? ""
                    groupMem.groupId = groupId
                    groupMem.memberName = memberDictionary?.value(forKey: "name") as? String ?? ""
                    groupMem.memberStatus = "1"
                    groupMem.groupMemberId = groupmemberTable.groupMemberId
                    let contactId = DatabaseManager.getContactIndex(globalUserId: groupMem.globalUserId)
                    if contactId != nil {
                        groupMem.groupMemberContactId = (contactId?.id)!
                    } else {
                        groupMem.groupMemberContactId = "0"
                    }
                    _ = DatabaseManager.updateGroupMembersforNewValue(groupMemebrsTable: groupMem)

                    let chnltyp = getChannelForGroup(grpType: groupIdTable!.groupType)
                    let chnls = getChannelTypeForGroup(grpType: groupIdTable!.groupType)

                    if let chTable = DatabaseManager.getChannelIndex(contactId: groupId, channelType: chnls) {
                        let messageText = GlobalStrings.memberAddedToGroup.replacingOccurrences(of: "[0]", with: groupMem.memberName)
                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: groupMem.groupMemberContactId, channelId: chTable.id, channel: chTable)

                        //to pass to eventBus
                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                    }
                } else {
                    let groupMem = GroupMemberTable()
                    groupMem.globalUserId = memberDictionary?.value(forKey: "globalId") as? String ?? ""
                    groupMem.album = false
                    groupMem.phoneNumber = memberDictionary?.value(forKey: "phone") as? String ?? ""
                    groupMem.thumbUrl = memberDictionary?.value(forKey: "thumbnailUrl") as? String ?? ""
                    groupMem.groupId = groupId
                    groupMem.memberName = memberDictionary?.value(forKey: "name") as? String ?? ""
                    groupMem.memberStatus = "1"
                    let contactId = DatabaseManager.getContactIndex(globalUserId: groupMem.globalUserId)
                    if contactId != nil {
                        groupMem.groupMemberContactId = (contactId?.id)!
                    } else {
                        groupMem.groupMemberContactId = "0"
                    }
                    _ = DatabaseManager.updateGroupMmembers(groupMemebrsTable: groupMem)

                    let chnls = getChannelTypeForGroup(grpType: groupIdTable!.groupType)

                    if let chTable = DatabaseManager.getChannelIndex(contactId: groupId, channelType: chnls) {
                        let messageText = GlobalStrings.memberAddedToGroup.replacingOccurrences(of: "[0]", with: groupMem.memberName)
                        let chnltyp = getChannelForGroup(grpType: groupIdTable!.groupType)

                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: groupMem.groupMemberContactId, channelId: chTable.id, channel: chTable)
                        //to pass to eventBus
                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                    }
                }
                if let ref = dataDict.value(forKey: "uniq_ref") {
                    let reference = ref as! String
                    _ = DatabaseManager.SaveUniqueRef(ref: reference)
                }
            } else {
                for groupMembers in groupMembersArray {
                    let memberDictionary = groupMembers as? NSDictionary

                    if let groupmemberTable = DatabaseManager.getGroupMemberIndex(groupId: groupId, globalUserId: (memberDictionary?.value(forKey: "globalId")! as? String)!) {
                        let groupMem = GroupMemberTable()
                        groupMem.globalUserId = memberDictionary?.value(forKey: "globalId") as? String ?? ""
                        groupMem.album = false
                        groupMem.phoneNumber = memberDictionary?.value(forKey: "phone") as? String ?? ""
                        groupMem.thumbUrl = memberDictionary?.value(forKey: "thumbnailUrl") as? String ?? ""
                        groupMem.groupId = groupId
                        groupMem.memberName = memberDictionary?.value(forKey: "name") as? String ?? ""
                        groupMem.memberStatus = "1"
                        groupMem.groupMemberId = groupmemberTable.groupMemberId
                        let contactId = DatabaseManager.getContactIndex(globalUserId: groupMem.globalUserId)
                        if contactId != nil {
                            groupMem.groupMemberContactId = (contactId?.id)!
                        } else {
                            groupMem.groupMemberContactId = "0"
                        }
                        _ = DatabaseManager.updateGroupMembersforNewValue(groupMemebrsTable: groupMem)
                        let chnltyp = getChannelForGroup(grpType: groupIdTable!.groupType)
                        let chnls = getChannelTypeForGroup(grpType: groupIdTable!.groupType)

                        if let chTable = DatabaseManager.getChannelIndex(contactId: groupId, channelType: chnls) {
                            let messageText = GlobalStrings.memberAddedToGroup.replacingOccurrences(of: "[0]", with: groupMem.memberName)
                            let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: groupMem.groupMemberContactId, channelId: chTable.id, channel: chTable)
                            //to pass to eventBus
                            let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                            ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                        }
                    } else {
                        let groupMem = GroupMemberTable()
                        groupMem.globalUserId = memberDictionary?.value(forKey: "globalId") as? String ?? ""
                        groupMem.album = false
                        groupMem.phoneNumber = memberDictionary?.value(forKey: "phone") as? String ?? ""
                        groupMem.thumbUrl = memberDictionary?.value(forKey: "thumbnailUrl") as? String ?? ""
                        groupMem.groupId = groupId
                        groupMem.memberName = memberDictionary?.value(forKey: "name") as? String ?? ""
                        groupMem.memberStatus = "1"
                        let contactId = DatabaseManager.getContactIndex(globalUserId: groupMem.globalUserId)
                        if contactId != nil {
                            groupMem.groupMemberContactId = (contactId?.id)!
                        } else {
                            groupMem.groupMemberContactId = "0"
                        }
                        _ = DatabaseManager.updateGroupMmembers(groupMemebrsTable: groupMem)
                        let chnltyp = getChannelForGroup(grpType: groupIdTable!.groupType)
                        let chnls = getChannelTypeForGroup(grpType: groupIdTable!.groupType)

                        if let chTable = DatabaseManager.getChannelIndex(contactId: groupId, channelType: chnls) {
                            let messageText = GlobalStrings.memberAddedToGroup.replacingOccurrences(of: "[0]", with: groupMem.memberName)
                            let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: groupMem.groupMemberContactId, channelId: chTable.id, channel: chTable)
                            //to pass to eventBus
                            let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                            ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                        }
                    }
                    if let ref = dataDict.value(forKey: "uniq_ref") {
                        let reference = ref as! String
                        _ = DatabaseManager.SaveUniqueRef(ref: reference)
                    }
                }
            }
        }
    }

    static func processDataForGroupMemberRemoved(dataDict: NSDictionary) {
        let data = dataDict.value(forKey: "data") as! NSDictionary

        if DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "groupId") as? String)!) != nil {
            let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "groupId") as? String)!)
            let groupId = (groupIdTable?.id)!
            let groupMemebrsDict = (data.value(forKey: "memGlobalUserIds") as? NSDictionary)!
            let groupMembersArray = (groupMemebrsDict.value(forKey: "globalUserId") as? NSArray)!

            for groupMembers in groupMembersArray {
                if let groupMember = DatabaseManager.getGroupMemberIndex(groupId: groupId, globalUserId: groupMembers as! String) {
                    let mem = groupMembers as! String
                    let groupMem = GroupMemberTable()
                    groupMem.globalUserId = groupMembers as! String
                    groupMem.groupId = groupId
                    groupMem.memberStatus = groupMemberStats.INACTIVE.rawValue
                    DatabaseManager.updateGroupMembersStatus(groupMemebrsTable: groupMem)
                    let userid = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!

                    let chnltyp = getChannelForGroup(grpType: groupIdTable!.groupType)
                    let chnls = getChannelTypeForGroup(grpType: groupIdTable!.groupType)

                    if let chTable = DatabaseManager.getChannelIndex(contactId: groupId, channelType: chnls) {
                        let messageText = GlobalStrings.memberRemovedFromGroup.replacingOccurrences(of: "[0]", with: groupMember.memberName)
                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: groupMember.groupMemberContactId, channelId: chTable.id, channel: chTable)
                        //to pass to eventBus
                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)

                        if userid == mem {
                            DatabaseManager.UpdateGroupStatus(groupStatus: groupStats.INACTIVE.rawValue, groupId: groupId)
                            ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.groupinactive)
                        }
                    }
                }
            }
            if let ref = dataDict.value(forKey: "uniq_ref") {
                let reference = ref as! String
                _ = DatabaseManager.SaveUniqueRef(ref: reference)
            }
        }
    }

    static func processDataForGroupMemberLeft(dataDict: NSDictionary) {
        let data = dataDict.value(forKey: "data") as! NSDictionary

        if DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "groupId") as? String)!) != nil {
            let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "groupId") as? String)!)
            let groupId = (groupIdTable?.id)!

            let groupMember = DatabaseManager.getGroupMemberIndex(groupId: groupId, globalUserId: data.value(forKey: "globalUserId") as! String)
            let groupMem = GroupMemberTable()
            groupMem.globalUserId = data.value(forKey: "globalUserId") as? String ?? ""
            groupMem.groupId = groupId
            groupMem.memberStatus = groupMemberStats.INACTIVE.rawValue
            DatabaseManager.updateGroupMembersStatus(groupMemebrsTable: groupMem)
            let chnltyp = getChannelForGroup(grpType: groupIdTable!.groupType)
            let chnls = getChannelTypeForGroup(grpType: groupIdTable!.groupType)

            if let chTable = DatabaseManager.getChannelIndex(contactId: groupId, channelType: chnls) {
                let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!

                var messageText = GlobalStrings.memberleftFromGroup.replacingOccurrences(of: "[0]", with: (groupMember?.memberName)!)

                if groupMem.globalUserId == userId {
                    messageText = "You have exited the group"
                }

                let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: (groupMember?.groupMemberContactId)!, channelId: chTable.id, channel: chTable)

                //to pass to eventBus
                let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
            }
            if let ref = dataDict.value(forKey: "uniq_ref") {
                let reference = ref as! String
                _ = DatabaseManager.SaveUniqueRef(ref: reference)
            }
        }
    }

    static func processDataForGroupMemberPhoneumberChanged(dataDict: NSDictionary) {
        let data = dataDict.value(forKey: "data") as! NSDictionary

        let groupMem = GroupMemberTable()
        groupMem.globalUserId = data.value(forKey: "globalUserId") as? String ?? ""
        groupMem.phoneNumber = data.value(forKey: "newPhone") as? String ?? ""
        DatabaseManager.updateGroupMembersPhoneNumber(groupMemebrsTable: groupMem)

        DatabaseManager.updateMemberPhoneNumber(phoneNumber: groupMem.phoneNumber, globalUserId: groupMem.globalUserId)

        let contact = DatabaseManager.getContactIndex(globalUserId: groupMem.globalUserId)

        if contact != nil {
            let messageString = GlobalStrings.phoneNumberChnange.replacingOccurrences(of: "[0]", with: (contact?.fullName)!).replacingOccurrences(of: "[1]", with: groupMem.phoneNumber)
            let channelId = UserDefaults.standard.value(forKey: UserKeys.userSystemChannelId)

//        saveUserSystemMessageToMessageTable(channelType: channelType.NOTIFICATIONS, messageType: messagetype.OTHER, messageText: messageString , messageOtherType: otherMessageType.INFO, senderId: (contact!.id), channelId:channelId as! String)
        }
        if let ref = dataDict.value(forKey: "uniq_ref") {
            let reference = ref as! String
            _ = DatabaseManager.SaveUniqueRef(ref: reference)
        }
    }

    static func processDataForGroupdetailsUpdate(dataDict: NSDictionary) {
        let data = dataDict.value(forKey: "data") as! NSDictionary

        if let groupDetails = DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "groupId") as? String)!) {
            if let name = data.value(forKey: "name") {
                groupDetails.groupName = name as! String
            }
            if let desc = data.value(forKey: "description") {
                groupDetails.groupDescription = desc as! String
            }

            DatabaseManager.UpdategroupTable(groupTable: groupDetails)
        }
        if let ref = dataDict.value(forKey: "uniq_ref") {
            let reference = ref as! String
            _ = DatabaseManager.SaveUniqueRef(ref: reference)
        }
    }

    static func processDataForGroupPhotoUpdate(dataDict: NSDictionary) {
        let data = dataDict.value(forKey: "data") as! NSDictionary

        if DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "groupId") as? String)!) != nil {
            let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "groupId") as? String)!)
            let groupId = (groupIdTable?.id)!
            let ImgUrl = data.value(forKey: "cloudUrl") as? String ?? ""
            let groups = GroupTable()
            groups.fullImageUrl = ImgUrl
            groups.id = groupId
            DatabaseManager.updateCloudImageInGroupTable(groupTable: groups)

            var downloadArray = [MediaRefernceHolderObject]()
            let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: ImgUrl, refernce: groupId, jobType: downLoadType.group, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")
            downloadArray.append(mediaDownloadObject)

            downloadImagesFromArray(downloadObjectArray: downloadArray)

            let chnltyp = getChannelForGroup(grpType: groupIdTable!.groupType)
            let chnls = getChannelTypeForGroup(grpType: groupIdTable!.groupType)

            if let chTable = DatabaseManager.getChannelIndex(contactId: groupId, channelType: chnls) {
                let messageText = GlobalStrings.groupPhotoChanged
                let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: "0", channelId: chTable.id, channel: chTable)
                //to pass to eventBus
                let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
            }
        }
        if let ref = dataDict.value(forKey: "uniq_ref") {
            let reference = ref as! String
            _ = DatabaseManager.SaveUniqueRef(ref: reference)
        }
    }

    static func mapDataValues(finalDataDict: NSDictionary) -> ACGroupIntroObject {
        let groupIntroObject = ACGroupIntroObject()
        let dataDict = finalDataDict.value(forKey: "data") as! NSDictionary
        groupIntroObject.adm_glbId = dataDict.value(forKey: "adm_glbId") as? String ?? ""
        groupIntroObject.adm_name = dataDict.value(forKey: "adm_name") as? String ?? ""
        groupIntroObject.adm_phone = dataDict.value(forKey: "adm_phone") as? String ?? ""
        groupIntroObject.adm_imgUrl = dataDict.value(forKey: "adm_imgUrl") as? String ?? ""
        groupIntroObject.super_admin = dataDict.value(forKey: "super_admin") as? String ?? ""
        groupIntroObject.conf = dataDict.value(forKey: "conf") as? String ?? ""
        groupIntroObject.typ = dataDict.value(forKey: "typ") as? String ?? ""
        groupIntroObject.thumb_url = dataDict.value(forKey: "thumb_url") as? String ?? ""
        groupIntroObject.channel = dataDict.value(forKey: "channel") as? String ?? ""
        groupIntroObject.grp_glbId = dataDict.value(forKey: "grp_glbId") as? String ?? ""
        groupIntroObject.name = dataDict.value(forKey: "name") as? String ?? ""

        return groupIntroObject
    }

    static func processDataFriendJoined(dataDict: NSDictionary) {
        let data = dataDict.value(forKey: "data") as! NSDictionary

        if DatabaseManager.getContactDetails(phoneNumber: data.value(forKey: "phone") as! String) != nil {
            let userProfile = DatabaseManager.getContactDetails(phoneNumber: data.value(forKey: "phone") as! String)
            let profile = ProfileTable()
            profile.globalUserId = data.value(forKey: "globalId") as! String
            profile.phoneNumber = data.value(forKey: "phone") as! String
            profile.picture = data.value(forKey: "thumbnail") as! String
            profile.isMember = true
            DatabaseManager.updateProfileMember(profile: profile)

            let channelId = UserDefaults.standard.value(forKey: UserKeys.userSystemChannelId)

            let messageText = (userProfile?.fullName)! + GlobalStrings.friendJoined
//            saveUserSystemMessageToMessageTable(channelType: channelType.NOTIFICATIONS, messageType: messagetype.OTHER, messageText: messageText , messageOtherType: otherMessageType.INFO, senderId: (userProfile!.id),channelId: channelId as! String)
        }
    }

    static func processDataForAdhocIntro(finalDataDict: NSDictionary, channelType: String) {
        let dataDict = finalDataDict.value(forKey: "data") as! NSDictionary

        let timestamp = NSDate().timeIntervalSince1970
        let finalTS = String(format: "%.0f", timestamp)

        var groupId: String = ""
        let group = GroupTable()
        if DatabaseManager.getGroupIndex(groupGlobalId: dataDict.value(forKey: "channel") as! String) != nil {
            let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: dataDict.value(forKey: "channel") as! String)
            groupId = (groupIdTable?.id)!
            group.id = groupId
        }

        group.groupName = dataDict.value(forKey: "title") as! String
        group.groupGlobalId = dataDict.value(forKey: "channel") as! String
        group.groupType = groupType.ADHOC_CHAT.rawValue
        group.groupStatus = groupStats.ACTIVE.rawValue
        group.createdBy = dataDict.value(forKey: "createdByUuid") as! String
        group.createdOn = finalTS

        DatabaseManager.checkIfGroupExistsOrUpdateTheSummary(groupTable: group)
        if let ref = finalDataDict.value(forKey: "uniq_ref") {
            let reference = ref as! String
            _ = DatabaseManager.SaveUniqueRef(ref: reference)
        }

        if group.id == "" {
            if DatabaseManager.getGroupIndex(groupGlobalId: dataDict.value(forKey: "channel") as! String) != nil {
                let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: dataDict.value(forKey: "channel") as! String)
                groupId = (groupIdTable?.id)!
                group.id = groupId
            }
        }

        // delete all group members
        DatabaseManager.deleteFromMembersTable(globalGroupId: group.id)

        let Members = dataDict.value(forKey: "members") as! [Any]
        var admName = ""
        for member in Members {
            let mem: NSDictionary = member as! NSDictionary
            // for adding admin to group member table
            let groupMem = GroupMemberTable()

            groupMem.globalUserId = mem.value(forKey: "Uuid") as! String
            groupMem.memberName = mem.value(forKey: "name") as! String

            if group.createdBy == groupMem.globalUserId {
                admName = groupMem.memberName
            }
            let contactId = DatabaseManager.getContactIndex(globalUserId: groupMem.globalUserId)
            if contactId != nil {
                groupMem.groupMemberContactId = (contactId?.id)!
            } else {
                groupMem.groupMemberContactId = "0"
            }

            groupMem.album = false
            groupMem.superAdmin = false
            groupMem.addMember = false
            groupMem.groupId = group.id
            groupMem.memberStatus = "1"
            _ = DatabaseManager.updateGroupMmembers(groupMemebrsTable: groupMem)
        }

        // for adding admin to group member table
        let groupMem = GroupMemberTable()

        groupMem.globalUserId = dataDict.value(forKey: "createdByUuid") as! String
        groupMem.memberName = dataDict.value(forKey: "createdBy") as! String

        let contactId = DatabaseManager.getContactIndex(globalUserId: groupMem.globalUserId)
        if contactId != nil {
            groupMem.groupMemberContactId = (contactId?.id)!

        } else {
            groupMem.groupMemberContactId = "0"
        }

        groupMem.album = false
        groupMem.superAdmin = true
        groupMem.addMember = false
        groupMem.groupId = group.id
        groupMem.memberStatus = "1"
        _ = DatabaseManager.updateGroupMmembers(groupMemebrsTable: groupMem)

        var channel = ChannelTable()
        if DatabaseManager.getChannelIndex(contactId: groupId, channelType: channelType) == nil {
            //to store to channel table
            channel = ACDatabaseMethods.createChannelTable(conatctId: group.id, channelType: channelType, globalChannelName: dataDict.value(forKey: "channel") as! String)
            let chnId = DatabaseManager.storeChannelData(channelTable: channel)
            channel.id = String(chnId)
        } else {
            channel = DatabaseManager.getChannelIndex(contactId: groupId, channelType: channelType)!
        }

        let chnltyp = getChannelForGroup(grpType: groupType.ADHOC_CHAT.rawValue)

        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(admName) has added you to the adhoc group", messageOtherType: otherMessageType.INFO, senderId: group.createdBy, channelId: channel.id, channel: channel)

        let eventBusObj = eventObject.init(chnlObj: channel, msg: newmsg)

        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)

        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.groupactive)

        DispatchQueue.main.async {
            let delegate = UIApplication.shared.delegate as? AppDelegate

            delegate?.showNotification(displayImage: "", title: group.groupName, subtitle: "\(groupMem.memberName) created a group and has added you", channelData: channel)
        }

        ACEventBusManager.postNotificationWithoutObject(notificationName: "newChannelCreated")
    }

    static func processDataForNewIntro(finalDataDict: NSDictionary, channelTyp _: String) {
        let dataDict = finalDataDict.value(forKey: "data") as! NSDictionary

        if DatabaseManager.getContactIndex(globalUserId: dataDict.value(forKey: "globalUserId") as! String) == nil {
            let userProfile = ProfileTable()
            userProfile.fullName = dataDict.value(forKey: "name") as! String
            userProfile.globalUserId = dataDict.value(forKey: "globalUserId") as! String
            userProfile.phoneNumber = dataDict.value(forKey: "phoneNumber") as! String
            userProfile.picture = dataDict.value(forKey: "picture") as! String
            userProfile.userstatus = "1"

            userProfile.isAnonymus = true

            let index = DatabaseManager.storeSingleConatct(profileTable: userProfile)
            print(index)
            DatabaseManager.updateChannelStatusForContactId(status: "1", contactId: String(index), channelTyp: channelType.ONE_ON_ONE_CHAT.rawValue)

        } else {
            if let userProfile = DatabaseManager.getContactIndex(globalUserId: dataDict.value(forKey: "globalUserId") as! String) {
                userProfile.fullName = dataDict.value(forKey: "name") as! String
                userProfile.globalUserId = dataDict.value(forKey: "globalUserId") as! String
                userProfile.phoneNumber = dataDict.value(forKey: "phoneNumber") as! String
                userProfile.picture = dataDict.value(forKey: "picture") as! String
                userProfile.userstatus = "1"
                userProfile.isAnonymus = true

                DatabaseManager.updateUserDatailsFromIntro(profile: userProfile)
                DatabaseManager.updateChannelStatusForContactId(status: "1", contactId: userProfile.id, channelTyp: channelType.ONE_ON_ONE_CHAT.rawValue)
            }
        }
    }

    static func processDataForReqIntro(finalDataDict: NSDictionary, channelType _: String) {
        let dataDict = finalDataDict.value(forKey: "data") as! NSDictionary

        if let msgindex = DatabaseManager.getMessageIndex(globalMsgId: dataDict.value(forKey: "msgId") as! String) {
            print(msgindex)
            let keys = dataDict.allKeys as NSArray
            if keys.contains("globalUserId") {
                if DatabaseManager.getContactIndex(globalUserId: dataDict.value(forKey: "globalUserId") as! String) != nil {
                    sendAnonymusIntroMessage(channelName: dataDict.value(forKey: "phoneNumber") as! String)
                }
            }
        }
    }

    static func processDataForAdhocRemoveMember(finalDataDict: NSDictionary, channel: String) {
        let dataDict = finalDataDict.value(forKey: "data") as! NSDictionary

        if let grp = DatabaseManager.getGroupIndex(groupGlobalId: channel) {
            let groupId = grp.id
            if let groupMemebr = (dataDict.value(forKey: "globalUserId") as? String) {
                if let member = DatabaseManager.getGroupMemberIndex(groupId: groupId, globalUserId: groupMemebr) {
                    let mem = groupMemebr

                    let groupMem = GroupMemberTable()
                    groupMem.globalUserId = mem
                    groupMem.groupId = groupId
                    groupMem.memberStatus = groupMemberStats.INACTIVE.rawValue
                    DatabaseManager.updateGroupMembersStatus(groupMemebrsTable: groupMem)

                    let chnltyp = getChannelForGroup(grpType: groupType.ADHOC_CHAT.rawValue)
                    let chnls = getChannelTypeForGroup(grpType: groupType.ADHOC_CHAT.rawValue)

                    if let chTable = DatabaseManager.getChannelIndex(contactId: groupId, channelType: chnls) {
                        let messageText = member.memberName + " has exited the group"
                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: member.groupMemberContactId, channelId: chTable.id, channel: chTable)
                        //to pass to eventBus
                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                        let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!

                        if userId == mem {
                            DatabaseManager.UpdateGroupStatus(groupStatus: groupStats.INACTIVE.rawValue, groupId: groupId)
                            ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.groupinactive)
                        }
                    }
                }
            }
        }

        if let ref = dataDict.value(forKey: "uniq_ref") {
            let reference = ref as! String
            _ = DatabaseManager.SaveUniqueRef(ref: reference)
        }
    }

    static func processDataForAdhocAddIntro(finalDataDict: NSDictionary, channelType _: String) {
        let dataDict = finalDataDict.value(forKey: "data") as! NSDictionary

        if let channel = dataDict.value(forKey: "channel") {
            let chnl = channel as! String

            if let grp = DatabaseManager.getGroupIndex(groupGlobalId: chnl) {
                let newMembers = dataDict.value(forKey: "newMembers") as! NSArray

                for member in newMembers {
                    let mem: NSDictionary = member as! NSDictionary
                    // for adding admin to group member table
                    let groupMem = GroupMemberTable()

                    groupMem.globalUserId = mem.value(forKey: "Uuid") as! String
                    groupMem.memberName = mem.value(forKey: "name") as! String

                    let contactId = DatabaseManager.getContactIndex(globalUserId: groupMem.globalUserId)
                    if contactId != nil {
                        groupMem.groupMemberContactId = (contactId?.id)!
                    } else {
                        groupMem.groupMemberContactId = "0"
                    }

                    groupMem.album = false
                    groupMem.superAdmin = false
                    groupMem.addMember = false
                    groupMem.groupId = grp.id
                    groupMem.memberStatus = "1"
                    _ = DatabaseManager.updateGroupMmembers(groupMemebrsTable: groupMem)

                    let chnltyp = getChannelForGroup(grpType: groupType.ADHOC_CHAT.rawValue)
                    let chnls = getChannelTypeForGroup(grpType: groupType.ADHOC_CHAT.rawValue)

                    if let chTable = DatabaseManager.getChannelIndex(contactId: grp.id, channelType: chnls) {
                        let messageText = GlobalStrings.memberAddedToGroup.replacingOccurrences(of: "[0]", with: groupMem.memberName)
                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: groupMem.groupMemberContactId, channelId: chTable.id, channel: chTable)

                        //to pass to eventBus
                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                    }
                }
            }
        }

        if let ref = finalDataDict.value(forKey: "uniq_ref") {
            let reference = ref as! String
            _ = DatabaseManager.SaveUniqueRef(ref: reference)
        }

        print(dataDict)
    }

    static func processDataForMemberPermissionChange(finalDataDict: NSDictionary) {
        let dataDict = finalDataDict.value(forKey: "data") as! NSDictionary
        let globalGroupId = dataDict.value(forKey: "globalGroupId") as! String

        if let grps = DatabaseManager.getGroupIndex(groupGlobalId: globalGroupId) {
            let grpMemer = GroupMemberTable()

            grpMemer.globalUserId = (dataDict.value(forKey: "globalUserId") as? String)!
            grpMemer.album = ((dataDict.value(forKey: "album") as? String)?.boolValue) ?? false
            grpMemer.addMember = ((dataDict.value(forKey: "memberAdmin") as? String)?.boolValue) ?? false
            grpMemer.memberTitle = ((dataDict.value(forKey: "memberTitle") as? String)!)
            grpMemer.events = ((dataDict.value(forKey: "events") as? String)?.boolValue) ?? false
            grpMemer.superAdmin = ((dataDict.value(forKey: "superAdmin") as? String)?.boolValue) ?? false
            grpMemer.publicView = ((dataDict.value(forKey: "public") as? String)?.boolValue) ?? false
            grpMemer.publish = ((dataDict.value(forKey: "publish") as? String)?.boolValue) ?? false
            grpMemer.groupId = grps.id

            if let groupMember = DatabaseManager.getGroupMemberIndex(groupId: grpMemer.groupId, globalUserId: grpMemer.globalUserId) {
                // check super admin
                if grpMemer.superAdmin == true {
                    // check perious permission
                    if groupMember.superAdmin != grpMemer.superAdmin {
                        let chnltyp = getChannelForGroup(grpType: grps.groupType)
                        let chnls = getChannelTypeForGroup(grpType: grps.groupType)

                        if let chTable = DatabaseManager.getChannelIndex(contactId: grps.id, channelType: chnls) {
                            let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!
                            if userId == grpMemer.globalUserId {
                                let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have been made as Super admin", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                //to pass to eventBus
                                let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.publishrights)

                                if groupMember.memberTitle != grpMemer.memberTitle {
                                    let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "Your title has been changed to \(grpMemer.memberTitle)", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                }
                            } else {
                                let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(groupMember.memberName) have been removed as Super admin", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)

                                let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.publishrights)

                                if groupMember.memberTitle != grpMemer.memberTitle {
                                    let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(groupMember.memberName) title has been changed to \(grpMemer.memberTitle)", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)

                                    let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)
                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                }
                            }
                        }

                    } else {
                        let chnltyp = getChannelForGroup(grpType: grps.groupType)
                        let chnls = getChannelTypeForGroup(grpType: grps.groupType)

                        if let chTable = DatabaseManager.getChannelIndex(contactId: grps.id, channelType: chnls) {
                            // check for member title
                            let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!
                            if userId == grpMemer.globalUserId {
                                if groupMember.memberTitle != grpMemer.memberTitle {
                                    let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "Your title has been changed to \(grpMemer.memberTitle)", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                }

                            } else {
                                if groupMember.memberTitle != grpMemer.memberTitle {
                                    let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(groupMember.memberName) title has been changed to \(grpMemer.memberTitle)", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)

                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                }
                            }
                        }
                    }

                } else {
                    let chnltyp = getChannelForGroup(grpType: grps.groupType)
                    let chnls = getChannelTypeForGroup(grpType: grps.groupType)

                    if let chTable = DatabaseManager.getChannelIndex(contactId: grps.id, channelType: chnls) {
                        let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!
                        if userId == grpMemer.globalUserId {
                            if groupMember.album != grpMemer.album {
                                if grpMemer.album == true {
                                    let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have been made as Album admin", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)

                                } else {
                                    let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have been removed as Album admin", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                }
                            }

                            if groupMember.addMember != grpMemer.addMember {
                                if grpMemer.addMember == true {
                                    let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have been made as Member admin", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                } else {
                                    let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have been removed as Member admin", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                }
                            }
                            if chnltyp == channelType.TOPIC_GROUP || chnltyp == channelType.PUBLIC_GROUP || chnltyp == channelType.PRIVATE_GROUP {
                                if groupMember.publish != grpMemer.publish {
                                    if grpMemer.publish == true {
                                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You have been granted Publish rights", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                        //to pass to eventBus
                                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.publishrights)

                                    } else {
                                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "You Publish rights has been revoked", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                        //to pass to eventBus
                                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.publishrights)
                                    }
                                }
                            }

                            if groupMember.memberTitle != grpMemer.memberTitle {
                                let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "Your title has been changed to \(grpMemer.memberTitle)", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                //to pass to eventBus
                                let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                            }
                        } else {
                            let mygroupStatus = DatabaseManager.getGroupMemberIndex(groupId: grpMemer.groupId, globalUserId: userId)
                            if checkmemberAdmins(groupMember: mygroupStatus!) {
                                if groupMember.album != grpMemer.album {
                                    if grpMemer.album == true {
                                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(groupMember.memberName) has been made as Album admin", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                        //to pass to eventBus
                                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)

                                    } else {
                                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(groupMember.memberName) has been removed as Album admin", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                        //to pass to eventBus
                                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                    }
                                }

                                if groupMember.addMember != grpMemer.addMember {
                                    if grpMemer.addMember == true {
                                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(groupMember.memberName) has been made as Member admin", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                        //to pass to eventBus
                                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                    } else {
                                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(groupMember.memberName) has been removed as Member admin", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                        //to pass to eventBus
                                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                    }
                                }

                                if groupMember.publish != grpMemer.publish {
                                    if grpMemer.publish == true {
                                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(groupMember.memberName) has been granted Publish rights", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                        //to pass to eventBus
                                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.publishrights)

                                    } else {
                                        let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(groupMember.memberName) Publish rights has been revoked", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                        //to pass to eventBus
                                        let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.publishrights)
                                    }
                                }

                                if groupMember.memberTitle != grpMemer.memberTitle {
                                    let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: "\(groupMember.memberName) title has been changed to \(grpMemer.memberTitle)", messageOtherType: otherMessageType.INFO, senderId: grps.createdBy, channelId: chTable.id, channel: chTable)
                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
                                }
                            }
                        }
                    }
                }
            }

            DatabaseManager.updateGroupMembersStatusNewValue(groupMemebrsTable: grpMemer)

            if let ref = finalDataDict.value(forKey: "uniq_ref") {
                let reference = ref as! String
                _ = DatabaseManager.SaveUniqueRef(ref: reference)
            }
        }

        print(dataDict)
    }

    static func checkmemberAdmins(groupMember: GroupMemberTable) -> Bool {
        if groupMember.superAdmin || groupMember.album || groupMember.addMember || groupMember.publish {
            return true
        } else {
            return false
        }
    }

    static func processDataForGroupDelete(dataDict: NSDictionary) {
        let data = dataDict.value(forKey: "data") as! NSDictionary

        if DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "globalGroupId") as? String)!) != nil {
            let groupIdTable = DatabaseManager.getGroupIndex(groupGlobalId: (data.value(forKey: "globalGroupId") as? String)!)
            let groupId = (groupIdTable?.id)!
            DatabaseManager.UpdateGroupStatus(groupStatus: groupStats.INACTIVE.rawValue, groupId: groupId)

            let chnltyp = getChannelForGroup(grpType: groupIdTable!.groupType)
            let chnls = getChannelTypeForGroup(grpType: groupIdTable!.groupType)

            if let chTable = DatabaseManager.getChannelIndex(contactId: groupId, channelType: chnls) {
                var messageText = GlobalStrings.groupDelete
                let glbUserId = (data.value(forKey: "globalUserId") as? String)!
                if let groupMember = DatabaseManager.getGroupMemberIndex(groupId: groupIdTable!.id, globalUserId: glbUserId) {
                    messageText = messageText + " by \(groupMember.memberName)"
                }

                let newmsg = saveUserSystemMessageToMessageTable(channelType: chnltyp, messageType: messagetype.OTHER, messageText: messageText, messageOtherType: otherMessageType.INFO, senderId: "0", channelId: chTable.id, channel: chTable)
                //to pass to eventBus
                let eventBusObj = eventObject.init(chnlObj: chTable, msg: newmsg)

                ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.systemMessage)
            }
        }
        if let ref = dataDict.value(forKey: "uniq_ref") {
            let reference = ref as! String
            _ = DatabaseManager.SaveUniqueRef(ref: reference)
        }
    }

    static func sendAnonymusIntroMessage(channelName: String) {
        let pubNubDictionary = NSMutableDictionary()
        pubNubDictionary.setValue("sys", forKey: "src")
        pubNubDictionary.setValue(channelName, forKey: "chnl")

        let dataDict = NSMutableDictionary()
        dataDict.setValue("sys_entity", forKey: "type")
        dataDict.setValue("I_AM", forKey: "action")

        let data = NSMutableDictionary()
        let name = UserDefaults.standard.string(forKey: UserKeys.userName)
        let phone = UserDefaults.standard.string(forKey: UserKeys.userPhoneNumber)
        let globalId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)
        let pic = ""

        data.setValue(name, forKey: "name")
        data.setValue(phone, forKey: "phoneNumber")
        data.setValue(globalId, forKey: "globalUserId")
        data.setValue(pic, forKey: "picture")

        dataDict.setValue(data, forKey: "data")

        pubNubDictionary.setValue(dataDict, forKey: "sys")
        let pubnubClass = ACPubnubClass()
        pubnubClass.sendSystemMessageToPubNub(msgObject: pubNubDictionary, channel: channelName, completionHandler: { (success) -> Void in

            print(success)
        })
    }

    static func saveUserSystemMessageToMessageTable(channelType: channelType, messageType: messagetype, messageText: String, messageOtherType: otherMessageType, senderId: String, channelId: String, channel: ChannelTable) -> MessagesTable {
        let msgData = MessagesTable()
        msgData.messageType = messageType.rawValue
        msgData.otherType = messageOtherType.rawValue
        msgData.chanelId = channelId
        msgData.channelType = channelType.rawValue
        msgData.text = messageText
        let timestamp = NSDate().timeIntervalSince1970 * 1000 * 10000
        let finalTS = String(format: "%.0f", timestamp)

        msgData.msgTimeStamp = finalTS
        msgData.globalMsgId = finalTS
        msgData.topicId = finalTS

        msgData.isMine = true
        msgData.senderId = senderId
        msgData.messageState = messageState.MESSAGE_INFO.rawValue
        let msgId = DatabaseManager.storeIntoMsgTable(messageTable: msgData)
        msgData.id = String(msgId)

        channel.lastSavedMsgid = msgData.id
        channel.lastMsgTime = msgData.msgTimeStamp
        DatabaseManager.updateChannelTable(channelTable: channel)

        return msgData
    }

    static func saveUserSystemMessageForNumberChanged(channelType: channelType, messageType: messagetype, messageText: String, messageOtherType: otherMessageType, senderId: String) {
        let channelId = UserDefaults.standard.value(forKey: UserKeys.userSystemChannelId)
        let msgData = MessagesTable()
        msgData.messageType = messageType.rawValue
        msgData.otherType = messageOtherType.rawValue
        msgData.chanelId = channelId as! String
        msgData.channelType = channelType.rawValue
        msgData.text = messageText
        msgData.msgTimeStamp = "\(NSDate().timeIntervalSince1970 * 1000 * 10000)"
        msgData.isMine = true
        msgData.senderId = senderId
        msgData.messageState = messageState.RECEIVER_RECEIVED.rawValue
        DatabaseManager.storeMultipleMessagesIntoMsgTable(messageTable: msgData)
    }

    // mark: downLoadImages
    static func downloadImagesFromArray(downloadObjectArray: [MediaRefernceHolderObject]) {
        for downloadObject in downloadObjectArray {
            ACImageDownloader.downloadImage(downloadObject: downloadObject, completionHandler: { (success, path) -> Void in

                let result = success
                if result.jobType == downLoadType.group {
                    DatabaseManager.updateGroupLocalImagePath(localImagePath: path, localId: result.refernce)
                } else {
                    DatabaseManager.updateGroupMembersLocalImagePath(localImagePath: path, localId: result.refernce)
                }

            })
        }
    }

    static func getChannelTypeForGroup(grpType: String) -> String {
        switch grpType {
        case groupType.GROUP_CHAT.rawValue:
            return channelType.GROUP_CHAT.rawValue
        case groupType.ADHOC_CHAT.rawValue:
            return channelType.ADHOC_CHAT.rawValue
        case groupType.PRIVATE_GROUP.rawValue:
            return channelType.PRIVATE_GROUP.rawValue
        case groupType.PUBLIC_GROUP.rawValue:
            return channelType.PUBLIC_GROUP.rawValue
        case groupType.TOPIC_GROUP.rawValue:
            return channelType.TOPIC_GROUP.rawValue
        default:
            return ""
        }
    }

    static func getChannelForGroup(grpType: String) -> channelType {
        switch grpType {
        case groupType.GROUP_CHAT.rawValue:
            return channelType.GROUP_CHAT
        case groupType.ADHOC_CHAT.rawValue:
            return channelType.ADHOC_CHAT
        case groupType.PRIVATE_GROUP.rawValue:
            return channelType.PRIVATE_GROUP
        case groupType.PUBLIC_GROUP.rawValue:
            return channelType.PUBLIC_GROUP
        case groupType.TOPIC_GROUP.rawValue:
            return channelType.TOPIC_GROUP
        default:
            return channelType.GROUP_CHAT
        }
    }
}

extension String {
    var boolValue: Bool {
        return (self as NSString).boolValue
    }
}
