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

class UserModel: EVNetworkingObject, Codable, FetchableRecord, TableRecord, PersistableRecord {
    var countryCode: String = ""
    var countryISOCode: String = ""
    var tokenIdentifier: String = ""
    var monthYearOfBirth: String = ""
    var picture: String = ""
    var deviceImei: String = ""
    var deviceApn: String = ""
    var deviceApnType: String = ""
    var qrUrl: String = ""
    var registerType: String = ""
    var emailId: String = ""
    var city: String = ""
    var zipCode: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var deviceMake: String = ""
    var mobileServiceProvider: String = ""
    var emailPassword: String = ""
    var nickName: String = ""
    var fullName: String = ""
    var dateofBirth: String = ""
    var gender: String = ""
    var isServiceProvider: String = ""
    var serviceType: String = ""
    var searchTerms: String = ""
    var serviceLocalities: String = ""
    var serviceCity: String = ""
    var securityCode = ""
    var globalUserId = ""
    var phoneNumber = ""
    var userQrcode = ""
    var localQrcode = ""
    var localImageFilePath: String = ""

    internal enum Columns: String, ColumnExpression {
        case countryCode
        case countryISOCode
        case tokenIdentifier
        case monthYearOfBirth
        case picture
        case deviceImei
        case deviceApn
        case deviceApnType
        case qrUrl
        case registerType
        case emailId
        case city
        case zipCode
        case latitude
        case longitude
        case deviceMake
        case mobileServiceProvider
        case emailPassword
        case nickName
        case fullName
        case dateofBirth
        case gender
        case isServiceProvider
        case serviceType
        case searchTerms
        case serviceLocalities
        case serviceCity
        case securityCode
        case globalUserId
        case phoneNumber
        case userQrcode
        case localQrcode
        case localImageFilePath
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.countryCode.name, .text)
        tableDefinition.column(Columns.countryISOCode.name, .text)
        tableDefinition.column(Columns.tokenIdentifier.name, .text)
        tableDefinition.column(Columns.monthYearOfBirth.name, .text)
        tableDefinition.column(Columns.picture.name, .text)
        tableDefinition.column(Columns.dateofBirth.name, .text)
        tableDefinition.column(Columns.deviceImei.name, .text)
        tableDefinition.column(Columns.deviceApn.name, .text)
        tableDefinition.column(Columns.deviceApnType.name, .text)
        tableDefinition.column(Columns.qrUrl.name, .text)
        tableDefinition.column(Columns.registerType.name, .text)
        tableDefinition.column(Columns.emailId.name, .text)
        tableDefinition.column(Columns.city.name, .text)
        tableDefinition.column(Columns.zipCode.name, .text)
        tableDefinition.column(Columns.latitude.name, .numeric)
        tableDefinition.column(Columns.longitude.name, .numeric)
        tableDefinition.column(Columns.deviceMake.name, .text)
        tableDefinition.column(Columns.mobileServiceProvider.name, .text)
        tableDefinition.column(Columns.emailPassword.name, .text)
        tableDefinition.column(Columns.nickName.name, .text)
        tableDefinition.column(Columns.fullName.name, .text)
        tableDefinition.column(Columns.gender.name, .text)
        tableDefinition.column(Columns.isServiceProvider.name, .text)
        tableDefinition.column(Columns.serviceType.name, .text)
        tableDefinition.column(Columns.searchTerms.name, .text)
        tableDefinition.column(Columns.serviceLocalities.name, .text)
        tableDefinition.column(Columns.serviceCity.name, .text)
        tableDefinition.column(Columns.securityCode.name, .text)
        tableDefinition.column(Columns.globalUserId.name, .text)
        tableDefinition.column(Columns.phoneNumber.name, .text).primaryKey()
        tableDefinition.column(Columns.userQrcode.name, .text).notNull()
        tableDefinition.column(Columns.localQrcode.name, .text)
        tableDefinition.column(Columns.localImageFilePath.name, .text)
    }
}
