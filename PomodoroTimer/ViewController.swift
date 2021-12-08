//
//  ViewController.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 11/15/21.
//

import UIKit
import UserNotifications

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
        
        loadSettings()
        
        NotificationCenter.default.addObserver(self, selector: #selector(enterForground), name: UIApplication.didBecomeActiveNotification, object: nil)
        UNUserNotificationCenter.current().delegate = self
        
        updateRoundsLabel()
        updateButtons()
        syncTime(timer: timer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        registerLocalNotifications()
    }
    
    @objc func openSettings() {
        let settingsVC = SettingsVC(timer: timer, onDismiss: { [weak self] timer in
            self?.timer = timer
            self?.timer.reset()
            self?.saveSettings()
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
        
        scheduleAlarm()
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

//MARK: Timer Events

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
        
        scheduleAlarm()
    }
    
    func onBreakStart() {
        progressRing.ringColor = .systemMint
        
        updateRoundsLabel()
        updateButtons()
        syncTime(timer: timer)
        
        scheduleAlarm()
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
    
}

//MARK: Load and save settings

extension ViewController {
    
    static let workTimeKey = "workTime"
    static let breakTimeKey = "breakTime"
    static let numRoundsKey = "numRounds"
    static let autoStartKey = "autoStart"
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys
        
        let workTime = keys.contains(ViewController.workTimeKey) ? defaults.integer(forKey: ViewController.workTimeKey) : 25
        let breakTime = keys.contains(ViewController.workTimeKey) ? defaults.integer(forKey: ViewController.breakTimeKey) : 5
        let numRounds = keys.contains(ViewController.workTimeKey) ? defaults.integer(forKey: ViewController.numRoundsKey) : 4
        let autoStart = defaults.bool(forKey: ViewController.autoStartKey)
        
        timer = PomodoroTimer(workTime: workTime, breakTime: breakTime, numRounds: numRounds, autoStart: autoStart)
        timer.delegate = self
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        
        //TODO: This makes me think I might want to refactor how the workTime and breakTime are accessed. It would be better for then to be integers here.
        //      I'm thinking a totalTime alongside timeRemaining, or just calculating the multiplication each time. Might make other code more clean too.
        defaults.set(Int(timer.workTime / 60.0), forKey: ViewController.workTimeKey)
        defaults.set(Int(timer.breakTime / 60.0), forKey: ViewController.breakTimeKey)
        defaults.set(timer.numRounds, forKey: ViewController.numRoundsKey)
        defaults.set(timer.autoStart, forKey: ViewController.autoStartKey)
    }
    
}

//MARK: Notifications

extension ViewController: UNUserNotificationCenterDelegate {
    
    @objc func enterForground() {
        clearAllNotifications()
    }
    
    func registerLocalNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                //TODO: How to handle authorization
                print("yay")
            } else {
                print("uh-oh")
            }
        }
    }
    
    func clearAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func scheduleAlarm() {
        let center = UNUserNotificationCenter.current()
        clearAllNotifications()
        
        if !timer.isPaused {
            let title: String
            let body: String
            
            switch timer.currentState {
            case .Work:
                if timer.isLastRound {
                    title = "Yay!"
                    body = "You're all done!"
                } else {
                    title = "Break Time!"
                    body = "Take it easy for a few."
                }
                
            case .Break:
                title = "Work Time"
                body = "Let's get back to it."
                
            case .Finished:
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = "alarm"
            content.sound = .default //TODO: Custom alarm sound.
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timer.timeRemaining, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
}
