//
//  ViewController.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 11/15/21.
//

import UIKit


class ViewController: UIViewController {
    
    var timer = PomodoroTimer(workTime: 1, breakTime: 1, /*longBreakTime: 1,*/ numRounds: 3)
    
    var ring: ProgressRing!
    var timeLabel: UILabel!
    var startButton: UIButton!
    
    override func loadView() {
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        view.addSubview(stack)
        
        let roundLabel = UILabel()
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.font = .systemFont(ofSize: 25)
        roundLabel.text = "Round 1"
        roundLabel.textAlignment = .center
        stack.addArrangedSubview(roundLabel)
        
        // Progress
        ring = ProgressRing()
        stack.addArrangedSubview(ring)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = "25:00"
        timeLabel.font = .monospacedSystemFont(ofSize: 50, weight: .bold)
        timeLabel.textAlignment = .center
        timeLabel.textColor = .systemPink
        ring.addSubview(timeLabel)
        
        // Start Button
        var startConfig = UIButton.Configuration.gray()
        startConfig.cornerStyle = .large
        startConfig.baseForegroundColor = .systemPink
        
        startButton = UIButton(configuration: startConfig, primaryAction: nil)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start", for: .normal)
        startButton.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
        stack.addArrangedSubview(startButton)
        
        // Settings Button
        var config = UIButton.Configuration.gray()
        config.cornerStyle = .capsule
        config.baseForegroundColor = .systemPink
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        stack.addArrangedSubview(button)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
            stack.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -50),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            timeLabel.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: ring.centerYAnchor),
            
//            startButton.heightAnchor.constraint(equalToConstant: 45),
//            startButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
            
            button.widthAnchor.constraint(equalToConstant: 45),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            
            ring.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            ring.heightAnchor.constraint(equalTo: ring.widthAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer.delegate = self
    }
    
    @objc func openSettings() {
        let settings = UINavigationController(rootViewController: SettingsVC())
        settings.modalPresentationStyle = .formSheet
        
        if let sheet = settings.sheetPresentationController {
            sheet.prefersGrabberVisible = true
        }
        
        present(settings, animated: true)
    }
    
    @objc func startPressed() {
        if timer.isPaused {
            timer.start()
            startButton.setTitle("Pause", for: .normal)
        } else {
            timer.pause()
            startButton.setTitle("Start", for: .normal)
        }
    }

}

extension ViewController: PomodoroTimerDelegate {
    func syncTime(timer: PomodoroTimer) {
        let (minutes, seconds) = timer.minAndSecRemaining
        timeLabel.text = "\(minutes):\(String(format: "%02d", seconds))"
        
        let ratio = timer.ratioRemaining
        ring.progress = ratio
    }
}
