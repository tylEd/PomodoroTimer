//
//  PomodoroTimer.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 12/1/21.
//

import UIKit

class PomodoroTimer {
    
    let workMinutes: Int
    let breakMinutes: Int
    let numRounds: Int
    let autoStart: Bool
    
    var workSeconds: Double { Double(workMinutes) * 60.0 }
    var breakSeconds: Double { Double(breakMinutes) * 60.0 }
    
    private(set) var secondsRemaining: CFTimeInterval
    private(set) var currentRound: Int
    private(set) var currentState: State
    enum State {
        case Work
        case Break
        case Finished
    }
    
    private var displayLink: CADisplayLink!
    private var lastSyncTime: CFTimeInterval = 0
    
    var delegate: PomodoroTimerDelegate?
    
    var minAndSecRemaining: (Int, Int) {
        let time = round(secondsRemaining)
        let minutes = Int(time / 60.0)
        let seconds = Int(time) - (minutes * 60)
        return (minutes, seconds)
    }
    
    var ratioRemaining: Double {
        switch currentState {
        case .Work:
            return secondsRemaining / workSeconds
        case .Break:
            return secondsRemaining / breakSeconds
        case .Finished:
            return 0.0
        }
    }
    
    var isLastRound: Bool { currentRound + 1 == numRounds }
    
    init(workMinutes: Int = 25,
         breakMinutes: Int = 5,
         numRounds: Int = 4,
         autoStart: Bool = false)
    {
        self.workMinutes = workMinutes
        self.breakMinutes = breakMinutes
        self.numRounds = numRounds
        self.autoStart = autoStart
        
        self.secondsRemaining = Double(workMinutes) * 60.0
        self.currentRound = 0
        self.currentState = .Work
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(syncTime))
        self.displayLink.preferredFramesPerSecond = 15
        self.displayLink.add(to: .main, forMode: .common)
        self.displayLink.isPaused = true
        
        reset()
    }
    
    deinit {
        self.displayLink.invalidate()
    }
    
    func reset() {
        self.secondsRemaining = self.workSeconds
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
            secondsRemaining -= interval
            if secondsRemaining <= 0.0 {
                endWork()
            }
            
        case .Break:
            secondsRemaining -= interval
            if secondsRemaining <= 0.0 {
                endBreak()
            }
            
        default:
            break
        }
        
        delegate?.syncTime(timer: self)
    }
    
    private func startWork() {
        self.currentState = .Work
        secondsRemaining = workSeconds
        if !autoStart {
            displayLink.isPaused = true
        }
        
        delegate?.onWorkStart()
    }
    
    private func endWork() {
        currentRound += 1
        if currentRound == numRounds {
            currentState = .Finished
            secondsRemaining = 0.0
            delegate?.onFinish()
        } else {
            delegate?.onWorkEnd()
            startBreak()
        }
    }
    
    private func startBreak() {
        self.currentState = .Break
        secondsRemaining = breakSeconds
        if !autoStart {
            displayLink.isPaused = true
        }
        
        delegate?.onBreakStart()
    }
    
    private func endBreak() {
        delegate?.onBreakEnd()
        startWork()
    }
    
}
