//
//  CreateGroup_BroadcastsViewController.swift
//  alltimecommunicator
//
//  Created by Suresh Mopidevi on 31/10/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

class CreateGroup_BroadcastsViewController: UIViewController {
    @IBOutlet var chatGroup: UIButton!
    @IBOutlet var privateBroadCast: UIButton!
    @IBOutlet var publicBroadCast: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
//        privateBroadCast.isEnabled = false
//        publicBroadCast.isEnabled = false
        // let searchButton = UIBarButtonItem(image:  UIImage(named: "NavSearch"),  style: .plain, target: self, action: #selector(didTapSearchButton))
//         navigationItem.rightBarButtonItem = searchButton

//
//        if let navigator = navigationController {
//            let backItem = UIBarButtonItem()
//            backItem.title = "Create group"
//            navigator.navigationItem.backBarButtonItem = backItem
//        }
    }

    @IBAction func createChatGroup(_: Any) {
        print(" clicked creating groupchat Button")
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "CreateNewGroupViewController") as? CreateNewGroupViewController {
            if let navigator = navigationController {
                nextViewController.hidesBottomBarWhenPushed = true
                nextViewController.chatGroup = true
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "Group chat", style: .plain, target: nil, action: nil)

                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    @IBAction func createPrivateBroadCastGroup(_: Any) {
        print(" clicked creating groupchat Button")
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "ACCreateSpeakerGroupViewController") as? ACCreateSpeakerGroupViewController {
            if let navigator = navigationController {
                nextViewController.hidesBottomBarWhenPushed = true
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    @IBAction func createPublicBroadCastgroup(_: Any) {
        print(" clicked creating groupchat Button")
        if let nextViewController = UIStoryboard(name: "OnBoarding", bundle: nil).instantiateViewController(withIdentifier: "CreateNewGroupViewController") as? CreateNewGroupViewController {
            if let navigator = navigationController {
                nextViewController.hidesBottomBarWhenPushed = true
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

                nextViewController.privateBroadCast = true
                navigator.pushViewController(nextViewController, animated: true)
            }
        }
    }

    @objc func didTapSearchButton() {}
}
