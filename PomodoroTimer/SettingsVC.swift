//
//  SettingsVC.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 11/29/21.
//

import UIKit

class SettingsVC: UIViewController {
    
    let timer: PomodoroTimer
    var onDismiss: ((PomodoroTimer) -> Void)?
    
    init(timer: PomodoroTimer, onDismiss: ((PomodoroTimer) -> Void)? = nil) {
        self.timer = timer
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var workTime: CustomStepper!
    var breakTime: CustomStepper!
    var rounds: CustomStepper!
    var autoStart: UISwitch!
    
    override func loadView() {
        view = UIScrollView()
        view.backgroundColor = .systemBackground
        
        let workLabel = UILabel()
        workLabel.translatesAutoresizingMaskIntoConstraints = false
        workLabel.text = "Work Time"
        workLabel.font = .systemFont(ofSize: 20)
        view.addSubview(workLabel)
        
        workTime = CustomStepper()
        workTime.minValue = 5
        workTime.maxValue = 95
        workTime.step = 5
        view.addSubview(workTime)
        
        let breakLabel = UILabel()
        breakLabel.translatesAutoresizingMaskIntoConstraints = false
        breakLabel.text = "Break Time"
        breakLabel.font = .systemFont(ofSize: 20)
        view.addSubview(breakLabel)
        
        breakTime = CustomStepper()
        breakTime.minValue = 1
        breakTime.maxValue = 30
        view.addSubview(breakTime)
        
        let roundsLabel = UILabel()
        roundsLabel.translatesAutoresizingMaskIntoConstraints = false
        roundsLabel.text = "Rounds"
        roundsLabel.font = .systemFont(ofSize: 20)
        view.addSubview(roundsLabel)
        
        rounds = CustomStepper()
        view.addSubview(rounds)
        
        let autoStartLabel = UILabel()
        autoStartLabel.translatesAutoresizingMaskIntoConstraints = false
        autoStartLabel.text = "Auto Start Next Round"
        autoStartLabel.font = .systemFont(ofSize: 20)
        view.addSubview(autoStartLabel)
        
        autoStart = UISwitch()
        autoStart.translatesAutoresizingMaskIntoConstraints = false
        autoStart.onTintColor = .systemPink
        view.addSubview(autoStart)
        
        NSLayoutConstraint.activate([
            // Work
            workLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 25),
            workLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            workTime.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            workTime.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            workTime.topAnchor.constraint(equalTo: workLabel.bottomAnchor, constant: 5),
            
            // Break
            breakLabel.topAnchor.constraint(equalTo: workTime.bottomAnchor, constant: 25),
            breakLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            breakTime.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            breakTime.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            breakTime.topAnchor.constraint(equalTo: breakLabel.bottomAnchor, constant: 5),
            
            // Rounds
            roundsLabel.topAnchor.constraint(equalTo: breakTime.bottomAnchor, constant: 25),
            roundsLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            rounds.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            rounds.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            rounds.topAnchor.constraint(equalTo: roundsLabel.bottomAnchor, constant: 5),
            
            // Auto Start
            autoStartLabel.topAnchor.constraint(equalTo: rounds.bottomAnchor, constant: 30),
            autoStartLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            autoStartLabel.trailingAnchor.constraint(equalTo: autoStart.leadingAnchor),
            autoStartLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            autoStart.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            autoStart.bottomAnchor.constraint(equalTo: autoStartLabel.bottomAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem?.tintColor = .systemPink
        navigationItem.leftBarButtonItem?.tintColor = .systemPink
        
        workTime.value = Int(timer.workTime / 60.0)
        breakTime.value = Int(timer.breakTime / 60.0)
        rounds.value = timer.numRounds
        autoStart.setOn(timer.autoStart, animated: false)
    }
    
    @objc func done() {
        let timer = PomodoroTimer(workTime: workTime.value,
                                  breakTime: breakTime.value,
                                  numRounds: rounds.value,
                                  autoStart: autoStart.isOn)
        timer.delegate = self.timer.delegate
        
        onDismiss?(timer)
        dismiss(animated: true)
    }
    
    @objc func cancel() {
        dismiss(animated: true)
    }
    
}
