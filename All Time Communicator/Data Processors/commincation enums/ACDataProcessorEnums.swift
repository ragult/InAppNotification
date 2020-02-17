//
//  ACDataProcessorEnums.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 26/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import Foundation

public enum source: String {
    case system = "sys"
    case authentication = "comm"
}

public enum systemEntityType: String {
    case systemEntity = "sys_entity"
    case communicationStatus = "comm_status"
}

public enum actionTypesForGroups: String {
    case groupIntro = "grp_intro"
    case groupMemebrAdded = "mem_added"
    case groupMemebrRemoved = "mem_remv"
    case phoneNumberChanged = "ph_chgd"
    case groupMemebrLeft = "mem_left"
    case groupPhotoChanged = "grp_photo_new"
    case groupdetails = "grp_details"
    case friendAdded = "mut_regd"
    case adhocIntro = "adh_intro"
    case I_AM
    case Req_intro = "WHO_ARE_YOU"
    case addhoc_memberAdded = "mem_added_adh"
    case addhoc_member_Removed = "adhoc_mem_left"

    case member_permission_changed = "mem_perm_chgd"
    case group_delete = "grp_del"
}

public enum NotificationEnum: Int {
    case showNoNotificatons = 1
    case ShowAllNotifications = 2
    case showRecentChatNotifications = 3
    case ShowAllGroupChatsNotification = 4
    case showExceptSpecificChannelId = 5
}

public enum readReceipts: String {
    case messageDelivered = "com_recd"
    case messageSeen = "com_seen"
}

public enum groupType: String {
    case GROUP_CHAT = "1"
    case ADHOC_CHAT = "2"
    case TOPIC_GROUP = "3"
    case PRIVATE_GROUP = "4"
    case PUBLIC_GROUP = "5"
}

public enum ContactSyncStatus: String {
    case NO_Action = "1"
    case INSERT = "2"
    case UPDATE = "3"
}
