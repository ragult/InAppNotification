//
//  NetworkingHelper.swift
//  alltimecommunicator
//
//  Created by Droid5 on 03/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import Alamofire
import EVReflection
import Foundation

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
        debugPrint(self)
        #endif
        return self
    }
}

class NetworkingManager {
    static func logs(_ request: String, _ url: String) {
        print("URL : \(url)")
        print("Request : \(request)")
    }

    static func logs(_ request: [String: Any], _ url: String) {
        print("URL : \(url)")
        print("Request : \(request)")
    }

    static func getOtp(countryIsoCode: String, phoneNumber: String, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        if let sendOtpRequestModelDicionary = SendOtpRequestModel(countryIsoCode: countryIsoCode, phoneNumber: phoneNumber).toDictionary() as? [String: Any] {
            logs(sendOtpRequestModelDicionary, API.GET_OTP)
            Alamofire.request(API.GET_OTP, method: .post, parameters: sendOtpRequestModelDicionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<SendOtpResponseModel>) in

                    UserDefaults.standard.set(phoneNumber, forKey: UserKeys.userPhoneNumber)
                    var result = SendOtpResponseModel()
                    if response.result.value != nil {
                        result = response.result.value!
                        result.saveDeviceData()
                        listener((result: result, success: true))
                    } else {
                        result.saveDeviceData()
                        listener((result: result, success: true))
                    }
                }
        }
    }

    static func verifyOtp(userOtp: String, securityCode: String, countryIsoCode: String, phoneNumber: String, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        if let verifyOtpRequestModelDictionary = VerifyOtpRequestModel(userOtp: userOtp, securityCode: securityCode, phoneNumber: phoneNumber, countryCode: countryIsoCode).toDictionary() as? [String: Any] {
            logs(verifyOtpRequestModelDictionary, API.VERIFY_OTP)
            Alamofire.request(API.VERIFY_OTP, method: .post, parameters: verifyOtpRequestModelDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<VerifyOtpResponseModel>) in

                    if let result = response.result.value {
                        print("response: \(result)")
                        // TODO: need to handle success
                        result.saveDeviceData()
                        listener((result: result, success: true))
                    } else {
                        let result = VerifyOtpResponseModel()
                        result.saveDeviceData()
                        listener((result: result, success: false))
                    }
                }
        }
    }

    static func changePhoneNumber(changeNumbermodel: ChangeNumberModel, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        if let verifyOtpRequestModelDictionary = changeNumbermodel.toDictionary() as? [String: Any] {
            logs(verifyOtpRequestModelDictionary, API.CHANGE_NUMBER_NEW)
            Alamofire.request(API.CHANGE_NUMBER_NEW, method: .post, parameters: verifyOtpRequestModelDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<VerifyOtpResponseModel>) in
                    if let result = response.result.value {
                        print("response: \(result)")
                        // TODO: need to handle success
                        listener((result: result, success: true))
                    } else {
                        let result = VerifyOtpResponseModel()
                        listener((result: result, success: false))
                    }
                }
        }
    }

    static func findMemberProfiles(model: FindMemberProfileRequestModel, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        if let findMemberProfileRequestModelDictionary = model.toDictionary() as? [String: Any] {
            logs(findMemberProfileRequestModelDictionary, API.FIND_MEMBER_PROFILES)
            Alamofire.request(API.FIND_MEMBER_PROFILES, method: .post, parameters: findMemberProfileRequestModelDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<FindMemberProfilesResponseModel>) in
                    if let result = response.result.value {
                        print("response: \(result)")
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, success: true))
                    } else {
                        let result = FindMemberProfilesResponseModel()
                        listener((result: result, success: false))
                    }
                }
        }
    }

    static func getMemberProfileByNonMember(getMemberProfileModel: GetMemberProfileRequestModel, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        if let getMemberProfileRequestModelDictionary = getMemberProfileModel.toDictionary() as? [String: Any] {
            logs(getMemberProfileRequestModelDictionary, API.GET_MEMBER_PROFILE)
            Alamofire.request(API.GET_MEMBER_PROFILE, method: .post, parameters: getMemberProfileRequestModelDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<GetMemberProfileResponseModel>) in
                    if let result = response.result.value {
                        print("response: \(result)")
                        // TODO: need to handle success
                        listener((result: result, success: true))
                    } else {
                        let result = GetMemberProfileResponseModel()
                        listener((result: result, success: false))
                    }
                }
        }
    }

    static func signIn(signInrequest: signinRequestModel, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        if let getMemberProfileRequestModelDictionary = signInrequest.toDictionary() as? [String: Any] {
            logs(getMemberProfileRequestModelDictionary, API.PERSON_SIGNIN)

            let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 120

            Alamofire.request(API.PERSON_SIGNIN, method: .post, parameters: getMemberProfileRequestModelDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<SignInResponseModel>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, success: true))
                    } else {
                        let result = SignInResponseModel()
                        listener((result: result, success: false))
                    }
                }
        }
    }

    static func signInWithChallenge(signInrequest: SigninChallengeRequestModel, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        if let getMemberProfileRequestModelDictionary = signInrequest.toDictionary() as? [String: Any] {
            logs(getMemberProfileRequestModelDictionary, API.PERSON_SIGNIN_Challenge)

            Alamofire.request(API.PERSON_SIGNIN_Challenge, method: .post, parameters: getMemberProfileRequestModelDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<SignInResponseModel>) in
                    if let result = response.result.value {
                        print("response: \(result)")
                        // TODO: need to handle success
                        result.updateSharedSecretKeys()
                        listener((result: result, success: true))
                    } else {
                        let result = SignInResponseModel()
                        result.updateSharedSecretKeys()
                        listener((result: result, success: false))
                    }
                }
        }
    }

    static func decryptResponse<T: EncryptedBaseResponseModel>(response: T) -> T {
        guard let data = response.encryptedData else { return response }

        let decryptedData = CryptoHelper.decrypt(input: data as String)
        let parsedData = NSString(string: decryptedData ?? "") as String
        response.decryptData(parsedData)
        return response
    }
    
    static func decryptResponse<T: UpdateBroadCastGroupEncryptedBaseModel>(response: T) -> T {
        guard let data = response.encryptedData else { return response }
        let decryptedData = CryptoHelper.decrypt(input: data as String)
        let parsedData = NSString(string: decryptedData ?? "") as String
        response.decryptData(parsedData)
        return response
    }

    static func personRegister(registrationModel: PersonRegistrationRequestModel, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        registrationModel.socialAccessToken = UserDefaults.standard.string(forKey: UserKeys.socialAccessToken) ?? ""

        if let personRegisterRequestModelDictionary = registrationModel.toDictionary() as? [String: Any] {
            let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 120
            logs(personRegisterRequestModelDictionary, API.PERSON_REGISTER)

            Alamofire.request(API.PERSON_REGISTER, method: .post, parameters: personRegisterRequestModelDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<PersonRegisterResponseModel>) in

                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, success: true))
                    } else {
                        let result = PersonRegisterResponseModel()
                        listener((result: result, success: false))
                    }
                }
        }
    }

    static func changeNumber(changeNumberModel: ChangeNumberRequestModel, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        if let changeNumberRequestModelDictionary = changeNumberModel.toDictionary() as? [String: Any] {
            logs(changeNumberRequestModelDictionary, API.CHANGE_ACCOUNT)

            Alamofire.request(API.CHANGE_ACCOUNT, method: .post, parameters: changeNumberRequestModelDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<ChangeNumberResponseModel>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, success: true))
                    } else {
                        let result = ChangeNumberResponseModel()
                        listener((result: result, success: false))
                    }
                }
        }
    }

    static func updateLastLogin(changeNumberModel: UpdatelastLoginModel, listener: @escaping ((result: Any, success: Bool)) -> Void) {
        if let changeNumberRequestModelDictionary = changeNumberModel.toDictionary() as? [String: Any] {
            logs(changeNumberRequestModelDictionary, API.CHANGE_ACCOUNT)
            Alamofire.request(API.CHANGE_ACCOUNT, method: .post, parameters: changeNumberRequestModelDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<UpdateLastLoginResponseModel>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, success: true))
                    } else {
                        let result = UpdateLastLoginResponseModel()
                        listener((result: result, success: false))
                    }
                }
        }
    }

    static func updateUserProfile(updateUserProfile: UpdateUserProfile, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let updateUserProfileDictionary = updateUserProfile.toDictionary() as? [String: Any] {
            logs(updateUserProfileDictionary, API.UPDATE_USER_PROFILE)
            Alamofire.request(API.UPDATE_USER_PROFILE, method: .post, parameters: updateUserProfileDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<EncryptedBaseResponseModel>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        let result = createGroupResponseModel()
                        listener((result: result, sucess: false))
                    }
                }
        }
    }

    static func sendQrToEmail(emailProfile : SendQRtoEmail, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let sendQrToEmail = emailProfile.toDictionary() as? [String: Any] {
            logs(sendQrToEmail, API.SEND_QR_TO_EMAIL)
            Alamofire.request(API.SEND_QR_TO_EMAIL, method: .post, parameters: sendQrToEmail, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<EncryptedBaseResponseModel>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        let result = EncryptedBaseResponseModel()
                        listener((result: result, sucess: false))
                    }
                }
        }
    }
    
    static func createGroup(createGroupModel: CreateGroupRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let createGroupRequestDictionary = createGroupModel.toDictionary() as? [String: Any] {
            logs(createGroupRequestDictionary, API.CREATE_GROUP)
            Alamofire.request(API.CREATE_GROUP, method: .post, parameters: createGroupRequestDictionary, encoding: JSONEncoding.default)
                .responseJSON(completionHandler: { response in
                    if let resultValue = response.result.value {
                        print("Response", resultValue, response.response?.statusCode ?? 0)
                    }
                })
                .responseObject { (response: DataResponse<createGroupResponseModel>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        let result = createGroupResponseModel()
                        listener((result: result, sucess: false))
                    }
                }
        }
    }

    static func createAdhocChat(createGroupModel: CreateAdhocChatRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let createGroupRequestDictionary = createGroupModel.toDictionary() as? [String: Any] {
            logs(createGroupRequestDictionary, API.CREATE_ADHOC_GROUP)

            Alamofire.request(API.CREATE_ADHOC_GROUP, method: .post, parameters: createGroupRequestDictionary, encoding: JSONEncoding.default).responseObject { (response: DataResponse<CreateAdhocResponseModel>) in
                if let result = response.result.value {
                    let updatedResult = decryptResponse(response: result)
                    print(" create adhoc group response \(result)")
                    listener((result: updatedResult, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func AddMembersAdhocChat(addAdhocMembersModel: AddMembersAdhocChatRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let createGroupRequestDictionary = addAdhocMembersModel.toDictionary() as? [String: Any] {
            logs(createGroupRequestDictionary, API.AddMember_ADHOC_GROUP)

            Alamofire.request(API.AddMember_ADHOC_GROUP, method: .post, parameters: createGroupRequestDictionary, encoding: JSONEncoding.default).responseObject { (response: DataResponse<CreateAdhocResponseModel>) in
                print(response)
                if let result = response.result.value {
                    print(" create adhoc group response \(result)")
                    listener((result: result, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func ExitMembersAdhocChat(addAdhocMembersModel: ExitMembersAdhocChatRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let createGroupRequestDictionary = addAdhocMembersModel.toDictionary() as? [String: Any] {
            logs(createGroupRequestDictionary, API.exitMember_ADHOC_GROUP)

            Alamofire.request(API.exitMember_ADHOC_GROUP, method: .post, parameters: createGroupRequestDictionary, encoding: JSONEncoding.default).responseObject { (response: DataResponse<CreateAdhocResponseModel>) in
                if let result = response.result.value {
                    print(" create adhoc group response \(result)")
                    listener((result: result, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func getActiveGroups(getActiveGroupsReqModel: GetActiveGroupsRequest, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getActiveGroupsRequestDictionary = getActiveGroupsReqModel.toDictionary() as? [String: Any] {
            logs(getActiveGroupsRequestDictionary, API.GET_ACTIVE_GROUPS)

            Alamofire.request(API.GET_ACTIVE_GROUPS, method: .post, parameters: getActiveGroupsRequestDictionary, encoding: JSONEncoding.default).responseObject { (response: DataResponse<GetActiveGroupResponse>) in
                if let result = response.result.value {
                    print(" get active groups response \(result)")
                    listener((result: result, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func updateGroup(updateRequestModel: UpdateGroupRequest, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let updateGroupRequestDictionary = updateRequestModel.toDictionary() as? [String: Any] {
            logs(updateGroupRequestDictionary, API.UPDATE_GROUP)
            Alamofire.request(API.UPDATE_GROUP, method: .post, parameters: updateGroupRequestDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<GetActiveGroupResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func addGroupMember(addGroupMemberModel: AddGroupMemberRequest, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let addGroupMemberRequestDictionary = addGroupMemberModel.toDictionary() as? [String: Any] {
            logs(addGroupMemberRequestDictionary, API.ADD_GROUP_MEMBERS)

            Alamofire.request(API.ADD_GROUP_MEMBERS, method: .post, parameters: addGroupMemberRequestDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<AddGroupMemberResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func joinGroupMember(addGroupMemberModel: JoinGroupMemberRequest, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let addGroupMemberRequestDictionary = addGroupMemberModel.toDictionary() as? [String: Any] {
            logs(addGroupMemberRequestDictionary, API.joinGroup)

            Alamofire.request(API.joinGroup, method: .post, parameters: addGroupMemberRequestDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<AddGroupMemberResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func removeGroupMember(addGroupMemberModel: RemoveGroupMemberRequest, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let addGroupMemberRequestDictionary = addGroupMemberModel.toDictionary() as? [String: Any] {
            logs(addGroupMemberRequestDictionary, API.deleteGroupMember)

            Alamofire.request(API.deleteGroupMember, method: .post, parameters: addGroupMemberRequestDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<AddGroupMemberResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func DeleteGroup(addGroupMemberModel: deleteGroupRequest, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let addGroupMemberRequestDictionary = addGroupMemberModel.toDictionary() as? [String: Any] {
            logs(addGroupMemberRequestDictionary, API.deleteGroup)

            Alamofire.request(API.deleteGroup, method: .post, parameters: addGroupMemberRequestDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<AddGroupMemberResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func updateGroupMembers(updateGroupMemsModel: UpdateGroupMembersRequest, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let updateGroupMembersDictionary = updateGroupMemsModel.toDictionary() as? [String: Any] {
            logs(updateGroupMembersDictionary, API.UPDATE_GROUP_MEMBERS)

            Alamofire.request(API.UPDATE_GROUP_MEMBERS, method: .post, parameters: updateGroupMembersDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<UpdateGroupMembersResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func updateGroupData(updateDictionary: NSMutableDictionary, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let updateGroupMembersDictionary = updateDictionary as? [String: Any] {
            logs(updateGroupMembersDictionary, API.UPDATE_GROUP)

            Alamofire.request(API.UPDATE_GROUP, method: .post, parameters: updateGroupMembersDictionary, encoding: JSONEncoding.default).responseObject { (response: DataResponse<UpdateGroupResponse>) in
                if let result = response.result.value {
                    let updatedResult = decryptResponse(response: result)
                    listener((result: updatedResult, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func updateGroupImage(updateDictionary: NSMutableDictionary, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let updateGroupMembersDictionary = updateDictionary as? [String: Any] {
            logs(updateGroupMembersDictionary, API.UPDATE_GROUP_IMAGE)

            Alamofire.request(API.UPDATE_GROUP_IMAGE, method: .post, parameters: updateGroupMembersDictionary, encoding: JSONEncoding.default).responseObject { (response: DataResponse<UpdateGroupResponse>) in
                if let result = response.result.value {
                    let updatedResult = decryptResponse(response: result)
                    listener((result: updatedResult, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func getGroup(getGroupModel: GetGroupRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.GET_GROUP)

            Alamofire.request(API.GET_GROUP, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default)
                .responseJSON(completionHandler: { response in
                    if let resultValue = response.result.value {
                        print("Response", resultValue, response.response?.statusCode ?? 0)
                    }
                })
                .responseObject { (response: DataResponse<GetGroupResponseModel>) in
                if let result = response.result.value {
                    let updatedResult = decryptResponse(response: result)
                    listener((result: updatedResult, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func cretaeBroadcast(getGroupModel: SendBroadcastRequestModel, acCommObj: ACCommunicationMsgObject, acMsgCon: ACMessageContextObject, attId _: String, listener: @escaping ((result: Any, sucess: Bool, msgObj: SendBroadcastRequestModel, commObj: ACCommunicationMsgObject, msgCont: ACMessageContextObject)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.CREATE_BROADCAST_GROUP)

            Alamofire.request(API.CREATE_BROADCAST_GROUP, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
                if let resultValue = response.result.value {
                    print("Response", resultValue, response.response?.statusCode ?? 0)
                }
            }).responseObject { (response: DataResponse<UpdateBroadcastGroupResponse>) in
                if let result = response.result.value {
                    print("get group response \(result)")
                    let updatedResult = decryptResponse(response: result)
                    listener((result: updatedResult, sucess: true, msgObj: getGroupModel, commObj: acCommObj, msgCont: acMsgCon))
                } else {
                    listener((result: response.result.error as Any, sucess: false, msgObj: getGroupModel, commObj: acCommObj, msgCont: acMsgCon))
                }
            }
        }
    }

    static func getBroadcastLastTimeStamp(getGroupModel: BroadcastGetMessageLastTimeStampRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.BROADCAST_GROUP_MESSAGE_TIMESTAMP)

            Alamofire.request(API.BROADCAST_GROUP_MESSAGE_TIMESTAMP, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default)
                .responseJSON(completionHandler: { (response) in
                    print(response.result.value)
                })
                .responseObject { (response: DataResponse<GetMessagesResponseModel>) in
                if let result = response.result.value {
                    let updatedResult = decryptResponse(response: result)
//                    let updatedResult = result
                    listener((result: updatedResult, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
        
    }

    static func getBroadcastMsgs(getGroupModel: BroadcastSyncModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.BROADCAST_GROUP_GETMESSAGES)

            Alamofire.request(API.BROADCAST_GROUP_GETMESSAGES, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<UpdateBroadcastSyncResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                    
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }
    
        static func unPublishMessage(getGroupModel: UnPublishRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
            if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
                logs(getGroupMemberDictionary, API.BROADCAST_GROUP_MESSAGE_UNPUBLISH)

                Alamofire.request(API.BROADCAST_GROUP_MESSAGE_UNPUBLISH, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default)
                    .responseJSON(completionHandler: { (response) in
                        print(response.result.value)
                    })
                    .responseObject { (response: DataResponse<GetMessagesResponseModel>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
            }
            
        }

    static func createPoll(getGroupModel: PollCreateRequestObject, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.CREATE_POLL)

            Alamofire.request(API.CREATE_POLL, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default).responseObject { (response: DataResponse<createPollResponseModel>) in
                if let result = response.result.value {
                    let updatedResult = decryptResponse(response: result)
                    listener((result: updatedResult, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func submitPoll(getGroupModel: submitPollIdRequestObject, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.SUBMIT_POLL)

            Alamofire.request(API.SUBMIT_POLL, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default).responseObject { (response: DataResponse<SubmitPollDataResponseObject>) in
                if let result = response.result.value {
                    let updatedResult = decryptResponse(response: result)
                    listener((result: updatedResult, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func getPollCounts(getGroupModel: GetPollDataRequestObject, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.POLL_STATUS)

            Alamofire.request(API.POLL_STATUS, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<PollStatusResponseObject>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func getPollData(getGroupModel: GetPollDataRequestObject, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.GET_POLL)

            Alamofire.request(API.GET_POLL, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<GetPollDataResponseObject>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func TwilioGetOTP(getGroupModel: TwilioRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.TWILIO_Request)

            Alamofire.request(API.TWILIO_Request, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<UpdateOtpResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func TwilioVerifyOtp(getGroupModel: TwilioVerifyRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.TWILIO_OTP)

            Alamofire.request(API.TWILIO_OTP, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<verifyMapOtpResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func searchLocation(getGroupModel: mapSearchRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.mapSearch)

            Alamofire.request(API.mapSearch, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default).responseJSON { response in
                if let result = response.result.value {
                    print("get group response \(result)")
                    listener((result: result, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func searchByName(getGroupModel: GroupSearch, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.groupNameSearch)

            Alamofire.request(API.groupNameSearch, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<GroupNameSearchResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func searchByKeyword(getGroupModel: GroupCodeSearch, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.groupCodeSearch)

            Alamofire.request(API.groupCodeSearch, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default)
                .responseObject { (response: DataResponse<GroupCodeSearchResponse>) in
                    if let result = response.result.value {
                        let updatedResult = decryptResponse(response: result)
                        listener((result: updatedResult, sucess: true))
                    } else {
                        listener((result: response.result.error as Any, sucess: false))
                    }
                }
        }
    }

    static func activeUsersSearch(activeNumbers: ActiveNumberSearch, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let createGroupRequestDictionary = activeNumbers.toDictionary() as? [String: Any] {
            logs(createGroupRequestDictionary, API.activeNumberSearch)

            Alamofire.request(API.activeNumberSearch, method: .post, parameters: createGroupRequestDictionary, encoding: JSONEncoding.default)
                .responseJSON(completionHandler: { (response) in
                    print(response.result.value)
                })
                .responseObject { (response: DataResponse<ActiveNumberSearchResponse>) in
                if let result = response.result.value {
                    let updatedResult = decryptResponse(response: result)
                    listener((result: updatedResult, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }

    static func getPublicGroup(getGroupModel: GetPublicGroupRequestModel, listener: @escaping ((result: Any, sucess: Bool)) -> Void) {
        if let getGroupMemberDictionary = getGroupModel.toDictionary() as? [String: Any] {
            logs(getGroupMemberDictionary, API.getPublicGroup)

            Alamofire.request(API.getPublicGroup, method: .post, parameters: getGroupMemberDictionary, encoding: JSONEncoding.default).responseObject { (response: DataResponse<GetPublicGroupResponseModel>) in
                if let result = response.result.value {
                    let updatedResult = decryptResponse(response: result)
                    listener((result: updatedResult, sucess: true))
                } else {
                    listener((result: response.result.error as Any, sucess: false))
                }
            }
        }
    }
}

func stringFromAny(_ value:Any?) -> String {
    if let nonNil = value, !(nonNil is NSNull) {
        return String(describing: nonNil)
    }
    return ""
}
