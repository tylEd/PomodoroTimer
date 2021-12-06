//
//  PomodoroTimer.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 12/1/21.
//

import UIKit

class PomodoroTimer {
    
    //NOTE: Stored in seconds
    let workTime: Double
    let breakTime: Double
    let numRounds: Int
    let autoStart: Bool
    
    private(set) var timeRemaining: CFTimeInterval
    private(set) var currentRound: Int
    private(set) var currentState: State
    enum State {
        case Delay
        case Work
        case Break
        
        case Finished
    }
    
    private var displayLink: CADisplayLink!
    private var lastSyncTime: CFTimeInterval = 0
    
    var delegate: PomodoroTimerDelegate?
    
    var minAndSecRemaining: (Int, Int) {
        let time = round(timeRemaining)
        let minutes = Int(time / 60.0)
        let seconds = Int(time) - (minutes * 60)
        return (minutes, seconds)
    }
    
    var ratioRemaining: Double {
        switch currentState {
        case .Delay:
            return 1.0
            
        case .Finished:
            return 0.0
            
        case .Work:
            return timeRemaining / workTime
        case .Break:
            return timeRemaining / breakTime
        }
    }
    
    init(workTime: Int = 25,
         breakTime: Int = 5,
         numRounds: Int = 4,
         autoStart: Bool = false)
    {
        //NOTE: Passed in minutes stored in seconds
        self.workTime = Double(workTime * 60)
        self.breakTime = Double(breakTime * 60)
        self.numRounds = numRounds
        self.autoStart = autoStart
        
        self.timeRemaining = self.workTime
        self.currentRound = 0
        self.currentState = .Work
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(syncTime))
        self.displayLink.preferredFramesPerSecond = 15
        self.displayLink.add(to: .main, forMode: .common)
        self.displayLink.isPaused = true
    }
    
    deinit {
        self.displayLink.invalidate()
    }
    
    func reset() {
        self.timeRemaining = self.workTime
        self.currentRound = 0
        self.currentState = .Work
        self.displayLink.isPaused = true
        
        delegate?.onReset()
    }
    
    func start() {
        switch currentState {
        case .Finished:
            break
            
        default:
            lastSyncTime = CACurrentMediaTime()
            displayLink.isPaused = false
        }
    }
    
    func pause() {
        displayLink.isPaused = true
    }
    
    var isPaused: Bool {
        displayLink.isPaused
    }
    
    @objc private func syncTime() {
        let now = CACurrentMediaTime()
        let interval = now - lastSyncTime
        lastSyncTime = now
        
        switch currentState {
        case .Work:
            timeRemaining -= interval
            if timeRemaining <= 0.0 {
                endWork()
            }
            
        case .Break:
            timeRemaining -= interval
            if timeRemaining <= 0.0 {
                endBreak()
            }
            
        default:
            break
        }
        
        delegate?.syncTime(timer: self)
    }
    
    private func startWork() {
        timeRemaining = workTime
        
        if autoStart {
            currentState = .Delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.currentState = .Work
            }
        } else {
            self.currentState = .Work
            displayLink.isPaused = true
        }
        
        delegate?.onWorkStart()
    }
    
    private func endWork() {
        currentRound += 1
        if currentRound == numRounds {
            currentState = .Finished
            timeRemaining = 0.0
            delegate?.onFinish()
        } else {
            delegate?.onWorkEnd()
            startBreak()
        }
    }
    
    private func startBreak() {
        timeRemaining = breakTime
        
        if autoStart {
            currentState = .Delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.currentState = .Break
            }
        } else {
            self.currentState = .Break
            displayLink.isPaused = true
        }
        
        delegate?.onBreakStart()
    }
    
    private func endBreak() {
        delegate?.onBreakEnd()
        startWork()
    }
    
}
