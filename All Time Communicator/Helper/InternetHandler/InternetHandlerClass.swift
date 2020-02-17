//
//  InternetHandlerClass.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 11/01/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import SwiftEventBus
import UIKit
class InternetHandlerClass {
    static let sharedInstance = InternetHandlerClass()
    private var reachability: Reachability!
    let delegate = UIApplication.shared.delegate as? AppDelegate

    func observeReachability() {
        reachability = Reachability()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try reachability.startNotifier()
        } catch {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
            delegate?.isInternetAvailable = true
            DispatchQueue.global(qos: .userInitiated).async {
                // Perform task
                UnsentProcessObjectClass.ProcessAllUnsentMessages()
            }
            ACEventBusManager.postToEventBusforInternet(isInternetAvailable: true, notificationName: InternetStrings.internetAvailable)
        case .wifi:
            print("Network available via WiFi.")
            delegate?.isInternetAvailable = true
            DispatchQueue.global(qos: .userInitiated).async {
                // Perform task
                UnsentProcessObjectClass.ProcessAllUnsentMessages()
            }
            ACEventBusManager.postToEventBusforInternet(isInternetAvailable: true, notificationName: InternetStrings.internetAvailable)

        case .none:
            print("Network is not available.")
            delegate?.isInternetAvailable = false

            ACEventBusManager.postToEventBusforInternet(isInternetAvailable: false, notificationName: InternetStrings.internetAvailable)
        }
    }
}
