//
//  API.swift
//  alltimecommunicator
//
//  Created by Droid5 on 03/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//
struct API {
    static let BASE_API: String = "http://13.127.187.72/services/api/"

    // MARK: LOGIN PHASE

    static let GET_OTP: String = "\(BASE_API)pub/sendOtp"
    static let RESEND_OTP: String = "\(BASE_API)pub/resendOtp"
    static let VERIFY_OTP: String = "\(BASE_API)pub/verifyOtp"
    static let PERSON_REGISTER: String = "\(BASE_API)pub/personRegister"
    static let PERSON_SIGNIN: String = "\(BASE_API)pub/signIn"

    // MARK: - Profile

//    static let FIND_MEMBER_PROFILES: String = "\(BASE_API)mem/findMemberProfiles"
    static let FIND_MEMBER_PROFILES: String = "\(BASE_API)mem/findMemberProfiles"
    static let UPDATE_USER_PROFILE: String = "\(BASE_API)mem/updateUserProfile"
    static let SEND_QR_TO_EMAIL : String = "\(BASE_API)mem/sendQrToEmail"

    // MARK: - Missing

    static let GET_MEMBER_PROFILE: String = "\(BASE_API)getMemberProfileAuthByMember"

    // MARK: - Groups

    static let CREATE_GROUP: String = "\(BASE_API)mem/createGroup"
    static let GET_GROUP: String = "\(BASE_API)mem/getGroup"
    static let UPDATE_GROUP: String = "\(BASE_API)mem/updateGroup"
    static let CHANGE_NUMBER_NEW: String = "\(BASE_API)mem/changePhoneNumber"
    static let UPDATE_GROUP_MEMBERS: String = "\(BASE_API)mem/updateGroupMember"
    static let DELETE_GROUP_MEMBER: String = "\(BASE_API)mem/deleteGroupMember"
    static let ADD_GROUP_MEMBERS: String = "\(BASE_API)mem/addGroupMember"

    // MARK: - Account

    static let CHANGE_ACCOUNT: String = "\(BASE_API)mem/changeAccount"

    // MARK: - CREATE GROUP PHASE

    static let CREATE_GROUP_MEMBER: String = "\(BASE_API)mem/createGroupMember"
    static let UPDATE_GROUP_IMAGE: String = "\(BASE_API)mem/groupPhotoUpdate"
    static let deleteGroupMember: String = "\(BASE_API)mem/deleteGroupMember"
    static let deleteGroup: String = "\(BASE_API)mem/deleteGroup"
    //   static let GET_GROUP_MEMBER:String = "\(BASE_API)groupMember/2"

    static let groupNameSearch: String = "\(BASE_API)mem/groupNameSearch"
    static let groupCodeSearch: String = "\(BASE_API)mem/groupCodeSearch"
    static let getPublicGroup: String = "\(BASE_API)mem/getPublicGroup"

    // MARK: Broadcast

    static let BROADCAST_GROUP_GETMESSAGES: String = "\(BASE_API)mem/getMessages"
    static let BROADCAST_GROUP_MESSAGE_TIMESTAMP: String = "\(BASE_API)mem/getHistory"
    static let BROADCAST_GROUP_MESSAGE_UNPUBLISH: String = "\(BASE_API)mem/deleteBroadcastPublication"
    
    // Mark:poll
    static let CREATE_POLL: String = "\(BASE_API)mem/createPoll"
    static let GET_POLL: String = "\(BASE_API)mem/getPollData"
    static let SUBMIT_POLL: String = "\(BASE_API)mem/submitPollResponse"
    static let POLL_STATUS: String = "\(BASE_API)mem/getPollStats"

    // Mark:TWILIO
    static let TWILIO_Request: String = "\(BASE_API)mem/requestPinForLocation"
    static let TWILIO_OTP: String = "\(BASE_API)mem/validatePinForLocation"

    static let activeNumberSearch: String = "\(BASE_API)mem/activeUsers"
    static let joinGroup: String = "\(BASE_API)mem/joinGroup"

    // MARK: - Missing

    static let GET_ACTIVE_GROUPS: String = "\(BASE_API)getActiveGroups"
    static let CHANGE_NUMBER: String = "\(BASE_API)changedNumber"
    static let UPDATE_LAST_LOGIN: String = "\(BASE_API)updateLastLogin"
    static let CREATE_BROADCAST_GROUP: String = "\(BASE_API)mem/broadcastRequest"
    static let BROADCAST_GROUP_MESSAGE_LASTID: String = "\(BASE_API)getGroupMessagesSinceLastId"
    static let BROADCAST_GROUP_COMFIRMID: String = "\(BASE_API)confirmLastId"
    static let mapSearch: String = "\(BASE_API)mapApi"

    // MARK: - Missing adhoc

    static let CREATE_ADHOC_GROUP: String = "\(BASE_API)mem/createAdHocGroup"
    static let AddMember_ADHOC_GROUP: String = "\(BASE_API)addMembersToAdhocGroup"
    static let exitMember_ADHOC_GROUP: String = "\(BASE_API)exitAdhocGroup"

    static let PERSON_SIGNIN_Challenge: String = "\(BASE_API)signInWithChallenge"
}
