//
//  PomodoroTimerDelegate.swift
//  PomodoroTimer
//
//  Created by Tyler Edwards on 12/6/21.
//

import Foundation

protocol PomodoroTimerDelegate {
    func syncTime(timer: PomodoroTimer)
    
    func onWorkStart()
    func onWorkEnd()
    
    func onBreakStart()
    func onBreakEnd()
    
    func onReset()
    
    func onFinish()
}

extension PomodoroTimerDelegate {
    func onWorkStart() {}
    func onWorkEnd() {}
    
    func onBreakStart() {}
    func onBreakEnd() {}
    
    func onReset() {}
    
    func onFinish() {}
}
