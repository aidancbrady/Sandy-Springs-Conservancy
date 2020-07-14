//
//  CircularProgress.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 7/14/20.
//  Copyright © 2020 aidancbrady. All rights reserved.
//

import Foundation
import UIKit

class CircularProgressView : UIView {
    var trackLayer = CAShapeLayer()
    var progressLayer = CAShapeLayer()
    
    var trackColor = UIColor.white {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    var progressColor = UIColor.white {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeCircularPath()
    }
    
    func makeCircularPath() {
        layer.cornerRadius = frame.size.width / 2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: (frame.size.width - 1.5) / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 5.0
        trackLayer.strokeEnd = 1.0
        trackLayer.zPosition = 5
        layer.addSublayer(trackLayer)
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 5.0
        progressLayer.strokeEnd = 0.0
        progressLayer.zPosition = 10
        layer.addSublayer(progressLayer)
    }
    
    func setProgress(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .default)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "progress")
    }
}
