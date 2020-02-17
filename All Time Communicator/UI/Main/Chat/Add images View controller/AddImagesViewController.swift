//
//  AddImagesViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 24/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import AVKit
import Photos
import TZImagePickerController
import UIKit

protocol AddImageDelegate {
    func imageAdded()
}

class AddImagesViewController: UIViewController {
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var imagePreview: UIImageView!
    @IBOutlet var addMoreImages: UIButton!
    @IBOutlet var sendImageButton: UIButton!
    @IBOutlet var addCommentTF: UITextView!
    @IBOutlet var imagesCollectionView: UICollectionView!
    var addedImages: [UIImage] = []
    var imagesSendArray: [MediaUploadObject] = []
    var imagesArray: [MediarefObject] = []
    var selectedList = [Any]()

    var selectedMedia = MediarefObject()
    var addImageDelegate : AddImageDelegate?
    var deselectedImage: UIImage?
    var coverImage: UIImage?
    var addedVideo: PHAsset?

    @IBOutlet var playButton: UIButton!
    @IBOutlet var textViewHC: NSLayoutConstraint!
    var isFromTopics = false
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var isViewAvailable = false
    var isImage = true
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePreview.image = nil
        playButton.isHidden = true
        activityIndicator.isHidden = true

//        addCommentTF.attributedPlaceholder = NSAttributedString(string: "Add Comment",
//                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        addCommentTF.delegate = self
        addCommentTF.translatesAutoresizingMaskIntoConstraints = false
        textViewHC.constant = 30
        print(addedImages)

        if isImage == true {
            addMoreImages.isHidden = false
            for asset in addedImages {
                processDataToUI(asset: asset)
            }
        } else {
            addMoreImages.isHidden = true

            imagePreview.image = coverImage
            playButton.isHidden = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()

            processDataForVideo(cImage: coverImage!, asset: addedVideo!)
        }
    }

    @IBAction func onClickofDeleteImage(_: Any) {
        for object in imagesArray {
            if object.uniqueRef == selectedMedia.uniqueRef {
                imagesArray.remove(object: object)
                let containsImage = imagesSendArray.filter { $0.uniqueId == object.uniqueRef }
                if containsImage.count > 0 {
                    if containsImage[0].mediaType == mediaDownloadType.image {
                        _ = ACImageDownloader.deleteImageAtPath(path: containsImage[0].localImagePath!, extn: ".png")
                    } else {
                        _ = ACImageDownloader.deleteImageAtPath(path: containsImage[0].localImagePath!, extn: ".mp4")
                    }
                    imagesSendArray.remove(object: containsImage[0])
                }

//                let containsasset = self.addedImages.filter{ $0.localIdentifier ==  object.uniqueRef}
//                if containsasset.count > 0 {
//
//                    self.addedImages.remove(object: containsasset[0])
//                }

                imagesCollectionView.reloadData()
                if imagesArray.count == 0 {
                    dismiss(animated: true, completion: nil)
                } else {
                    imagePreview.image = imagesArray[0].imageData
                    selectedMedia = imagesArray[0]
                    if imagesArray[0].type == messagetype.IMAGE {
                        playButton.isHidden = true
                    } else {
                        playButton.isHidden = false
                    }
                }
                return
            }
        }
    }

    @IBAction func onClickOfPlay(_: Any) {
        playVideo(selectedMedia.fullVideo as! AVAsset)
    }

    func processDataToUI(asset: UIImage) {
        let media = MediarefObject()
        media.imageData = asset
        media.uniqueRef = String(getcurrentTimeStampFOrPubnub())
        media.type = messagetype.IMAGE
        media.status = true
        imagesArray.append(media)
        if imagesArray.count == 1 {
            imagePreview.image = asset
            selectedMedia = media
            playButton.isHidden = true
        }
        DispatchQueue.global(qos: .background).async {
            let resizedImage: UIImage? = media.imageData!.resizedTo500Kb()

            ACImageDownloader.downloadImageForLocalPath(imageData: resizedImage!.pngData()!, ref: media.uniqueRef!, completionHandler: { (success, _) -> Void in
                print("download complete")
                let mediaObj = MediaUploadObject(path: success, name: "", imgData: (resizedImage?.pngData())!, mediaTyp: messagetype.IMAGE)
                mediaObj.uniqueId = media.uniqueRef!
                self.imagesSendArray.append(mediaObj)

                DispatchQueue.main.async { () in

                    self.imagesCollectionView.reloadData()
                }
            })
        }
    }

    func processDataForVideo(cImage _: UIImage, asset: PHAsset) {
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
        options.deliveryMode = .fastFormat
        options.version = .original

        manager.requestAVAsset(forVideo: asset, options: nil, resultHandler: { avasset, _, _ in

            if let avassetURL = avasset as? AVURLAsset {
                DispatchQueue.main.async { () in

                    guard let video = try? Data(contentsOf: avassetURL.url) else {
                        return
                    }

                    let videoData = video

                    let media = MediarefObject()
                    media.imageData = self.coverImage
                    media.uniqueRef = asset.localIdentifier
                    media.type = messagetype.VIDEO
                    media.status = false
                    media.videoData = videoData
                    media.fullVideo = avasset
                    self.imagesArray.append(media)
                    if self.imagesArray.count == 1 {
                        self.imagePreview.image = media.imageData
                        self.selectedMedia = media
                        self.playButton.isHidden = false
                    }
                    self.imagesCollectionView.reloadData()

                    DispatchQueue.global(qos: .background).async {
                        ACImageDownloader.downloadVideoForLocalPath(imageData: media.videoData as! Data, completionHandler: { (success, path) -> Void in

                            let mediaObj = MediaUploadObject(path: success, name: path, imgData: media.videoData as! Data, mediaTyp: messagetype.VIDEO)
                            mediaObj.uniqueId = media.uniqueRef!

                            ACImageDownloader.downloadImageForLocalPath(imageData: (self.coverImage?.pngData())!, ref: media.uniqueRef!, completionHandler: { (success, _) -> Void in
                                mediaObj.imageName = success

                                let containsImage = self.imagesSendArray.filter { $0.uniqueId == mediaObj.uniqueId }
                                if containsImage.count == 0 {
                                    self.imagesSendArray.append(mediaObj)
                                }
                                DispatchQueue.main.async(execute: { () in
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.isHidden = true

                                    // update ui here
                                    if self.isViewAvailable {
                                        self.imagesCollectionView.reloadData()
                                    }

                                })

                            })
                        })
                    }
                }
            }
        })
    }

//    func processDataToDisplay(asset:DKAsset) {
//        if asset.type == DKAssetType.photo {
//            print("image 1")
//            let options = PHImageRequestOptions()
//            options.deliveryMode = .fastFormat
//            options.resizeMode = .exact
//
//            asset.fetchOriginalImage(options: options, completeBlock: { image, info in
//                print("image fetched from asset")
//
//                let actImage:UIImage? = image
//                let media = MediarefObject()
//                media.imageData = actImage!
//                media.uniqueRef = asset.localIdentifier
//                media.type = messagetype.IMAGE
//                media.status = true
//                self.imagesArray .append(media)
//                if self.imagesArray.count == 1 {
//                    self.imagePreview.image = actImage
//                    self.selectedMedia = media
//                    self.playButton.isHidden = true
//                }
//                let sectionToReload = IndexPath(item: self.imagesArray.count - 1, section: 0)
//                self.imagesCollectionView.insertItems(at: [sectionToReload])
//                self.imagesCollectionView?.scrollToItem(at:sectionToReload, at: .left, animated: false)
//
//            })
//
//
//
//
//        } else {
//            // video
//
//            let manager = PHImageManager.default()
//            let options = PHVideoRequestOptions()
//            options.deliveryMode = .fastFormat
//            options.version = .original
//
//            manager.requestAVAsset(forVideo: asset.originalAsset!, options: nil, resultHandler: { (avasset, audio, info) in
//
//                if let avassetURL = avasset as? AVURLAsset {
//                    DispatchQueue.main.async(execute: { () in
//
//                        guard let video = try? Data(contentsOf: avassetURL.url) else {
//                            return
//                        }
//
//                        let videoData = video
//
//                        let media = MediarefObject()
//                        media.imageData = self.generateThumbnail(path: avassetURL.url)
//                        media.uniqueRef = asset.localIdentifier
//                        media.type = messagetype.VIDEO
//                        media.status = false
//                        media.videoData = videoData
//                        media.fullVideo = avasset
//                        self.imagesArray .append(media)
//                        if self.imagesArray.count == 1 {
//                            self.imagePreview.image = media.imageData
//                            self.selectedMedia = media
//                            self.playButton.isHidden = false
//                        }
//                        let sectionToReload = IndexPath(item: self.imagesArray.count - 1, section: 0)
//                        self.imagesCollectionView.insertItems(at: [sectionToReload])
//                        self.imagesCollectionView?.scrollToItem(at:sectionToReload, at: .left, animated: false)
//
//                    })
//
//
//                }
//            })
//
//        }
//
//    }
//
    func viewWillAppear() {
        isViewAvailable = true
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications
    }

    override func viewWillDisappear(_: Bool) {
        isViewAvailable = false
    }

    @IBAction func backButton(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addMoreImages(_: Any) {
        let pickerController = TZImagePickerController()

        pickerController.maxImagesCount = 8
        pickerController.isSelectOriginalPhoto = false
        pickerController.allowTakePicture = true
        pickerController.allowTakeVideo = false
        pickerController.allowPreview = true
        pickerController.allowPickingImage = true
        pickerController.allowPickingVideo = false
        pickerController.allowCameraLocation = false

        if addedImages.count > 1 {
            pickerController.selectedAssets = selectedList as? NSMutableArray
        }
        pickerController.didFinishPickingPhotosWithInfosHandle = { (photos, assets, isSelectOriginalPhoto, infoArr) -> Void in
            self.selectedList = assets ?? []
            debugPrint("\(photos!.count) ---\(assets!.count) ---- \(isSelectOriginalPhoto) --- \((infoArr?.count)!)")
            for photo in photos! {
                self.addedImages.append(photo)
                self.processDataToUI(asset: photo)
            }
            self.textViewHC.constant = 30
        }

        present(pickerController, animated: true, completion: nil)
    }

    @IBAction func sendImageButton(_: Any) {
//        Loader.show()

        if imagesSendArray.count == addedImages.count {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                if imagesSendArray.count > 1 {
                    delegate.isFromAttachmentView = attachmentType.imageArray
                } else {
//                    if isFromTopics {
                        if self.imagesSendArray.count == 1 {
                            delegate.isFromAttachmentView = attachmentType.IMAGE
                        } else {
                            delegate.isFromAttachmentView = attachmentType.imageArray
                        }
//                    } else {
//                    delegate.isFromAttachmentView = attachmentType.IMAGE
//                    }
                }
                imagesSendArray[0].messageTextString = addCommentTF.text ?? ""
                delegate.attachmentArray = imagesSendArray
            }
            addImageDelegate?.imageAdded()
            dismiss(animated: true, completion: nil)
        } else {
            if isImage == false {
                if imagesSendArray.count == 1 {
                    if let delegate = UIApplication.shared.delegate as? AppDelegate {
                        delegate.isFromAttachmentView = attachmentType.IMAGE
                        imagesSendArray[0].messageTextString = addCommentTF.text ?? ""
                        delegate.attachmentArray = imagesSendArray
                        addImageDelegate?.imageAdded()
                        dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
//        self.processImageForSending(imagesArray: imagesArray)
    }

    func processImageForSending(imagesArray _: [MediarefObject]) {}

    func saveImageDocumentDirectory(attachData: Data, attachName: String, downloadtype: downLoadType, extn: String) -> String {
        let fileManager = FileManager.default

        var folderName = downloadtype.rawValue
        switch downloadtype {
        case downLoadType.profile:
            folderName = fileName.contactProfileFileName

        case downLoadType.group:
            folderName = fileName.groupProfileFileName

        case downLoadType.groupMember:
            folderName = fileName.groupMemberProfileFileName

        case downLoadType.media:
            folderName = fileName.imagemediaFileName
        }

        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(folderName)/\(attachName)" + extn)

        fileManager.createFile(atPath: paths as String, contents: attachData, attributes: nil)

        return paths
    }

    func compressImage(image: UIImage) -> UIImage {
//        return image

        return image.resizedTo500Kb()!
    }

    func animate(duration: Double) {
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

extension AddImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return imagesArray.count
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCell", for: indexPath) as! ImagesCell
        let tag = indexPath.row + 1
        cell.tag = tag
        let media = imagesArray[indexPath.row]

        if media.type == messagetype.VIDEO {
            cell.addedImage.image = media.imageData

            if imagesArray[indexPath.row].status == false {
                DispatchQueue.global(qos: .background).async {
                    ACImageDownloader.downloadVideoForLocalPath(imageData: media.videoData as! Data, completionHandler: { (success, path) -> Void in

                        let mediaObj = MediaUploadObject(path: success, name: path, imgData: media.videoData as! Data, mediaTyp: messagetype.VIDEO)
                        mediaObj.uniqueId = media.uniqueRef!

                        ACImageDownloader.downloadImageForLocalPath(imageData: (self.coverImage?.pngData())!, ref: media.uniqueRef!, completionHandler: { (success, _) -> Void in
                            mediaObj.imageName = success

                            let containsImage = self.imagesSendArray.filter { $0.uniqueId == mediaObj.uniqueId }
                            if containsImage.count == 0 {
                                self.imagesSendArray.append(mediaObj)
                            }
                            DispatchQueue.main.async(execute: { () in

                                // update ui here
                                print(self.imagesSendArray.count)
                                if self.isViewAvailable {
                                    self.imagesArray[indexPath.row].status = true
                                }

                            })

                        })
                    })
                }
            }

        } else {
            cell.addedImage.image = media.imageData
            if imagesArray[indexPath.row].status == false {
                DispatchQueue.global(qos: .background).async {
                    let resizedImage: UIImage? = media.imageData!.resizedTo500Kb()
                    print("image resize end")

                    ACImageDownloader.downloadImageForLocalPath(imageData: (resizedImage?.pngData())!, ref: media.uniqueRef!, completionHandler: { (success, _) -> Void in
                        print("download complete")

                        let mediaObj = MediaUploadObject(path: success, name: "", imgData: (resizedImage?.pngData())!, mediaTyp: messagetype.IMAGE)
                        mediaObj.uniqueId = media.uniqueRef!
                        let containsImage = self.imagesSendArray.filter { $0.uniqueId == mediaObj.uniqueId }
                        if containsImage.count == 0 {
                            self.imagesSendArray.append(mediaObj)
                        }

                        DispatchQueue.main.async {
                            if self.isViewAvailable {
                                self.imagesArray[indexPath.row].status = true
                            }
                        }
                    })
                }
            }
        }

        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let media = imagesArray[indexPath.row]

        if media.type == messagetype.VIDEO {
            imagePreview.image = media.imageData
            selectedMedia = media
            playButton.isHidden = false
        } else {
            imagePreview.image = media.imageData
            selectedMedia = media
            playButton.isHidden = true
        }
    }

//    var documentsUrl: URL {
//        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    }
//
//    private func load(attName: String) -> UIImage? {
//        let type = fileName.imagemediaFileName
//        let fileURL = documentsUrl.appendingPathComponent(type + "/" + attName)
//        do {
//            let imageData = try Data(contentsOf: fileURL)
//            return UIImage(data: imageData)
//        } catch {
//            print("Error loading image : \(error)")
//        }
//        return nil
//    }

    func getAVAsset(fileName: String) -> AVAsset {
        let fullUrl = URL(string: fileName)

        let asset = AVAsset(url: fullUrl!)
        return asset
    }

    func playVideo(_ asset: AVAsset) {
        let avPlayerItem = AVPlayerItem(asset: asset)

        let avPlayer = AVPlayer(playerItem: avPlayerItem)
        let player = AVPlayerViewController()
        player.player = avPlayer

        avPlayer.play()

        present(player, animated: true, completion: nil)
    }

    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}

extension AddImagesViewController: UITextViewDelegate {
    func textViewDidChange(_: UITextView) {
        let size = CGSize(width: addCommentTF.frame.width, height: .infinity)
        let estimatedSize = addCommentTF.sizeThatFits(size)
        if estimatedSize.height < 120 {
            textViewHC.constant = estimatedSize.height
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let string = textView.text else { return true }
        let newLength = text.count + string.count - range.length
        if newLength <= 100 {
            return true
        } else {
            alert(message: "The maximum length for the text message has been reached.")

            return false
        }
    }
}

extension PHAsset {
    var image: UIImage {
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
            thumbnail = image!
        })
        return thumbnail
    }
}

class MediarefObject: NSObject {
    var uniqueRef: String?
    var type: messagetype?
    var imageData: UIImage?
    var status: Bool = false
    var videoData: Any?
    var fullVideo: Any?
}
