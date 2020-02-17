//
//  Loader.swift
//  alltimecommunicator
//
//  Created by Droid5 on 17/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import NVActivityIndicatorView

class Loader {
    static let data = ActivityData(type: NVActivityIndicatorType.lineScale)

    internal static func show() {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(data, NVActivityIndicatorView.DEFAULT_FADE_IN_ANIMATION)
    }

    internal static func close() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(NVActivityIndicatorView.DEFAULT_FADE_OUT_ANIMATION)
    }
}
