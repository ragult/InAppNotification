//
//  ContactTable.swift
//  alltimecommunicator
//
//  Created by Droid5 on 12/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB
class ProfileTable: EVNetworkingObject, Codable, FetchableRecord, TableRecord, PersistableRecord {
    var id: String = ""
    var nickName: String = ""
    var fullName: String = ""
    var dateOfBirth: String = ""
    var picture: String = ""
    var localImageFilePath: String = ""
    var phoneNumber: String = ""
    var emailId: String = ""
    var isoCode: String = ""
    var globalUserId: String = ""
    var countryCode: String = ""
    var contactId: String = ""
    var deviceApn: String = ""
    var deviceApnType: String = ""
    var selected: Bool = false
    var isMember: Bool = false
    var userstatus: String = ""
    var isAnonymus: Bool = false
    var userQrcode: String = ""
    var localQrcode: String = ""

    internal enum Columns: String, ColumnExpression {
        case id
        case nickName
        case fullName
        case dateOfBirth
        case picture
        case phoneNumber
        case emailId
        case isoCode
        case countryCode
        case globalUserId
        case contactId
        case deviceApn
        case deviceApnType
        case isMember
        case selected
        case localImageFilePath
        case userstatus
        case isAnonymus
        case userQrcode
        case localQrcode
    }

    convenience init(phoneNumber: String, countyCode: String, fullName: String) {
        self.init()
        self.phoneNumber = phoneNumber
        countryCode = countyCode
        self.fullName = fullName
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.id.name, .integer).primaryKey(onConflict: .ignore, autoincrement: true)
        tableDefinition.column(Columns.phoneNumber.name, .text)
        tableDefinition.column(Columns.contactId.name, .text)
        tableDefinition.column(Columns.fullName.name, .text)
        tableDefinition.column(Columns.nickName.name, .text)
        tableDefinition.column(Columns.dateOfBirth.name, .text)
        tableDefinition.column(Columns.picture.name, .text)
        tableDefinition.column(Columns.emailId.name, .text)
        tableDefinition.column(Columns.isoCode.name, .text)
        tableDefinition.column(Columns.countryCode.name, .text)
        tableDefinition.column(Columns.globalUserId.name, .text)
        tableDefinition.column(Columns.deviceApn.name, .text)
        tableDefinition.column(Columns.deviceApnType.name, .text)
        tableDefinition.column(Columns.isMember.name, .boolean)
        tableDefinition.column(Columns.selected.name, .boolean)
        tableDefinition.column(Columns.localImageFilePath.name, .text)
        tableDefinition.column(Columns.userstatus.name, .text)
        tableDefinition.column(Columns.isAnonymus.name, .boolean)
        tableDefinition.column(Columns.userQrcode.name, .text).notNull()
        tableDefinition.column(Columns.localQrcode.name, .text)
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
//        ("propertyName", nil) for ignoring
        return [("phoneNumber", "ph_no"), ("contactId", "contact_id"), ("nickName", nil), ("fullName", nil), ("dateOfBirth", nil), ("picture", "picture"), ("emailId", nil), ("isoCode", nil), ("countryCode", nil), ("globalUserId", nil), ("phoneNumber2", nil), ("existingUser", nil), ("selected", nil), ("deviceApn", nil), ("deviceApnType", nil), ("userstatus", "status")]
    }
}
