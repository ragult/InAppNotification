//
//  imagePreviewViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 22/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import AVKit
import UIKit

class imagePreviewViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var previewImage: UIImageView!
    @IBOutlet var previewTitle: UILabel!
    @IBOutlet var previewDescription: UILabel!
    @IBOutlet var imagesCountController: UIPageControl!
    @IBOutlet var textstackView: UIStackView!

    @IBOutlet var shareButton: UIButton!

    @IBOutlet var currentImageCountDisplayLabel: UILabel!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var imageScrollView: UIScrollView!
    @IBOutlet var topHeightConstraints: NSLayoutConstraint!

    @IBOutlet var navTopHeight: NSLayoutConstraint!
    @IBOutlet var textBGViewHeight:
        NSLayoutConstraint!
    var imagesCount: Int?
    var imagesData: Any?
    var ImagesArray: NSMutableArray?
    var cloudDataArray: NSArray?
    var localMessageId: String?

    var imageText: String?
    var playButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
//        let gestureRecognizer = UIPanGestureRecognizer(target: self,
//                                                       action: #selector(panGestureRecognizerHandler(_:)))
//        view.addGestureRecognizer(gestureRecognizer)

        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.maximumZoomScale = 10.0
        previewImage.isUserInteractionEnabled = true
//        self.topHeightConstraints.constant = 40

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubletap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        previewImage.addGestureRecognizer(doubleTap)

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingletap(recognizer:)))
        singleTap.numberOfTouchesRequired = 1
        singleTap.numberOfTapsRequired = 1
        previewImage.addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)

        imageScrollView.delegate = self
        imageScrollView.alwaysBounceVertical = false
        imageScrollView.alwaysBounceHorizontal = false

        previewDescription.isHidden = true
        imagesCountController.numberOfPages = imagesCount!
        imagesCountController.currentPage = 1

        playButton = UIButton(frame: CGRect(x: view.frame.size.width / 2 - 100, y: view.frame.size.height / 2 - 100, width: 200, height: 200))
        playButton?.setImage(UIImage(named: "ic_play"), for: .normal)
        playButton?.addTarget(self, action: #selector(onTapOfPlay(_:)), for: .touchUpInside)
        previewImage.isUserInteractionEnabled = true
        previewImage.addSubview(playButton!)
        playButton!.isHidden = true
        imagesCountController.isHidden = true

        if imagesCount == 1 {
            previewImage.image = load(attName: imagesData as! String)
            currentImageCountDisplayLabel.isHidden = true
            textBGViewHeight.constant = 100

            if (imageText?.count)! > 0 {
//                self.currentImageCountDisplayLabel.isHidden = true
                previewDescription.isHidden = false

                previewDescription.text = imageText!
//                self.textBGViewHeight.constant = 100
            }
        } else {
            currentImageCountDisplayLabel.text = "\(imagesCountController.currentPage)" + "/ \(imagesCountController.numberOfPages)"

            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
            swipeRight.direction = UISwipeGestureRecognizer.Direction.right
            previewImage.addGestureRecognizer(swipeRight)

            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
            swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
            previewImage.addGestureRecognizer(swipeLeft)

            ImagesArray = (imagesData as! NSArray).mutableCopy() as? NSMutableArray
            let img1 = ImagesArray![0] as! NSDictionary
            if img1.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
                previewImage.image = load(attName: img1.value(forKey: "thumbnail") as! String)
            } else {
                previewImage.image = load(attName: img1.value(forKey: "imageName") as! String)
            }

            imagesCountController.currentPage = 0
            textBGViewHeight.constant = 100

            if (imageText?.count)! > 0 {
                previewDescription.text = imageText!
                previewDescription.isHidden = false
//                self.textBGViewHeight.constant = 100
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(imagePreviewViewController.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    override func viewWillAppear(_: Bool) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate!.notificationStatus = NotificationEnum.ShowAllNotifications
    }

    override func viewWillDisappear(_: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            let limage = previewImage.image
            previewImage.image = limage
        } else {
            print("Portrait")
            let limage = previewImage.image
            previewImage.image = limage
        }
    }

    var Counts: Int = 0
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                print("Swiped right")
                if Counts > 0 {
                    Counts = imagesCountController.currentPage - 1

                    imagesCountController.currentPage = Counts
                    animateImageView(isFromLeft: true)
                }

            case UISwipeGestureRecognizer.Direction.left:
                print("Swiped left")
                if Counts < ((ImagesArray?.count)! - 1) {
                    Counts = (imagesCountController.currentPage + 1)
                    imagesCountController.currentPage = Counts

                    animateImageView(isFromLeft: false)
                }

            default:
                break
            }
        }
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)

    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        view.backgroundColor = UIColor.clear
        let touchPoint = sender.location(in: view?.window)

        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizer.State.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: view.frame.size.width, height: view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
            if touchPoint.y - initialTouchPoint.y > 50 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }

    @IBAction func onClickOfBackButton(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onClickOfSave(_: Any) {
        if let image = self.previewImage.image {
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
            present(vc, animated: true, completion: nil)
        }
    }

    @objc func onTapOfPlay(_: TableViewButton) {
        let img1 = ImagesArray![self.imagesCountController.currentPage] as! NSDictionary

        let attName = img1.value(forKey: "imageName") as! String
        if attName == "" {
            let cloudData = cloudDataArray![self.imagesCountController.currentPage] as! NSDictionary
            let cloudUrl = cloudData.value(forKey: "cloudUrl") as! String

            let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: cloudUrl, refernce: localMessageId!, jobType: downLoadType.media, mediaType: mediaDownloadType.video.rawValue, mediaExtension: "")

            DispatchQueue.global(qos: .background).async {
                ACImageDownloader.downloadVideo(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in
                    let result = success
                    let attch = NSMutableDictionary()
                    attch.setValue(img1.value(forKey: "thumbnail") as! String, forKey: "thumbnail")
                    attch.setValue(path, forKey: "imageName")
                    attch.setValue(result.mediaType, forKey: "msgType")
                    self.ImagesArray!.removeObject(at: self.imagesCountController.currentPage)
                    self.ImagesArray!.add(attch)

                    let dataDict = NSMutableDictionary()
                    dataDict.setValue(self.ImagesArray!, forKey: "attachmentArray")
                    let attachmentString = self.convertDictionaryToJsonString(dict: dataDict)
                    DatabaseManager.updateMessageTableForOtherColoumn(imageData: attachmentString, localId: result.refernce)

                })
            }
        } else {
            let attName = img1.value(forKey: "imageName") as! String
            let type = fileName.imagemediaFileName
            let fileURL = documentsUrl.appendingPathComponent(type + "/" + attName)
            let asset = AVAsset(url: fileURL)

            let avPlayerItem = AVPlayerItem(asset: asset)

            let avPlayer = AVPlayer(playerItem: avPlayerItem)
            let player = AVPlayerViewController()
            player.player = avPlayer

            avPlayer.play()

            present(player, animated: true, completion: nil)
        }
    }

    let animationDuration: TimeInterval = 0.5
//    let switchingInterval: TimeInterval = 3
    func animateImageView(isFromLeft: Bool) {
        CATransaction.begin()

        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
//            DispatchQueue.main.asyncAfter(deadline: .now() + self.switchingInterval) {
//                self.animateImageView()
//            }
        }

        let transition = CATransition()
        transition.type = CATransitionType.push
        if isFromLeft {
            transition.subtype = CATransitionSubtype.fromLeft

        } else {
            transition.subtype = CATransitionSubtype.fromRight
        }

        /*
         transition.type = kCATransitionPush
         transition.subtype = kCATransitionFromRight
         */
        previewImage.layer.add(transition, forKey: kCATransition)
        let img1 = ImagesArray![self.imagesCountController.currentPage] as! NSDictionary
        if img1.value(forKey: "msgType") as! String == messagetype.VIDEO.rawValue {
            previewImage.image = load(attName: img1.value(forKey: "thumbnail") as! String)
            let attName = img1.value(forKey: "imageName") as! String
            if attName == "" {
                playButton?.setTitle("Download", for: .normal)
            }

            playButton?.isHidden = false
        } else {
            previewImage.image = load(attName: img1.value(forKey: "imageName") as! String)
            playButton?.isHidden = true
        }
        CATransaction.commit()
        currentImageCountDisplayLabel.text = "\(imagesCountController.currentPage + 1)" + "/ \(imagesCountController.numberOfPages)"

//        index = index < images.count - 1 ? index + 1 : 0
    }

    @objc func onDoubletap(recognizer: UITapGestureRecognizer) {
        print("doubleTap")
        if imageScrollView.zoomScale == 1 {
            imageScrollView.zoom(to: zoomRectForScale(scale: imageScrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            imageScrollView.setZoomScale(1, animated: true)
        }
    }

    @objc func onSingletap(recognizer: UITapGestureRecognizer) {
        view.layoutIfNeeded()

        if recognizer.numberOfTapsRequired == 1 {
            if navTopHeight.constant == 0 {
                navTopHeight.constant = 64
                shareButton.isHidden = false
                textBGViewHeight.constant = 100

//                self.topHeightConstraints.constant = 40
                if imagesCount == 1 {
                    currentImageCountDisplayLabel.isHidden = true

                } else {
                    currentImageCountDisplayLabel.isHidden = false
                }
                if (imageText?.count)! > 0 {
//                    self.topHeightConstraints.constant = 40

//                    self.previewDescription.text = imageText!
                    previewDescription.isHidden = false
                }
            } else {
                shareButton.isHidden = true
                currentImageCountDisplayLabel.isHidden = true
                previewDescription.isHidden = true
//                self.topHeightConstraints.constant = -20
                textBGViewHeight.constant = 0
                navTopHeight.constant = 0
            }

            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = previewImage.frame.size.height / scale
        zoomRect.size.width = previewImage.frame.size.width / scale
        let newCenter = previewImage.convert(center, from: imageScrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    func viewForZooming(in _: UIScrollView) -> UIView? {
        return previewImage
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            let limage = previewImage.image
            previewImage.image = limage
        } else {
            let pimage = previewImage.image
            print("Portrait")
            previewImage.image = pimage
        }
    }
}

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        if let visibleVC = visibleViewController {
            return visibleVC.shouldAutorotate
        }
        return super.shouldAutorotate
    }

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let visibleVC = visibleViewController {
            return visibleVC.preferredInterfaceOrientationForPresentation
        }
        return super.preferredInterfaceOrientationForPresentation
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let visibleVC = visibleViewController {
            return visibleVC.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
}
