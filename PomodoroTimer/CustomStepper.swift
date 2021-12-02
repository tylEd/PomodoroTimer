//
//  CustomStepper.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 11/29/21.
//

import UIKit

protocol CustomStepperDelegate {
    //TODO: This delegate might be unecessary, since the values can just be read from the steppers themselves.
    func valueDidChange(_ sender: CustomStepper)
}

class CustomStepper: UIStackView {
    
    var step = 1
    var minValue = 1
    var maxValue = 10
    var value = 5 {
        didSet {
            value = min(max(value, minValue), maxValue)
            label.text = "\(value)"
        }
    }
    
    private var label: UILabel!
    
    var delegate: CustomStepperDelegate?
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .fillEqually
        alignment = .center
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 10
        
        var config = UIButton.Configuration.tinted()
        config.cornerStyle = .capsule
        config.baseForegroundColor = .systemPink
        config.baseBackgroundColor = .systemPink
        
        let minusButton = UIButton(configuration: config, primaryAction: nil)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.setImage(UIImage(systemName: "minus"), for: .normal)
        minusButton.addTarget(self, action: #selector(minus), for: .touchUpInside)
        let minusContainer = UIView()
        minusContainer.translatesAutoresizingMaskIntoConstraints = false
        minusContainer.addSubview(minusButton)
        addArrangedSubview(minusContainer)
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(value)"
        label.textAlignment = .center
        label.font = .monospacedDigitSystemFont(ofSize: 50, weight: .bold)
        addArrangedSubview(label)
        
        let plusButton = UIButton(configuration: config, primaryAction: nil)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.addTarget(self, action: #selector(plus), for: .touchUpInside)
        let plusContainer = UIView()
        plusContainer.translatesAutoresizingMaskIntoConstraints = false
        plusContainer.addSubview(plusButton)
        addArrangedSubview(plusContainer)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: label.heightAnchor, multiplier: 1.5),
            
            minusButton.centerXAnchor.constraint(equalTo: minusContainer.centerXAnchor),
            minusButton.centerYAnchor.constraint(equalTo: minusContainer.centerYAnchor),
            
            plusButton.centerXAnchor.constraint(equalTo: plusContainer.centerXAnchor),
            plusButton.centerYAnchor.constraint(equalTo: plusContainer.centerYAnchor),
            
            minusContainer.heightAnchor.constraint(equalTo: heightAnchor),
            plusContainer.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func minus() {
        value -= step
        
        if let delegate = delegate {
            delegate.valueDidChange(self)
        }
    }
    
    @objc func plus() {
        value += step
        
        if let delegate = delegate {
            delegate.valueDidChange(self)
        }
    }
    
}
