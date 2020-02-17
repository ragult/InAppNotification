//
//  MediaprocessingObject.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 10/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit

class MediaProcessingObject: NSObject {
    var mediaUrl: String = ""
    var refernce: String = ""
    var jobType: downLoadType?

    init(mediaUrl: String, refernce: String, jobType: downLoadType) {
        self.mediaUrl = mediaUrl
        self.refernce = refernce
        self.jobType = jobType
    }
}
