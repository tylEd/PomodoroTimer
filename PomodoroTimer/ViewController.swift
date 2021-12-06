//
//  ViewController.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 11/15/21.
//

import UIKit

class ViewController: UIViewController {
    
    var timer = PomodoroTimer()
    
    var roundLabel: UILabel!
    var progressRing: ProgressRing!
    var timeLabel: UILabel!
    var startButton: UIButton!
    var resetButton: UIButton!
    var settingsButton: UIButton!
    
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
        
        // Timer Progress
        roundLabel = UILabel()
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.font = .systemFont(ofSize: 25)
        //roundLabel.text = "\(timer.currentRound) / \(timer.numRounds)"
        roundLabel.textAlignment = .center
        roundLabel.textColor = .secondaryLabel
        stack.addArrangedSubview(roundLabel)
        
        progressRing = ProgressRing()
        stack.addArrangedSubview(progressRing)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        //timeLabel.text = "25:00"
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 50, weight: .thin)
        timeLabel.textAlignment = .center
        timeLabel.textColor = .secondaryLabel
        progressRing.addSubview(timeLabel)
        
        // Buttons
        var circleBtnConfig = UIButton.Configuration.gray()
        circleBtnConfig.cornerStyle = .capsule
        circleBtnConfig.baseForegroundColor = .secondaryLabel
        
        startButton = UIButton(configuration: circleBtnConfig, primaryAction: nil)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        //startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        startButton.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
        stack.addArrangedSubview(startButton)
        
        var resetConfig = UIButton.Configuration.plain()
        resetConfig.baseForegroundColor = .secondaryLabel
        
        resetButton = UIButton(configuration: resetConfig, primaryAction: nil)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(resetPressed), for: .touchUpInside)
        stack.addArrangedSubview(resetButton)
        
        settingsButton = UIButton(configuration: circleBtnConfig, primaryAction: nil)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setImage(UIImage(systemName: "gear"), for: .normal)
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        stack.addArrangedSubview(settingsButton)
        
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
            stack.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -50),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            progressRing.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            progressRing.heightAnchor.constraint(equalTo: progressRing.widthAnchor),
            
            timeLabel.centerXAnchor.constraint(equalTo: progressRing.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: progressRing.centerYAnchor),
            
            startButton.widthAnchor.constraint(equalToConstant: 65),
            startButton.heightAnchor.constraint(equalTo: startButton.widthAnchor),
            
            settingsButton.widthAnchor.constraint(equalToConstant: 45),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer.delegate = self
        
        //TODO: Load timer settings from UserDefaults
        
        updateRoundsLabel()
        updateButtons()
        syncTime(timer: timer)
    }
    
    @objc func openSettings() {
        let settingsVC = SettingsVC(timer: timer, onDismiss: { [weak self] timer in
            self?.timer = timer
            self?.timer.reset()
            
            //TODO: Save settings to UserDefaults
        })
        
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.modalPresentationStyle = .formSheet
        present(settingsNav, animated: true)
    }
    
    @objc func resetPressed() {
        let ac = UIAlertController(title: "Reset Timer", message: "Are you sure you want to reset?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.timer.reset()
        })
        
        present(ac, animated: true)
    }
    
    @objc func startPressed() {
        settingsButton.alpha = 0
        
        if timer.isPaused {
            timer.start()
        } else {
            timer.pause()
        }
        
        updateButtons()
    }
    
    func updateButtons() {
        if timer.isPaused {
            startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            resetButton.alpha = 1
        } else {
            startButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            resetButton.alpha = 0
        }
    }
    
    func updateRoundsLabel() {
        roundLabel.text = "\(timer.currentRound) / \(timer.numRounds)"
    }
    
}

extension ViewController: PomodoroTimerDelegate {
    func syncTime(timer: PomodoroTimer) {
        let (minutes, seconds) = timer.minAndSecRemaining
        timeLabel.text = "\(minutes):\(String(format: "%02d", seconds))"
        
        let ratio = timer.ratioRemaining
        progressRing.progress = ratio
    }
    
    func onWorkStart() {
        progressRing.ringColor = .systemPink
        
        updateRoundsLabel()
        updateButtons()
        syncTime(timer: timer)
    }
    
    
    func onBreakStart() {
        progressRing.ringColor = .systemMint
        
        updateRoundsLabel()
        updateButtons()
        syncTime(timer: timer)
    }
    
    func onReset() {
        onWorkStart()
        settingsButton.alpha = 1
    }
    
    func onFinish() {
        onBreakStart()
        
        let ac = UIAlertController(title: "Yay!", message: "You've completed your time", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
            self?.timer.reset()
        })
        
        present(ac, animated: true)
    }
    
    //NOTE: I didn't want to find royalty free alarm sound
    //    func onWorkEnd() {
    //    func onBreakEnd() {
    //        var alarmSound: AVAudioPlayer?
    //
    //        let path = Bundle.main.path(forResource: "alarm.mp3", ofType: nil)!
    //        let url = URL(fileURLWithPath: path)
    //
    //        do {
    //            alarmSound = try AVAudioPlayer(contentsOf: url)
    //            alarmSound?.play()
    //        } catch {
    //            // Couldn't load sound
    //        }
    //    }
}
