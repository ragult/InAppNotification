//
//  ACGroupChatCommunicationProcessor.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 04/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACGroupChatCommunicationProcessor: NSObject {
    var isMine = false
    var msgStateForReceivedMsg = messageState.RECEIVER_RECEIVED.rawValue

    func processDataForGroupChat(dataDict: NSDictionary, channelType: channelType, channelName: String, isFromHistory: Bool) {
        var msgObject = ACCommunicationMsgObject()
        msgObject = msgObject.mapDataValues(dataDict: dataDict)
        let userGllobalId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)
        if msgObject.senderUUID != userGllobalId {
            if DatabaseManager.getGroupIndex(groupGlobalId: msgObject.receiver!) != nil {
                if let groupDetails = DatabaseManager.getGroupIndex(groupGlobalId: msgObject.receiver!) {
                    if let channelIndex = DatabaseManager.getChannelIndex(contactId: groupDetails.id, channelType: channelType.rawValue) {
                        if let GroupSenderDetails = DatabaseManager.getGroupMemberIndex(groupId: groupDetails.id, globalUserId: msgObject.senderUUID!) {
                            let channelId = channelIndex.id
                            let senderLocalId = GroupSenderDetails.groupMemberId

                            let index = ACDatabaseMethods.saveIncomingMessageToDb(msgObject, channelId, senderLocalId, channelType, isMine, msgStateForReceivedMsg)

                            if index != "0" {
                                let message = DatabaseManager.getMessageIndex(globalMsgId: msgObject.globalMsgId!)

                                let type = msgObject.msgType
                                //to update channel table
                                channelIndex.unseenCount = msgObject.getUnseenCount(unseenCount: channelIndex.unseenCount)
                                channelIndex.lastSavedMsgid = (message?.id)!
                                channelIndex.lastSenderPhone = msgObject.senderPhone!
                                channelIndex.lastSenderContactId = GroupSenderDetails.groupMemberId
                                channelIndex.lastMsgTime = msgObject.sent_utc!
                                DatabaseManager.updateChannelTable(channelTable: channelIndex)

                                let readReceipt = ACreadReceiptObjectClass()
                                readReceipt.id_first = msgObject.globalMsgId
                                readReceipt.id_last = msgObject.globalMsgId
                                readReceipt.chnl_name = channelName
                                readReceipt.chnl_typ = channelType.rawValue
                                readReceipt.receiver = msgObject.receiver!
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

                                pubnubClass.sendreceiptsMessageToPubNub(msgObject: pubNubDictionary, channel: readReceipt.chnl_name!, completionHandler: { (status) -> Void in

                                    print(status)
                                })

                                switch type! {
                                case messagetype.TEXT.rawValue:
                                    //to pass to eventBus
                                    let eventBusObj = eventObject.init(chnlObj: channelIndex, msg: message!)

                                    if !isFromHistory {
                                        DispatchQueue.main.async {
                                            let delegate = UIApplication.shared.delegate as? AppDelegate

                                            delegate?.showNotification(displayImage: GroupSenderDetails.localImagePath, title: GroupSenderDetails.memberName, subtitle: (message?.text)!, channelData: channelIndex)
                                        }
                                    }

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

                                                    delegate?.showNotification(displayImage: GroupSenderDetails.localImagePath, title: GroupSenderDetails.memberName, subtitle: "You have received an Attachment", channelData: channelIndex)
                                                }
                                            }

                                            //to pass to eventBus
                                            let eventBusObj = eventObject.init(chnlObj: channelIndex, msg: msg)

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

                                                    delegate?.showNotification(displayImage: GroupSenderDetails.localImagePath, title: GroupSenderDetails.memberName, subtitle: "You have received an Attachment", channelData: channelIndex)
                                                }
                                            }

                                            //to pass to eventBus
                                            let eventBusObj = eventObject.init(chnlObj: channelIndex, msg: msg)

                                            ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)

                                        })
                                    }
                                case messagetype.VIDEO.rawValue:
                                    if msgObject.media != "" {
                                        var downloadArray = [MediaRefernceHolderObject]()
                                        let json = convertJsonStringToDictionary(text: msgObject.media!)
                                        if json != nil {
                                            let urlStr = json!["imgurl"]! as! String

                                            // addObject TO Array
                                            let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: urlStr, refernce: (message?.id)!, jobType: downLoadType.media, mediaType: mediaDownloadType.video.rawValue, mediaExtension: "")
                                            downloadArray.append(mediaDownloadObject)
                                            downloadImagesThumbnailFromArray(downloadObjectArray: downloadArray, message: message!, completionHandler: { (msg) -> Void in

                                                if !isFromHistory {
                                                    DispatchQueue.main.async {
                                                        let delegate = UIApplication.shared.delegate as? AppDelegate
                                                        delegate?.showNotification(displayImage: GroupSenderDetails.localImagePath, title: GroupSenderDetails.memberName, subtitle: "You have received an Attachment", channelData: channelIndex)
                                                    }
                                                }

                                                //to pass to eventBus
                                                let eventBusObj = eventObject.init(chnlObj: channelIndex, msg: msg)

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

                                                        delegate?.showNotification(displayImage: GroupSenderDetails.localImagePath, title: GroupSenderDetails.memberName, subtitle: "You have received an Attachment", channelData: channelIndex)
                                                    }
                                                }

                                                //to pass to eventBus
                                                let eventBusObj = eventObject.init(chnlObj: channelIndex, msg: msg)

                                                ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)

                                        })

                                    case otherMessageType.TEXT_POLL.rawValue:

                                        let json = convertJsonStringToDictionary(text: msgObject.other as! String)
                                        let pollData = json!["pollData"] as! NSDictionary

                                        let polldata = PollTable()
                                        polldata.pollId = pollData.value(forKey: "pollId") as! String
                                        polldata.messageId = index
                                        polldata.pollTitle = pollData.value(forKey: "pollTitle") as! String
                                        polldata.pollCreatedOn = ""
                                        polldata.pollCreatedBy = pollData.value(forKey: "pollCreatedBy") as! String

                                        polldata.pollExpireOn = pollData.value(forKey: "pollEndDate") as! String
                                        polldata.pollType = pollData.value(forKey: "pollType") as! String
                                        polldata.pollOPtions = ""
                                        polldata.selectedChoice = ""
                                        polldata.numberOfOptions = 0
                                        let pollLocalId = polldata.toJsonString()

                                        DatabaseManager.updateMessageTableForOtherColoumn(imageData: pollLocalId, localId: message!.id)

                                        let getPoll = GetPollDataRequestObject()
                                        getPoll.auth = DefaultDataProcessor().getAuthDetails()
                                        getPoll.pollId = polldata.pollId

                                        NetworkingManager.getPollData(getGroupModel: getPoll) { (result: Any, sucess: Bool) in
                                            if let results = result as? GetPollDataResponseObject, sucess {
                                                if sucess {
                                                    if results.status == "Success" {
                                                        let choices = results.data

                                                        var data = [PollTable.PollOptions]()
                                                        var downloadArray = [MediaRefernceHolderObject]()

                                                        for choice in (choices?.first!.choices)! {
                                                            let ch = choice
                                                            let option = PollTable.PollOptions()
                                                            option.choiceImage = ch.choiceImage
                                                            option.choiceText = ch.choiceText
                                                            option.choiceId = ch.choiceId

                                                            data.append(option)

                                                            if polldata.pollType != "1" {
                                                                let cloudUrl = ch.choiceImage
                                                                let type = "image"

                                                                let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: cloudUrl, refernce: ch.choiceId, jobType: downLoadType.media, mediaType: type, mediaExtension: "")
                                                                downloadArray.append(mediaDownloadObject)
                                                            }
                                                        }

                                                        let obj = data.toJsonString()

                                                        let polldat = PollTable()
                                                        polldat.pollId = polldata.pollId
                                                        polldat.messageId = index

                                                        polldat.pollTitle = choices?.first?.pollQuestion ?? ""
                                                        polldat.pollCreatedOn = choices?.first?.createdBy ?? ""

                                                        polldat.pollCreatedBy = choices?.first?.createdBy ?? ""

                                                        polldat.pollExpireOn = choices?.first?.pollEndDate ?? ""
                                                        polldat.pollType = choices?.first?.pollType ?? ""
                                                        polldat.pollOPtions = obj
                                                        polldat.selectedChoice = ""
                                                        polldat.numberOfOptions = data.count

                                                        let pollLocalId = polldat.toJsonString()

                                                        DatabaseManager.updateMessageTableForOtherColoumn(imageData: pollLocalId, localId: message!.id)

                                                        message?.other = pollLocalId
                                                        DispatchQueue.main.async {
                                                            let delegate = UIApplication.shared.delegate as? AppDelegate

                                                            delegate?.showNotification(displayImage: GroupSenderDetails.localImagePath, title: GroupSenderDetails.memberName, subtitle: "You have received an poll Request", channelData: channelIndex)
                                                        }
                                                        //to pass to eventBus
                                                        let eventBusObj = eventObject.init(chnlObj: channelIndex, msg: message!)

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
                                        polldata.messageId = index
                                        polldata.pollTitle = pollData.value(forKey: "pollTitle") as! String
                                        polldata.pollCreatedOn = ""
                                        polldata.pollCreatedBy = pollData.value(forKey: "pollCreatedBy") as! String

                                        polldata.pollExpireOn = pollData.value(forKey: "pollEndDate") as! String
                                        polldata.pollType = pollData.value(forKey: "pollType") as! String
                                        polldata.pollOPtions = ""
                                        polldata.selectedChoice = ""
                                        polldata.numberOfOptions = 0
                                        let pollLocalId = polldata.toJsonString()

                                        DatabaseManager.updateMessageTableForOtherColoumn(imageData: pollLocalId, localId: message!.id)

                                        let getPoll = GetPollDataRequestObject()
                                        getPoll.auth = DefaultDataProcessor().getAuthDetails()
                                        getPoll.pollId = polldata.pollId

                                        NetworkingManager.getPollData(getGroupModel: getPoll) { (result: Any, sucess: Bool) in
                                            if let results = result as? GetPollDataResponseObject, sucess {
                                                if sucess {
                                                    if results.status == "Success" {
                                                        let choices = results.data

                                                        var data = [PollTable.PollOptions]()
                                                        var downloadArray = [MediaRefernceHolderObject]()

                                                        for choice in (choices?.first!.choices)! {
                                                            let ch = choice
                                                            let option = PollTable.PollOptions()
                                                            option.choiceImage = ch.choiceImage
                                                            option.choiceText = ch.choiceText

                                                            option.choiceId = ch.choiceId

                                                            data.append(option)

                                                            if polldata.pollType != "1" {
                                                                let cloudUrl = ch.choiceImage
                                                                let type = "image"

                                                                let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: cloudUrl, refernce: ch.choiceId, jobType: downLoadType.media, mediaType: type, mediaExtension: "")
                                                                downloadArray.append(mediaDownloadObject)
                                                            }
                                                        }

                                                        let obj = data.toJsonString()

                                                        let polldat = PollTable()
                                                        polldat.pollId = polldata.pollId
                                                        polldat.messageId = index

                                                        polldat.pollTitle = choices?.first?.pollQuestion ?? ""
                                                        polldat.pollCreatedOn = choices?.first?.createdBy ?? ""

                                                        polldat.pollCreatedBy = choices?.first?.createdBy ?? ""

                                                        polldat.pollExpireOn = choices?.first?.pollEndDate ?? ""
                                                        polldat.pollType = choices?.first?.pollType ?? ""
                                                        polldat.pollOPtions = obj
                                                        polldat.selectedChoice = ""
                                                        polldat.numberOfOptions = data.count

                                                        let pollLocalId = polldat.toJsonString()

                                                        DatabaseManager.updateMessageTableForOtherColoumn(imageData: pollLocalId, localId: message!.id)

                                                        message?.other = pollLocalId
                                                        if polldat.pollType != "1" {
                                                            self.downloadImagesFromArrayForPollObject(downloadObjectArray:

                                                                downloadArray, msg: message!.id, msgObj: message!, completionHandler: { (msg) -> Void in
                                                                    if !isFromHistory {
                                                                        DispatchQueue.main.async {
                                                                            let delegate = UIApplication.shared.delegate as? AppDelegate

                                                                            delegate?.showNotification(displayImage: GroupSenderDetails.localImagePath, title: GroupSenderDetails.memberName, subtitle: "You have received an poll Request", channelData: channelIndex)
                                                                        }
                                                                    }

                                                                    //to pass to eventBus
                                                                    let eventBusObj = eventObject.init(chnlObj: channelIndex, msg: msg)

                                                                    ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)
                                                            })
                                                        } else {
                                                            DispatchQueue.main.async {
                                                                let delegate = UIApplication.shared.delegate as? AppDelegate

                                                                delegate?.showNotification(displayImage: GroupSenderDetails.localImagePath, title: GroupSenderDetails.memberName, subtitle: "You have received an poll Request", channelData: channelIndex)
                                                            }
                                                            //to pass to eventBus
                                                            let eventBusObj = eventObject.init(chnlObj: channelIndex, msg: message!)

                                                            ACEventBusManager.postToEventBusWithChannelObject(eventBusChannelObject: eventBusObj, notificationName: eventBusHandler.channelUpdated)
                                                        }
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

                        } else {
                            print("profile not exists")
                        }
                    }
                }
            }
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

    func downloadImagesFromArrayForPollObject(downloadObjectArray: [MediaRefernceHolderObject], msg: String, msgObj: MessagesTable, completionHandler: @escaping CompletionHandler) {
        let attch = NSMutableDictionary()
        for downloadObject in downloadObjectArray {
            ACImageDownloader.downloadImageForPollIncomingMessages(downloadObject: downloadObject, pollId: msg, messageObj: msgObj, completionHandler: { (success, path, polId, msgObjs) -> Void in

                let result = success

                attch.setValue(path, forKey: result.refernce)

                if attch.allKeys.count == downloadObjectArray.count {
                    let attachmentString = ACMessageSenderClass.convertDictionaryToJsonString(dict: attch)

                    DatabaseManager.updateMessageTableForLocalImage(localImagePath: attachmentString, localId: polId)

                    msgObj.other = attachmentString
                    completionHandler(msgObjs)
                }

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

    func getDataForNotification(dataDict: NSMutableDictionary) -> NotificationObject {
        let notify = NotificationObject()
        var msgObject = ACCommunicationMsgObject()
        msgObject = msgObject.mapDataValues(dataDict: dataDict)
        let userGllobalId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)
        if msgObject.senderUUID != userGllobalId {
            if DatabaseManager.getGroupIndex(groupGlobalId: msgObject.receiver!) != nil {
                if let groupDetails = DatabaseManager.getGroupIndex(groupGlobalId: msgObject.receiver!) {
                    notify.title = groupDetails.groupName
                    if let GroupSenderDetails = DatabaseManager.getGroupMemberIndex(groupId: groupDetails.id, globalUserId: msgObject.senderUUID!) {
                        notify.body = GroupSenderDetails.memberName + ": \n"

                        if msgObject.msgType == messagetype.TEXT.rawValue {
                            notify.body = notify.body + msgObject.text!
                        } else {
                            notify.body = notify.body + "Sent you an attachment"
                        }
                    }
                }
            }
        }
        return notify
    }
}

class NotificationObject: NSObject {
    var title: String = ""
    var body = ""
}
