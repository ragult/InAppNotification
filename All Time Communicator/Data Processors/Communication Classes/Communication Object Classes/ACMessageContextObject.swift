//
//  ACMessageContextObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 03/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class ACMessageContextObject: NSObject {
    // type of message as in enumeration for text/image/other
    var messageType: messagetype?

    // local messageId
    var localMessageId: String?

    // type of communication as in enumeration
    var contentSource: source?

    // index coloumn from channel table
    var globalChannelName: String?

    // index coloumn from channel table
    var localChanelId: String?

    // self id from the profile table
    var localSenderId: String?

    // self number with country code
    var senderPhoneNo: String?

    // self userid
    var senderGlobalId: String?

    // globalGroupId or the receiving person phone number
    var receiverGlobalId: String?

    // type of channel as in enumeration for 1-1/group etc
    var channelType: channelType?

    var groupType: String?

    //  self globalId + local timestamp
    var globalMsgId: String?

    // type of message from enumeration for new/reply message
    var action: useractionType?

    // the globalMsgId of the selected message to be replied to
    var replyToId: String?

    // is always true when sender is self
    var isMine: Bool?

    // local timestamo in utc*10000
    var msgTimeStamp: String = ""

    //type of message from enumeration for sent/received/seen
    var messageState: messageState?

    //the number of groupmembers
    var targetCount: String?

    var topicId: String?

    var seenMembers: String?
    var readMembers: String?

    var showBeak: beakState = beakState.noData
    var isForward: Bool?

}
