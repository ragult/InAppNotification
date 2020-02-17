//
//  ACDirectChatClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 31/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import SwiftEventBus
import UIKit

class ACDirectChatCommunicationProcessor: NSObject {
    var isMine = false
    var msgStateForReceivedMsg = messageState.RECEIVER_RECEIVED.rawValue
    var channelIndex: ChannelTable?

    func processDataForDirectChat(dataDict: NSDictionary, chnlType: channelType, isHistory: Bool = false) {
        var msgObject = ACCommunicationMsgObject()
        msgObject = msgObject.mapDataValues(dataDict: dataDict)

        if chnlType == channelType.ONE_ON_ONE_CHAT {
            if let profile = DatabaseManager.getContactIndex(globalUserId: msgObject.senderUUID!) {
                channelIndex = DatabaseManager.getChannelIndex(contactId: profile.id, channelType: chnlType.rawValue)

                if channelIndex == nil {
                    //to store to channel table
                    let channel = ACDatabaseMethods.createChannelTable(conatctId: profile.id, channelType: chnlType.rawValue, globalChannelName: msgObject.senderUUID!)
                    let insertId = DatabaseManager.storeChannelData(channelTable: channel)
                    channelIndex = ChannelTable()
                    channelIndex?.id = String(insertId)
                }
                if profile.fullName == "" {
                    getAnonymusSenderDetails(channelName: msgObject.senderUUID!, msgId: msgObject.globalMsgId!)
                }
                processMessage(msgObject: msgObject, chnlType: chnlType, localSenderId: profile.id, userImage: profile.localImageFilePath, name: profile.fullName, isFromHistory: isHistory)
            } else {
                var userName = ""
                var picture = ""

                if let introdata = dataDict.value(forKey: "newIntro") {
                    let introDataDict = introdata as! NSDictionary
                    userName = introDataDict.value(forKey: "name") as! String
                    picture = introDataDict.value(forKey: "picture") as! String
                }
                let profile = ProfileTable()
                profile.fullName = userName
                profile.picture = picture
                profile.globalUserId = msgObject.senderUUID!
                profile.isAnonymus = false
                profile.phoneNumber = msgObject.senderPhone!
                profile.userstatus = "0"
                let data = DatabaseManager.storeSingleConatct(profileTable: profile)
                profile.id = String(data)

                channelIndex = DatabaseManager.getChannelIndex(contactId: profile.id, channelType: chnlType.rawValue)

                if channelIndex == nil {
                    //to store to channel table
                    let channel = ACDatabaseMethods.createChannelTable(conatctId: profile.id, channelType: chnlType.rawValue, globalChannelName: msgObject.senderUUID!)
                    if userName == "" {
                        channel.channelStatus = "-1"
                    }
                    let insertId = DatabaseManager.storeChannelData(channelTable: channel)
                    channelIndex = ChannelTable()
                    channelIndex?.id = String(insertId)
                }
                if userName == "" {
                    getAnonymusSenderDetails(channelName: msgObject.senderUUID!, msgId: msgObject.globalMsgId!)
                }
                processMessage(msgObject: msgObject, chnlType: chnlType, localSenderId: profile.id, userImage: profile.localImageFilePath, name: profile.fullName, isFromHistory: isHistory)
            }

        } else if chnlType == channelType.GROUP_MEMBER_ONE_ON_ONE {
            if let groupIndex = DatabaseManager.getGroupIndex(groupGlobalId: msgObject.refGroupId!) {
                if let profile = DatabaseManager.getGroupMemberIndex(groupId: groupIndex.id, globalUserId: msgObject.senderUUID!) {
                    channelIndex = DatabaseManager.getChannelIndex(contactId: profile.groupMemberId, channelType: chnlType.rawValue)

                    if channelIndex == nil {
                        //to store to channel table
                        let channel = ACDatabaseMethods.createChannelTable(conatctId: profile.groupMemberId, channelType: chnlType.rawValue, globalChannelName: msgObject.senderUUID!)
                        let insertId = DatabaseManager.storeChannelData(channelTable: channel)
                        channelIndex = ChannelTable()
                        channelIndex?.id = String(insertId)
                    }
                    processMessage(msgObject: msgObject, chnlType: chnlType, localSenderId: profile.groupMemberId, userImage: profile.localImagePath, name: profile.memberName, isFromHistory: isHistory)
                }
            }
        }
    }

    func processMessage(msgObject: ACCommunicationMsgObject, chnlType: channelType, localSenderId: String, userImage: String, name: String, isFromHistory: Bool) {
        let channelId = channelIndex?.id
        let senderLocalId = localSenderId

        let index = ACDatabaseMethods.saveIncomingMessageToDb(msgObject, channelId!, senderLocalId, chnlType, isMine, msgStateForReceivedMsg)

        if index != "0" {
            let message = DatabaseManager.getMessageIndex(globalMsgId: msgObject.globalMsgId!)
            let type = msgObject.msgType
            //to update channel table
            channelIndex?.unseenCount = msgObject.getUnseenCount(unseenCount: (channelIndex?.unseenCount)!)
            channelIndex?.lastSavedMsgid = (message?.id)!
            channelIndex?.lastSenderPhone = msgObject.senderPhone!
            channelIndex?.lastSenderContactId = localSenderId
            channelIndex?.lastMsgTime = msgObject.sent_utc!
            DatabaseManager.updateChannelTable(channelTable: channelIndex!)

            let readReceipt = ACreadReceiptObjectClass()
            readReceipt.id_first = msgObject.globalMsgId
            readReceipt.id_last = msgObject.globalMsgId
            readReceipt.chnl_name = msgObject.senderUUID!
            readReceipt.chnl_typ = chnlType.rawValue
            readReceipt.receiver = msgObject.senderUUID
            readReceipt.senderPhone = UserDefaults.standard.value(forKey: UserKeys.userPhoneNumber) as? String
            readReceipt.senderUUID = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String
            readReceipt.mesg_state = messageState.RECEIVER_RECEIVED.rawValue

            let pubnubClass = ACPubnubClass()

            let pubNubDictionary = NSMutableDictionary()
            pubNubDictionary.setValue("sys", forKey: "src")
            pubNubDictionary.setValue(readReceipt.chnl_name!, forKey: "chnl")
            let convertTodictionary = readReceipt.toDictionary() as? [String: Any]
            let systemData = NSMutableDictionary()
            systemData.setValue("com_recd", forKey: "action")
            systemData.setValue("comm_status", forKey: "type")
            systemData.setValue(convertTodictionary, forKey: "data")
            pubNubDictionary.setValue(systemData, forKey: "sys")

            pubnubClass.sendreceiptsMessageToPubNub(msgObject: pubNubDictionary, channel: "per." + readReceipt.chnl_name!, completionHandler: { (status) -> Void in
                print(status)
            })

            switch type! {
            case messagetype.TEXT.rawValue:
                //to pass to eventBus

                if !isFromHistory {
                    DispatchQueue.main.async {
                        let delegate = UIApplication.shared.delegate as? AppDelegate

                        delegate?.showNotification(displayImage: userImage, title: name, subtitle: (message?.text)!, channelData: self.channelIndex!)
                    }
                }

                let eventBusObj = eventObject.init(chnlObj: channelIndex!, msg: message!)

                ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)
            case messagetype.IMAGE.rawValue:
                if msgObject.media != "" {
                    var downloadArray = [MediaRefernceHolderObject]()

                    // addObject TO Array
                    let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: msgObject.media!, refernce: (message?.id)!, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")
                    downloadArray.append(mediaDownloadObject)
                    downloadImagesFromArray(downloadObjectArray: downloadArray, message: message!, completionHandler: { (msg) -> Void in

                        if !isFromHistory {
                            DispatchQueue.main.async {
                                let delegate = UIApplication.shared.delegate as? AppDelegate

                                delegate?.showNotification(displayImage: userImage, title: name, subtitle: "You have received an Attachment", channelData: self.channelIndex!)
                            }
                        }

                        //to pass to eventBus
                        let eventBusObj = eventObject.init(chnlObj: self.channelIndex!, msg: msg)

                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)

                    })
                }
            case messagetype.AUDIO.rawValue:
                if msgObject.media != "" {
                    var downloadArray = [MediaRefernceHolderObject]()

                    // addObject TO Array
                    let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: msgObject.media!, refernce: (message?.id)!, jobType: downLoadType.media, mediaType: mediaDownloadType.audio.rawValue, mediaExtension: "")
                    downloadArray.append(mediaDownloadObject)
                    downloadImagesFromArray(downloadObjectArray: downloadArray, message: message!, completionHandler: { (msg) -> Void in

                        if !isFromHistory {
                            DispatchQueue.main.async {
                                let delegate = UIApplication.shared.delegate as? AppDelegate

                                delegate?.showNotification(displayImage: userImage, title: name, subtitle: "You have received an Attachment", channelData: self.channelIndex!)
                            }
                        }

                        //to pass to eventBus
                        let eventBusObj = eventObject.init(chnlObj: self.channelIndex!, msg: msg)

                        ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)

                    })
                }
            case messagetype.VIDEO.rawValue:
                if msgObject.media != "" {
                    let json = convertJsonStringToDictionary(text: msgObject.media!)

                    if json != nil {
                        var downloadArray = [MediaRefernceHolderObject]()

                        let urlStr = json!["imgurl"]! as! String

                        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: urlStr, refernce: (message?.id)!, jobType: downLoadType.media, mediaType: mediaDownloadType.video.rawValue, mediaExtension: "")
                        downloadArray.append(mediaDownloadObject)
                        downloadImagesThumbnailFromArray(downloadObjectArray: downloadArray, message: message!, completionHandler: { (msg) -> Void in

                            if !isFromHistory {
                                DispatchQueue.main.async {
                                    let delegate = UIApplication.shared.delegate as? AppDelegate

                                    delegate?.showNotification(displayImage: userImage, title: name, subtitle: "You have received an Attachment", channelData: self.channelIndex!)
                                }
                            }

                            //to pass to eventBus
                            let eventBusObj = eventObject.init(chnlObj: self.channelIndex!, msg: msg)

                            ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)

                        })
                    }
                }
            case messagetype.OTHER.rawValue:
                let otherType = msgObject.otherType
                switch otherType! {
                case otherMessageType.MEDIA_ARRAY.rawValue:

                    let images = ACMessageSenderClass.convertJsonStringToDictionary(text: msgObject.other as! String)
                    let imgArray: NSMutableArray = images.mutableCopy() as! NSMutableArray
                    var downloadArray = [MediaRefernceHolderObject]()

                    for image in imgArray {
                        let imageData = image as! [String: Any]
                        let cloudUrl = imageData["cloudUrl"] as! String
                        let type = imageData["messagetype"] as! String

                        let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: cloudUrl, refernce: (message?.id)!, jobType: downLoadType.media, mediaType: type, mediaExtension: "")
                        downloadArray.append(mediaDownloadObject)
                    }
                    downloadImagesFromArrayForMediaObject(downloadObjectArray:

                        downloadArray, message: message!, completionHandler: { (msg) -> Void in

                            if !isFromHistory {
                                DispatchQueue.main.async {
                                    let delegate = UIApplication.shared.delegate as? AppDelegate

                                    delegate?.showNotification(displayImage: userImage, title: name, subtitle: "You have received an Attachment", channelData: self.channelIndex!)
                                }
                            }

                            //to pass to eventBus
                            let eventBusObj = eventObject.init(chnlObj: self.channelIndex!, msg: msg)

                            ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)

                    })

                case otherMessageType.TEXT_POLL.rawValue:

                    let json = convertJsonStringToDictionary(text: msgObject.other as! String)
                    let pollData = json!["pollData"] as! NSDictionary

                    let polldata = PollTable()
                    polldata.pollId = pollData.value(forKey: "pollId") as! String
                    polldata.messageId = ""
                    polldata.pollTitle = pollData.value(forKey: "pollTitle") as! String
                    polldata.pollCreatedOn = ""
                    polldata.pollCreatedBy = pollData.value(forKey: "pollCreatedBy") as! String

                    polldata.pollExpireOn = pollData.value(forKey: "pollEndDate") as! String
                    polldata.pollType = pollData.value(forKey: "pollType") as! String
                    polldata.pollOPtions = ""
                    polldata.selectedChoice = ""
                    polldata.numberOfOptions = 0
                    let pollLocalId = DatabaseManager.storePollData(pollTable: polldata)

                    DatabaseManager.updateMessageTableForOtherColoumn(imageData: String(pollLocalId), localId: message!.id)

                    let getPoll = GetPollDataRequestObject()
                    getPoll.auth = DefaultDataProcessor().getAuthDetails()
                    getPoll.pollId = polldata.pollId

                    NetworkingManager.getPollData(getGroupModel: getPoll) { (result: Any, sucess: Bool) in
                        if let results = result as? GetPollDataResponseObject, sucess {
                            if sucess {
                                if results.status == "Success" {
                                    let choices = results.data

                                    var data = [PollTable.PollOptions]()
                                    for choice in (choices?.first!.choices)! {
                                        let ch = choice
                                        let option = PollTable.PollOptions()
                                        option.choiceImage = ch.choiceImage
                                        option.choiceText = ch.choiceText

                                        option.choiceId = ch.choiceId

                                        data.append(option)
                                    }

                                    let obj = data.toJsonString()

                                    let polldat = PollTable()
                                    polldat.pollId = polldata.pollId
                                    polldat.messageId = ""

                                    polldat.pollTitle = choices?.first?.pollQuestion ?? ""
                                    polldat.pollCreatedOn = choices?.first?.createdBy ?? ""

                                    polldat.pollCreatedBy = choices?.first?.createdBy ?? ""

                                    polldat.pollExpireOn = choices?.first?.pollEndDate ?? ""
                                    polldat.pollType = choices?.first?.pollType ?? ""
                                    polldat.pollOPtions = obj
                                    polldat.selectedChoice = ""
                                    polldat.numberOfOptions = data.count

                                    _ = DatabaseManager.storePollData(pollTable: polldat)

                                    if !isFromHistory {
                                        DispatchQueue.main.async {
                                            let delegate = UIApplication.shared.delegate as? AppDelegate

                                            delegate?.showNotification(displayImage: userImage, title: name, subtitle: "You have received an poll Request", channelData: self.channelIndex!)
                                        }
                                    }

                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: self.channelIndex!, msg: message!)

                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)
                                }
                            }
                        }
                    }

                case otherMessageType.IMAGE_POLL.rawValue:

                    let json = convertJsonStringToDictionary(text: msgObject.other as! String)
                    let pollData = json!["pollData"] as! NSDictionary

                    let polldata = PollTable()
                    polldata.pollId = pollData.value(forKey: "pollId") as! String
                    polldata.messageId = ""
                    polldata.pollTitle = pollData.value(forKey: "pollTitle") as! String
                    polldata.pollCreatedOn = ""
                    polldata.pollCreatedBy = pollData.value(forKey: "pollCreatedBy") as! String

                    polldata.pollExpireOn = pollData.value(forKey: "pollEndDate") as! String
                    polldata.pollType = pollData.value(forKey: "pollType") as! String
                    polldata.pollOPtions = ""
                    polldata.selectedChoice = ""
                    polldata.numberOfOptions = 0
                    let pollLocalId = DatabaseManager.storePollData(pollTable: polldata)

                    DatabaseManager.updateMessageTableForOtherColoumn(imageData: String(pollLocalId), localId: message!.id)

                    let getPoll = GetPollDataRequestObject()
                    getPoll.auth = DefaultDataProcessor().getAuthDetails()
                    getPoll.pollId = polldata.pollId

                    NetworkingManager.getPollData(getGroupModel: getPoll) { (result: Any, sucess: Bool) in
                        if let results = result as? GetPollDataResponseObject, sucess {
                            if sucess {
                                if results.status == "Success" {
                                    let choices = results.data

                                    var data = [PollTable.PollOptions]()
                                    for choice in (choices?.first!.choices)! {
                                        let ch = choice
                                        let option = PollTable.PollOptions()
                                        option.choiceImage = ch.choiceImage
                                        option.choiceText = ch.choiceText
                                        option.choiceId = ch.choiceId

                                        data.append(option)
                                    }

                                    let obj = data.toJsonString()

                                    let polldat = PollTable()
                                    polldat.pollId = polldata.pollId
                                    polldat.messageId = ""

                                    polldat.pollTitle = choices?.first?.pollQuestion ?? ""
                                    polldat.pollCreatedOn = choices?.first?.createdBy ?? ""

                                    polldat.pollCreatedBy = choices?.first?.createdBy ?? ""

                                    polldat.pollExpireOn = choices?.first?.pollEndDate ?? ""
                                    polldat.pollType = choices?.first?.pollType ?? ""
                                    polldat.pollOPtions = obj
                                    polldat.selectedChoice = ""
                                    polldat.numberOfOptions = data.count

                                    _ = DatabaseManager.storePollData(pollTable: polldat)

                                    if !isFromHistory {
                                        DispatchQueue.main.async {
                                            let delegate = UIApplication.shared.delegate as? AppDelegate

                                            delegate?.showNotification(displayImage: userImage, title: name, subtitle: "You have received an poll Request", channelData: self.channelIndex!)
                                        }
                                    }

                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: self.channelIndex!, msg: message!)

                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)
                                }
                            }
                        }
                    }

                default:
                    print("do nothing")
                }

            default:
                print("do nothing")
            }

        } else {
            print("exists")
        }
    }

    typealias CompletionHandler = (_ msg: MessagesTable) -> Void

    // mark: downLoadImages
    func downloadImagesFromArray(downloadObjectArray: [MediaRefernceHolderObject], message: MessagesTable, completionHandler: @escaping CompletionHandler) {
        for downloadObject in downloadObjectArray {
            ACImageDownloader.downloadImageForIncomingMessages(downloadObject: downloadObject, message: message, completionHandler: { (_, _, messageObj) -> Void in

                completionHandler(messageObj)
            })
        }
    }

    // mark: downLoadThumbnailImages
    func downloadImagesThumbnailFromArray(downloadObjectArray: [MediaRefernceHolderObject], message: MessagesTable, completionHandler: @escaping CompletionHandler) {
        for downloadObject in downloadObjectArray {
            ACImageDownloader.downloadImageForIncomingMessages(downloadObject: downloadObject, message: message, completionHandler: { (_, _, messageObj) -> Void in

                completionHandler(messageObj)

            })
        }
    }

    // mark: downLoadImagesArray

    func downloadImagesFromArrayForMediaObject(downloadObjectArray: [MediaRefernceHolderObject], message: MessagesTable, completionHandler: @escaping CompletionHandler) {
        let localAttachArray = NSMutableArray()
        for downloadObject in downloadObjectArray {
            ACImageDownloader.downloadImageForMediaIncomingMessages(downloadObject: downloadObject, message: message, completionHandler: { (success, path, messageObj) -> Void in

                let result = success
                let attch = NSMutableDictionary()
                if result.mediaType == messagetype.VIDEO.rawValue {
                    attch.setValue(path, forKey: "thumbnail")
                    attch.setValue("", forKey: "imageName")

                } else {
                    attch.setValue(path, forKey: "imageName")
                }
                attch.setValue(result.mediaType, forKey: "msgType")

                localAttachArray.add(attch)

                if localAttachArray.count == downloadObjectArray.count {
                    let dataDict = NSMutableDictionary()
                    dataDict.setValue(localAttachArray, forKey: "attachmentArray")
                    let attachmentString = self.convertDictionaryToJsonString(dict: dataDict)
                    DatabaseManager.updateMessageTableForOtherColoumn(imageData: attachmentString, localId: result.refernce)
                    messageObj.other = attachmentString
                    completionHandler(messageObj)
                }

            })
        }
    }

    func convertDictionaryToJsonString(dict: NSMutableDictionary) -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())
        if let jsonString = NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue) {
            return "\(jsonString)"
        }
        return ""
    }

    func convertJsonStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.replacingOccurrences(of: "\n", with: "").data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func getAnonymusSenderDetails(channelName: String, msgId: String) {
        let pubNubDictionary = NSMutableDictionary()
        pubNubDictionary.setValue("sys", forKey: "src")
        pubNubDictionary.setValue(channelName, forKey: "chnl")

        let dataDict = NSMutableDictionary()
        dataDict.setValue("sys_entity", forKey: "type")
        dataDict.setValue("WHO_ARE_YOU", forKey: "action")

        let data = NSMutableDictionary()
        let phone = UserDefaults.standard.string(forKey: UserKeys.userPhoneNumber)
        let globalId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)

        data.setValue(phone, forKey: "phoneNumber")
        data.setValue(globalId, forKey: "globalUserId")
        data.setValue(msgId, forKey: "msgId")

        dataDict.setValue(data, forKey: "data")

        pubNubDictionary.setValue(dataDict, forKey: "sys")
        let pubnubClass = ACPubnubClass()
        pubnubClass.sendSystemMessageToPubNub(msgObject: pubNubDictionary, channel: channelName, completionHandler: { (success) -> Void in

            print(success)
        })
    }
}
