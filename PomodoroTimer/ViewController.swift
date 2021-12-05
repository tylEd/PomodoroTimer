//
//  ViewController.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 11/15/21.
//

import UIKit


class ViewController: UIViewController {
    
    var timer = PomodoroTimer(workTime: 1, breakTime: 1, /*longBreakTime: 1,*/ numRounds: 2)
    
    var roundLabel: UILabel!
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
        
        roundLabel = UILabel()
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.font = .systemFont(ofSize: 25)
        roundLabel.text = "\(timer.currentRound) / \(timer.numRounds)"
        roundLabel.textAlignment = .center
        roundLabel.textColor = .secondaryLabel
        stack.addArrangedSubview(roundLabel)
        
        // Progress
        ring = ProgressRing()
        stack.addArrangedSubview(ring)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = "25:00"
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 50, weight: .thin)
        timeLabel.textAlignment = .center
        timeLabel.textColor = .secondaryLabel//.systemPink
        ring.addSubview(timeLabel)
        
        // Start Button
        var startConfig = UIButton.Configuration.gray()
        startConfig.cornerStyle = .capsule
        startConfig.baseForegroundColor = .secondaryLabel
        
        startButton = UIButton(configuration: startConfig, primaryAction: nil)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        //startButton.setTitle("Start", for: .normal)
        startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        startButton.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
        stack.addArrangedSubview(startButton)
        
        var resetConfig = UIButton.Configuration.plain()
        resetConfig.baseForegroundColor = .secondaryLabel
        
        let resetButton = UIButton(configuration: resetConfig, primaryAction: nil)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(resetPressed), for: .touchUpInside)
        stack.addArrangedSubview(resetButton)
        
        // Settings Button
        var config = UIButton.Configuration.gray()
        config.cornerStyle = .capsule
        config.baseForegroundColor = .secondaryLabel
        
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
            
            startButton.widthAnchor.constraint(equalToConstant: 65),
            startButton.heightAnchor.constraint(equalTo: button.widthAnchor),
            
            button.widthAnchor.constraint(equalToConstant: 45),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            
            ring.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            ring.heightAnchor.constraint(equalTo: ring.widthAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer.delegate = self
        self.syncTime(timer: timer)
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
            //NOTE: Could use a toggle function, but meh
            timer.start()
        } else {
            timer.pause()
        }
        
        updateStartButton()
    }
    
    func updateStartButton() {
        if timer.isPaused {
            startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            startButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @objc func resetPressed() {
        let ac = UIAlertController(title: "Reset Timer", message: "Are you sure you want to reset?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.timer.reset()
        })
        present(ac, animated: true)
    }
    
}

extension ViewController: PomodoroTimerDelegate {
    func syncTime(timer: PomodoroTimer) {
        let (minutes, seconds) = timer.minAndSecRemaining
        timeLabel.text = "\(minutes):\(String(format: "%02d", seconds))"
        
        let ratio = timer.ratioRemaining
        ring.progress = ratio
    }
    
    func onWorkStart() {
        ring.setColor(color: .systemPink)
        roundLabel.text = "\(timer.currentRound) / \(timer.numRounds)"
        updateStartButton()
        syncTime(timer: timer)
    }
    
    func onBreakStart() {
        ring.setColor(color: .systemMint)
        roundLabel.text = "\(timer.currentRound) / \(timer.numRounds)"
        updateStartButton()
        syncTime(timer: timer)
    }
    
    func onReset() {
        onWorkStart()
    }
    
    func onFinish() {
        onBreakStart()
        
        let ac = UIAlertController(title: "Yay!", message: "You've completed your time", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
            self?.timer.reset()
        })
        
        present(ac, animated: true)
    }
}
