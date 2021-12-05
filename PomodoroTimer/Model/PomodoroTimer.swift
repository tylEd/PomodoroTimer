//
//  PomodoroTimer.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 12/1/21.
//

import UIKit


protocol PomodoroTimerDelegate {
    func syncTime(timer: PomodoroTimer)
    
    func onWorkStart()
    //func onWorkEnd()
    
    func onBreakStart()
    //func onBreakEnd()
    
    func onReset()
    
    func onFinish()
}

extension PomodoroTimerDelegate {
    func onWorkStart() {}
    //func onWorkEnd() {}
    
    func onBreakStart() {}
    //func onBreakEnd() {}
    
    func onReset() {}
    
    func onFinish() {}
}


class PomodoroTimer {
    
    //NOTE: Stored in seconds
    let workTime: Double
    let breakTime: Double
    let numRounds: Int
    let autoStart: Bool
    
    private(set) var timeRemaining: CFTimeInterval
    private(set) var currentRound: Int = 0
    private(set) var currentState: State = .Start
    enum State {
        case Start
        
        case Delay
        case Work
        case Break
        
        case Finished
    }
    
    var delegate: PomodoroTimerDelegate?
    
    //TODO: DisplayLink is probably insane overkill for a pomodoro timer.
    //      I'm just copying what I had from ClockClone for the StopWatch
    private var displayLink: CADisplayLink!
    private var lastSyncTime: CFTimeInterval = 0
    
    var minAndSecRemaining: (Int, Int) {
        let time = round(timeRemaining)
        let minutes = Int(time / 60.0)
        let seconds = Int(time) - (minutes * 60)
        return (minutes, seconds)
    }
    
    var ratioRemaining: Double {
        switch currentState {
        case .Start:
            fallthrough
        case .Delay:
            return 1.0
            
        case .Work:
            return timeRemaining / workTime
        case .Break:
            //TODO: LongBreak
            return timeRemaining / breakTime
            
        case .Finished:
            return 0.0
        }
    }
    
    init(workTime: Int = 25,
         breakTime: Int = 5,
         numRounds: Int = 4,
         autoStart: Bool = false)
    {
        //NOTE: Passed in minutes stored in seconds
        self.workTime = 10.0//Double(workTime * 60) TODO: put this back
        self.breakTime = 5.0//Double(breakTime * 60) TODO: put this back
        //self.longBreakTime = Double(longBreakTime * 60)
        self.numRounds = numRounds
        self.autoStart = false
        
        self.timeRemaining = self.workTime
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(syncTime))
        self.displayLink.preferredFramesPerSecond = 15
        self.displayLink.add(to: .main, forMode: .common)
        self.displayLink.isPaused = true
    }
    
    func reset() {
        self.timeRemaining = self.workTime
        self.currentRound = 0
        self.currentState = .Start
        self.displayLink.isPaused = true
        
        delegate?.onReset()
    }
    
    func start() {
        switch currentState {
        case .Finished:
            break
            
        case .Start:
            currentState = .Work
            fallthrough
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
        
        //let prev = timeRemaining
        if currentState != .Delay, currentState != .Finished {
            timeRemaining -= interval
        }
        
        if timeRemaining <= 0.0 {
            switch currentState {
            case .Work:
                currentRound += 1
                if currentRound == numRounds {
                    currentState = .Finished
                    timeRemaining = 0.0
                    delegate?.onFinish()
                    break
                } else {
                    startBreak()
                }
                
            case .Break:
                startWork()
                
            default:
                break
            }
        }
        
        delegate?.syncTime(timer: self)
    }
    
    func startBreak() {
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
    
    func startWork() {
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
    
}
