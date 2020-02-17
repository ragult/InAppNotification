//
//  BroadcastDataProcessor.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 30/03/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class BroadcastDataProcessor: NSObject {
    
    var requestSubmitedTime : String = ""
    
    func getLastMessageIdForGroups() {
        let groups = DatabaseManager.fetchAllBroadcastGroup()

        var msgTimeStampArray = [String]()

        for group in groups! {
            msgTimeStampArray.append(group.groupGlobalId)
        }

        if msgTimeStampArray.count > 0 {
            let data = BroadcastGetMessageLastTimeStampRequestModel()
            data.auth = DefaultDataProcessor().getAuthDetails()
            let laseRequestSubmitedTime = UserDefaults.standard.string(forKey: UserKeys.lastBroadcastSigninTime)! as String
            let time  = Double(laseRequestSubmitedTime)
            data.sinceTimeStamp = String(Int64(time! * Double(10000000)))
            data.globalGroupId = msgTimeStampArray

            self.requestSubmitedTime = String(NSDate().timeIntervalSince1970)

            NetworkingManager.getBroadcastLastTimeStamp(getGroupModel: data, listener: {
                result, success in if let result = result as? GetMessagesResponseModel, success {
                    if success {
                        if result.status == "Success" {
                            let msgs = result.data
                            var receivedArray = [String]()
                            var requiredArray = [String]()

                            for msg in msgs! {
                                if let msgId = msg.globalMessageId, DatabaseManager.checkIfMsgExists(msgId: msgId) == true {
                                    receivedArray.append(msgId)
                                } else if let msgId = msg.globalMessageId {
                                    requiredArray.append(msgId)
                                }
                            }

                            self.syncMessages(recArray: receivedArray, reqArray: requiredArray)
                        }
                    }
                }
            })
        }
    }

    func syncMessages(recArray: [String], reqArray: [String]) {
        if recArray.count > 0 || reqArray.count > 0 {
            let data = BroadcastSyncModel()
            data.auth = DefaultDataProcessor().getAuthDetails()
            data.received = recArray
            data.required = reqArray

            NetworkingManager.getBroadcastMsgs(getGroupModel: data, listener: {
                result, success in if let result = result as? UpdateBroadcastSyncResponse, success {
                    if success {
                        if result.status == "Success" {
                            let msgs = result.data
                            for msg in msgs! {
                                let glbMsgId = msg.globalMessageId ?? ""
                                if glbMsgId != "" {
                                    ACFeedProcessorObjectClass().checkTypeOfDataReceived(dataDictionary: msg.message!)
                                }
                            }
                            UserDefaults.standard.set(self.requestSubmitedTime, forKey: UserKeys.lastBroadcastSigninTime)
                        }
                    }
                }
            })
        }
    }
}
