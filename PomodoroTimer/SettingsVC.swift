//
//  SettingsVC.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 11/29/21.
//

import UIKit

class SettingsVC: UIViewController {
    
    var workTime: CustomStepper!
    
    override func loadView() {
        view = UIScrollView()
        view.backgroundColor = .systemBackground
        
        let workLabel = UILabel()
        workLabel.translatesAutoresizingMaskIntoConstraints = false
        workLabel.text = "Work Time"
        workLabel.font = .systemFont(ofSize: 20)
        view.addSubview(workLabel)
        
        workTime = CustomStepper()
        workTime.minValue = 20
        workTime.maxValue = 95
        workTime.value = 25
        workTime.step = 5
        workTime.delegate = self
        view.addSubview(workTime)
        
        let breakLabel = UILabel()
        breakLabel.translatesAutoresizingMaskIntoConstraints = false
        breakLabel.text = "Break Time"
        breakLabel.font = .systemFont(ofSize: 20)
        view.addSubview(breakLabel)
        let breakTime = CustomStepper()
        breakTime.minValue = 1
        breakTime.maxValue = 30
        breakTime.value = 5
        breakTime.delegate = self
        view.addSubview(breakTime)
        
        let longLabel = UILabel()
        longLabel.translatesAutoresizingMaskIntoConstraints = false
        longLabel.text = "Long Break"
        longLabel.font = .systemFont(ofSize: 20)
        view.addSubview(longLabel)
        let longBreakTime = CustomStepper()
        longBreakTime.minValue = 10
        longBreakTime.maxValue = 60
        longBreakTime.value = 20
        longBreakTime.step = 5
        longBreakTime.delegate = self
        view.addSubview(longBreakTime)
        
        let roundsLabel = UILabel()
        roundsLabel.translatesAutoresizingMaskIntoConstraints = false
        roundsLabel.text = "Rounds"
        roundsLabel.font = .systemFont(ofSize: 20)
        view.addSubview(roundsLabel)
        let rounds = CustomStepper()
        rounds.value = 4
        rounds.delegate = self
        view.addSubview(rounds)
        
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
            
            // Long Break
            longLabel.topAnchor.constraint(equalTo: breakTime.bottomAnchor, constant: 25),
            longLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            longBreakTime.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            longBreakTime.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            longBreakTime.topAnchor.constraint(equalTo: longLabel.bottomAnchor, constant: 5),
            
            // Rounds
            roundsLabel.topAnchor.constraint(equalTo: longBreakTime.bottomAnchor, constant: 25),
            roundsLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            rounds.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            rounds.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            rounds.topAnchor.constraint(equalTo: roundsLabel.bottomAnchor, constant: 5),
            
            rounds.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //TODO: Not sure why this isn't working.
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemPink]
        navigationItem.standardAppearance?.buttonAppearance = buttonAppearance
        navigationItem.compactAppearance?.buttonAppearance = buttonAppearance
    }
    
    @objc func done() {
        //if let presenter = presentingViewController as? ViewController {
        if let _ = presentingViewController as? ViewController {
            //TODO: Pass data back to the main ViewController
            //TODO: Should / Could this be done with a segue completely in code?
            print("Yep")
        }
        
        dismiss(animated: true)
    }
    
}

extension SettingsVC: CustomStepperDelegate {
    
    func valueDidChange(_ sender: CustomStepper) {
        if sender == workTime {
            print("yep")
        }
    }
    
}
