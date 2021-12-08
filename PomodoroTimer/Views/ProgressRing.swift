//
//  ProgressRing.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 11/29/21.
//

import UIKit

class ProgressRing: UIView {
    
    let lineWidth: CGFloat = 10
    
    private var bgRing = CAShapeLayer()
    private var colorRing = CAShapeLayer()
    var ringColor = UIColor.systemPink {
        didSet {
            colorRing.strokeColor = ringColor.cgColor
        }
    }
    
    var progress = 1.0 {
        didSet {
            colorRing.strokeEnd = progress
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        bgRing.lineWidth = lineWidth
        bgRing.fillColor = UIColor.clear.cgColor
        bgRing.strokeEnd = 1
        layer.addSublayer(bgRing)
        
        colorRing.lineWidth = lineWidth
        colorRing.lineCap = .round
        colorRing.fillColor = UIColor.clear.cgColor
        colorRing.strokeEnd = progress
        layer.addSublayer(colorRing)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let startAngle = -CGFloat.pi / 2
        let endAngle = (2 * CGFloat.pi) - (CGFloat.pi / 2)
        let radius = (min(bounds.width, bounds.height) / 2) - (lineWidth / 2)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        bgRing.path = circlePath.cgPath
        colorRing.path = circlePath.cgPath
        
        //NOTE: layoutSubviews is called when appearance changes
        bgRing.strokeColor = UIColor.secondarySystemBackground.cgColor
        colorRing.strokeColor = ringColor.cgColor
    }
    
}
