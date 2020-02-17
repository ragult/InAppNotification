//
//  GroupMemberTable.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 21/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection
import Foundation
import GRDB

class GroupMemberTable: EVNetworkingObject, Codable, PersistableRecord, TableRecord, FetchableRecord {
    var groupMemberId: String = ""
    var groupId: String = ""
    var groupMemberContactId: String = ""
    var memberTitle: String = ""
    var memberName: String = ""
    var globalUserId: String = ""
    var phoneNumber: String = ""
    var thumbUrl: String = ""
    var localImagePath: String = ""

    var memberStatus: String = "1"
    var createdOn: String = ""
    var createdBy: String = ""
    var superAdmin: Bool = false
    var publish: Bool = false
    var events: Bool = false
    var album: Bool = false
    var addMember: Bool = false
    var publicView: Bool = false

    func loadValues(result: GroupMemberModel) {
        groupId = result.groupId ?? ""
//        self.groupMemberContactId = result.groupMemberContactId ?? ""
        memberTitle = result.memberTitle ?? ""
        memberName = result.memberName ?? ""
        globalUserId = result.globalUserId ?? ""
        phoneNumber = result.phoneNumber ?? ""
        thumbUrl = result.thumbUrl ?? ""
        publish = result.publish?.bool ?? false
        events = result.events?.bool ?? false
        album = result.album?.bool ?? false
        addMember = result.addMember?.bool ?? false
        superAdmin = result.superAdmin?.bool ?? false
        memberStatus = result.memberStatus ?? ""
        createdBy = result.createdBy ?? ""
        createdOn = result.createdOn ?? ""
    }

    internal enum Columns: String, ColumnExpression {
        case groupMemberId
        case groupId
        case memberTitle
        case memberName
        case globalUserId
        case phoneNumber
        case thumbUrl
        case publish
        case events
        case album
        case addMember
        case memberStatus
        case createdOn
        case createdBy
        case superAdmin
        case groupMemberContactId
        case localImagePath
        case publicView
    }

    internal static func defineTableDefinition(tableDefinition: TableDefinition) {
        tableDefinition.column(Columns.groupMemberId.name, .integer).primaryKey(onConflict: .replace, autoincrement: true)
        tableDefinition.column(Columns.groupId.name, .text)
        tableDefinition.column(Columns.memberTitle.name, .text)
        tableDefinition.column(Columns.memberName.name, .text)
        tableDefinition.column(Columns.globalUserId.name, .text)
        tableDefinition.column(Columns.phoneNumber.name, .text)
        tableDefinition.column(Columns.thumbUrl.name, .text)
        tableDefinition.column(Columns.publish.name, .text)
        tableDefinition.column(Columns.events.name, .text)
        tableDefinition.column(Columns.album.name, .text)
        tableDefinition.column(Columns.addMember.name, .boolean)
        tableDefinition.column(Columns.superAdmin.name, .boolean)
        tableDefinition.column(Columns.publicView.name, .boolean)
        tableDefinition.column(Columns.memberStatus.name, .text)
        tableDefinition.column(Columns.createdOn.name, .text)
        tableDefinition.column(Columns.createdBy.name, .text)
        tableDefinition.column(Columns.groupMemberContactId.name, .text)
        tableDefinition.column(Columns.localImagePath.name, .text)
    }

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [("memberName", "name"), ("phoneNumber", "mobileNo"), ("memberStatus", "status"), ("publicView", "public")]
    }
}
