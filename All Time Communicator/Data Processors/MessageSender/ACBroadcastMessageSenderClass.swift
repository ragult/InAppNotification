//
//  ACBroadcastMessageSenderClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 25/05/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACBroadcastMessageSenderClass {
    static func sendMessageAndPublish(context: UIViewController, communicationObject: ACCommunicationMsgObject, messageContext: ACMessageContextObject, groupName: String, attachId: String = "") {
        let commClass = BrocastCommClass().mapDataValues(dataDict: communicationObject)

        sendToBroadcast(context: context, communicationObject: communicationObject, messageContext: messageContext, groupName: groupName, attachId: attachId, attachData: "", actualCommunicationObj: commClass)
    }

    static func sendToBroadcast(context: UIViewController, communicationObject: ACCommunicationMsgObject, messageContext: ACMessageContextObject, groupName _: String, attachId: String = "", attachData: String, actualCommunicationObj: BrocastCommClass, chatList: chatListObject = chatListObject()) {
        var text = communicationObject.text
        if text == "" {
            text = "You have received an attachment"
        }

        let broadcastobject = SendBroadcastRequestModel()
        broadcastobject.auth = DefaultDataProcessor().getAuthDetails()
        broadcastobject.groupId = communicationObject.receiver
        broadcastobject.mesgtype = communicationObject.msgType
        broadcastobject.otherType = communicationObject.otherType
        // set data dict
        let pubnubDict = NSMutableDictionary()
        pubnubDict.setValue("comm", forKey: "src")
        pubnubDict.setValue(messageContext.globalChannelName!, forKey: "chnl")

        let convertTodictionary = actualCommunicationObj.toDictionary() as? [String: Any]
        pubnubDict.setValue(convertTodictionary, forKey: "comm")

        broadcastobject.data = pubnubDict
        //            broadcastobject.mode = "1"
        if communicationObject.msgType == messagetype.IMAGE.rawValue {
            let imageurl = communicationObject.media
            broadcastobject.attachment = imageurl

        } else {
            broadcastobject.attachment = ""
        }

        NetworkingManager.cretaeBroadcast(getGroupModel: broadcastobject, acCommObj: communicationObject, acMsgCon: messageContext, attId: attachId) { (result: Any, sucess: Bool, _: SendBroadcastRequestModel, commObj: ACCommunicationMsgObject, msgCont: ACMessageContextObject) in
            if let results = result as? UpdateBroadcastGroupResponse, sucess {
                if sucess {
                    if results.status == "Success" {
                        print("message sent")
                        if (communicationObject.msgType == messagetype.OTHER.rawValue && communicationObject.otherType == otherMessageType.TEXT_POLL.rawValue) || (communicationObject.msgType == messagetype.OTHER.rawValue && communicationObject.otherType == otherMessageType.IMAGE_POLL.rawValue) {
                            communicationObject.other = chatList.messageItem?.message
                            communicationObject.media = chatList.messageItem?.localMediaPaths
                        }

                        if communicationObject.msgType == messagetype.VIDEO.rawValue {
                            communicationObject.other = chatList.messageItem?.thumbnail
                            communicationObject.media = chatList.messageItem?.message as? String
                        }
                        communicationObject.globalMsgId = results.data?.first?.globalMessageId ?? ""
                        communicationObject.globalTopicId = commObj.globalMsgId

                        let msgIndex = ACDatabaseMethods.saveMessageToDb(communicationObject, msgCont.localChanelId!, msgCont.localSenderId!, msgCont.channelType!, msgCont.isMine!, messageState.SENDER_SENT.rawValue)
                        msgCont.localMessageId = msgIndex
                        DatabaseManager.updateMessageTableForattachMentUrl(attachmentUrl: attachData, globalMessageId: actualCommunicationObj.globalMsgId!)

                        ACEventBusManager.postNotificationWithoutObject(notificationName: eventBusHandler.messageSent)
                        let remCount = results.data?.first?.remCount ?? "0|0"
                        let remArray = remCount.split(separator: "|")
                        context.alert(message: "Can post \(remArray[1]) more messages this month")
//                                context.alert(message: "Can post \(results.errorMsg[1]) more messages this month" )
                            
                    } else if results.status == "Exception" {
                         ACEventBusManager.postNotificationWithoutObject(notificationName: eventBusHandler.apiFailure)
                        if results.errorMsg.count > 0 {
                            let errorMsg = results.errorMsg[0]
                            
                            if stringFromAny(errorMsg) == "MAX-MSG" {
//                                context.showToast(message: "Can post \(results.errorMsg[1]) more messages this month", font: UIFont.systemFont(ofSize: 12))
                                                                context.alert(message: "Reached maximum quota for this month" )
                            }
                        }
                        print("error")
                    }
                } else {
                    print("json Error")
                }
            }
        }
    }

    static func uploadToCloudinaryAndSendToPubnub(context: UIViewController, communicationObject: ACCommunicationMsgObject, messageContext: ACMessageContextObject, object: [MediaUploadObject], groupName: String, actualCommunicationObj: BrocastCommClass, chatlistObj: chatListObject) {
        let imageType: String = s3BucketName.imageType
        let videoType: String = s3BucketName.videoType
        let audioType: String = s3BucketName.audioType

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
                    AWSManager.instance.uploadDataS3(config: config, data: data, completionHandler: { (url, error) in
                        if error == nil {
                            // s3BucketName.chatBucketName
                            actualCommunicationObj.media = url

                            self.sendToBroadcast(context: context, communicationObject: communicationObject, messageContext: messageContext, groupName: groupName, attachId: "", attachData: url, actualCommunicationObj: actualCommunicationObj)
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

                        AWSManager.instance.uploadDataS3(config: config, data: imgData!, completionHandler: { (url, error) in
                            if error == nil {
                                // chatBucketName
                                let imgfileName = url

                                config.fileName = object[0].localImagePath!
                                config.type = s3BucketName.videoType

                                AWSManager.instance.uploadDataS3(config: config, data: data, completionHandler: {  (url, error) in
                                    if error == nil {
                                        // s3BucketName.chatBucketName

                                        let mediaDisplayObject = NSMutableDictionary()
                                        mediaDisplayObject.setValue(url, forKey: "vidurl")
                                        mediaDisplayObject.setValue(imgfileName, forKey: "imgurl")

                                        let str = self.convertDictionaryToJsonString(dict: mediaDisplayObject)
                                        actualCommunicationObj.media = str

                                        self.sendToBroadcast(context: context, communicationObject: communicationObject, messageContext: messageContext, groupName: groupName, attachData: url, actualCommunicationObj: actualCommunicationObj, chatList: chatlistObj)
                                    }

                                })
                            }
                        })
                    }

                } else if object[0].msgType == messagetype.AUDIO {
                    if let data = object[0].imageData {
                        config.fileName = (object[0].localImagePath! + ".m4a")
                        config.type = s3BucketName.audioType

                        AWSManager.instance.uploadDataS3(config: config, data: data, completionHandler: {  (url, error) in
                            if error == nil {
                                // s3BucketName.chatBucketName

                                actualCommunicationObj.media = url

                                self.sendToBroadcast(context: context, communicationObject: communicationObject, messageContext: messageContext, groupName: groupName, attachData: url, actualCommunicationObj: actualCommunicationObj)
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

                AWSManager.instance.uploadDataS3(config: config, data: mediaObject.imageData!, completionHandler: {  (url, error) in
                    if error == nil {
                        // s3BucketName.chatBucketName

                        let mediaDisplayObject = NSMutableDictionary()
                        mediaDisplayObject.setValue(url, forKey: "cloudUrl")
                        mediaDisplayObject.setValue(mediaObject.msgType.rawValue, forKey: "messagetype")
                        attachmentArray.add(mediaDisplayObject)

                        if attachmentArray.count == object.count {
                            let str = self.convertArrayToJsonString(dict: attachmentArray)
                            actualCommunicationObj.other = str

                            self.sendToBroadcast(context: context, communicationObject: communicationObject, messageContext: messageContext, groupName: groupName, attachData: str, actualCommunicationObj: actualCommunicationObj)
                        }
                    }
                })
            }
        }
    }

    static func sendMessageAndPublishForMedia(context: UIViewController, communicationObject: ACCommunicationMsgObject, messageContext: ACMessageContextObject, object: [MediaUploadObject], groupName: String, chatList: chatListObject) {
        let commClass = BrocastCommClass().mapDataValues(dataDict: communicationObject)
        uploadToCloudinaryAndSendToPubnub(context: context, communicationObject: communicationObject, messageContext: messageContext, object: object, groupName: groupName, actualCommunicationObj: commClass, chatlistObj: chatList)
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

    static func sendTextMessage(context: UIViewController, messageContext: ACMessageContextObject, message: String, groupName: String, grpRefId: String, messageTitle: String) {
        let communicationObject = mapDataValues(dataDict: messageContext, message: message, messageType: messagetype.TEXT, otherType: "", messageTextString: messageTitle, refGroupId: grpRefId)
        sendMessageAndPublish(context: context, communicationObject: communicationObject, messageContext: messageContext, groupName: groupName)
    }

    static func sendMediaMessage(context: UIViewController, messageContext: ACMessageContextObject, url: String, messageType: messagetype, imageObject: MediaUploadObject, messageTextString: String, other: String, groupName: String, refGroupId: String, chatlist: chatListObject = chatListObject()) {
        let communicationObject = mapDataValues(dataDict: messageContext, message: url, messageType: messageType, otherType: other, messageTextString: messageTextString, refGroupId: refGroupId)

        sendMessageAndPublishForMedia(context: context, communicationObject: communicationObject, messageContext: messageContext, object: [imageObject], groupName: groupName, chatList: chatlist)
    }

    static func sendImageArrayMessage(context: UIViewController, messageContext: ACMessageContextObject, url: Any, messageType: messagetype, imageObject: [MediaUploadObject], otherType: otherMessageType, messageTextString: String, groupName: String, refGroupId: String, attachId: String = "", chatlist: chatListObject = chatListObject()) {
        let communicationObject = mapDataValues(dataDict: messageContext, message: url, messageType: messageType, otherType: otherType.rawValue, messageTextString: messageTextString, refGroupId: refGroupId)

        if otherType == otherMessageType.TEXT_POLL || otherType == otherMessageType.IMAGE_POLL {
            sendMessageAndPublish(context: context, communicationObject: communicationObject, messageContext: messageContext, groupName: groupName, attachId: attachId)

        } else {
            sendMessageAndPublishForMedia(context: context, communicationObject: communicationObject, messageContext: messageContext, object: imageObject, groupName: groupName, chatList: chatlist)
        }
    }

    static func sendPollData(context: UIViewController, chatlist: chatListObject, url: Any, messageType: messagetype, imageObject _: [MediaUploadObject], otherType: otherMessageType, messageTextString: String, groupName: String, refGroupId: String, attachId: String = "") {
        let communicationObject = mapDataValues(dataDict: chatlist.messageContext!, message: url, messageType: messageType, otherType: otherType.rawValue, messageTextString: messageTextString, refGroupId: refGroupId)

        sendPollAndPublish(context: context, communicationObject: communicationObject, chatlist: chatlist, groupName: groupName, attachId: attachId)
    }

    static func sendPollAndPublish(context: UIViewController, communicationObject: ACCommunicationMsgObject, chatlist: chatListObject, groupName: String, attachId: String = "") {
        let commClass = BrocastCommClass().mapDataValues(dataDict: communicationObject)

        sendToBroadcast(context: context, communicationObject: communicationObject, messageContext: chatlist.messageContext!, groupName: groupName, attachId: attachId, attachData: "", actualCommunicationObj: commClass, chatList: chatlist)
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
