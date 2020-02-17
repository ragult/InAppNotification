//
//  ACImageDownloadHelper.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 10/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Alamofire
import Foundation

//let destination = DownloadRequest.suggestedDownloadDestination()
extension Alamofire.DownloadRequest {
    open class func suggestedDownloadDestination(
        for directory: FileManager.SearchPathDirectory = .documentDirectory,
        in domain: FileManager.SearchPathDomainMask = .userDomainMask,
        with options: DownloadOptions)
        -> DownloadFileDestination
    {
        return { temporaryURL, response in
            let destination = DownloadRequest.suggestedDownloadDestination(for: directory, in: domain)(temporaryURL, response)
            return (destination.destinationURL, options)
        }
    }
}

let destination: DownloadRequest.DownloadFileDestination = { temporaryURL, response in
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename ?? "")
    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
}

//let destination =  DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory, in: .userDomainMask, with: [.removePreviousFile, .createIntermediateDirectories])

class ACImageDownloader {
    typealias CompletionHandler = (_ success: MediaRefernceHolderObject, _ path: String) -> Void

    typealias incomingCompletionHandler = (_ success: MediaRefernceHolderObject, _ path: String, _ messageObj: MessagesTable) -> Void

    typealias incomingPollCompletionHandler = (_ success: MediaRefernceHolderObject, _ path: String, _ pollId: String, _ messageObj: MessagesTable) -> Void

    static func checkPublicImage(url: String) -> Bool {
        return url.contains("http")
    }

    class func downloadPublicImage(url: String, completionHandler: @escaping downloadHandler) {
        print("s3 alternate \(url)")
//        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
//            if error != nil {
//                print(error!)
//                return
//            }
//            DispatchQueue.main.async {
//                completionHandler(data!, nil)
//            }
//        }).resume()
        Alamofire.download(url, to: destination).responseData(completionHandler: { (response) in
            completionHandler(response.value, nil)
        })
    }

    class func handleDownloadImageForIncomingMessages(downloadObject: MediaRefernceHolderObject,
                                                      imageData: Data,
                                                      message: MessagesTable,
                                                      completionHandler: @escaping incomingCompletionHandler) {
        print("Download Finished")
        let timestamp = NSDate().timeIntervalSince1970 * 10_000_000
        let finalTS = String(format: "%.0f", timestamp)

        if downloadObject.mediaType == mediaDownloadType.video.rawValue {
            _ = ACImageDownloader.saveImageDocumentDirectory(attachData: imageData,
                                                             attachName: finalTS,
                                                             downloadtype: downloadObject.jobType!,
                                                             extn: ".png")

            let msg = message
            DatabaseManager.updateMessageTableForOtherColoumn(imageData: finalTS + ".png", localId: msg.id)
            msg.other = finalTS + ".png"

            completionHandler(downloadObject, finalTS + ".png", msg)

        } else if downloadObject.mediaType == mediaDownloadType.audio.rawValue {
            _ = ACImageDownloader.saveImageDocumentDirectory(attachData: imageData,
                                                             attachName: finalTS,
                                                             downloadtype: downloadObject.jobType!,
                                                             extn: ".m4a")

            let msg = message
            DatabaseManager.updateMessageTableForLocalImage(localImagePath: finalTS, localId: msg.id)
            msg.media = finalTS

            completionHandler(downloadObject, finalTS, msg)

        } else {
            _ = ACImageDownloader.saveImageDocumentDirectory(attachData: imageData,
                                                             attachName: finalTS,
                                                             downloadtype: downloadObject.jobType!,
                                                             extn: ".png")
            let msg = message
            DatabaseManager.updateMessageTableForLocalImage(localImagePath: finalTS + ".png", localId: msg.id)
            msg.media = finalTS + ".png"

            completionHandler(downloadObject, finalTS + ".png", msg)
        }
    }

    static func downloadImageForIncomingMessages(downloadObject: MediaRefernceHolderObject,
                                                 message: MessagesTable, completionHandler: @escaping incomingCompletionHandler) {
        print("Download Started")
        if let obj = downloadObject.mediaUrl, checkPublicImage(url: obj.absoluteString) {
            ACImageDownloader.downloadPublicImage(url: obj.absoluteString, completionHandler: { data, error in
                guard let imageData = data, error == nil else { return }
                ACImageDownloader.handleDownloadImageForIncomingMessages(downloadObject: downloadObject,
                                                                         imageData: imageData,
                                                                         message: message,
                                                                         completionHandler: completionHandler)
            })
        } else {
            AWSManager.instance.downloadImage(fileName: String(describing: downloadObject.mediaUrl!), completionHandler: { data, error in
                guard let imageData = data, error == nil else { return }
                ACImageDownloader.handleDownloadImageForIncomingMessages(downloadObject: downloadObject,
                                                                         imageData: imageData,
                                                                         message: message,
                                                                         completionHandler: completionHandler)
            })
        }
    }

    static func handleDownloadImageForMediaIncomingMessages(downloadObject: MediaRefernceHolderObject,
                                                            imageData: Data,
                                                            message: MessagesTable,
                                                            completionHandler: @escaping incomingCompletionHandler) {
        print("Download Finished")
        let timestamp = NSDate().timeIntervalSince1970 * 10_000_000
        let finalTS = String(format: "%.0f", timestamp)
        if downloadObject.mediaType == mediaDownloadType.video.rawValue {
            _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".png")

            completionHandler(downloadObject, finalTS + ".png", message)

        } else if downloadObject.mediaType == mediaDownloadType.audio.rawValue {
            _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".m4a")

            let msg = message

            completionHandler(downloadObject, finalTS, msg)

        } else {
            _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".png")
            let msg = message

            completionHandler(downloadObject, finalTS + ".png", msg)
        }
    }

    static func downloadImageForMediaIncomingMessages(downloadObject: MediaRefernceHolderObject, message: MessagesTable, completionHandler: @escaping incomingCompletionHandler) {
        print("Download Started")
        if let obj = downloadObject.mediaUrl, checkPublicImage(url: obj.absoluteString) {
            ACImageDownloader.downloadPublicImage(url: obj.absoluteString, completionHandler: { data, error in
                guard let imageData = data, error == nil else { return }
                ACImageDownloader.handleDownloadImageForMediaIncomingMessages(downloadObject: downloadObject,
                                                                              imageData: imageData,
                                                                              message: message,
                                                                              completionHandler: completionHandler)
            })
        } else {
            AWSManager.instance.downloadImage(fileName: String(describing: downloadObject.mediaUrl!), completionHandler: { data, error in
                guard let imageData = data, error == nil else { return }
                ACImageDownloader.handleDownloadImageForMediaIncomingMessages(downloadObject: downloadObject,
                                                                              imageData: imageData,
                                                                              message: message,
                                                                              completionHandler: completionHandler)
            })
        }
    }

    static func handleDownloadImageForPollIncomingMessages(downloadObject: MediaRefernceHolderObject,
                                                           imageData: Data,
                                                           pollId: String,
                                                           messageObj: MessagesTable,
                                                           completionHandler: @escaping incomingPollCompletionHandler) {
        print("Download Finished")
        let timestamp = NSDate().timeIntervalSince1970 * 10_000_000
        let finalTS = String(format: "%.0f", timestamp)

        if downloadObject.mediaType == mediaDownloadType.video.rawValue {
            _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".png")

            completionHandler(downloadObject, finalTS + ".png", pollId, messageObj)

        } else if downloadObject.mediaType == mediaDownloadType.audio.rawValue {
            _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".m4a")

            completionHandler(downloadObject, finalTS, pollId, messageObj)

        } else {
            _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".png")

            completionHandler(downloadObject, finalTS + ".png", pollId, messageObj)
        }
    }

    static func downloadImageForPollIncomingMessages(downloadObject: MediaRefernceHolderObject, pollId: String, messageObj: MessagesTable, completionHandler: @escaping incomingPollCompletionHandler) {
        print("Download Started")
        if let obj = downloadObject.mediaUrl, checkPublicImage(url: obj.absoluteString) {
            ACImageDownloader.downloadPublicImage(url: obj.absoluteString, completionHandler: { data, error in
                guard let imageData = data, error == nil else { return }
                ACImageDownloader.handleDownloadImageForPollIncomingMessages(downloadObject: downloadObject,
                                                                             imageData: imageData,
                                                                             pollId: pollId,
                                                                             messageObj: messageObj,
                                                                             completionHandler: completionHandler)
            })
        } else {
            AWSManager.instance.downloadImage(fileName: String(describing: downloadObject.mediaUrl!), completionHandler: { data, error in

                guard let imageData = data, error == nil else { return }
                ACImageDownloader.handleDownloadImageForPollIncomingMessages(downloadObject: downloadObject,
                                                                             imageData: imageData,
                                                                             pollId: pollId,
                                                                             messageObj: messageObj,
                                                                             completionHandler: completionHandler)
            })
        }
    }

    static func handleDownloadImage(downloadObject: MediaRefernceHolderObject,
                                    imageData: Data,
                                    completionHandler: @escaping CompletionHandler) {
        print("Download Finished")

        let timestamp = NSDate().timeIntervalSince1970 * 10_000_000
        let finalTS = String(format: "%.0f", timestamp)

        if downloadObject.mediaType == mediaDownloadType.video.rawValue {
            _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".png")

            completionHandler(downloadObject, finalTS + ".png")

        } else if downloadObject.mediaType == mediaDownloadType.audio.rawValue {
            _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".m4a")

            completionHandler(downloadObject, finalTS)

        } else {
            _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".png")

            completionHandler(downloadObject, finalTS + ".png")
        }
    }

    static func downloadImage(downloadObject: MediaRefernceHolderObject, completionHandler: @escaping CompletionHandler) {
        print("Download Started \(downloadObject.mediaUrl)")
        if let obj = downloadObject.mediaUrl, checkPublicImage(url: obj.absoluteString) {
            ACImageDownloader.downloadPublicImage(url: obj.absoluteString, completionHandler: { data, error in
                guard let imageData = data, error == nil else {
                    completionHandler(downloadObject, "")
                    return
                }

                ACImageDownloader.handleDownloadImage(downloadObject: downloadObject,
                                                      imageData: imageData,
                                                      completionHandler: completionHandler)
            })
        } else {
            AWSManager.instance.downloadImage(fileName: String(describing: downloadObject.mediaUrl!), completionHandler: { data, error in
                guard let imageData = data, error == nil else {
                    completionHandler(downloadObject, "")
                    return
                }
                ACImageDownloader.handleDownloadImage(downloadObject: downloadObject,
                                                      imageData: imageData,
                                                      completionHandler: completionHandler)
            })
        }
    }

    static func handleDownloadVideo(downloadObject: MediaRefernceHolderObject,
                                    imageData: Data,
                                    completionHandler: @escaping CompletionHandler) {
        print("Download Finished")
        let timestamp = NSDate().timeIntervalSince1970
        let finalTS = String(format: "%.0f", timestamp)
        _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".mp4")
        completionHandler(downloadObject, finalTS + ".mp4")
    }

    static func downloadVideo(downloadObject: MediaRefernceHolderObject, completionHandler: @escaping CompletionHandler) {
        print("Download Started")
        if let obj = downloadObject.mediaUrl, checkPublicImage(url: obj.absoluteString) {
            ACImageDownloader.downloadPublicImage(url: obj.absoluteString, completionHandler: { data, error in
                guard let imageData = data, error == nil else { return }
                ACImageDownloader.handleDownloadVideo(downloadObject: downloadObject,
                                                      imageData: imageData,
                                                      completionHandler: completionHandler)
            })
        } else {
            AWSManager.instance.downloadImage(fileName: String(describing: downloadObject.mediaUrl!), completionHandler: { data, error in
                guard let imageData = data, error == nil else { return }
                ACImageDownloader.handleDownloadVideo(downloadObject: downloadObject,
                                                      imageData: imageData,
                                                      completionHandler: completionHandler)
            })
        }
    }

    static func handleDownloadAudio(downloadObject: MediaRefernceHolderObject,
                                    imageData: Data,
                                    completionHandler: @escaping CompletionHandler) {
        print("Download Finished")
        let timestamp = NSDate().timeIntervalSince1970
        let finalTS = String(format: "%.0f", timestamp)

        _ = saveImageDocumentDirectory(attachData: imageData, attachName: finalTS, downloadtype: downloadObject.jobType!, extn: ".m4a")

        completionHandler(downloadObject, finalTS)
    }

    static func downloadAudio(downloadObject: MediaRefernceHolderObject, completionHandler: @escaping CompletionHandler) {
        print("Download Started")
        if let obj = downloadObject.mediaUrl, checkPublicImage(url: obj.absoluteString) {
            ACImageDownloader.downloadPublicImage(url: obj.absoluteString, completionHandler: { data, error in
                guard let imageData = data, error == nil else { return }
                ACImageDownloader.handleDownloadAudio(downloadObject: downloadObject,
                                                      imageData: imageData,
                                                      completionHandler: completionHandler)
            })
        } else {
            AWSManager.instance.downloadImage(fileName: String(describing: downloadObject.mediaUrl!), completionHandler: { data, error in
                guard let imageData = data, error == nil else { return }
                ACImageDownloader.handleDownloadAudio(downloadObject: downloadObject,
                                                      imageData: imageData,
                                                      completionHandler: completionHandler)
            })
        }
    }

    typealias CompletionHand = (_ imageName: String, _ path: String) -> Void

    static func downloadImageForLocalPath(imageData: Data, ref: String, completionHandler: @escaping CompletionHand) {
        print("Download Started")

        let finalName = ACMessageSenderClass.getTimestampForPubnubWithUserId()

        let path = saveImageDocumentDirectory(attachData: imageData, attachName: finalName, downloadtype: downLoadType.media, extn: ".png")

        print("Download finished")

        completionHandler(finalName + ".png", ref)
    }

    static func downloadVideoForLocalPath(imageData: Data, completionHandler: @escaping CompletionHand) {
        print("Download Started")

        let finalName = ACMessageSenderClass.getTimestampForPubnubWithUserId()

        let path = saveImageDocumentDirectory(attachData: imageData, attachName: finalName, downloadtype: downLoadType.media, extn: ".mp4")

        print("Download finished")

        completionHandler(finalName + ".mp4", path)
    }

    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    static func saveImageDocumentDirectory(attachData: Data, attachName: String, downloadtype: downLoadType, extn: String) -> String {
        let fileManager = FileManager.default

        var folderName = downloadtype.rawValue
        switch downloadtype {
        case downLoadType.profile:
            folderName = fileName.imagemediaFileName

        case downLoadType.group:
            folderName = fileName.imagemediaFileName

        case downLoadType.groupMember:
            folderName = fileName.imagemediaFileName

        case downLoadType.media:
            folderName = fileName.imagemediaFileName

            if extn == ".m4a" {
                folderName = fileName.audiomediaFileName
            }
        }

        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(folderName)/\(attachName)" + extn)

        fileManager.createFile(atPath: paths as String, contents: attachData, attributes: nil)

        return paths
    }

    static func deleteImageAtPath(path: String, extn: String) -> Bool {
        let name = fileName.imagemediaFileName
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(name)/\(path)" + extn)

        if FileManager.default.fileExists(atPath: paths) {
            do {
                try FileManager.default.removeItem(atPath: paths)
                print("User photo has been removed")
            } catch {
                print("an error during a removing")
            }

            return true
        } else {
            return false
        }
    }
}
