//
//  CreateEventViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 01/02/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import UIKit
class CreateEventViewController: UIViewController {
    @IBOutlet var createEventTableview: UITableView!
    @IBOutlet var createBtn: UIButton!
    @IBOutlet var closeBtn: UIButton!
    var titleImage: UIImage?
    private struct SECTION {
        static var TITLE_DESCRIPTION: Int = 0
        static var DATE_TIME: Int = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createEventTableview.estimatedRowHeight = 89
        createEventTableview.rowHeight = UITableView.automaticDimension

        createEventTableview.register(UINib(nibName: "InviteTItleDescrptionTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteTItleDescrptionTableViewCell")
        createEventTableview.register(UINib(nibName: "InviteDateAndTimeTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteDateAndTimeTableViewCell")
    }

    @IBAction func createBtnAction(_: Any) {}

    @IBAction func closeBtnAction(_: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateEventViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION.TITLE_DESCRIPTION:
            return 2
        case SECTION.DATE_TIME:
            return 1
        default:
            return 0
        }
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch indexPath.section {
        case SECTION.TITLE_DESCRIPTION:
            let titleDescriptionCell = createEventTableview.dequeueReusableCell(withIdentifier: "InviteTItleDescrptionTableViewCell", for: indexPath) as! InviteTItleDescrptionTableViewCell
            if indexPath.row == 0 {
                titleDescriptionCell.openGalleryBtn.addTarget(self, action: #selector(didSelectUploadImage), for: .touchUpInside)
                titleDescriptionCell.deleteImageBtn.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)

                if titleImage != nil {
                    titleDescriptionCell.deleteImageBtn.isHidden = false
                    titleDescriptionCell.openGalleryBtn.isHidden = true
                    titleDescriptionCell.titleImage.isHidden = false
                    titleDescriptionCell.titleImage.image = titleImage
                } else {
                    titleDescriptionCell.deleteImageBtn.isHidden = true
                    titleDescriptionCell.openGalleryBtn.isHidden = false
                    titleDescriptionCell.titleImage.isHidden = true
                }
            } else {
                titleDescriptionCell.inviteTitleLabel.text = "Description"
                titleDescriptionCell.inviteTF.setBottomBorder()
                titleDescriptionCell.openGalleryBtn.isHidden = true
                titleDescriptionCell.textFieldTrailingAnchor.constant = 32
            }
            return titleDescriptionCell
        case SECTION.DATE_TIME:
            let dateTimeCell = createEventTableview.dequeueReusableCell(withIdentifier: "InviteDateAndTimeTableViewCell", for: indexPath) as! InviteDateAndTimeTableViewCell
            dateTimeCell.separatorInset = UIEdgeInsets(top: 0, left: createEventTableview.frame.width / 2, bottom: 0, right: createEventTableview.frame.width / 2)
            dateTimeCell.datePicker.minimumDate = Date()
            dateTimeCell.datePicker.extCornerRadius = 4
            dateTimeCell.timePicker.extCornerRadius = 4
            return dateTimeCell
        default:
            print("error while switching cell")
            return cell
        }
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerText = PaddedLabel(frame: CGRect(x: view.frame.minX, y: 20, width: 150, height: 20))
        headerText.textAlignment = .left
        headerText.backgroundColor = .white
        headerText.padding = UIEdgeInsets(top: 10, left: 32, bottom: 0, right: 0)
        headerText.textColor = .black
        headerText.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 12)
        if section == SECTION.DATE_TIME {
            headerText.text = "Event Time"
        }
        return headerText
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SECTION.DATE_TIME {
            return 40
        } else {
            return 20
        }
    }

    @objc func didSelectUploadImage() {
        print("Pressed Image button")
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { profileImage in
            self.titleImage = profileImage
            self.createEventTableview.reloadData()
        }
    }

    @objc func didTapDeleteButton() {
        titleImage = nil
        createEventTableview.reloadData()
    }
}
