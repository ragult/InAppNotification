//
//  UnsentProcessObjectClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 04/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import AVKit
import UIKit

class UnsentProcessObjectClass {
    static func ProcessAllUnsentMessages() {
        let unsentMsgs = DatabaseManager.getUnsentMessages()

        if unsentMsgs != nil {
            for message in unsentMsgs! {
                if let channelDetails = DatabaseManager.getChannelIndexbyMessage(contactId: message.chanelId, channelType: message.channelType) {
                    var userLocalId = ""
                    var globalChatId = ""
                    var groupName = ""
                    var groupType = ""
                    var refGroupId = ""

                    if channelDetails.channelType == channelType.ONE_ON_ONE_CHAT.rawValue {
                        userLocalId = (UserDefaults.standard.value(forKey: UserKeys.userContactIndex) as? String)!
                        globalChatId = channelDetails.globalChannelName

                    } else if channelDetails.channelType == channelType.GROUP_MEMBER_ONE_ON_ONE.rawValue {
                        let contactDetails = DatabaseManager.getGroupMemberIndexForMemberId(groupId: channelDetails.contactId)

                        let groupDetail = DatabaseManager.getGroupDetail(groupGlobalId: (contactDetails?.groupId)!)

                        userLocalId = (contactDetails?.groupMemberId)!
                        globalChatId = channelDetails.globalChannelName
                        refGroupId = (groupDetail?.groupGlobalId)!

                    } else {
                        let userGlobalId = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String

                        let groupTable = DatabaseManager.getGroupDetail(groupGlobalId: channelDetails.contactId)
                        let GroupMemberIndex = DatabaseManager.getGroupMemberIndex(groupId: channelDetails.contactId, globalUserId: userGlobalId!)

                        groupType = groupTable?.groupType ?? ""
                        groupName = groupTable?.groupName ?? ""
                        userLocalId = (GroupMemberIndex?.groupMemberId)!
                        globalChatId = (groupTable?.groupGlobalId)!
                    }

                    switch message.messageType {
                    case messagetype.TEXT.rawValue:

                        let sendMessage = ChatMessageProcessor.createMessageContextObject(groupType: groupType, text: message.text, channel: channelDetails.globalChannelName, chanlType: channelType(rawValue: channelDetails.channelType)!, localSenderId: userLocalId, localChannelId: channelDetails.id, globalChatId: globalChatId, replyId: message.replyToId)
                        sendMessage.messageContext?.localMessageId = message.id
                        sendMessage.messageContext?.topicId = message.topicId
                        sendMessage.messageContext?.globalMsgId = message.globalMsgId

                        let communicationObject = ACMessageSenderClass.mapDataValues(dataDict: sendMessage.messageContext!, message: message.text, messageType: messagetype.TEXT, otherType: "", messageTextString: message.text, refGroupId: refGroupId)

                        ACMessageSenderClass.sendToPubNub(communicationObject: communicationObject, messageContext: sendMessage.messageContext!, groupName: groupName)

                    case messagetype.IMAGE.rawValue:

                        let sendMessage = ChatMessageProcessor.createImageContextObject(text: message.text, channel: channelDetails.globalChannelName, chanlType: channelType(rawValue: channelDetails.channelType)!, localSenderId: userLocalId, localChannelId: channelDetails.channelType, globalChatId: globalChatId, mediaType: messagetype(rawValue: message.messageType)!, mediaObject: message.media, thumbnail: message.other)
                        sendMessage.messageContext?.localMessageId = message.id
                        sendMessage.messageContext?.topicId = message.topicId
                        sendMessage.messageContext?.globalMsgId = message.globalMsgId

                        if message.attachmentsExtra == "" {
                            let image = load(attName: message.media)
                            let mediaObj = MediaUploadObject(path: message.media, name: "", imgData: (image?.pngData())!, mediaTyp: messagetype.IMAGE)

                            let communicationObject = ACMessageSenderClass.mapDataValues(dataDict: sendMessage.messageContext!, message: message.attachmentsExtra, messageType: messagetype.IMAGE, otherType: "", messageTextString: message.text, refGroupId: refGroupId)

                            ACMessageSenderClass.uploadToCloudinaryAndSendToPubnub(communicationObject: communicationObject, messageContext: sendMessage.messageContext!, object: [mediaObj], groupName: groupName)

                        } else {
                            let communicationObject = ACMessageSenderClass.mapDataValues(dataDict: sendMessage.messageContext!, message: message.attachmentsExtra, messageType: messagetype.IMAGE, otherType: "", messageTextString: message.text, refGroupId: refGroupId)

                            ACMessageSenderClass.sendToPubNub(communicationObject: communicationObject, messageContext: sendMessage.messageContext!, groupName: groupName)
                        }

                    case messagetype.VIDEO.rawValue:

                        let sendMessage = ChatMessageProcessor.createImageContextObject(text: message.text, channel: channelDetails.globalChannelName, chanlType: channelType(rawValue: channelDetails.channelType)!, localSenderId: userLocalId, localChannelId: channelDetails.id, globalChatId: globalChatId, mediaType: messagetype(rawValue: message.messageType)!, mediaObject: message.media, thumbnail: message.other)
                        sendMessage.messageContext?.localMessageId = message.id
                        sendMessage.messageContext?.topicId = message.topicId
                        sendMessage.messageContext?.globalMsgId = message.globalMsgId

                        if message.attachmentsExtra == "" {
                            let attName = message.media
                            let type = fileName.imagemediaFileName
                            let fileURL = documentsUrl.appendingPathComponent(type + "/" + attName)

                            guard let video = try? Data(contentsOf: fileURL) else {
                                return
                            }
                            let mediaObj = MediaUploadObject(path: message.media, name: message.other, imgData: video as Data, mediaTyp: messagetype.VIDEO)

                            let communicationObject = ACMessageSenderClass.mapDataValues(dataDict: sendMessage.messageContext!, message: message.attachmentsExtra, messageType: messagetype.VIDEO, otherType: "", messageTextString: message.text, refGroupId: refGroupId)

                            ACMessageSenderClass.uploadToCloudinaryAndSendToPubnub(communicationObject: communicationObject, messageContext: sendMessage.messageContext!, object: [mediaObj], groupName: groupName)

                        } else {
                            let communicationObject = ACMessageSenderClass.mapDataValues(dataDict: sendMessage.messageContext!, message: message.attachmentsExtra, messageType: messagetype.VIDEO, otherType: "", messageTextString: message.text, refGroupId: refGroupId)

                            ACMessageSenderClass.sendToPubNub(communicationObject: communicationObject, messageContext: sendMessage.messageContext!, groupName: groupName)
                        }

                    case messagetype.AUDIO.rawValue:

                        let sendMessage = ChatMessageProcessor.createImageContextObject(text: message.text, channel: channelDetails.globalChannelName, chanlType: channelType(rawValue: channelDetails.channelType)!, localSenderId: userLocalId, localChannelId: channelDetails.id, globalChatId: globalChatId, mediaType: messagetype(rawValue: message.messageType)!, mediaObject: message.media, thumbnail: message.other)
                        sendMessage.messageContext?.localMessageId = message.id
                        sendMessage.messageContext?.topicId = message.topicId
                        sendMessage.messageContext?.globalMsgId = message.globalMsgId

                        if message.attachmentsExtra == "" {
                            let recorder = KAudioRecorder.shared
                            let audio = recorder.getData(name: message.media)
                            let mediaObj = MediaUploadObject(path: message.media, name: "", imgData: audio, mediaTyp: messagetype.AUDIO)

                            let communicationObject = ACMessageSenderClass.mapDataValues(dataDict: sendMessage.messageContext!, message: message.attachmentsExtra, messageType: messagetype.AUDIO, otherType: "", messageTextString: message.text, refGroupId: refGroupId)

                            ACMessageSenderClass.uploadToCloudinaryAndSendToPubnub(communicationObject: communicationObject, messageContext: sendMessage.messageContext!, object: [mediaObj], groupName: groupName)

                        } else {
                            let communicationObject = ACMessageSenderClass.mapDataValues(dataDict: sendMessage.messageContext!, message: message.attachmentsExtra, messageType: messagetype.AUDIO, otherType: "", messageTextString: message.text, refGroupId: refGroupId)

                            ACMessageSenderClass.sendToPubNub(communicationObject: communicationObject, messageContext: sendMessage.messageContext!, groupName: groupName)
                        }
                    case messagetype.OTHER.rawValue:

                        switch message.otherType {
                        case otherMessageType.MEDIA_ARRAY.rawValue:

                            let sendMessage = ChatMessageProcessor.createOtherContextObject(text: message.text, channel: channelDetails.globalChannelName, chanlType: channelType(rawValue: channelDetails.channelType)!, localSenderId: userLocalId, localChannelId: channelDetails.id, globalChatId: globalChatId, mediaType: messagetype.OTHER, otherType: otherMessageType.MEDIA_ARRAY, mediaObject: message.other)

                            sendMessage.messageContext?.localMessageId = message.id
                            sendMessage.messageContext?.topicId = message.topicId
                            sendMessage.messageContext?.globalMsgId = message.globalMsgId

                            if message.attachmentsExtra == "" {
                                var mediaUploadObject = [MediaUploadObject]()
                                let text = message.other
                                if text.count > 2, text.contains("attachmentArray") {
                                    let json = convertJsonStringToDictionary(text: text)
                                    let images = json!["attachmentArray"] as! NSArray

                                    for attach in images {
                                        let localData = attach as! NSDictionary
                                        if localData.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                                            let attName = localData.value(forKey: "imageName") as! String
                                            let type = fileName.imagemediaFileName
                                            let fileURL = documentsUrl.appendingPathComponent(type + "/" + attName)

                                            guard let video = try? Data(contentsOf: fileURL) else {
                                                return
                                            }
                                            let mediaObj = MediaUploadObject(path: message.media, name: "", imgData: video as Data, mediaTyp: messagetype.VIDEO)
                                            mediaUploadObject.append(mediaObj)
                                        } else {
                                            let attName = localData.value(forKey: "imageName")
                                            let image = load(attName: attName as! String)
                                            let mediaObj = MediaUploadObject(path: message.media, name: "", imgData: (image?.pngData())!, mediaTyp: messagetype.IMAGE)
                                            mediaUploadObject.append(mediaObj)
                                        }
                                    }

                                    let communicationObject = ACMessageSenderClass.mapDataValues(dataDict: sendMessage.messageContext!, message: message.attachmentsExtra, messageType: messagetype.OTHER, otherType: message.otherType, messageTextString: message.text, refGroupId: refGroupId)

                                    ACMessageSenderClass.uploadToCloudinaryAndSendToPubnub(communicationObject: communicationObject, messageContext: sendMessage.messageContext!, object: mediaUploadObject, groupName: groupName)
                                }

                            } else {
                                let communicationObject = ACMessageSenderClass.mapDataValues(dataDict: sendMessage.messageContext!, message: message.attachmentsExtra, messageType: messagetype.OTHER, otherType: message.otherType, messageTextString: message.text, refGroupId: refGroupId)
                                ACMessageSenderClass.sendToPubNub(communicationObject: communicationObject, messageContext: sendMessage.messageContext!, groupName: groupName)
                            }

                        default:
                            print("do Nothing")
                        }

                    default:
                        print("do nothing")
                    }
                }
            }
        }
    }

    static var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    static func load(attName: String) -> UIImage? {
        let type = fileName.imagemediaFileName
        let fileURL = documentsUrl.appendingPathComponent(type + "/" + attName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }

    static func convertJsonStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.replacingOccurrences(of: "\n", with: "").data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
