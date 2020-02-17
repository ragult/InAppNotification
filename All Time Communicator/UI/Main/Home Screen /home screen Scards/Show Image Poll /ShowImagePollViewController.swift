//
//  CreateImagePollViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 30/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import AXPhotoViewer
import UIKit

class ShowImagePollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AXPhotosViewControllerDelegate {
    @IBOutlet var pollTitle: UILabel!
    @IBOutlet var pollImagesCollectionView: UICollectionView!
    @IBOutlet var submitBtn: UIButton!
    @IBOutlet var pollTableView: UITableView!
    var localMsgId: String?

    var pollData = NSMutableDictionary()
    var isSelected: Bool = false
    var oPtionsArray: NSArray?
    var imagesLocalData: String?

    var tempSelect = ""
    var delegate = UIApplication.shared.delegate as? AppDelegate
    var imagesDataDict: NSDictionary?
    let imageCache = NSCache<AnyObject, AnyObject>()
    let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!

    override func viewDidLoad() {
        super.viewDidLoad()

        let data = pollData["pollOPtions"] as! String
        oPtionsArray = data.toJSON() as? NSArray
        pollTitle.text = pollData["pollTitle"] as? String

        pollImagesCollectionView.delegate = self
        pollImagesCollectionView.dataSource = self

        pollTableView.delegate = self
        pollTableView.dataSource = self
        pollImagesCollectionView.allowsSelection = true
        pollImagesCollectionView.allowsMultipleSelection = false
        pollImagesCollectionView.register(UINib(nibName: "ImagePollCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImagePollCollectionViewCell")

        pollTableView.register(UINib(nibName: "PollImageResultCell", bundle: nil), forCellReuseIdentifier: "PollImageResultCell")

        let rightNavbarButtonImage = UIImage(named: "more")!
        let rightNavbarButton = UIBarButtonItem(image: rightNavbarButtonImage, style: .plain, target: self, action: #selector(didTapRightNavBtn))
        navigationItem.rightBarButtonItem = rightNavbarButton
        navigationItem.rightBarButtonItem?.tintColor = .gray

        pollTableView.allowsSelection = false

        if (pollData["selectedChoice"] as! String) == "", (pollData["pollCreatedBy"] as! String) != userId {
            print("user can submit poll")
            pollTableView.isHidden = true
            pollImagesCollectionView.isHidden = false

        } else {
            pollImagesCollectionView.allowsSelection = false
            pollTableView.isHidden = false
            pollImagesCollectionView.isHidden = true

            submitBtn.setTitle("Refresh", for: .normal)
        }

        if imagesLocalData != "" {
            imagesDataDict = convertJsonStringToDictionary(text: imagesLocalData!) as NSDictionary?

        } else {
            downLoadImagesForPoll()
        }
    }

    @IBAction func submitBtnAction(_ sender: UIButton) {
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                if sender.titleLabel?.text == "Refresh" {
                    getPollDetailsForPollIdAndIndex(pollId: pollData["pollId"] as! String, pollOptions: oPtionsArray!, msgId: localMsgId!)
                } else {
                    if tempSelect != "" {
                        let time = Double(pollData["pollExpireOn"] as! String)! / 1000

                        if checkIfDateExpired(timeStamp: time) {
                            let pollReq = submitPollIdRequestObject()
                            pollReq.auth = DefaultDataProcessor().getAuthDetails()
                            pollReq.pollId = pollData["pollId"] as! String
                            pollReq.pollChoiceId = tempSelect

                            Loader.show()
                            NetworkingManager.submitPoll(getGroupModel: pollReq) { (result: Any, sucess: Bool) in
                                if let results = result as? SubmitPollDataResponseObject, sucess {
                                    Loader.close()
                                    if sucess {
                                        if results.status == "Success" {
//                                            let pollD = pollData.mutableCopy() as! NSMutableDictionary
                                            self.pollData.setValue(self.tempSelect, forKey: "selectedChoice")
                                            let str = self.pollData.toJsonString()
                                            DatabaseManager.updateMessageTableForOtherColoumn(imageData: str, localId: self.localMsgId!)

                                            self.getPollDetailsForPollIdAndIndex(pollId: (self.pollData["pollId"] as? String)!, pollOptions: self.oPtionsArray!, msgId: self.localMsgId!)
                                        }
                                    }
                                }
                            }

                        } else {
                            alert(message: "The Poll has ended")
                        }
                    } else {
                        alert(message: "Please select an poll option to submit")
                    }
                }

            } else {
                alert(message: "Internet is required")
            }
        }
    }

    func getPollDetailsForPollIdAndIndex(pollId: String, pollOptions: NSArray, msgId: String) {
        let getPoll = GetPollDataRequestObject()
        getPoll.auth = DefaultDataProcessor().getAuthDetails()
        getPoll.pollId = pollId

        Loader.show()

        NetworkingManager.getPollCounts(getGroupModel: getPoll) { (result: Any, sucess: Bool) in
            if let results = result as? PollStatusResponseObject, sucess {
                Loader.close()

                if sucess {
                    if results.status == "Success" {
                        var obj = [PollTable.PollOptions]()
                        let choices = results.data?.pollstats

                        for choice in pollOptions {
                            let pollOps = PollTable.PollOptions()
                            let ch = choice as! NSDictionary

                            for object in choices! {
                                if object.choiceId == ch.value(forKey: "choiceId") as! String {
                                    pollOps.choiceId = object.choiceId
                                    pollOps.numberOfVotes = object.count
                                    pollOps.choiceImage = ch.value(forKey: "choiceImage") as! String
                                    pollOps.choiceText = ch.value(forKey: "choiceText") as! String

                                    obj.append(pollOps)
                                }
                            }
                        }

                        let dat = obj.toJsonString()

                        self.pollData.setValue(dat, forKey: "pollOPtions")
                        let str = self.pollData.toJsonString()
                        DatabaseManager.updateMessageTableForOtherColoumn(imageData: str, localId: msgId)

                        if self.pollData["selectedChoice"] as? String != "" {
//                            self.oPtionsArray = obj as NSArray
                            self.pollImagesCollectionView.allowsSelection = false
                            self.pollTableView.isHidden = false
                            self.pollImagesCollectionView.isHidden = true

                            self.submitBtn.setTitle("Refresh", for: .normal)
                        }
//                        if let pollDat = DatabaseManager.getPollDataForId(localPollId: "\(self.pollData.id ?? 0)") {
//
//                            let data = pollDat.pollOPtions
                        self.oPtionsArray = dat.toJSON() as? NSArray
                        self.pollTableView.reloadData()
//
//                        }

                        self.pollImagesCollectionView.reloadData()
                    }
                }
            }
        }
    }

    @objc func didTapRightNavBtn() {}
}

extension ShowImagePollViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return oPtionsArray!.count
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = pollImagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ImagePollCollectionViewCell", for: indexPath) as! ImagePollCollectionViewCell
        let opt3 = oPtionsArray!.object(at: indexPath.row) as! [String: Any]

        let choiceId1 = opt3["choiceId"] as? String
        let imgName1 = imagesDataDict![choiceId1!]
        let img1 = getImage(imageName: imgName1 as! String)
        cell.pollOptionImage.image = img1

        cell.checkMark.isHidden = false
        cell.checkMark.setImage(UIImage(named: "photo_original_def"), for: .normal)

        cell.pollOptionDescription.isHidden = true
        if pollData["selectedChoice"] as! String == "", pollData["pollCreatedBy"] as! String != userId {
            if isSelected == true {
            } else {
                cell.backgroundColor = .clear
            }

        } else {
            cell.checkMark.isHidden = true

            cell.pollOptionDescription.isHidden = false
            var str = opt3["numberOfVotes"] as? String
            if str == "1" || str == "0" {
                str = " Vote"
            } else {
                str = " Votes"
            }

            cell.pollOptionDescription.text = "\(opt3["numberOfVotes"] as? String ?? "0")" + str!
            if pollData["selectedChoice"] as? String == opt3["choiceId"] as? String {
                cell.checkMark.isHidden = false
                cell.checkMark.setImage(UIImage(named: "ticMarkSmall"), for: .normal)

                cell.backgroundColor = COLOURS.TABLE_BACKGROUND_COLOUR

            } else {
                cell.checkMark.setImage(UIImage(named: "ticMarkSmall"), for: .normal)
            }
        }

        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selecteds")
        guard let cell = pollImagesCollectionView.cellForItem(at: indexPath) as? ImagePollCollectionViewCell else {
            return
        }
        let opt3 = oPtionsArray!.object(at: indexPath.row) as! [String: Any]
        tempSelect = (opt3["choiceId"] as? String)!
        cell.backgroundColor = COLOURS.TABLE_BACKGROUND_COLOUR
        cell.checkMark.setImage(UIImage(named: "ticMarkSmall"), for: .normal)
    }

    func collectionView(_: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = pollImagesCollectionView.cellForItem(at: indexPath) as? ImagePollCollectionViewCell else {
            return
        }
        tempSelect = ""
        cell.backgroundColor = .clear

        cell.checkMark.setImage(UIImage(named: "photo_original_def"), for: .normal)
    }

    func downLoadImagesForPoll() {
        Loader.show()
        let data = pollData["pollOPtions"] as? String
        if data != "" {
            let oPtionsArray = data!.toJSON() as! NSArray

            let attch = NSMutableDictionary()

            for option in oPtionsArray {
                let opt = option as! [String: Any]

                let cloudUrl = opt["data"] as! String
                let type = "image"
                let ref = opt["choiceId"] as! String

                // addObject TO Array
                let mediaDownloadObject = MediaRefernceHolderObject(mediaUrl: cloudUrl, refernce: ref, jobType: downLoadType.media, mediaType: type, mediaExtension: "")

                ACImageDownloader.downloadImage(downloadObject: mediaDownloadObject, completionHandler: { (success, path) -> Void in

                    let result = success

                    attch.setValue(path, forKey: result.refernce)

                    // check if count matches
                    if attch.allKeys.count == oPtionsArray.count {
                        let attachmentString = self.convertDictionaryToJsonString(dict: attch)
//                    DatabaseManager.updatePollLocalDataOptions(localData: attachmentString, pollId: self.pollData.pollId)
                        // get main thread and reload cell
                        Loader.close()
                        DispatchQueue.main.async { () in
                            self.imagesDataDict = self.convertJsonStringToDictionary(text: attachmentString) as NSDictionary?
                        }
                    }

                })
            }
        }
    }

    func getImage(imageName: String) -> UIImage {
        var image = UIImage()
        if let cachedimage = self.imageCache.object(forKey: imageName as AnyObject) as? UIImage {
            image = cachedimage
        } else {
            if imageName != "" {
                if let img = self.load(attName: imageName) {
                    image = img
                    imageCache.setObject(image, forKey: imageName as AnyObject)
                }
            }
        }
        return image
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return oPtionsArray?.count ?? 0
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let optionsCell = pollTableView.dequeueReusableCell(withIdentifier: "PollImageResultCell", for: indexPath) as! PollImageResultCell

//            let opt3 = oPtionsArray!.object(at: indexPath.row) as! Dictionary<String, Any>
//            optionsCell.pollOptionTitle.text = "\(indexPath.row + 1). \(opt3["data"] as? String ?? "")"

        let opt3 = oPtionsArray!.object(at: indexPath.row) as! [String: Any]

        let choiceId1 = opt3["choiceId"] as? String
        let imgName1 = imagesDataDict![choiceId1!]
        let img1 = getImage(imageName: imgName1 as! String)
        optionsCell.optionSelectionCheckMark.image = img1

        optionsCell.checkMark.isHidden = false
        optionsCell.checkMark.setImage(UIImage(named: "ticMarkSmall"), for: .normal)
        optionsCell.imgBtn.tag = indexPath.row
        optionsCell.imgBtn.addTarget(self, action: #selector(goToDiscuss(_:)), for: .touchUpInside)

        optionsCell.checkMark.isHidden = true

        optionsCell.numberOfVotes.isHidden = false
        optionsCell.pollProgressBar.isHidden = false
        optionsCell.pollPercentage.isHidden = false

        var count = opt3["numberOfVotes"] as? String ?? "0"
        if count == "" {
            count = "0"
        }
        var str = "Votes"
        if count == "1" || count == "0" {
            str = "Vote"
        }

        optionsCell.numberOfVotes.text = "\(count) \(str)"
        optionsCell.pollProgressBar.progress = Float(count)! / 100
        optionsCell.pollPercentage.text = "\(opt3["numberOfVotes"] as? String ?? "0")%"

        if opt3["choiceId"] as? String == pollData["selectedChoice"] as? String {
            optionsCell.checkMark.isHidden = false
        } else {
            optionsCell.checkMark.isHidden = true
        }

        return optionsCell
    }

    @objc func goToDiscuss(_ sender: UIButton) {
        let indexPath: IndexPath = IndexPath(row: sender.tag, section: 0)

        let cell = pollTableView.cellForRow(at: indexPath as IndexPath) as! PollImageResultCell
        let imageView = cell.optionSelectionCheckMark

        let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) { [weak self] (_, _) -> UIImageView? in
            guard let self = self else { return nil }

            guard let cell = self.pollTableView.cellForRow(at: indexPath as IndexPath) else { return nil }

            // adjusting the reference view attached to our transition info to allow for contextual animation
            let cardscell = cell as! PollImageResultCell
            return cardscell.optionSelectionCheckMark
        }

        let opt3 = oPtionsArray!.object(at: indexPath.row) as! [String: Any]

        let choiceId1 = opt3["choiceId"] as? String
        let imgName1 = imagesDataDict![choiceId1!]
        let img = getImage(imageName: imgName1 as! String)

        let str = NSAttributedString(string: "")
        let photos = [AXPhoto(attributedTitle: str, image: img)]

        let dataSource = AXPhotosDataSource(photos: photos)
        let pagingConfig = AXPagingConfig(loadingViewClass: nil)
        let photosViewController = AXPhotosViewController(dataSource: dataSource, pagingConfig: pagingConfig, transitionInfo: transitionInfo)
        photosViewController.delegate = self
        present(photosViewController, animated: true)
    }
}
