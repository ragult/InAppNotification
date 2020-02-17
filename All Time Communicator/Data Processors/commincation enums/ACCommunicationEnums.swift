//
//  ACCommunicationEnums.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 31/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import Foundation

public enum channelType: String {
    case NOTIFICATIONS = "1"
    case ONE_ON_ONE_CHAT = "2"
    case GROUP_MEMBER_ONE_ON_ONE = "3"

    case ADHOC_CHAT = "21"
    case GROUP_CHAT = "22"
    case TOPIC_GROUP = "23"
    case PRIVATE_GROUP = "24"
    case PUBLIC_GROUP = "25"
}

public enum useractionType: String {
    case NEW = "new"
    case REPLY = "reply"
    case OTHERTYPE_RESPONSE = "resp"
}

public enum downloadStatus: Int {
    case inProgress = 1
    case downloaded = 2
    case failed = 3
}

public enum messagetype: String {
    case TEXT = "1"
    case IMAGE = "2"
    case AUDIO = "3"
    case VIDEO = "4"
    case OTHER = "5"
}

public enum visibilityStatus: String {
    case visible = "1"
    case deleted = "2"
    case hidden = "3"
}

public enum attachmentType: String {
    case TEXT = "1"
    case IMAGE = "2"
    case AUDIO = "3"
    case VIDEO = "4"
    case imageArray = "5"
    case poll = "6"
}

public enum groupStatus {
    case JOINED
    case BLOCKED
    case EXITED
}

public enum groupStats: String {
    case ACTIVE = "1"
    case INACTIVE = "2"
}

public enum groupMemberStats: String {
    case ACTIVE = "1"
    case INACTIVE = "2"
}

public enum otherMessageType: String {
    case POST_SYSTEM_EVENT = "1"
    case ENTITY_SPAM_REP_CHOICE = "2"
    case PERSON_INTRO = "3"
    case INFO = "4"

    case MEDIA_ARRAY = "22"
    case TEXT_POLL = "23"
    case IMAGE_POLL = "24"

    case MEETING = "25"
    case INVITE = "26"
    case REMINDER = "27"
}

public enum messageState: String {
    case INSTR_RECEIVED = "1"
    case SENDER_UNSENT = "2"
    case SENDER_SENT = "3"
    case RECEIVER_RECEIVED = "4"
    case RECEIVER_SEEN = "5"
    case MESSAGE_HIDDEN = "6"
    case MESSAGE_MARKED_DELETE = "7"
    case MESSAGE_INFO = "8"
}

public enum MessageOrigin {
    case SELF
    case RECEIVED
}

public enum beakState: Int {
    case noData = 1
    case SHOWBEAK = 2
    case NOBEAK = 3
}
