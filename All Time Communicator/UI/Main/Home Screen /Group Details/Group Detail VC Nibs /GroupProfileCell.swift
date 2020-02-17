//
//  GroupProfileCell.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 27/11/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class GroupProfileCell: UITableViewCell {
    @IBOutlet var groupImage: UIImageView!
    @IBOutlet var groupName: UILabel!
    @IBOutlet var confidentialFlag: UILabel!
    @IBOutlet var groupEditButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setGroupProfileData(groupDetails: GroupTable, groupAllMembersList : [GroupMemberTable], setLocalPath: ((String) -> Void)?,loadImage: ((String) -> Void)?) {
        self.isUserInteractionEnabled = true
        self.selectionStyle = .none
        if groupDetails.localImagePath == "" {
            if groupDetails.fullImageUrl != "" {
                let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: groupDetails.fullImageUrl, refernce: groupDetails.id, jobType: downLoadType.media, mediaType: mediaDownloadType.image.rawValue, mediaExtension: "")
                DispatchQueue.global(qos: .background).async {
                    ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (_, path) -> Void in
                        DatabaseManager.updateGroupLocalImagePath(localImagePath: path, localId: groupDetails.id)
                        setLocalPath?(path)
                        DispatchQueue.main.async { () in
                            loadImage?(groupDetails.localImagePath)
                        }
                    })
                }
            }
        } else {
            loadImage?(groupDetails.localImagePath)
        }
        
        if groupDetails.groupDescription == "" {
            self.confidentialFlag.text = ""
        } else {
            self.confidentialFlag.text = groupDetails.groupDescription
        }
        
        self.groupEditButton.isHidden = true
        self.groupName.text = groupDetails.groupName
    }
}
