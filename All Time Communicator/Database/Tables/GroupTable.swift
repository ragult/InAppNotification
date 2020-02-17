//
//  groupTable.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 21/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class GroupTable: EVNetworkingObject, Codable, FetchableRecord, TableRecord, PersistableRecord {
    var id: String = ""
    var groupGlobalId: String = ""
    var groupType: String = ""
    var groupName: String = ""
    var groupDescription: String = ""
    var confidentialFlag: String = ""
    var fullImageUrl: String = ""
    var localImagePath: String = ""
    var thumbnailUrl: String = ""
    var groupStatus: String = ""
    var createdOn: String = ""
    var createdBy: String = ""
    var createdByThumbnailUrl: String = ""
    var createdByMobileNumber: String = ""
    var lastConfirmId: String = ""
    var uniqueRef: String = ""
    var coordinates: String = ""
    var mapLocationId: String = ""
    var mapServiceProvider: String = ""
    var qrURL: String = ""
    var address: String = ""
    var qrCode: String = ""
    var localQrcode: String = ""
    var publicGroupCode: String = ""
    var groupCode: String = ""
    var webUrl: String = ""
    var groupPublicId: String = ""

    //to be refactractored and removed
//        var groupMembers = [GroupMemberTable]()

    func loadValues(result: GroupTable) {
        id = result.id
        groupGlobalId = result.groupGlobalId
        groupType = result.groupType
        groupName = result.groupName
        groupDescription = result.groupDescription
        confidentialFlag = result.confidentialFlag
        fullImageUrl = result.fullImageUrl
        thumbnailUrl = result.thumbnailUrl
        groupStatus = result.groupStatus
        createdBy = result.createdBy
        createdOn = result.createdOn
        createdByThumbnailUrl = result.createdByThumbnailUrl
        createdByMobileNumber = result.createdByMobileNumber
        address = result.address
        qrCode = result.qrCode
        localQrcode = result.localQrcode
        publicGroupCode = result.publicGroupCode
        groupCode = result.groupCode
        webUrl = result.webUrl
        groupPublicId = result.groupPublicId
//    self.groupMembers = result.groupMembers
    }

    internal enum Columns: String, ColumnExpression {
        case id
        case groupGlobalId
        case groupName
        case groupType
        case groupDescription
        case confidentialFlag
        case fullImageUrl
        case thumbnailUrl
        case groupStatus
        case createdOn
        case createdBy
        case createdByThumbnailUrl
        case createdByMobileNumber
        case localImagePath
        case lastConfirmId
        case uniqueRef
        case coordinates
        case mapLocationId
        case mapServiceProvider
        case qrURL
        case address
        case qrCode
        case localQrcode
        case publicGroupCode
        case webUrl
        case groupCode
        case groupPublicId
//        case groupMembers
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.id.name, .integer).primaryKey(onConflict: .ignore, autoincrement: true)
        tableDefinition.column(Columns.groupGlobalId.name, .text)
        tableDefinition.column(Columns.groupName.name, .text)
        tableDefinition.column(Columns.groupType.name, .text)
        tableDefinition.column(Columns.groupDescription.name, .text)
        tableDefinition.column(Columns.confidentialFlag.name, .text)
        tableDefinition.column(Columns.fullImageUrl.name, .text)
        tableDefinition.column(Columns.thumbnailUrl.name, .text)
        tableDefinition.column(Columns.groupStatus.name, .text)
        tableDefinition.column(Columns.createdBy.name, .text)
        tableDefinition.column(Columns.createdOn.name, .text)
        tableDefinition.column(Columns.createdByMobileNumber.name, .text)
        tableDefinition.column(Columns.createdByThumbnailUrl.name, .text)
        tableDefinition.column(Columns.localImagePath.name, .text)
        tableDefinition.column(Columns.uniqueRef.name, .text)
        tableDefinition.column(Columns.lastConfirmId.name, .text)
        tableDefinition.column(Columns.coordinates.name, .text)
        tableDefinition.column(Columns.mapLocationId.name, .text)
        tableDefinition.column(Columns.mapServiceProvider.name, .text)
        tableDefinition.column(Columns.qrURL.name, .text)
        tableDefinition.column(Columns.address.name, .text)
        tableDefinition.column(Columns.qrCode.name, .text)
        tableDefinition.column(Columns.publicGroupCode.name, .text)
        tableDefinition.column(Columns.webUrl.name, .text)
        tableDefinition.column(Columns.groupCode.name, .text)
        tableDefinition.column(Columns.localQrcode.name, .text)
        tableDefinition.column(Columns.groupPublicId.name, .text)
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("groupGlobalId", "groupId"), ("groupName", "name"), ("phoneNumber", "mobileNo"), ("groupStatus", "status"), ("groupDescription", "description"), ("createdByThumbnailUrl", "createdByThumbUrl"), ("createdByMobileNumber", "createdByMobileNo"), ("groupType", "type")]
    }

    //
}
