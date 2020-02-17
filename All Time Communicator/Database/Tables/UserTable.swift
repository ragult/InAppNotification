//
import EVReflection
import Foundation
//  UserModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 06/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//
import GRDB

let tableName = "user"

class UserModel: EVNetworkingObject, Codable, FetchableRecord, TableRecord, PersistableRecord {
    var nickName: String?
    var fullName: String?
    var monthYearOfBirth: String?
    var dateOfBirth: String?
    var picture: String?
    var logo: String?
    var phoneNumber: String?
    var registerType: String?
    var emailId: String?
    var emailPassword: String?
    var city: String?
    var countryPhoneCode: String?
    var countryIsoCode: String?
    var zipCode: String?
    var latitude: String?
    var longitude: String?
    var tokenIdentifier: String?
    var deviceImei: String?
    var deviceMake: String?
    var mobileServiceProvider: String?
    var searchTerms: String?
    var phoneNumberLength: Int?
}

// extension UserTable: EVCustomReflectable {
//    static func constructWith(value: Any?) -> EVCustomReflectable? {
//        print("value: \(String(describing: value))")
//        return UserTable()
//    }
//
//    func constructWith(value: Any?) -> EVCustomReflectable? {
//        print("value: \(String(describing: value))")
//        return UserTable()
//    }
//
//    func toCodableValue() -> Any {
//        print("self: \(self)")
//        return tableName
//    }
//
//    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
//        return [("countryIsoCode", "country"), ("countryPhoneCode", "countryCode"), ("securityCode", nil), ("globalUserId", nil), ("phoneNumberLength", nil)]
//    }
// }
