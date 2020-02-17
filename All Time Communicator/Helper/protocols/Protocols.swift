//
//  protocols.swift
//  alltimecommunicator
//
//  Created by Droid5 on 07/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

protocol CaseIterable {
    associatedtype AllCases: Collection where AllCases.Element == Self
    static var allCases: AllCases { get }
}
