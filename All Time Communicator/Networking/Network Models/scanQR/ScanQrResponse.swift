//
//  ScanQrResponse.swift
//  alltimecommunicator
//
//  Created by Lokesh on 12/31/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Foundation
import EVReflection

class ScanQrResponse : EVNetworkingObject {
    var data: ScanQrData?
}

class ScanQrData: EVNetworkingObject {
    var objType: String = ""
    var objVer: String = ""
    var objData: ScanObjData?
}

class ScanObjData: EVNetworkingObject {
    var entity: ScanEntity?
    var webData: ScanWebData?
}

class ScanEntity: EVNetworkingObject {
    var name: String = ""
    var type: String = ""
    var services: String = ""
}

class ScanWebData: EVNetworkingObject {
    var pubid: String = ""
    var pubtyp: String = ""
}
