//
//  IncomingMessageBubbleView.swift
//  ATC
//
//  Created by Suresh on 26/12/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import UIKit

public class ChatBubbleDesignHelper: NSObject {
    //// Cache

    private struct Cache {
        static let shadow: NSShadow = NSShadow(color: UIColor.lightGray, offset: CGSize(width: 0, height: 0), blurRadius: 2)
    }

    //// Shadows

    @objc public dynamic class var shadow: NSShadow { return Cache.shadow }

    //// Drawing Methods

    @objc public dynamic class func drawIncomingMessageChatBubble(mainFrame: CGRect = CGRect(x: 13, y: 5, width: 220, height: 109)) {
        //// General Declarations

        if let context = UIGraphicsGetCurrentContext() {
            //// Color Declarations
            let color = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

            //// Subframes
            let tailFrame = CGRect(x: mainFrame.minX, y: mainFrame.minY, width: 47, height: 19)
            let bottomHelperFrame = CGRect(x: mainFrame.minX + 10, y: mainFrame.minY + mainFrame.height - 8.5, width: 7, height: 8)
            let bottomHelperFrame2 = CGRect(x: mainFrame.minX + mainFrame.width - 7, y: mainFrame.minY, width: 7, height: 8)
            let bottomHelperFrame3 = CGRect(x: mainFrame.minX + mainFrame.width - 7, y: mainFrame.minY + mainFrame.height - 8.5, width: 7, height: 8)

            //// incomingChatBubble Drawing
            let incomingChatBubblePath = UIBezierPath()
            incomingChatBubblePath.move(to: CGPoint(x: tailFrame.minX + 0.21958 * tailFrame.width, y: tailFrame.minY + 0.00000 * tailFrame.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame2.minX + 0.14878 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + -0.00000 * bottomHelperFrame2.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame2.minX + 0.62695 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.03812 * bottomHelperFrame2.height), controlPoint1: CGPoint(x: bottomHelperFrame2.minX + 0.39388 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + -0.00000 * bottomHelperFrame2.height), controlPoint2: CGPoint(x: bottomHelperFrame2.minX + 0.51644 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.00000 * bottomHelperFrame2.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame2.minX + 0.64836 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.04360 * bottomHelperFrame2.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame2.minX + 0.95829 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.36754 * bottomHelperFrame2.height), controlPoint1: CGPoint(x: bottomHelperFrame2.minX + 0.79240 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.09839 * bottomHelperFrame2.height), controlPoint2: CGPoint(x: bottomHelperFrame2.minX + 0.90586 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.21699 * bottomHelperFrame2.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame2.minX + 1.00000 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.88970 * bottomHelperFrame2.height), controlPoint1: CGPoint(x: bottomHelperFrame2.minX + 1.00000 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.50542 * bottomHelperFrame2.height), controlPoint2: CGPoint(x: bottomHelperFrame2.minX + 1.00000 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.63351 * bottomHelperFrame2.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame3.minX + 1.00000 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.11030 * bottomHelperFrame3.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame3.minX + 0.96353 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.61009 * bottomHelperFrame3.height), controlPoint1: CGPoint(x: bottomHelperFrame3.minX + 1.00000 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.36649 * bottomHelperFrame3.height), controlPoint2: CGPoint(x: bottomHelperFrame3.minX + 1.00000 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.49458 * bottomHelperFrame3.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame3.minX + 0.95829 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.63246 * bottomHelperFrame3.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame3.minX + 0.64836 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.95640 * bottomHelperFrame3.height), controlPoint1: CGPoint(x: bottomHelperFrame3.minX + 0.90586 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.78301 * bottomHelperFrame3.height), controlPoint2: CGPoint(x: bottomHelperFrame3.minX + 0.79240 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.90161 * bottomHelperFrame3.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame3.minX + 0.14878 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 1.00000 * bottomHelperFrame3.height), controlPoint1: CGPoint(x: bottomHelperFrame3.minX + 0.51644 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 1.00000 * bottomHelperFrame3.height), controlPoint2: CGPoint(x: bottomHelperFrame3.minX + 0.39388 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 1.00000 * bottomHelperFrame3.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame.minX + 0.92933 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 1.00000 * bottomHelperFrame.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame.minX + 0.62048 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.96257 * bottomHelperFrame.height), controlPoint1: CGPoint(x: bottomHelperFrame.minX + 0.69377 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 1.00000 * bottomHelperFrame.height), controlPoint2: CGPoint(x: bottomHelperFrame.minX + 0.73195 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 1.00000 * bottomHelperFrame.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame.minX + 0.59889 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.95719 * bottomHelperFrame.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame.minX + 0.28627 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.63915 * bottomHelperFrame.height), controlPoint1: CGPoint(x: bottomHelperFrame.minX + 0.45360 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.90339 * bottomHelperFrame.height), controlPoint2: CGPoint(x: bottomHelperFrame.minX + 0.33915 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.78696 * bottomHelperFrame.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame.minX + 0.24420 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.12648 * bottomHelperFrame.height), controlPoint1: CGPoint(x: bottomHelperFrame.minX + 0.24420 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.50377 * bottomHelperFrame.height), controlPoint2: CGPoint(x: bottomHelperFrame.minX + 0.24420 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.37800 * bottomHelperFrame.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: tailFrame.minX + 0.25532 * tailFrame.width, y: tailFrame.minY + 0.73684 * tailFrame.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: tailFrame.minX + 0.00000 * tailFrame.width, y: tailFrame.minY + 0.00000 * tailFrame.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: tailFrame.minX + 0.21958 * tailFrame.width, y: tailFrame.minY + 0.00000 * tailFrame.height))
            incomingChatBubblePath.close()
            context.saveGState()
            context.setShadow(offset: ChatBubbleDesignHelper.shadow.shadowOffset, blur: ChatBubbleDesignHelper.shadow.shadowBlurRadius, color: (ChatBubbleDesignHelper.shadow.shadowColor as! UIColor).cgColor)
            color.setFill()
            incomingChatBubblePath.fill()
            context.restoreGState()
        }
    }

    @objc public dynamic class func drawOutGoingMessageChatBubble(mainFrame: CGRect = CGRect(x: 5, y: 3, width: 219, height: 111)) {
        //// General Declarations

        if let context = UIGraphicsGetCurrentContext() {
            //// Color Declarations
            let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR

            //// Subframes
            let tailFrame = CGRect(x: mainFrame.minX + mainFrame.width - 34, y: mainFrame.minY, width: 34, height: 22)
            let bottomHelperFrame = CGRect(x: mainFrame.minX, y: mainFrame.minY + mainFrame.height - 8, width: 7, height: 8)
            let bottomHelperFrame2 = CGRect(x: mainFrame.minX, y: mainFrame.minY, width: 7, height: 8)
            let bottomHelperFrame3 = CGRect(x: mainFrame.minX + mainFrame.width - 22, y: mainFrame.minY + mainFrame.height - 8, width: 10, height: 8)

            //// incomingChatBubble Drawing
            let incomingChatBubblePath = UIBezierPath()
            incomingChatBubblePath.move(to: CGPoint(x: tailFrame.minX + 0.64139 * tailFrame.width, y: tailFrame.minY + 0.00000 * tailFrame.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame2.minX + 0.83956 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + -0.00000 * bottomHelperFrame2.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame2.minX + 0.36794 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.03812 * bottomHelperFrame2.height), controlPoint1: CGPoint(x: bottomHelperFrame2.minX + 0.59781 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + -0.00000 * bottomHelperFrame2.height), controlPoint2: CGPoint(x: bottomHelperFrame2.minX + 0.47694 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.00000 * bottomHelperFrame2.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame2.minX + 0.34682 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.04360 * bottomHelperFrame2.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame2.minX + 0.04114 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.36754 * bottomHelperFrame2.height), controlPoint1: CGPoint(x: bottomHelperFrame2.minX + 0.20476 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.09839 * bottomHelperFrame2.height), controlPoint2: CGPoint(x: bottomHelperFrame2.minX + 0.09285 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.21699 * bottomHelperFrame2.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame2.minX + 0.00000 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.88970 * bottomHelperFrame2.height), controlPoint1: CGPoint(x: bottomHelperFrame2.minX + -0.00000 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.50542 * bottomHelperFrame2.height), controlPoint2: CGPoint(x: bottomHelperFrame2.minX + 0.00000 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.63351 * bottomHelperFrame2.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame.minX + 0.00000 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.04780 * bottomHelperFrame.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame.minX + 0.03597 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.54759 * bottomHelperFrame.height), controlPoint1: CGPoint(x: bottomHelperFrame.minX + 0.00000 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.30399 * bottomHelperFrame.height), controlPoint2: CGPoint(x: bottomHelperFrame.minX + 0.00000 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.43208 * bottomHelperFrame.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame.minX + 0.04114 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.56996 * bottomHelperFrame.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame.minX + 0.34682 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.89390 * bottomHelperFrame.height), controlPoint1: CGPoint(x: bottomHelperFrame.minX + 0.09285 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.72051 * bottomHelperFrame.height), controlPoint2: CGPoint(x: bottomHelperFrame.minX + 0.20476 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.83911 * bottomHelperFrame.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame.minX + 0.83956 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.93750 * bottomHelperFrame.height), controlPoint1: CGPoint(x: bottomHelperFrame.minX + 0.47694 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.93750 * bottomHelperFrame.height), controlPoint2: CGPoint(x: bottomHelperFrame.minX + 0.59781 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.93750 * bottomHelperFrame.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: bottomHelperFrame3.minX + 0.37071 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.93750 * bottomHelperFrame3.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame3.minX + 0.66195 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.86409 * bottomHelperFrame3.height), controlPoint1: CGPoint(x: bottomHelperFrame3.minX + 0.45906 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.93750 * bottomHelperFrame3.height), controlPoint2: CGPoint(x: bottomHelperFrame3.minX + 0.57166 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.91152 * bottomHelperFrame3.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame3.minX + 0.81468 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.70165 * bottomHelperFrame3.height), controlPoint1: CGPoint(x: bottomHelperFrame3.minX + 0.73787 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.82421 * bottomHelperFrame3.height), controlPoint2: CGPoint(x: bottomHelperFrame3.minX + 0.79801 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.76916 * bottomHelperFrame3.height))
            incomingChatBubblePath.addCurve(to: CGPoint(x: bottomHelperFrame3.minX + 0.84373 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.06398 * bottomHelperFrame3.height), controlPoint1: CGPoint(x: bottomHelperFrame3.minX + 0.84373 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.56627 * bottomHelperFrame3.height), controlPoint2: CGPoint(x: bottomHelperFrame3.minX + 0.84373 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.31550 * bottomHelperFrame3.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: tailFrame.minX + 0.59267 * tailFrame.width, y: tailFrame.minY + 0.60870 * tailFrame.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: tailFrame.minX + 0.91176 * tailFrame.width, y: tailFrame.minY + 0.00000 * tailFrame.height))
            incomingChatBubblePath.addLine(to: CGPoint(x: tailFrame.minX + 0.64139 * tailFrame.width, y: tailFrame.minY + 0.00000 * tailFrame.height))
            incomingChatBubblePath.close()
            context.saveGState()
            context.setShadow(offset: ChatBubbleDesignHelper.shadow.shadowOffset, blur: ChatBubbleDesignHelper.shadow.shadowBlurRadius, color: (ChatBubbleDesignHelper.shadow.shadowColor as! UIColor).cgColor)
            color3.setFill()
            incomingChatBubblePath.fill()
            context.restoreGState()
        }
    }

    @objc public dynamic class func drawOutGoingMessageChatBubbleWhilte(mainFrame: CGRect = CGRect(x: 5, y: 3, width: 216, height: 111)) {
        //// Subframes
        let tailFrame = CGRect(x: mainFrame.minX + mainFrame.width - 31, y: mainFrame.minY, width: 31, height: 16)
        let bottomHelperFrame = CGRect(x: mainFrame.minX, y: mainFrame.minY + mainFrame.height - 8, width: 7, height: 8)
        let bottomHelperFrame2 = CGRect(x: mainFrame.minX, y: mainFrame.minY, width: 7, height: 8)
        let bottomHelperFrame3 = CGRect(x: mainFrame.minX + mainFrame.width - 15, y: mainFrame.minY + mainFrame.height - 8, width: 9, height: 8)

        //// outGoing2 Drawing
        let outGoing2Path = UIBezierPath()
        outGoing2Path.move(to: CGPoint(x: tailFrame.minX + 0.79612 * tailFrame.width, y: tailFrame.minY + 0.00000 * tailFrame.height))
        outGoing2Path.addLine(to: CGPoint(x: bottomHelperFrame2.minX + 0.00000 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.00000 * bottomHelperFrame2.height))
        outGoing2Path.addCurve(to: CGPoint(x: bottomHelperFrame.minX + -0.00000 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.87500 * bottomHelperFrame.height), controlPoint1: CGPoint(x: bottomHelperFrame2.minX + 0.00000 * bottomHelperFrame2.width, y: bottomHelperFrame2.minY + 0.00000 * bottomHelperFrame2.height), controlPoint2: CGPoint(x: bottomHelperFrame.minX + 0.00000 * bottomHelperFrame.width, y: bottomHelperFrame.minY + 0.62500 * bottomHelperFrame.height))
        outGoing2Path.addLine(to: CGPoint(x: bottomHelperFrame3.minX + 0.77778 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.87500 * bottomHelperFrame3.height))
        outGoing2Path.addCurve(to: CGPoint(x: tailFrame.minX + 0.74194 * tailFrame.width, y: tailFrame.minY + 0.60870 * tailFrame.height), controlPoint1: CGPoint(x: bottomHelperFrame3.minX + 0.77778 * bottomHelperFrame3.width, y: bottomHelperFrame3.minY + 0.75000 * bottomHelperFrame3.height), controlPoint2: CGPoint(x: tailFrame.minX + 0.74194 * tailFrame.width, y: tailFrame.minY + 0.60870 * tailFrame.height))
        outGoing2Path.addLine(to: CGPoint(x: tailFrame.minX + 1.00000 * tailFrame.width, y: tailFrame.minY + 0.00000 * tailFrame.height))
        outGoing2Path.addLine(to: CGPoint(x: tailFrame.minX + 0.79612 * tailFrame.width, y: tailFrame.minY + 0.00000 * tailFrame.height))
        outGoing2Path.close()
        UIColor.white.setFill()
        outGoing2Path.fill()
    }

    @objc public dynamic class func drawOutGoingMessageChatBubbleNL(mainFrame: CGRect = CGRect(x: 5, y: 3, width: 219, height: 111)) {
        //// General Declarations

        if let context = UIGraphicsGetCurrentContext() {
            //// Color Declarations
            let color3 = COLOURS.APP_MEDIUM_GREEN_COLOR

            //// Subframes
            let frame = CGRect(x: mainFrame.minX, y: mainFrame.minY, width: 7, height: 7)
            let frame2 = CGRect(x: mainFrame.minX, y: mainFrame.minY + mainFrame.height - 7, width: 7, height: 7)
            let frame3 = CGRect(x: mainFrame.minX + mainFrame.width - 18, y: mainFrame.minY + mainFrame.height - 7, width: 7, height: 7)
            let frame4 = CGRect(x: mainFrame.minX + mainFrame.width - 18, y: mainFrame.minY, width: 7, height: 7)

            //// Rectangle Drawing
            let rectanglePath = UIBezierPath()
            rectanglePath.move(to: CGPoint(x: frame.minX + 0.86092 * frame.width, y: frame.minY + 0.00000 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: mainFrame.minX + 0.90855 * mainFrame.width, y: mainFrame.minY + 0.00000 * mainFrame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame4.minX + 0.19413 * frame4.width, y: frame4.minY + 0.03743 * frame4.height), controlPoint1: CGPoint(x: mainFrame.minX + 0.91648 * mainFrame.width, y: mainFrame.minY + 0.00000 * mainFrame.height), controlPoint2: CGPoint(x: frame4.minX + 0.08235 * frame4.width, y: frame4.minY + -0.00000 * frame4.height))
            rectanglePath.addLine(to: CGPoint(x: frame4.minX + 0.21578 * frame4.width, y: frame4.minY + 0.04281 * frame4.height))
            rectanglePath.addCurve(to: CGPoint(x: frame4.minX + 0.52924 * frame4.width, y: frame4.minY + 0.36085 * frame4.height), controlPoint1: CGPoint(x: frame4.minX + 0.36146 * frame4.width, y: frame4.minY + 0.09661 * frame4.height), controlPoint2: CGPoint(x: frame4.minX + 0.47622 * frame4.width, y: frame4.minY + 0.21304 * frame4.height))
            rectanglePath.addCurve(to: CGPoint(x: frame4.minX + 0.57143 * frame4.width, y: frame4.minY + 0.87352 * frame4.height), controlPoint1: CGPoint(x: frame4.minX + 0.57143 * frame4.width, y: frame4.minY + 0.49623 * frame4.height), controlPoint2: CGPoint(x: frame4.minX + 0.57143 * frame4.width, y: frame4.minY + 0.62200 * frame4.height))
            rectanglePath.addLine(to: CGPoint(x: frame3.minX + 0.57143 * frame3.width, y: frame3.minY + 0.12648 * frame3.height))
            rectanglePath.addCurve(to: CGPoint(x: frame3.minX + 0.53454 * frame3.width, y: frame3.minY + 0.61718 * frame3.height), controlPoint1: CGPoint(x: frame3.minX + 0.57143 * frame3.width, y: frame3.minY + 0.37800 * frame3.height), controlPoint2: CGPoint(x: frame3.minX + 0.57143 * frame3.width, y: frame3.minY + 0.50377 * frame3.height))
            rectanglePath.addLine(to: CGPoint(x: frame3.minX + 0.52924 * frame3.width, y: frame3.minY + 0.63915 * frame3.height))
            rectanglePath.addCurve(to: CGPoint(x: frame3.minX + 0.21578 * frame3.width, y: frame3.minY + 0.95719 * frame3.height), controlPoint1: CGPoint(x: frame3.minX + 0.47622 * frame3.width, y: frame3.minY + 0.78696 * frame3.height), controlPoint2: CGPoint(x: frame3.minX + 0.36146 * frame3.width, y: frame3.minY + 0.90339 * frame3.height))
            rectanglePath.addCurve(to: CGPoint(x: mainFrame.minX + 0.90855 * mainFrame.width, y: mainFrame.minY + 1.00000 * mainFrame.height), controlPoint1: CGPoint(x: frame3.minX + 0.08235 * frame3.width, y: frame3.minY + 1.00000 * frame3.height), controlPoint2: CGPoint(x: mainFrame.minX + 0.91648 * mainFrame.width, y: mainFrame.minY + 1.00000 * mainFrame.height))
            rectanglePath.addLine(to: CGPoint(x: frame2.minX + 0.86092 * frame2.width, y: frame2.minY + 1.00000 * frame2.height))
            rectanglePath.addCurve(to: CGPoint(x: frame2.minX + 0.37730 * frame2.width, y: frame2.minY + 0.96257 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.61302 * frame2.width, y: frame2.minY + 1.00000 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.48908 * frame2.width, y: frame2.minY + 1.00000 * frame2.height))
            rectanglePath.addLine(to: CGPoint(x: frame2.minX + 0.35565 * frame2.width, y: frame2.minY + 0.95719 * frame2.height))
            rectanglePath.addCurve(to: CGPoint(x: frame2.minX + 0.04219 * frame2.width, y: frame2.minY + 0.63915 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.20997 * frame2.width, y: frame2.minY + 0.90339 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.09521 * frame2.width, y: frame2.minY + 0.78696 * frame2.height))
            rectanglePath.addCurve(to: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.12648 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.50377 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.37800 * frame2.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.87352 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.03689 * frame.width, y: frame.minY + 0.38282 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.62200 * frame.height), controlPoint2: CGPoint(x: frame.minX + -0.00000 * frame.width, y: frame.minY + 0.49623 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.04219 * frame.width, y: frame.minY + 0.36085 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.35565 * frame.width, y: frame.minY + 0.04281 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.09521 * frame.width, y: frame.minY + 0.21304 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.20997 * frame.width, y: frame.minY + 0.09661 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.86092 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.48908 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.61302 * frame.width, y: frame.minY + 0.00000 * frame.height))
            rectanglePath.close()
            context.saveGState()
            context.setShadow(offset: ChatBubbleDesignHelper.shadow.shadowOffset, blur: ChatBubbleDesignHelper.shadow.shadowBlurRadius, color: (ChatBubbleDesignHelper.shadow.shadowColor as! UIColor).cgColor)
            color3.setFill()
            rectanglePath.fill()
            context.restoreGState()
        }
    }

    @objc public dynamic class func drawIncomingMessageChatBubbleNL(mainFrame: CGRect = CGRect(x: 13, y: 5, width: 220, height: 109)) {
        //// General Declarations
        if let context = UIGraphicsGetCurrentContext() {
            //// Color Declarations
            let color = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

            //// Subframes
            let frame = CGRect(x: mainFrame.minX + 10, y: mainFrame.minY, width: 7, height: 7)
            let frame2 = CGRect(x: mainFrame.minX + mainFrame.width - 7, y: mainFrame.minY, width: 7, height: 7)
            let frame3 = CGRect(x: mainFrame.minX + mainFrame.width - 7, y: mainFrame.minY + mainFrame.height - 7, width: 7, height: 7)
            let frame4 = CGRect(x: mainFrame.minX + 10, y: mainFrame.minY + mainFrame.height - 7, width: 7, height: 7)

            //// Rectangle Drawing
            let rectanglePath = UIBezierPath()
            rectanglePath.move(to: CGPoint(x: frame.minX + 0.87352 * frame.width, y: frame.minY + 0.00000 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame2.minX + 0.12648 * frame2.width, y: frame2.minY + 0.00000 * frame2.height))
            rectanglePath.addCurve(to: CGPoint(x: frame2.minX + 0.61718 * frame2.width, y: frame2.minY + 0.03743 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.37800 * frame2.width, y: frame2.minY + 0.00000 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.50377 * frame2.width, y: frame2.minY + -0.00000 * frame2.height))
            rectanglePath.addLine(to: CGPoint(x: frame2.minX + 0.63915 * frame2.width, y: frame2.minY + 0.04281 * frame2.height))
            rectanglePath.addCurve(to: CGPoint(x: frame2.minX + 0.95719 * frame2.width, y: frame2.minY + 0.36085 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.78696 * frame2.width, y: frame2.minY + 0.09661 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.90339 * frame2.width, y: frame2.minY + 0.21304 * frame2.height))
            rectanglePath.addCurve(to: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.87352 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.49623 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.62200 * frame2.height))
            rectanglePath.addLine(to: CGPoint(x: frame3.minX + 1.00000 * frame3.width, y: frame3.minY + 0.12648 * frame3.height))
            rectanglePath.addCurve(to: CGPoint(x: frame3.minX + 0.96257 * frame3.width, y: frame3.minY + 0.61718 * frame3.height), controlPoint1: CGPoint(x: frame3.minX + 1.00000 * frame3.width, y: frame3.minY + 0.37800 * frame3.height), controlPoint2: CGPoint(x: frame3.minX + 1.00000 * frame3.width, y: frame3.minY + 0.50377 * frame3.height))
            rectanglePath.addLine(to: CGPoint(x: frame3.minX + 0.95719 * frame3.width, y: frame3.minY + 0.63915 * frame3.height))
            rectanglePath.addCurve(to: CGPoint(x: frame3.minX + 0.63915 * frame3.width, y: frame3.minY + 0.95719 * frame3.height), controlPoint1: CGPoint(x: frame3.minX + 0.90339 * frame3.width, y: frame3.minY + 0.78696 * frame3.height), controlPoint2: CGPoint(x: frame3.minX + 0.78696 * frame3.width, y: frame3.minY + 0.90339 * frame3.height))
            rectanglePath.addCurve(to: CGPoint(x: frame3.minX + 0.12648 * frame3.width, y: frame3.minY + 1.00000 * frame3.height), controlPoint1: CGPoint(x: frame3.minX + 0.50377 * frame3.width, y: frame3.minY + 1.00000 * frame3.height), controlPoint2: CGPoint(x: frame3.minX + 0.37800 * frame3.width, y: frame3.minY + 1.00000 * frame3.height))
            rectanglePath.addLine(to: CGPoint(x: frame4.minX + 0.87352 * frame4.width, y: frame4.minY + 1.00000 * frame4.height))
            rectanglePath.addCurve(to: CGPoint(x: frame4.minX + 0.38282 * frame4.width, y: frame4.minY + 0.96257 * frame4.height), controlPoint1: CGPoint(x: frame4.minX + 0.62200 * frame4.width, y: frame4.minY + 1.00000 * frame4.height), controlPoint2: CGPoint(x: frame4.minX + 0.49623 * frame4.width, y: frame4.minY + 1.00000 * frame4.height))
            rectanglePath.addLine(to: CGPoint(x: frame4.minX + 0.36085 * frame4.width, y: frame4.minY + 0.95719 * frame4.height))
            rectanglePath.addCurve(to: CGPoint(x: frame4.minX + 0.04281 * frame4.width, y: frame4.minY + 0.63915 * frame4.height), controlPoint1: CGPoint(x: frame4.minX + 0.21304 * frame4.width, y: frame4.minY + 0.90339 * frame4.height), controlPoint2: CGPoint(x: frame4.minX + 0.09661 * frame4.width, y: frame4.minY + 0.78696 * frame4.height))
            rectanglePath.addCurve(to: CGPoint(x: frame4.minX + 0.00000 * frame4.width, y: frame4.minY + 0.12648 * frame4.height), controlPoint1: CGPoint(x: frame4.minX + 0.00000 * frame4.width, y: frame4.minY + 0.50377 * frame4.height), controlPoint2: CGPoint(x: frame4.minX + 0.00000 * frame4.width, y: frame4.minY + 0.37800 * frame4.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.87352 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.03743 * frame.width, y: frame.minY + 0.38282 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.62200 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.49623 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.04281 * frame.width, y: frame.minY + 0.36085 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.36085 * frame.width, y: frame.minY + 0.04281 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.09661 * frame.width, y: frame.minY + 0.21304 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.21304 * frame.width, y: frame.minY + 0.09661 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.87352 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.49623 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.62200 * frame.width, y: frame.minY + 0.00000 * frame.height))
            rectanglePath.close()
            context.saveGState()
            context.setShadow(offset: ChatBubbleDesignHelper.shadow.shadowOffset, blur: ChatBubbleDesignHelper.shadow.shadowBlurRadius, color: (ChatBubbleDesignHelper.shadow.shadowColor as! UIColor).cgColor)
            color.setFill()
            rectanglePath.fill()
            context.restoreGState()
        }
    }

    @objc public dynamic class func drawOutGoingMessageChatBubbleWhilteNL(mainFrame: CGRect = CGRect(x: 5, y: 3, width: 219, height: 111)) {
        //// General Declarations

        if let context = UIGraphicsGetCurrentContext() {
            //// Color Declarations
            let color = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

            //// Subframes
            let frame = CGRect(x: mainFrame.minX, y: mainFrame.minY, width: 7, height: 7)
            let frame2 = CGRect(x: mainFrame.minX, y: mainFrame.minY + mainFrame.height - 7, width: 7, height: 7)
            let frame3 = CGRect(x: mainFrame.minX + mainFrame.width - 18, y: mainFrame.minY + mainFrame.height - 7, width: 7, height: 7)
            let frame4 = CGRect(x: mainFrame.minX + mainFrame.width - 18, y: mainFrame.minY, width: 7, height: 7)

            //// Rectangle Drawing
            let rectanglePath = UIBezierPath()
            rectanglePath.move(to: CGPoint(x: frame.minX + 0.87352 * frame.width, y: frame.minY + 0.00000 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame4.minX + 0.12648 * frame4.width, y: frame4.minY + 0.00000 * frame4.height))
            rectanglePath.addCurve(to: CGPoint(x: frame4.minX + 0.61718 * frame4.width, y: frame4.minY + 0.03743 * frame4.height), controlPoint1: CGPoint(x: frame4.minX + 0.37800 * frame4.width, y: frame4.minY + 0.00000 * frame4.height), controlPoint2: CGPoint(x: frame4.minX + 0.50377 * frame4.width, y: frame4.minY + -0.00000 * frame4.height))
            rectanglePath.addLine(to: CGPoint(x: frame4.minX + 0.63915 * frame4.width, y: frame4.minY + 0.04281 * frame4.height))
            rectanglePath.addCurve(to: CGPoint(x: frame4.minX + 0.95719 * frame4.width, y: frame4.minY + 0.36085 * frame4.height), controlPoint1: CGPoint(x: frame4.minX + 0.78696 * frame4.width, y: frame4.minY + 0.09661 * frame4.height), controlPoint2: CGPoint(x: frame4.minX + 0.90339 * frame4.width, y: frame4.minY + 0.21304 * frame4.height))
            rectanglePath.addCurve(to: CGPoint(x: frame4.minX + 1.00000 * frame4.width, y: frame4.minY + 0.87352 * frame4.height), controlPoint1: CGPoint(x: frame4.minX + 1.00000 * frame4.width, y: frame4.minY + 0.49623 * frame4.height), controlPoint2: CGPoint(x: frame4.minX + 1.00000 * frame4.width, y: frame4.minY + 0.62200 * frame4.height))
            rectanglePath.addLine(to: CGPoint(x: frame3.minX + 1.00000 * frame3.width, y: frame3.minY + 0.12648 * frame3.height))
            rectanglePath.addCurve(to: CGPoint(x: frame3.minX + 0.96257 * frame3.width, y: frame3.minY + 0.61718 * frame3.height), controlPoint1: CGPoint(x: frame3.minX + 1.00000 * frame3.width, y: frame3.minY + 0.37800 * frame3.height), controlPoint2: CGPoint(x: frame3.minX + 1.00000 * frame3.width, y: frame3.minY + 0.50377 * frame3.height))
            rectanglePath.addLine(to: CGPoint(x: frame3.minX + 0.95719 * frame3.width, y: frame3.minY + 0.63915 * frame3.height))
            rectanglePath.addCurve(to: CGPoint(x: frame3.minX + 0.63915 * frame3.width, y: frame3.minY + 0.95719 * frame3.height), controlPoint1: CGPoint(x: frame3.minX + 0.90339 * frame3.width, y: frame3.minY + 0.78696 * frame3.height), controlPoint2: CGPoint(x: frame3.minX + 0.78696 * frame3.width, y: frame3.minY + 0.90339 * frame3.height))
            rectanglePath.addCurve(to: CGPoint(x: frame3.minX + 0.12648 * frame3.width, y: frame3.minY + 1.00000 * frame3.height), controlPoint1: CGPoint(x: frame3.minX + 0.50377 * frame3.width, y: frame3.minY + 1.00000 * frame3.height), controlPoint2: CGPoint(x: frame3.minX + 0.37800 * frame3.width, y: frame3.minY + 1.00000 * frame3.height))
            rectanglePath.addLine(to: CGPoint(x: frame2.minX + 0.87352 * frame2.width, y: frame2.minY + 1.00000 * frame2.height))
            rectanglePath.addCurve(to: CGPoint(x: frame2.minX + 0.38282 * frame2.width, y: frame2.minY + 0.96257 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.62200 * frame2.width, y: frame2.minY + 1.00000 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.49623 * frame2.width, y: frame2.minY + 1.00000 * frame2.height))
            rectanglePath.addLine(to: CGPoint(x: frame2.minX + 0.36085 * frame2.width, y: frame2.minY + 0.95719 * frame2.height))
            rectanglePath.addCurve(to: CGPoint(x: frame2.minX + 0.04281 * frame2.width, y: frame2.minY + 0.63915 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.21304 * frame2.width, y: frame2.minY + 0.90339 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.09661 * frame2.width, y: frame2.minY + 0.78696 * frame2.height))
            rectanglePath.addCurve(to: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.12648 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.50377 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.37800 * frame2.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.87352 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.03743 * frame.width, y: frame.minY + 0.38282 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.62200 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.49623 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.04281 * frame.width, y: frame.minY + 0.36085 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.36085 * frame.width, y: frame.minY + 0.04281 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.09661 * frame.width, y: frame.minY + 0.21304 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.21304 * frame.width, y: frame.minY + 0.09661 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.87352 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.49623 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.62200 * frame.width, y: frame.minY + 0.00000 * frame.height))
            rectanglePath.close()
            context.saveGState()
            context.setShadow(offset: ChatBubbleDesignHelper.shadow.shadowOffset, blur: ChatBubbleDesignHelper.shadow.shadowBlurRadius, color: (ChatBubbleDesignHelper.shadow.shadowColor as! UIColor).cgColor)
            color.setFill()
            rectanglePath.fill()
            context.restoreGState()
        }
    }

    //// Generated Images

    @objc public dynamic class func imageOfIncomingMessageChatBubble(imageSize: CGSize = CGSize(width: 220, height: 109)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        ChatBubbleDesignHelper.drawIncomingMessageChatBubble(mainFrame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

        let imageOfIncomingMessageChatBubble = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfIncomingMessageChatBubble
    }

    @objc public dynamic class func imageOfOutGoingMessageChatBubble(imageSize: CGSize = CGSize(width: 219, height: 111)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        ChatBubbleDesignHelper.drawOutGoingMessageChatBubble(mainFrame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

        let imageOfOutGoingMessageChatBubble = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfOutGoingMessageChatBubble
    }

    @objc public dynamic class func imageOfOutGoingMessageChatBubbleWhilte(imageSize: CGSize = CGSize(width: 216, height: 111)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        ChatBubbleDesignHelper.drawOutGoingMessageChatBubbleWhilte(mainFrame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

        let imageOfOutGoingMessageChatBubbleWhilte = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfOutGoingMessageChatBubbleWhilte
    }

    @objc public dynamic class func imageOfOutGoingMessageChatBubbleNL(imageSize: CGSize = CGSize(width: 219, height: 111)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        ChatBubbleDesignHelper.drawOutGoingMessageChatBubbleNL(mainFrame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

        let imageOfOutGoingMessageChatBubbleNL = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfOutGoingMessageChatBubbleNL
    }

    @objc public dynamic class func imageOfIncomingMessageChatBubbleNL(imageSize: CGSize = CGSize(width: 220, height: 109)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        ChatBubbleDesignHelper.drawIncomingMessageChatBubbleNL(mainFrame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

        let imageOfIncomingMessageChatBubbleNL = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfIncomingMessageChatBubbleNL
    }

    @objc public dynamic class func imageOfOutGoingMessageChatBubbleWhilteNL(imageSize: CGSize = CGSize(width: 219, height: 111)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        ChatBubbleDesignHelper.drawOutGoingMessageChatBubbleWhilteNL(mainFrame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

        let imageOfOutGoingMessageChatBubbleWhilteNL = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfOutGoingMessageChatBubbleWhilteNL
    }
}

private extension NSShadow {
    convenience init(color: AnyObject!, offset: CGSize, blurRadius: CGFloat) {
        self.init()
        shadowColor = color
        shadowOffset = offset
        shadowBlurRadius = blurRadius
    }
}
