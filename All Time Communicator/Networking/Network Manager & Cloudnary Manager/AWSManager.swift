//
//  AWSManager.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 22/04/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import AWSCore
import AWSS3

struct s3BucketName {
    // com.alltime.dev.

    static let baseBucketName = "com.alltime.dev."
    static let privateMediaBucket = baseBucketName + "pvt.chatmedia"
    static let privateProfileBucket = baseBucketName + "pvt.prof"
    static let publicMediaBucket = baseBucketName + "pub.chatmedia"
    static let publicProfileBucket = baseBucketName + "pub.prof"

    //    static let profileBucketName             =   "com.alltime.profiledev"
    //    static let chatBucketName               =    "com.alltime.chatdev"
    //    static let profileUserProfile            =   "profile/"
    //    static let profileGroupProfile           =   "groups/"
    static let mediaBucketImage = "image/"
    static let mediaBucketAudio = "audio/"
    static let mediaBucketVideo = "video/"

    static let albumFolder = "group/albums/"
    static let userProfFolder = "user/"
    static let grpProfFolder = "group/"

    static let imageType = "image/png"
    static let videoType = "video/mp4"
    static let audioType = "audio/mp3"
}

struct AWSConfigGenarator {
    var bucketName: String
    var fileName: String
    var folderName: String
    var type: String
    var isPublic: Bool
    var regionType: AWSRegionType = .APSouth1
    var isChat: Bool
    var isGroup : Bool

    var url: String {
        return bucketName + "/" + folderName + fileName
    }

    init(bucketName: String, fileName: String, folderName: String, type: String, regionType: AWSRegionType, isPublic: Bool, isChat: Bool, isGroup: Bool) {
        self.bucketName = bucketName
        self.isPublic = isPublic
        self.fileName = fileName
        self.folderName = folderName
        self.type = type
        self.regionType = regionType
        self.isChat = isChat
        self.isGroup = isGroup
    }
    
    mutating func updateValues() {
        if isChat {
            regionType = .APSouth1
            bucketName = isPublic ? s3BucketName.publicMediaBucket : s3BucketName.privateMediaBucket
            if type == s3BucketName.imageType {
                folderName = s3BucketName.mediaBucketImage
            } else if type == s3BucketName.videoType {
                folderName = s3BucketName.mediaBucketVideo
            } else if type == s3BucketName.audioType {
                folderName = s3BucketName.mediaBucketAudio
            }
        } else {
            regionType = .APSouth1
            bucketName = isPublic ? s3BucketName.publicProfileBucket : s3BucketName.privateProfileBucket
            folderName = (isGroup) ? s3BucketName.grpProfFolder : s3BucketName.userProfFolder
        }
    }
}
typealias downloadHandler = (Data?, Error?) -> Void
class AWSManager {
    class var accessKey: String {
        return UserDefaults.standard.string(forKey: UserKeys.serverAWSAccessKey) ?? ""
    }

    class var secretKey: String {
        return UserDefaults.standard.string(forKey: UserKeys.serverAWSSecretKey) ?? ""
    }

//    var s3accessKey = "AKIARHSB7LW45HOCFZ6D"
//    var s3secretKey = "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"

    class var instance: AWSManager {
        struct awsManagerObj {
            static let instance = AWSManager()
        }
        return awsManagerObj.instance
    }

    func isPublicType(gType: String) -> Bool {
        if gType == groupType.PUBLIC_GROUP.rawValue {
            return true
        }
        return false
    }

    func getConfig(gType: String, isChat: Bool, isProfile: Bool, isGroup: Bool? = false, fileName: String, type: String) -> (AWSConfigGenarator) {
        var bucketName = ""
        var folderName = ""
        let isPublic = isPublicType(gType: gType)
        var regionType: AWSRegionType = .APSouth1
        if isChat {
            regionType = .APSouth1
            bucketName = isPublic ? s3BucketName.publicMediaBucket : s3BucketName.privateMediaBucket
            if type == s3BucketName.imageType {
                folderName = s3BucketName.mediaBucketImage
            } else if type == s3BucketName.videoType {
                folderName = s3BucketName.mediaBucketVideo
            } else if type == s3BucketName.audioType {
                folderName = s3BucketName.mediaBucketAudio
            }
        } else {
            regionType = .APSouth1
            bucketName = isPublic ? s3BucketName.publicProfileBucket : s3BucketName.privateProfileBucket
            folderName = (isGroup ?? false) ? s3BucketName.grpProfFolder : s3BucketName.userProfFolder
        }
        return AWSConfigGenarator(bucketName: bucketName, fileName: fileName, folderName: folderName, type: type, regionType: regionType, isPublic: isPublic, isChat: isChat, isGroup: isGroup ?? false)
    }

    // used with chat bucket
    func uploadDataS3(config: AWSConfigGenarator, data: Data, completionHandler: @escaping (String, Error?) -> Void) {
        print("s3 url and regionType \(config.url) \(config.regionType)")
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: AWSManager.accessKey, secretKey: AWSManager.secretKey)
        let configuration: AWSServiceConfiguration = AWSServiceConfiguration(region: config.regionType, credentialsProvider: credentialsProvider)
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { _, progress in
            DispatchQueue.main.async {
                print(progress)
                //                progressHandler(progress)
            }
        }
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        AWSS3TransferUtility.default().uploadData(
            data as Data,
            bucket: config.bucketName,
            key: config.folderName + config.fileName,
            contentType: config.type,
            expression: expression
        ) { task, error in
            print("s3 result handler")
        }.continueOnSuccessWith { (task) -> Any? in
            print("s3 result suceess", task.result)
        }.continueWith { task -> AnyObject? in
            if let error = task.error {
                DispatchQueue.main.async {
                    print(error)
                    completionHandler("", error)
                    return
                }
            }
            print("s3 result", task.result)
            let url = AWSS3.default().configuration.endpoint.url
            print("s3 base url \(url)")
            let publicURL = url?.appendingPathComponent(config.bucketName).appendingPathComponent(config.folderName + config.fileName)
            if let absoluteString = publicURL?.absoluteString {
                // Set image with URL
                print("s3 Public Image URL : ", absoluteString)
                print("s3 Private Image URL : ", config.url)
                if config.isPublic {
                    completionHandler(absoluteString, nil)
                    return nil
                } else {
                    completionHandler(config.url, nil)
                    return nil
                }
            } else {
                completionHandler("", nil)
                return nil
            }
        }
    }

    func getDownloadConfig(fileName: String) -> (count: Int, path: String, S3BucketName: String, S3DownloadKeyName: String, isProfile: Bool) {
        var componentsArray = fileName.components(separatedBy: "/")
        let count = componentsArray.count
        if count > 2 {
            let path = componentsArray[0]
            componentsArray.remove(at: 0)
            let S3BucketName: String = path
            let S3DownloadKeyName: String = componentsArray.joined(separator: "/")
            return (count, path, S3BucketName, S3DownloadKeyName, path.contains(".prof"))
        }
        return (0, "", "", "", false)
    }
    
    func downloadImage(fileName: String, completionHandler: @escaping downloadHandler) {
        // downloading image
//        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,identityPoolId:"us-east-1:d3745f7f-087b-46a2-88fd-ccb3724e0056")
        let dConfig = getDownloadConfig(fileName: fileName)
        if dConfig.count > 2 {
            let expression = AWSS3TransferUtilityDownloadExpression()
            expression.progressBlock = { _, progress in
                DispatchQueue.main.async {
                    print(progress)
                    NSLog("Progress is: %f", progress)
                }
            }

            let credentialsProvider = AWSStaticCredentialsProvider(accessKey: AWSManager.accessKey, secretKey: AWSManager.secretKey)
            
            let configuration = AWSServiceConfiguration(region: dConfig.isProfile ? .APSouth1 : .APSouth1, credentialsProvider: credentialsProvider)
            
            AWSServiceManager.default().defaultServiceConfiguration = configuration

//            print("s3 isProfile: \(dConfig.isProfile)")
//            print("s3 filename: \(fileName)")
//            print("s3 S3BucketName: \(dConfig.S3BucketName)")
//            print("s3 S3DownloadKeyName: \(dConfig.S3DownloadKeyName)")

            let transferUtility = AWSS3TransferUtility.default()
            transferUtility.downloadData(fromBucket: dConfig.S3BucketName, key: dConfig.S3DownloadKeyName, expression: expression) { _, _, data, error in

                if error != nil {
                    print("s3 error \(error!)")
                    completionHandler(data, error)

                    return
                }
                DispatchQueue.main.async(execute: {
                    print("s3 success Got here")
                    completionHandler(data, error)

                })
            }
//            }
        }
    }
}

func getContentType(fileExtension: String) -> String {
    var contentType = ""

    var fextension = fileExtension.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    switch fextension {
        case ".m4a":
            contentType = "audio/m4a"
        case "mp3":
            contentType = "audio/mp3"
        case "mp4":
            contentType = "video/mp4"
        case "bmp":
            contentType = "image/bmp"
        case "jpeg":
            contentType = "image/jpeg"
        case "jpg":
            contentType = "image/jpg"
        case "gif":
            contentType = "image/gif"
        case "tiff":
            contentType = "image/tiff"
        case "png":
            contentType = "image/png"
        case "plain":
            contentType = "text/plain"
        case "rtf":
            contentType = "text/rtf"
        case "msword":
            contentType = "application/msword"
        case "zip":
            contentType = "application/zip"
        case "mpeg":
            contentType = "audio/mpeg"
        case "pdf":
            contentType = "application/pdf"
        case "xgzip":
            contentType = "application/x-gzip"
        case "xcompressed":
            contentType = "application/x-compressed"
        default:
            contentType = "image/jpeg"
    }
    return contentType
}
