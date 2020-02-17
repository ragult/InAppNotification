//
//  ACContactsProcessor.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 12/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Contacts
import ContactsUI
import UIKit

typealias CompletionHandler = (_ success: Bool) -> Void
typealias CompletionHandlerNew = (_ success: Bool, _ status: String) -> Void

class ACContactsProcessor: NSObject {
    let contactsStore = CNContactStore()
    let userNumber = UserDefaults.standard.string(forKey: UserKeys.userPhoneNumber)
    let countyCode = UserDefaults.standard.string(forKey: UserKeys.countryCode)
    let length = UserDefaults.standard.string(forKey: UserKeys.numberLength)

    var contactsToVerify = [ProfileTable]()
    var databaseContactsArray = [ACContactsObject]()
    var syncedContacts = [ACContactsObject]()
    var contactsToSendArray = [ContactModel]()
    var finalContactsFromDB = [ProfileTable]()

    func getContactsAndUpdate(notify: Bool, completionHandler: @escaping CompletionHandler) {
        contactsStore.requestAccess(for: .contacts) { success, _ in
            if success {
                print("Authuorized")
                self.contactsToVerify = [ProfileTable]()
                self.databaseContactsArray = [ACContactsObject]()
                self.syncedContacts = [ACContactsObject]()

                self.populateContactsDatabase()
                self.syncedContacts = self.fetchContactsFromPhoneContactBook()
                self.insertOrUpdateToDb(contacts: self.syncedContacts)
                if notify {
                    self.populateDatabaseTosendtoServer()
                    self.getContacts(notifyStatus: notify, completionHandler: { (success) -> Void in

                        if success == true {
                            completionHandler(true)
                        }
                    })
                } else {
                    self.populateExistingDatabaseTosendtoServer()
                    self.mapExistingContacts(notifyStatus: notify, completionHandler: { (success) -> Void in

                        if success == true {
                            completionHandler(true)
                        }
                    })
                }

            } else {
                print("Un Authorized contacts ")
            }
        }
    }

    func getContacts(notifyStatus: Bool, completionHandler: @escaping CompletionHandler) {
        let findMemberModel = FindMemberProfileRequestModel()

        findMemberModel.notifyFriend = notifyStatus
        findMemberModel.auth = DefaultDataProcessor().getAuthDetails()
        findMemberModel.phoneNumbers = contactsToSendArray
        NetworkingManager.findMemberProfiles(model: findMemberModel) {
            result, success in if let result = result as? FindMemberProfilesResponseModel, success {
                if result.status == "Success" {
                    var uploadContacts = [ProfileTable]()

                    if let profiles: [FindProfileModel] = result.data {
                        print(result)

                        for profile in profiles {
                            if self.contactsToSendArray.first(where: { (contactsProfile) -> Bool in
                                contactsProfile.phoneNumber == profile.phoneNumber
                            }) != nil {
                                let uContacts = ProfileTable()
                                uContacts.phoneNumber = profile.phoneNumber ?? ""
//                            contacts.fullName = profile.fullName ?? "" to be added a new coloumn
                                uContacts.nickName = profile.nickName ?? ""
                                uContacts.countryCode = profile.countryCode ?? ""
                                uContacts.dateOfBirth = profile.dateOfBirth ?? ""
                                uContacts.globalUserId = profile.globalUserId ?? ""
                                uContacts.emailId = profile.emailId ?? ""
                                uContacts.isoCode = profile.countryIsoCode ?? ""
                                uContacts.picture = profile.picture ?? ""
                                uContacts.deviceApnType = profile.deviceApnType ?? ""
                                uContacts.deviceApn = profile.deviceApn ?? ""
                                uContacts.isMember = true
                                uContacts.id = profile.contactId ?? ""
                                uContacts.isAnonymus = false

                                uploadContacts.append(uContacts)

                            } else {
                                print("Error in storing contacts in DataBase")
                            }
                        }
                    }
                    DatabaseManager.updateContactsFromServerToDb(profileTables: uploadContacts)
                    completionHandler(true)
                }
            }
        }
    }

    func mapExistingContacts(notifyStatus: Bool, completionHandler: @escaping CompletionHandler) {
        let findMemberModel = FindMemberProfileRequestModel()

        findMemberModel.notifyFriend = notifyStatus
        findMemberModel.auth = DefaultDataProcessor().getAuthDetails()
        findMemberModel.phoneNumbers = contactsToSendArray
        NetworkingManager.findMemberProfiles(model: findMemberModel) {
            result, success in if let result = result as? FindMemberProfilesResponseModel, success {
                if result.status == "Success" {
                    if let profiles: [FindProfileModel] = result.data {
                        print(result)
                        self.mapDataValues(profiles: profiles)
                    }
                    completionHandler(true)

                } else {
                    Loader.close()
                    if result.status == "Exception" {
                        let errorMsg = result.errorMsg[0]
                        if errorMsg == "IU-100" || errorMsg == "AUT-101" {
                            self.gotohomePagefromobject()
                        }
                    }
                }
            }
        }
    }

    func mapDataValues(profiles: [FindProfileModel]) {
        for profile in profiles {
            let containsNumber = finalContactsFromDB.filter { $0.globalUserId == profile.globalUserId }

            if containsNumber.count > 0 {
                // global id available check phone number

                if containsNumber[0].phoneNumber == profile.phoneNumber {
                    let uContacts = ProfileTable()

                    uContacts.phoneNumber = profile.phoneNumber ?? ""
                    uContacts.nickName = profile.nickName ?? ""
                    uContacts.countryCode = profile.countryCode ?? ""
                    uContacts.dateOfBirth = profile.dateOfBirth ?? ""
                    uContacts.globalUserId = profile.globalUserId ?? ""
                    uContacts.emailId = profile.emailId ?? ""
                    uContacts.isoCode = profile.countryIsoCode ?? ""
                    uContacts.picture = profile.picture ?? ""
                    uContacts.deviceApnType = profile.deviceApnType ?? ""
                    uContacts.deviceApn = profile.deviceApn ?? ""
                    uContacts.isMember = true
                    uContacts.id = profile.contactId ?? ""
                    uContacts.userstatus = profile.userStatus ?? ""
                    uContacts.isAnonymus = false

                    DatabaseManager.updateContactsFromServerToDb(profileTables: [uContacts])
                } else {
                    let uContacts = ProfileTable()

                    uContacts.phoneNumber = profile.phoneNumber ?? ""
                    uContacts.nickName = profile.nickName ?? ""
                    uContacts.countryCode = profile.countryCode ?? ""
                    uContacts.dateOfBirth = profile.dateOfBirth ?? ""
                    uContacts.globalUserId = profile.globalUserId ?? ""
                    uContacts.emailId = profile.emailId ?? ""
                    uContacts.isoCode = profile.countryIsoCode ?? ""
                    uContacts.picture = profile.picture ?? ""
                    uContacts.deviceApnType = profile.deviceApnType ?? ""
                    uContacts.deviceApn = profile.deviceApn ?? ""
                    uContacts.isMember = true
                    uContacts.id = containsNumber[0].id
                    uContacts.userstatus = profile.userStatus ?? ""
                    uContacts.isAnonymus = false

                    DatabaseManager.updateContactsFromServerToDb(profileTables: [uContacts])

                    let numberMatch = finalContactsFromDB.filter { $0.phoneNumber == profile.phoneNumber }
                    if numberMatch.count > 0 {
                        let uContacts = ProfileTable()
                        uContacts.id = numberMatch[0].id
                        uContacts.userstatus = "0"
                        DatabaseManager.updateProfileUserStatus(profile: uContacts)
                    }
                }

            } else {
                // global id not in list
                let numberMatch = finalContactsFromDB.filter { $0.phoneNumber == profile.phoneNumber }
                if numberMatch.count > 0 {
                    let uContacts = ProfileTable()

                    uContacts.phoneNumber = profile.phoneNumber ?? ""
                    uContacts.nickName = profile.nickName ?? ""
                    uContacts.countryCode = profile.countryCode ?? ""
                    uContacts.dateOfBirth = profile.dateOfBirth ?? ""
                    uContacts.globalUserId = profile.globalUserId ?? ""
                    uContacts.emailId = profile.emailId ?? ""
                    uContacts.isoCode = profile.countryIsoCode ?? ""
                    uContacts.picture = profile.picture ?? ""
                    uContacts.deviceApnType = profile.deviceApnType ?? ""
                    uContacts.deviceApn = profile.deviceApn ?? ""
                    uContacts.isMember = true
                    uContacts.id = profile.contactId ?? ""
                    uContacts.userstatus = profile.userStatus ?? ""
                    uContacts.isAnonymus = false

                    DatabaseManager.updateContactsFromServerToDb(profileTables: [uContacts])
                }
            }
        }
    }

    private func populateContactsDatabase() {
        let contactsArr = DatabaseManager.getContactsForSync() ?? []
        for profile in contactsArr {
            let contactToInsert = ACContactsObject(phoneNumber: profile.phoneNumber, name: profile.fullName, status: ContactSyncStatus.NO_Action, globalId: profile.globalUserId)
            databaseContactsArray.append(contactToInsert)
        }
        if databaseContactsArray.count == 0 {
            databaseContactsArray = [ACContactsObject]()
        }
    }

    private func populateDatabaseTosendtoServer() {
        contactsToSendArray = DatabaseManager.getContactsForUpload() ?? []
    }

    private func populateExistingDatabaseTosendtoServer() {
        contactsToSendArray = DatabaseManager.getContactsForUpload() ?? []
        finalContactsFromDB = DatabaseManager.getContactsForSync() ?? []
    }

    private func fetchContactsFromPhoneContactBook() -> [ACContactsObject] {
        let key = [CNContactPhoneNumbersKey, CNContactIdentifierKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactImageDataKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: key)
        do {
            try contactsStore.enumerateContacts(with: request, usingBlock: { contact, _ in
                var contactNumber = contact.phoneNumbers.first?.value.stringValue.extStrippedSpecialCharactersFromNumbers
                let contactName = contact.givenName.trimmingCharacters(in: .whitespacesAndNewlines) + " " + contact.middleName.trimmingCharacters(in: .whitespacesAndNewlines) + " " + contact.familyName.trimmingCharacters(in: .whitespacesAndNewlines)

                if contactNumber == nil || contactNumber == "" || contactName.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    print("contact has no number or name")
                } else {
                    if contactNumber?.count == Int(self.length ?? "") {
                        contactNumber = (self.countyCode ?? "") + contactNumber!
                    }

                    if contactNumber != self.userNumber {
                        let containsNumber = self.databaseContactsArray.filter { $0.phoneNumber == contactNumber }

                        if containsNumber.count > 0 {
                            let dbcontact = containsNumber[0]
                            if dbcontact.globalId == "" {
                                if dbcontact.fullName.lowercased() != contactName.lowercased() {
                                    self.databaseContactsArray.remove(object: dbcontact)
                                    dbcontact.fullName = contactName
                                    dbcontact.syncStatus = ContactSyncStatus.UPDATE
                                    self.databaseContactsArray.append(dbcontact)
                                }
                            }

                        } else {
                            let contactToInsert = ACContactsObject(phoneNumber: contactNumber!, name: contactName, status: ContactSyncStatus.INSERT, globalId: "")
                            self.databaseContactsArray.append(contactToInsert)
                        }
                    }
                }

            })
        } catch {
            print("error in fetching Contacts")
        }
        return databaseContactsArray
    }

    func insertOrUpdateToDb(contacts: [ACContactsObject]) {
        let updateContactsArray = contacts.filter { $0.syncStatus == ContactSyncStatus.UPDATE }
        let insertContactsArray = contacts.filter { $0.syncStatus == ContactSyncStatus.INSERT }

        DatabaseManager.storeContacts(profileTables: insertContactsArray)
        DatabaseManager.UpdateContactsName(contacts: updateContactsArray)
    }

    func downloadImagesFromArray(downloadObjectArray: [MediaRefernceHolderObject]) {
        for downloadObject in downloadObjectArray {
            ACImageDownloader.downloadImage(downloadObject: downloadObject, completionHandler: { (success, path) -> Void in

                print(success)
                print(path)

            })
        }
    }
}
