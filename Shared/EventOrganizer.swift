//
//  EventOrganizer.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 23.08.20.
//

import Foundation
import EventKit

struct EventOrganizer {
    
    let dateComponentsForLimits: [(DateComponents, DateComponents)]
    let pauseEvery: TimeInterval
    let pauseLength: TimeInterval
    
    init(dateComponentsForLimits: [(DateComponents, DateComponents)], pauseEvery: TimeInterval? = nil, pauseLength: TimeInterval? = nil) {
        self.dateComponentsForLimits = dateComponentsForLimits
        if let pauseEvery = pauseEvery {
            self.pauseEvery = pauseEvery
        } else {
            self.pauseEvery = (PauseEveryTimeInterval(rawValue: UserDefaults().string(forKey: UserDefaultsKeys.pauseEveryTimeInterval) ?? "2h") ?? PauseEveryTimeInterval.h2).timeInterval
        }
        if let pauseLength = pauseLength {
            self.pauseLength = pauseLength
        } else {
            self.pauseLength = (PauseLengthTimeInterval(rawValue: UserDefaults().string(forKey: UserDefaultsKeys.pauseLengthTimeInterval) ?? "45 min") ?? PauseLengthTimeInterval.min45).timeInterval
        }
    }
    
    func _getLimits(for task: Task) -> [(Date, Date)] {
        var results = [(Date, Date)]()
        var limit1: Date
        var limit2: Date
        let taskDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: task.date)
        
        for (components1, components2) in dateComponentsForLimits {
            var limit1Components = DateComponents()
            limit1Components.year = taskDateComponents.year
            limit1Components.month = taskDateComponents.month
            limit1Components.day = taskDateComponents.day
            limit1Components.hour = components1.hour
            limit1Components.minute = components1.minute
            limit1 = Calendar.current.date(from: limit1Components)!
            
            var limit2Components = DateComponents()
            limit2Components.year = taskDateComponents.year
            limit2Components.month = taskDateComponents.month
            limit2Components.day = taskDateComponents.day
            limit2Components.hour = components2.hour
            limit2Components.minute = components2.minute
            limit2 = Calendar.current.date(from: limit2Components)!
            
            results.append((limit1, limit2))
        }
        
        return results
    }
    
    func _sortTasks(_ tasks: [Task]) -> [Task] {
        guard tasks.count > 0 else { return [] }
        var taskDict = [Date: [Task]]()
        var result = [Task]()
        for task in tasks {
                if taskDict[task.date] == nil {
                    taskDict[task.date] = [task]
                } else {
                    taskDict[task.date]?.append(task)
                }
        }
        let sortedKeys = Array(taskDict.keys).sorted()
        for key in sortedKeys {
            result.append(contentsOf: taskDict[key]!.sorted())
        }
        return result
    }
    
    func organize(tasks: [Task], with store: EKEventStore, for calendar: EKCalendar, progressCallback: (Float) -> Void) -> (events: [EKEvent], notOrganizedTasks: [Task]) {
        struct StopIteration: Error {}
        progressCallback(0.0)
        var events = [EKEvent]()
        var event: EKEvent
        var dateCursor: Date
        var endDate: Date
        var task: Task
        var idxCursor = 0
        var sorted = _sortTasks(tasks)
        let totalCount = sorted.count
        guard let first = sorted.first else { return (events: [], notOrganizedTasks: sorted) }
        var limits = _getLimits(for: first)
        var limitIdx = 0
        var limit1: Date
        var limit2: Date
        var tempLimits: [(Date, Date)]
        var notOrganized = [Task]()
        var progress: Float {
            Float(notOrganized.count + events.count) / Float(totalCount)
        }
        var workingSince: TimeInterval = 0
        
        outer: while limits.count > limitIdx {
            limit1 = limits[limitIdx].0
            limit2 = limits[limitIdx].1
            dateCursor = limit1
            while sorted.count > 0 {
                if idxCursor >= sorted.count {
                    break
                }
                if workingSince >= pauseEvery {
                    dateCursor += pauseLength
                    workingSince = 0
                }
                task = sorted[idxCursor]
                tempLimits = _getLimits(for: task)
                if tempLimits.first!.0 > limit2 {
                    limits = tempLimits
                    limit1 = limits[limitIdx].0
                    limit2 = limits[limitIdx].1
                    dateCursor = limit1
                    workingSince = 0
                }
                endDate = dateCursor + task.time
                if endDate > limit2 {
                    if limitIdx == limits.count - 1{
                        idxCursor += 1
                        if idxCursor >= limits.count {
                            if notOrganized.filter({$0.id == task.id}).count == 0 {
                                notOrganized.append(task)
                            }
                        }
                    } else {
                        break
                    }
                } else {
                    event = EKEvent(eventStore: store)
                    event.title = task.title
                    event.startDate = dateCursor
                    event.endDate = endDate
                    event.calendar = calendar
                    workingSince += task.time
                    events.append(event)
                    dateCursor = endDate
                    sorted.remove(at: idxCursor)
                    if idxCursor == sorted.count {
                        if sorted.count > 0 {
                            idxCursor -= 1
                        } else {
                            break outer
                        }
                    }
                }
                progressCallback(progress)
            }
            limitIdx += 1
        }
        events.sort()
        return (events: events, notOrganizedTasks: notOrganized)
    }
}
