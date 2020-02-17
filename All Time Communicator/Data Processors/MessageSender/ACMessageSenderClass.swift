//
//  ACComposeMessageClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 03/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACMessageSenderClass {
    static func sendMessageAndPublish(communicationObject: ACCommunicationMsgObject, messageContext: ACMessageContextObject, groupName: String, attachId: String = "") {
        if (communicationObject.msgType == messagetype.OTHER.rawValue && communicationObject.otherType == otherMessageType.IMAGE_POLL.rawValue) || (communicationObject.msgType == messagetype.OTHER.rawValue && communicationObject.otherType == otherMessageType.TEXT_POLL.rawValue) {
            let otherValue = communicationObject.other

            communicationObject.other = attachId
            let msgIndex = ACDatabaseMethods.saveMessageToDb(communicationObject, messageContext.localChanelId!, messageContext.localSenderId!, messageContext.channelType!, messageContext.isMine!, messageContext.messageState!.rawValue)
            communicationObject.other = otherValue
            messageContext.localMessageId = msgIndex

        } else {
            let msgIndex = ACDatabaseMethods.saveMessageToDb(communicationObject, messageContext.localChanelId!, messageContext.localSenderId!, messageContext.channelType!, messageContext.isMine!, messageContext.messageState!.rawValue)
            messageContext.localMessageId = msgIndex
        }

        sendToPubNub(communicationObject: communicationObject, messageContext: messageContext, groupName: groupName)
    }

    static func sendPollAndPublish(communicationObject: ACCommunicationMsgObject, chatlist: chatListObject, groupName: String, attachId _: String = "") {
        let otherValue = communicationObject.other

        communicationObject.other = chatlist.messageItem?.message
        communicationObject.media = chatlist.messageItem?.localMediaPaths

        let msgIndex = ACDatabaseMethods.saveMessageToDb(communicationObject, chatlist.messageContext!.localChanelId!, chatlist.messageContext!.localSenderId!, chatlist.messageContext!.channelType!, chatlist.messageContext!.isMine!, chatlist.messageContext!.messageState!.rawValue)
        communicationObject.other = otherValue
        communicationObject.media = ""
        chatlist.messageContext!.localMessageId = msgIndex

        sendToPubNub(communicationObject: communicationObject, messageContext: chatlist.messageContext!, groupName: groupName)
    }

    static func saveToDbAndPublish(communicationObject: ACCommunicationMsgObject, messageContext: ACMessageContextObject, groupName: String, oldMsg: MessagesTable) {
        let msgIndex = ACDatabaseMethods.saveMessageToDbWithOldMsg(communicationObject, oldMsg, messageContext.localChanelId!, messageContext.localSenderId!, messageContext.channelType!, messageContext.isMine!, messageContext.messageState!.rawValue)
        messageContext.localMessageId = msgIndex

        sendToPubNub(communicationObject: communicationObject, messageContext: messageContext, groupName: groupName)
    }

    static func sendToPubNub(communicationObject: ACCommunicationMsgObject, messageContext: ACMessageContextObject, groupName: String) {
        let pubnubClass = ACPubnubClass()
        var text = communicationObject.text
        if text == "" {
            text = "You have received an attachment"
        }
        let name = UserDefaults.standard.value(forKey: UserKeys.userName) as? String
        let pubNubDictionary = NSMutableDictionary()
        let apsDictionary = setAppleApns(text: text!, name: name!, communicationObject: communicationObject, glblChnlName: messageContext.globalChannelName!, groupName: groupName)

        let pnGCMDIct = setGoogleGCM(text: text!, name: name!, communicationObject: communicationObject, glblChnlName: messageContext.globalChannelName!, groupName: groupName)

        let pnapsDIct = NSMutableDictionary()
        pnapsDIct.setValue(apsDictionary, forKey: "aps")

        pubNubDictionary.setValue(pnGCMDIct, forKey: "pn_gcm")
        pubNubDictionary.setValue(pnapsDIct, forKey: "pn_apns")
        pubNubDictionary.setValue("comm", forKey: "src")
        pubNubDictionary.setValue(messageContext.globalChannelName!, forKey: "chnl")

        let convertTodictionary = communicationObject.toDictionary()
        var channel = messageContext.globalChannelName!
        if communicationObject.channelType == channelType.ONE_ON_ONE_CHAT.rawValue {
            channel = "per." + messageContext.globalChannelName!
        }
        if communicationObject.channelType == channelType.ONE_ON_ONE_CHAT.rawValue || communicationObject.channelType == channelType.GROUP_CHAT.rawValue {

            if UserDefaults.standard.bool(forKey: UserKeys.newIntro) {
                let data = NSMutableDictionary()
                let name = UserDefaults.standard.string(forKey: UserKeys.userName)
                let pic = ""

                data.setValue(name, forKey: "name")
                data.setValue(pic, forKey: "picture")

                convertTodictionary.setValue(data, forKey: "newIntro")
                UserDefaults.standard.set(false, forKey: UserKeys.newIntro)
            }
        }
        pubNubDictionary.setValue(convertTodictionary, forKey: "comm")
//            let ccc = pubNubDictionary as! Dictionary<String, Any>
//            print(ccc.prettyPrint)
        //        let jsonstring = self.convertDictionaryToJsonString(dict: pubNubDictionary)
        pubnubClass.sendMessageToPubNub(msgObject: pubNubDictionary, channel: channel, completionHandler: { (success) -> Void in

            print(success)

            DatabaseManager.updateMessageTableForDirectChatReadReceipt(messageState: success.msgState, globalMessageId: success.messageId)

            let time = Double(messageContext.msgTimeStamp)! / 10_000_000
            let finalDate = time.getDateFromUTC()

            //to communicate with eventbus
            let eventBusObj = ACReadReceiptEventBusObject(firstMsgId: messageContext.globalMsgId!, lastMsgId: messageContext.globalMsgId!, channelName: success.channel, messageState: messageState.SENDER_SENT, isMine: true, date: finalDate)

            ACEventBusManager.postToEventBusWithReadReceiptObject(eventBusObject: eventBusObj, notificationName: "readReceiptsMessage")

        })
    }

    static func uploadToCloudinaryAndSendToPubnub(communicationObject: ACCommunicationMsgObject, messageContext: ACMessageContextObject, object: [MediaUploadObject], groupName: String) {
        var config = AWSManager.instance.getConfig(
            gType: messageContext.groupType ?? "",
            isChat: true,
            isProfile: false,
            fileName: object[0].localImagePath!,
            type: s3BucketName.imageType
        )

        if object.count == 1 {
            if object[0].msgType == messagetype.IMAGE {
                if let data = object[0].imageData {
                    config.fileName = object[0].localImagePath!
                    config.type = s3BucketName.imageType
                    config.updateValues()
                    // s3BucketName.mediaBucketImage
                    AWSManager.instance.uploadDataS3(config: config, data: data, completionHandler: { (url, error) in
                        if error == nil {
                            // s3BucketName.chatBucketName
                            communicationObject.media = url

                            DatabaseManager.updateMessageTableForattachMentUrl(attachmentUrl: url, globalMessageId: communicationObject.globalMsgId!)

                            self.sendToPubNub(communicationObject: communicationObject, messageContext: messageContext, groupName: groupName)
                        }

                    })
                }

            } else {
                if object[0].msgType == messagetype.VIDEO {
                    communicationObject.other = ""
                    if let data = object[0].imageData {
                        let name = object[0].imageName!
                        let image = UnsentProcessObjectClass.load(attName: name)
                        let imgData = image?.pngData()

                        config.fileName = object[0].imageName!
                        config.type = s3BucketName.imageType
                        config.updateValues()
                        // s3BucketName.mediaBucketImage
                        AWSManager.instance.uploadDataS3(config: config, data: imgData!, completionHandler: { (url, error) in
                            if error == nil {
                                // chatBucketName
                                let imgfileName = config.url

                                config.fileName = object[0].localImagePath!
                                config.type = s3BucketName.videoType
                                config.updateValues()
                                
                                // s3BucketName.mediaBucketVideo
                                AWSManager.instance.uploadDataS3(config: config, data: data, completionHandler: {  (url, error) in
                                    if error == nil {
                                        // chatBucketName
                                        let mediaDisplayObject = NSMutableDictionary()
                                        mediaDisplayObject.setValue(url, forKey: "vidurl")
                                        mediaDisplayObject.setValue(imgfileName, forKey: "imgurl")

                                        let str = self.convertDictionaryToJsonString(dict: mediaDisplayObject)
                                        communicationObject.media = str
                                        DatabaseManager.updateMessageTableForattachMentUrl(attachmentUrl: url, globalMessageId: communicationObject.globalMsgId!)

                                        self.sendToPubNub(communicationObject: communicationObject, messageContext: messageContext, groupName: groupName)
                                    }
                                })
                            }
                        })
                    }

                } else if object[0].msgType == messagetype.AUDIO {
                    if let data = object[0].imageData {
                        config.fileName = (object[0].localImagePath! + ".m4a")
                        config.type = s3BucketName.audioType
                        config.updateValues()
                        AWSManager.instance.uploadDataS3(config: config, data: data, completionHandler: { (url, error) in
                            if error == nil {
                                // s3BucketName.chatBucketName
                                communicationObject.media = url
                                DatabaseManager.updateMessageTableForattachMentUrl(attachmentUrl: config.url, globalMessageId: communicationObject.globalMsgId!)

                                self.sendToPubNub(communicationObject: communicationObject, messageContext: messageContext, groupName: groupName)
                            }

                        })
                    }
                }
            }

        } else {
            // for image array
            let attachmentArray = NSMutableArray()
            for mediaObject in object {
                config.type = s3BucketName.imageType
                if mediaObject.msgType == messagetype.VIDEO {
                    config.type = s3BucketName.videoType
                    communicationObject.other = ""
                }
                config.fileName = mediaObject.localImagePath!
                config.updateValues()
                AWSManager.instance.uploadDataS3(config: config, data: mediaObject.imageData!, completionHandler: {  (url, error) in
                    if error == nil {
                        // s3BucketName.chatBucketName
                        let mediaDisplayObject = NSMutableDictionary()
                        mediaDisplayObject.setValue(url, forKey: "cloudUrl")
                        mediaDisplayObject.setValue(mediaObject.msgType.rawValue, forKey: "messagetype")
                        attachmentArray.add(mediaDisplayObject)

                        if attachmentArray.count == object.count {
                            let str = self.convertArrayToJsonString(dict: attachmentArray)
                            communicationObject.other = str

                            DatabaseManager.updateMessageTableForattachMentUrl(attachmentUrl: str, globalMessageId: communicationObject.globalMsgId!)
                            self.sendToPubNub(communicationObject: communicationObject, messageContext: messageContext, groupName: groupName)
                        }
                    }
                })
            }
        }
    }

    static func sendMessageAndPublishForMedia(communicationObject: ACCommunicationMsgObject, messageContext: ACMessageContextObject, object: [MediaUploadObject], groupName: String) {
        let msgIndex = ACDatabaseMethods.saveMessageToDb(communicationObject, messageContext.localChanelId!, messageContext.localSenderId!, messageContext.channelType!, messageContext.isMine!, messageContext.messageState!.rawValue)
        messageContext.localMessageId = msgIndex
        uploadToCloudinaryAndSendToPubnub(communicationObject: communicationObject, messageContext: messageContext, object: object, groupName: groupName)
    }

    static func convertArrayToJsonString(dict: NSArray) -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())
        if let jsonString = NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue) {
            return "\(jsonString)"
        }
        return ""
    }

    static func convertDictionaryToJsonString(dict: NSMutableDictionary) -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())
        if let jsonString = NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue) {
            return "\(jsonString)"
        }
        return ""
    }

    static func convertJsonStringToDictionary(text: String) -> NSArray {
        if let data = text.replacingOccurrences(of: "\n", with: "").data(using: String.Encoding.utf8) {
            do {
                return try (JSONSerialization.jsonObject(with: data, options: []) as? NSArray)!
            } catch {
                print(error.localizedDescription)
            }
        }
        return []
    }

    static func setAppleApns(text: String, name: String, communicationObject: ACCommunicationMsgObject, glblChnlName: String, groupName: String) -> NSMutableDictionary {
        let pubnubDict = NSMutableDictionary()
        let alertDictionary = NSMutableDictionary()
        let apsDictionary = NSMutableDictionary()

        if communicationObject.channelType! == channelType.ONE_ON_ONE_CHAT.rawValue || communicationObject.channelType! == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
            alertDictionary.setValue(text, forKey: "body")
            alertDictionary.setValue(name, forKey: "title")
            apsDictionary.setValue("default", forKey: "sound")

            apsDictionary.setValue(alertDictionary, forKey: "alert")

        } else {
            if communicationObject.channelType! == channelType.TOPIC_GROUP.rawValue || communicationObject.channelType! == channelType.PUBLIC_GROUP.rawValue || communicationObject.channelType! == channelType.PRIVATE_GROUP.rawValue {
                if communicationObject.globalTopicId == communicationObject.globalMsgId {
                    let listDisp = name + ": \n" + text
                    alertDictionary.setValue(listDisp, forKey: "body")
                    alertDictionary.setValue(groupName, forKey: "title")
                    apsDictionary.setValue("default", forKey: "sound")
                    apsDictionary.setValue(alertDictionary, forKey: "alert")
                }
            }
        }

        pubnubDict.setValue("comm", forKey: "src")
        pubnubDict.setValue(glblChnlName, forKey: "chnl")
        let convertTodictionary = communicationObject.toDictionary()
        if communicationObject.channelType == channelType.ONE_ON_ONE_CHAT.rawValue || communicationObject.channelType == channelType.GROUP_CHAT.rawValue {
            if UserDefaults.standard.bool(forKey: UserKeys.newIntro) {
                let data = NSMutableDictionary()
                let name = UserDefaults.standard.string(forKey: UserKeys.userName)
                let pic = ""

                data.setValue(name, forKey: "name")
                data.setValue(pic, forKey: "picture")

                convertTodictionary.setValue(data, forKey: "newIntro")
            }
        }
        pubnubDict.setValue(convertTodictionary, forKey: "comm")

        apsDictionary.setValue(pubnubDict, forKey: "data")
        apsDictionary.setValue("CHAT", forKey: "category")
        apsDictionary.setValue(true, forKey: "content-available")

        if communicationObject.msgType == messagetype.IMAGE.rawValue {
            let imageurl = communicationObject.media
            apsDictionary.setValue(1, forKey: "mutable-content")

            apsDictionary.setValue(imageurl, forKey: "attachment-url")
        }

        return apsDictionary
    }

    static func setGoogleGCM(text _: String, name: String, communicationObject: ACCommunicationMsgObject, glblChnlName: String, groupName _: String) -> NSMutableDictionary {
        let dataDict = NSMutableDictionary()
        dataDict.setValue(name, forKey: "title")
        dataDict.setValue(name, forKey: "body")
        dataDict.setValue("appicon", forKey: "icon")

        let pnapsDIct = NSMutableDictionary()
//        pnapsDIct.setValue(dataDict, forKey: "notification")

        let pubnubDict = NSMutableDictionary()

        pubnubDict.setValue("comm", forKey: "src")
        pubnubDict.setValue(glblChnlName, forKey: "chnl")
        let convertTodictionary = communicationObject.toDictionary()
        if communicationObject.channelType == channelType.ONE_ON_ONE_CHAT.rawValue || communicationObject.channelType == channelType.GROUP_CHAT.rawValue {
            if UserDefaults.standard.bool(forKey: UserKeys.newIntro) {
                let data = NSMutableDictionary()
                let name = UserDefaults.standard.string(forKey: UserKeys.userName)
                let pic = ""

                data.setValue(name, forKey: "name")
                data.setValue(pic, forKey: "picture")

                convertTodictionary.setValue(data, forKey: "newIntro")
            }
        }
        pubnubDict.setValue(convertTodictionary, forKey: "comm")
        pnapsDIct.setValue(pubnubDict, forKey: "data")

        return pnapsDIct
    }

    static func sendTextMessage(messageContext: ACMessageContextObject, message: String, groupName: String, grpRefId: String, messageTitle: String) {
        let communicationObject = mapDataValues(dataDict: messageContext, message: message, messageType: messagetype.TEXT, otherType: "", messageTextString: messageTitle, refGroupId: grpRefId)
        sendMessageAndPublish(communicationObject: communicationObject, messageContext: messageContext, groupName: groupName)
    }

    static func sendMediaMessage(messageContext: ACMessageContextObject, url: String, messageType: messagetype, imageObject: MediaUploadObject, messageTextString: String, other: String, groupName: String, refGroupId: String) {
        let communicationObject = mapDataValues(dataDict: messageContext, message: url, messageType: messageType, otherType: other, messageTextString: messageTextString, refGroupId: refGroupId)

        sendMessageAndPublishForMedia(communicationObject: communicationObject, messageContext: messageContext, object: [imageObject], groupName: groupName)
    }

    static func sendImageArrayMessage(messageContext: ACMessageContextObject, url: Any, messageType: messagetype, imageObject: [MediaUploadObject], otherType: otherMessageType, messageTextString: String, groupName: String, refGroupId: String, attachId: String = "") {
        let communicationObject = mapDataValues(dataDict: messageContext, message: url, messageType: messageType, otherType: otherType.rawValue, messageTextString: messageTextString, refGroupId: refGroupId)

        if otherType == otherMessageType.TEXT_POLL || otherType == otherMessageType.IMAGE_POLL {
            sendMessageAndPublish(communicationObject: communicationObject, messageContext: messageContext, groupName: groupName, attachId: attachId)

        } else {
            sendMessageAndPublishForMedia(communicationObject: communicationObject, messageContext: messageContext, object: imageObject, groupName: groupName)
        }
    }

    static func sendPollData(chatlist: chatListObject, url: Any, messageType: messagetype, imageObject _: [MediaUploadObject], otherType: otherMessageType, messageTextString: String, groupName: String, refGroupId: String, attachId: String = "") {
        let communicationObject = mapDataValues(dataDict: chatlist.messageContext!, message: url, messageType: messageType, otherType: otherType.rawValue, messageTextString: messageTextString, refGroupId: refGroupId)

        sendPollAndPublish(communicationObject: communicationObject, chatlist: chatlist, groupName: groupName, attachId: attachId)
    }

    static func mapDataValues(dataDict: ACMessageContextObject, message: Any, messageType: messagetype, otherType: String, messageTextString: String, refGroupId: String) -> ACCommunicationMsgObject {
        let directMsgObj = ACCommunicationMsgObject()

        directMsgObj.action = dataDict.action.map { $0.rawValue }
        directMsgObj.channelType = dataDict.channelType.map { $0.rawValue }
        directMsgObj.contSource = dataDict.contentSource.map { $0.rawValue }
        directMsgObj.globalMsgId = dataDict.globalMsgId
        directMsgObj.globalTopicId = dataDict.topicId
        directMsgObj.msgType = messageType.rawValue
        if messageType == messagetype.TEXT {
            directMsgObj.text = message as? String
            directMsgObj.other = messageTextString

        } else if messageType == messagetype.OTHER {
            directMsgObj.other = message
            directMsgObj.otherType = otherType
            directMsgObj.text = messageTextString

        } else {
            directMsgObj.media = message as? String
            directMsgObj.text = messageTextString
            directMsgObj.other = otherType
        }

        directMsgObj.receiver = dataDict.receiverGlobalId
        directMsgObj.senderUUID = dataDict.senderGlobalId
        directMsgObj.senderPhone = dataDict.senderPhoneNo
        directMsgObj.sent_utc = dataDict.msgTimeStamp
        directMsgObj.replyToId = dataDict.replyToId
        directMsgObj.refGroupId = refGroupId

        return directMsgObj
    }

    static func getTimestampForPubnubWithUserId() -> String {
        let timestamp = NSDate().timeIntervalSince1970 * 10_000_000
        let finalTS = String(format: "%.0f", timestamp)
        let userid = UserDefaults.standard.string(forKey: UserKeys.userGlobalId) ?? ""
        let finalName = userid + finalTS
        return finalName
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    var prettyPrint: String {
        return String(describing: self as AnyObject)
    }
}
