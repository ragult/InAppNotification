//
//  ACFeedProcessorObjectClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 26/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class ACFeedProcessorObjectClass: NSObject {
    func checkTypeOfDataReceived(dataDictionary: NSDictionary, isFromHistory: Bool = false) {
        if let src = dataDictionary.value(forKey: "src") {
            switch src as! String {
            case source.system.rawValue:
                let sysDataDictionary: NSDictionary = dataDictionary.value(forKey: source.system.rawValue) as! NSDictionary
                if let channel = dataDictionary.value(forKey: "chnl") {
                    checkEntityType(dataDictionary: sysDataDictionary, chnl: channel as! String)
                }
            case source.authentication.rawValue:
                print("type of comm")
                let sysDataDictionary = dataDictionary.value(forKey: source.authentication.rawValue)
                let channelName = dataDictionary.value(forKey: "chnl")
                var proceedData = false
                let data = dataDictionary.value(forKeyPath: "comm.gl_mesg_id") as? String ?? ""
                let unique = DatabaseManager.getGlobalMsgId(ref: data)
                    if unique == nil {
                        proceedData = true
                    }
//                } else {
//                    proceedData = true
//                }
                if proceedData {
                    checkMessageChannelType(dataDictionary: sysDataDictionary as! NSDictionary, channelName: channelName as! String, isFromHistory: isFromHistory)
                }
                
            default:
                print("not recognized")
            }
        }
    }

    func checkEntityType(dataDictionary: NSDictionary, chnl: String = "") {
        let type = dataDictionary.value(forKey: "type") as! String

        switch type {
        case systemEntityType.systemEntity.rawValue:
            let actionType = dataDictionary.value(forKey: "action") as! String
            checkActionTypeAndProcessData(actionType: actionType, dataDictionary: dataDictionary, chnl: chnl)
        case systemEntityType.communicationStatus.rawValue:
            let actionType = dataDictionary.value(forKey: "action") as! String
            checkCommunicationStatusType(actionType: actionType, dataDictionary: dataDictionary)
        default:
            print("nothing to be done")
        }
    }

    func checkCommunicationStatusType(actionType: String, dataDictionary: NSDictionary) {
        let readReceiptsClass = ACReadReceiptsProcessorClass()
        readReceiptsClass.processDataForDeliveredMessage(dataDictionary: dataDictionary, actionType: actionType)
    }

    func checkActionTypeAndProcessData(actionType: String, dataDictionary: NSDictionary, chnl: String = "") {
        var proceedData = false
        if let data = dataDictionary.value(forKey: "uniq_ref") {
            let reference = data as! String
            let unique = DatabaseManager.getUniqueRef(ref: reference)
            if unique == nil {
                proceedData = true
            }
        } else {
            proceedData = true
        }
        if proceedData {
            DispatchQueue.global(qos: .background).async {
                switch actionType {
                case actionTypesForGroups.groupIntro.rawValue:
                    ACGroupsProcessingObjectClass.processDataForGroupIntro(dataDict: dataDictionary, channelType: "1")

                case actionTypesForGroups.groupMemebrAdded.rawValue:
                    ACGroupsProcessingObjectClass.processDataForGroupMemberAdded(dataDict: dataDictionary)

                case actionTypesForGroups.groupdetails.rawValue:

                    ACGroupsProcessingObjectClass.processDataForGroupdetailsUpdate(dataDict: dataDictionary)

                case actionTypesForGroups.groupMemebrLeft.rawValue:
                    ACGroupsProcessingObjectClass.processDataForGroupMemberLeft(dataDict: dataDictionary)

                case actionTypesForGroups.groupMemebrRemoved.rawValue:
                    ACGroupsProcessingObjectClass.processDataForGroupMemberRemoved(dataDict: dataDictionary)

                case actionTypesForGroups.groupPhotoChanged.rawValue:
                    ACGroupsProcessingObjectClass.processDataForGroupPhotoUpdate(dataDict: dataDictionary)

                case actionTypesForGroups.phoneNumberChanged.rawValue:
                    ACGroupsProcessingObjectClass.processDataForGroupMemberPhoneumberChanged(dataDict: dataDictionary)

                case actionTypesForGroups.friendAdded.rawValue:

                    ACGroupsProcessingObjectClass.processDataFriendJoined(dataDict: dataDictionary)

                case actionTypesForGroups.adhocIntro.rawValue:

                    ACGroupsProcessingObjectClass.processDataForAdhocIntro(finalDataDict: dataDictionary, channelType: channelType.ADHOC_CHAT.rawValue)

                case actionTypesForGroups.I_AM.rawValue:

                    ACGroupsProcessingObjectClass.processDataForNewIntro(finalDataDict: dataDictionary, channelTyp: "")

                case actionTypesForGroups.Req_intro.rawValue:

                    ACGroupsProcessingObjectClass.processDataForReqIntro(finalDataDict: dataDictionary, channelType: "")

                case actionTypesForGroups.addhoc_memberAdded.rawValue:

                    ACGroupsProcessingObjectClass.processDataForAdhocAddIntro(finalDataDict: dataDictionary, channelType: "")

                case actionTypesForGroups.addhoc_member_Removed.rawValue:

                    ACGroupsProcessingObjectClass.processDataForAdhocRemoveMember(finalDataDict: dataDictionary, channel: chnl)

                case actionTypesForGroups.member_permission_changed.rawValue:

                    ACGroupsProcessingObjectClass.processDataForMemberPermissionChange(finalDataDict: dataDictionary)

                case actionTypesForGroups.group_delete.rawValue:

                    ACGroupsProcessingObjectClass.processDataForGroupDelete(dataDict: dataDictionary)

                default:
                    print("nothing to be done")
                }
            }
        }
    }

    func checkMessageChannelType(dataDictionary: NSDictionary, channelName: String, isFromHistory: Bool = false) {
        let type = (dataDictionary as AnyObject).value(forKey: "channeltype") as! String

        switch type {
        case channelType.ONE_ON_ONE_CHAT.rawValue:
            let directMsgProcess = ACDirectChatCommunicationProcessor()
            directMsgProcess.processDataForDirectChat(dataDict: dataDictionary, chnlType: channelType.ONE_ON_ONE_CHAT, isHistory: isFromHistory)

        case channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue:
            let directMsgProcess = ACDirectChatCommunicationProcessor()
            directMsgProcess.processDataForDirectChat(dataDict: dataDictionary, chnlType: channelType.GROUP_MEMBER_ONE_ON_ONE, isHistory: isFromHistory)

        case channelType.GROUP_CHAT.rawValue:
            let directMsgProcess = ACGroupChatCommunicationProcessor()
            directMsgProcess.processDataForGroupChat(dataDict: dataDictionary, channelType: channelType.GROUP_CHAT, channelName: channelName, isFromHistory: isFromHistory)
        case channelType.PUBLIC_GROUP.rawValue:
            let directMsgProcess = ACGroupChatCommunicationProcessor()
            directMsgProcess.processDataForGroupChat(dataDict: dataDictionary, channelType: channelType.PUBLIC_GROUP, channelName: channelName, isFromHistory: isFromHistory)
            print("public group")
        case channelType.PRIVATE_GROUP.rawValue:
            let directMsgProcess = ACGroupChatCommunicationProcessor()
            directMsgProcess.processDataForGroupChat(dataDict: dataDictionary, channelType: channelType.PRIVATE_GROUP, channelName: channelName, isFromHistory: isFromHistory)
            print("broadcast group")
        case channelType.ADHOC_CHAT.rawValue:
            let directMsgProcess = ACGroupChatCommunicationProcessor()
            directMsgProcess.processDataForGroupChat(dataDict: dataDictionary, channelType: channelType.ADHOC_CHAT, channelName: channelName, isFromHistory: isFromHistory)
            print("broadcast group")
        case channelType.TOPIC_GROUP.rawValue:
            let directMsgProcess = ACGroupChatCommunicationProcessor()
            directMsgProcess.processDataForGroupChat(dataDict: dataDictionary, channelType: channelType.TOPIC_GROUP, channelName: channelName, isFromHistory: isFromHistory)
            print("broadcast group")

        default:
            print("nothing to be done")
        }
    }
}
