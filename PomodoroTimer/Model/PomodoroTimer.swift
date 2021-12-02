//
//  PomodoroTimer.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 12/1/21.
//

import UIKit


protocol PomodoroTimerDelegate {
    func syncTime(timer: PomodoroTimer)
}


class PomodoroTimer {
    
    //NOTE: Stored in seconds
    let workTime: Double
    let breakTime: Double
    //let longBreakTime: Double
    let numRounds: Int
    
    //TODO: DisplayLink is probably insane overkill for a pomodoro timer.
    //      I'm just copying what I had from ClockClone for the StopWatch
    private var displayLink: CADisplayLink!
    private var lastSyncTime: CFTimeInterval = 0
    
    var delegate: PomodoroTimerDelegate?
    
    private(set) var timeRemaining: CFTimeInterval
    private(set) var currentRound: Int = 0
    private(set) var currentState: State = .Working
    
    enum State {
        case Working
        case Breaking
    }
    
    var minAndSecRemaining: (Int, Int) {
        let minutes = Int(timeRemaining / 60.0)
        let seconds = Int(timeRemaining) - (minutes * 60)
        return (minutes, seconds)
    }
    
    var ratioRemaining: Double {
        switch currentState {
        case .Working:
            return timeRemaining / workTime
        case .Breaking:
            //TODO: LongBreak
            return timeRemaining / breakTime
        }
    }
    
    init(workTime: Int = 25,
         breakTime: Int = 5,
         //longBreakTime: Int = 20,
         numRounds: Int = 4)
    {
        //NOTE: Passed in minutes stored in seconds
        self.workTime = Double(workTime * 60)
        self.breakTime = Double(breakTime * 60)
        //self.longBreakTime = Double(longBreakTime * 60)
        self.numRounds = numRounds
        
        self.timeRemaining = Double(workTime) * 60.0
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(syncTime))
        self.displayLink.preferredFramesPerSecond = 15
        self.displayLink.add(to: .main, forMode: .common)
        self.displayLink.isPaused = true
    }
    
    func start() {
        lastSyncTime = CACurrentMediaTime()
        displayLink.isPaused = false
    }
    
    func pause() {
        displayLink.isPaused = true
    }
    
    func stop() {
        timeRemaining = 25 * 60
        displayLink.isPaused = true
    }
    
    var isPaused: Bool {
        displayLink.isPaused
    }
    
    @objc private func syncTime() {
        let now = CACurrentMediaTime()
        let interval = now - lastSyncTime
        lastSyncTime = now
        
        //let prev = timeRemaining
        timeRemaining -= interval
        
        if timeRemaining <= 0.0 {
            switch currentState {
            case .Working:
                startBreak()
            case .Breaking:
                startWork()
            }
        }
        
        if let delegate = delegate//,
           //Int(prev) != Int(timeRemaining)
        //TODO: Calling this repeatedly causes more work than necessary in the ViewController, but I want this to animate the ring. Can I fix this? Should I try?
        {
            delegate.syncTime(timer: self)
        }
    }
    
    func startBreak() {
        timeRemaining = breakTime
        currentRound += 1
        currentState = .Breaking
        //TODO: Callback
    }
    
    func startWork() {
        timeRemaining = workTime
        currentState = .Working
        //TODO: Callback
    }
    
}
