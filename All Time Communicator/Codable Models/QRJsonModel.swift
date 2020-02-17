//
//  QRJsonModel.swift
//  alltimecommunicator
//
//  Created by Ragul kts on 21/01/20.
//  Copyright © 2020 Droid5. All rights reserved.
//

import Foundation
struct QrJSONData: Codable {
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let objType, objVer: String
    let objData: ObjData
}

// MARK: - ObjData
struct ObjData: Codable {
    let entity: Entity?
    let webData: WebData?
    var st: String?
}

// MARK: - Entity
struct Entity: Codable {
    let name, type, services: String
}

// MARK: - WebData
struct WebData: Codable {
    let pubid, pubtyp: String?
}
