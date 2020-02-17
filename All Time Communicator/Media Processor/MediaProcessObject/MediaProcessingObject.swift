//
//  MediaprocessingObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 10/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

public enum downLoadType: String {
    case profile
    case group
    case groupMember
    case media
}

public enum mediaDownloadType: String {
    case TEXT = "1"
    case image = "2"
    case video = "4"
    case audio = "3"
}

class MediaRefernceHolderObject: NSObject {
    var mediaUrl: URL?
    var refernce: String = ""
    var jobType: downLoadType?
    var mediaType: String = ""
    var mediaExtension: String = ""

    init(mediaUrl: String, refernce: String, jobType: downLoadType, mediaType: String, mediaExtension: String) {
        self.mediaUrl = NSURL(string: mediaUrl)! as URL
        self.refernce = refernce
        self.jobType = jobType
        self.mediaType = mediaType
        self.mediaExtension = mediaExtension
    }
}
