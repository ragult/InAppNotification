//
//  MediaUploadObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 21/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class MediaUploadObject: NSObject {
    var localImagePath: String?
    var imageName: String?
    var imageData: Data?
    var status: Bool = false
    var mediaType: mediaDownloadType = mediaDownloadType.image
    var msgType: messagetype = messagetype.IMAGE
    var actualImageData: Any?
    var messageTextString: String = ""
    var uniqueId: String = ""

    init(path: String, name: String, imgData: Data, mediaTyp: messagetype) {
        super.init()
        localImagePath = path
        imageName = name
        imageData = imgData
        msgType = mediaTyp
    }
}
