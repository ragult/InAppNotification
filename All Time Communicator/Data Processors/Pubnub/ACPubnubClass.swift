//
//  ACPubnubClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 03/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACPubnubClass: NSObject {
    typealias CompletionHandler = (_ success: ACPubnubReferenceObjectClass) -> Void
    typealias Completion = (_ success: Bool) -> Void

    typealias onlineState = (_ status: Bool) -> Void

    func sendMessageToPubNub(msgObject: NSMutableDictionary, channel: String, completionHandler: @escaping CompletionHandler) {
        DispatchQueue.main.async {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.client.publish(msgObject, toChannel: channel, storeInHistory: true, withCompletion: { status in
                    if !status.isError {
                        print("message sent")
                        let obj: NSDictionary = msgObject.value(forKey: "comm") as! NSDictionary

                        let callBackObject = ACPubnubReferenceObjectClass(messageId: obj.value(forKey: "gl_mesg_id") as! String, timeStamp: obj.value(forKey: "sent_utc") as! String, msgState: messageState.SENDER_SENT.rawValue, chnl: channel)

                        completionHandler(callBackObject)
                    }
                })
            }
        }
    }

    func sendSystemMessageToPubNub(msgObject: NSMutableDictionary, channel: String, completionHandler: @escaping Completion) {
        DispatchQueue.main.async {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.client.publish(msgObject, toChannel: channel, storeInHistory: true, withCompletion: { status in
                    if !status.isError {
                        print("message sent")
                        completionHandler(true)
                    }
                })
            }
        }
    }

    func sendreceiptsMessageToPubNub(msgObject: NSMutableDictionary, channel: String, completionHandler: @escaping onlineState) {
        DispatchQueue.main.async {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.client.publish(msgObject, toChannel: channel, compressed: false) { status in
                    if !status.isError {
                        print("read recipt")
                        completionHandler(true)

                    } else {
                        completionHandler(false)
                    }
                }
            }
        }
    }

    static func sendTypingStatus(typingObject: ACTypingStatusObject) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let typingObj = typingObject.toDictionary()
            delegate.client.setState(typingObj as! [String: Any], forUUID: delegate.client.uuid(), onChannel: typingObject.channelName, withCompletion: { status in

                if !status.isError {
                    // Client state successfully modified on specified channel.
                    print("STATUS Change")
                } else {
                    // Handle client state modification error. Check 'category' property to find out possible
                    // issue because of which request did fail.
                    //
                    // Request can be resent using: [status retry];
                    print(status.errorData)
                }
            })
        }
    }

    func getHistoryMessages() {
        getHistoryChannels()
    }

    // Pull out all messages newer then message sent at 14395051270438477.

    func getHistoryChannels() {
        getMessagesForOwnChannel()

        // get messages for other channels
        let channels = DatabaseManager.fetchAllChannelGroup()

        for channel in channels! {
            var lastMessageDate = NSNumber()

            if let msgs = DatabaseManager.getTimeStampOfLastMessageForchannel(channelId: channel.id, channelType: channel.channelType) {
                lastMessageDate = Double(msgs.msgTimeStamp)! as NSNumber

            } else {
                if channel.channelSyncTime != "" {
                    lastMessageDate = Double(channel.channelSyncTime)! as NSNumber
                } else {
                    if UserDefaults.standard.value(forKey: UserKeys.lastSigninTime) != nil {
                        lastMessageDate = (UserDefaults.standard.value(forKey: UserKeys.lastSigninTime) as! CUnsignedLongLong) as NSNumber
                    }
                }
            }

            print(lastMessageDate)
            
            historyNewerThen(channel.id, lastMessageDate, onChannel: channel.globalChannelName, withCompletion: { messages in

                print("Messages from history: \(messages)")
                DispatchQueue.global(qos: .userInitiated).async {
                    for message in messages {
                        let dataToProcess = ACFeedProcessorObjectClass()
                        let DataDict: NSDictionary = (message as AnyObject) as! NSDictionary
//                        let data = DataDict .value(forKey: "message")
                        dataToProcess.checkTypeOfDataReceived(dataDictionary: DataDict, isFromHistory: true)
                    }
                }
            })
        }
    }

    func getMessagesForOwnChannel() {
        let channel = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)
        var lastMessageDate = NSNumber()
        if UserDefaults.standard.value(forKey: UserKeys.lastMessageTime) != nil {
            lastMessageDate = (UserDefaults.standard.value(forKey: UserKeys.lastMessageTime) as! CUnsignedLongLong) as NSNumber
        } else {
            if UserDefaults.standard.value(forKey: UserKeys.lastSigninTime) != nil {
                lastMessageDate = (UserDefaults.standard.value(forKey: UserKeys.lastSigninTime) as! CUnsignedLongLong) as NSNumber
            }
        }
        print(lastMessageDate)
        let updatedChannel = "per." + (channel ?? "")
        historyNewerThen("", lastMessageDate, onChannel: updatedChannel, withCompletion: { messages in

            print("Messages from history: \(messages)")
            DispatchQueue.global(qos: .userInitiated).async {
                for message in messages {
                    let dataToProcess = ACFeedProcessorObjectClass()
                    let DataDict: NSDictionary = (message as AnyObject) as! NSDictionary
//                        let data = DataDict .value(forKey: "message")
                    dataToProcess.checkTypeOfDataReceived(dataDictionary: DataDict, isFromHistory: true)
                }
            }

        })
    }

    func historyNewerThen(_ localId: String, _ date: NSNumber, onChannel channel: String,
                          withCompletion closure: @escaping ([Any]) -> Void) {
        var msgs: [Any] = []
        historyNewerThen(localId, date, onChannel: channel, withProgress: { messages in

            msgs.append(contentsOf: messages)
            if messages.count < 100 { closure(msgs) }
        })
    }

    private func historyNewerThen(_ localId: String, _ date: NSNumber, onChannel channel: String, withProgress closure: @escaping ([Any]) -> Void) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.client.historyForChannel(channel, start: nil, end: date, limit: 100, reverse: false, withCompletion: { result, status in

                if status == nil {
                    if ((result?.data.messages.count)!) > 0, localId != "" {
                        let ti = (result?.data.end.intValue)! + 1
                        let tim = NSNumber(value: ti)

                        DatabaseManager.updateChannelSyncTimeForChannelId(channelId: localId, time: tim.stringValue)
                    } else if ((result?.data.messages.count)!) > 0, localId == "" {
                        let ti = (result?.data.end.intValue)! + 1
                        let tim = NSNumber(value: ti)

                        UserDefaults.standard.set(tim, forKey: UserKeys.lastMessageTime)
                    }
                    closure((result?.data.messages)!)
                    if result?.data.messages.count == 100 {
                        self.historyNewerThen(localId, (result?.data.end)!, onChannel: channel,
                                              withProgress: closure)
                    }
                } else {
                    /**
                     Handle message history download error. Check 'category' property
                     to find out possible reason because of which request did fail.
                     Review 'errorData' property (which has PNErrorData data type) of status
                     object to get additional information about issue.

                     Request can be resent using: [status retry];
                     */
                }
            })
        }
    }

    // MARK: notification subscription

    func subscribeToPubnubNotification(token: Data) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let user = UserDefaults.standard.value(forKey: UserKeys.userGlobalId) as? String

            let deviceToken = UserDefaults.standard.value(forKey: UserKeys.deviceTokenData)

            delegate.client.addPushNotificationsOnChannels([user ?? ""],
                                                           withDevicePushToken: token,
                                                           andCompletion: { status in

                                                               if !status.isError {
                                                                   // Handle successful push notification enabling on passed channels.
                                                                   print("success")
                                                               } else {
                                                                   print("error")
                                                               }
            })
        }
    }

    // MARK: notification subscription

    func subscribeToPubnubNotificationForGroup(groupChannelId: String) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
//            let user = UserDefaults.standard.value(forKey: UserKeys.userPhoneNumber) as? String

            let deviceToken = UserDefaults.standard.data(forKey: UserKeys.deviceTokenData)
            if deviceToken != nil {
                delegate.client.addPushNotificationsOnChannels([groupChannelId],
                                                               withDevicePushToken: deviceToken!,
                                                               andCompletion: { status in

                                                                   if !status.isError {
                                                                       // Handle successful push notification enabling on passed channels.
                                                                       print("success")
                                                                   } else {
                                                                       print("error")
                                                                   }
                })
            }
        }
    }

    func getPresenceStateForChannel(channelName: String, completionHandler: @escaping onlineState) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            // With .UUID client will pull out list of unique identifiers and occupancy information.
            delegate.client.hereNowForChannel(channelName, withVerbosity: .state,
                                              completion: { result, status in

                                                  if status == nil {
                                                      let uuids = result?.data.uuids as! NSArray
                                                      if uuids.contains(channelName) {
                                                          completionHandler(true)
                                                      } else {
                                                          completionHandler(false)
                                                      }
                                                      /**
                                                       Handle downloaded presence information using:
                                                       result.data.uuids - list of uuids.
                                                       result.data.occupancy - total number of active subscribers.
                                                       */
                                                  } else {
                                                      completionHandler(false)
                                                      /**
                                                       Handle presence audit error. Check 'category' property to find
                                                       out possible reason because of which request did fail.
                                                       Review 'errorData' property (which has PNErrorData data type) of status
                                                       object to get additional information about issue.

                                                       Request can be resent using: status.retry()
                                                       */
                                                  }
            })
        }
    }
}
