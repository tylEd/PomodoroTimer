//
//  ProgressRing.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 11/29/21.
//

import UIKit

class ProgressRing: UIView {
    
    private var bgRing = CAShapeLayer()
    private var colorRing = CAShapeLayer()
    
    var progress = 1.0 {
        didSet {
            colorRing.strokeEnd = progress
        }
    }
    
    let lineWidth: CGFloat = 10

    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        //TODO: This is not adaptive. Fix that.
        bgRing.strokeColor = UIColor.secondarySystemBackground.cgColor
        bgRing.lineWidth = lineWidth
        bgRing.fillColor = UIColor.clear.cgColor
        bgRing.strokeEnd = 1
        layer.addSublayer(bgRing)
        
        //TODO: This is not adaptive. Fix that for dark mode.
        colorRing.strokeColor = UIColor.systemPink.cgColor
        colorRing.lineWidth = lineWidth
        colorRing.lineCap = .round
        colorRing.fillColor = UIColor.clear.cgColor
        colorRing.strokeEnd = progress
        layer.addSublayer(colorRing)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    //TODO: Take me out.
    @objc func handleTap() {
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.toValue = 0
        anim.duration = 2
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        
        colorRing.add(anim, forKey: "ring_anim")
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
    }
    
}
