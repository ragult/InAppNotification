//
//  PollViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 21/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class PollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var pollTableView: UITableView!
    @IBOutlet var submitButton: UIButton!
    var pollTitle: String = "Which is the best city in world"
    let pollOptionTitles: [String] = ["Doing that in the storyboard ", "er in the storyboard. Then"]
    let pollPercentages = [12, 23, 53, 97]
    var isSelectedRow = [false, false, false, false]
    var isSelected: Bool = false
    var localMsgId: String?
    var groupDetail = GroupTable()
    var pollData = NSMutableDictionary()
    var oPtionsArray: NSArray?
    var tempSelect = ""
    var delegate = UIApplication.shared.delegate as? AppDelegate
    let userId = UserDefaults.standard.string(forKey: UserKeys.userGlobalId)!

    override func viewDidLoad() {
        super.viewDidLoad()

        let data = pollData["pollOPtions"] as! String
        oPtionsArray = data.toJSON() as? NSArray
        pollTitle = (pollData["pollTitle"] as? String)!

        pollTableView.reloadData()
        pollTableView.rowHeight = UITableView.automaticDimension
        pollTableView.estimatedRowHeight = 12
        pollTableView.register(UINib(nibName: "PollOptionsCell", bundle: nil), forCellReuseIdentifier: "PollOptionsCell")
        if pollData["selectedChoice"] as? String != "" {
            submitButton.setTitle("Refresh", for: .normal)
            pollTableView.allowsSelection = false
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return oPtionsArray?.count ?? 0
        } else {
            return 1
        }
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleCell = pollTableView.dequeueReusableCell(withIdentifier: "PollTitleCell", for: indexPath) as! PollTitleCell
        let optionsCell = pollTableView.dequeueReusableCell(withIdentifier: "PollOptionsCell", for: indexPath) as! PollOptionsCell
        if indexPath.section == 0 {
            titleCell.selectionStyle = .none
            titleCell.pollTitleLabel.text = pollTitle
            return titleCell
        } else {
            let opt3 = oPtionsArray!.object(at: indexPath.row) as! [String: Any]
            optionsCell.pollOptionTitle.text = "\(indexPath.row + 1). \(opt3["choiceText"] as? String ?? "")"

            if pollData["selectedChoice"] as? String == "", pollData["pollCreatedBy"] as! String != userId {
                if isSelectedRow[indexPath.row] == true {
                    optionsCell.optionSelectionCheckMark.isHighlighted = true
                } else {
                    optionsCell.optionSelectionCheckMark.isHighlighted = false
                }

                optionsCell.numberOfVotes.isHidden = true
                optionsCell.pollProgressBar.isHidden = true
                optionsCell.pollPercentage.isHidden = true
            } else {
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
                    optionsCell.optionSelectionCheckMark.isHighlighted = true
                } else {
                    optionsCell.optionSelectionCheckMark.isHighlighted = false
                }
            }
            return optionsCell
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let opt3 = oPtionsArray!.object(at: indexPath.row) as! [String: Any]
        tempSelect = (opt3["choiceId"] as? String)!
        isSelectedRow[indexPath.row] = true
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 0
    }

    @IBAction func submitAction(_ sender: UIButton) {
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                if sender.titleLabel?.text == "Refresh" {
                    getPollDetailsForPollIdAndIndex(pollId: (pollData["pollId"] as? String)!, pollOptions: oPtionsArray!, msgId: localMsgId!)
                } else {
                    if tempSelect != "" {
                        let time = Double(pollData["pollExpireOn"] as! String)! / 1000

                        if checkIfDateExpired(timeStamp: time) {
                            let pollReq = submitPollIdRequestObject()
                            pollReq.auth = DefaultDataProcessor().getAuthDetails()
                            pollReq.pollId = (pollData["pollId"] as? String)!
                            pollReq.pollChoiceId = tempSelect

                            Loader.show()
                            NetworkingManager.submitPoll(getGroupModel: pollReq) { (result: Any, sucess: Bool) in
                                if let results = result as? SubmitPollDataResponseObject, sucess {
                                    Loader.close()
                                    if sucess {
                                        if results.status == "Success" {
                                            //                                             self.pollData.setValue(self.tempSelect, forKey: "selectedChoice")
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
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
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
                                    self.oPtionsArray = obj as NSArray
                                    self.pollTableView.allowsSelection = false

                                    self.submitButton.setTitle("Refresh", for: .normal)
                                }
//                                if let pollDat = DatabaseManager.getPollDataForId(localPollId: "\(self.pollData.id ?? 0)") {

                                self.oPtionsArray = dat.toJSON() as? NSArray
//
//                                }
                                self.pollTableView.reloadData()
                            }
                        }
                    }
                }
            } else {
                alert(message: "Internet is required")
            }
        }
    }
}
