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
    
    func organize(tasks: [Task], with store: EKEventStore, for calendar: EKCalendar) -> (events: [EKEvent], notOrganizedTasks: [Task]) {
        var events = [EKEvent]()
        var event: EKEvent
        var dateCursor: Date
        var endDate: Date
        var task: Task
        var idxCursor = 0
        var sorted = tasks.sorted()
        guard let first = sorted.first else { return (events: [], notOrganizedTasks: sorted) }
        var limits = _getLimits(for: first)
        var limitIdx = 0
        var limit1: Date
        var limit2: Date
        var tempLimits: [(Date, Date)]
        var notOrganized = [Task]()
        
        while limits.count > limitIdx {
            limit1 = limits[limitIdx].0
            limit2 = limits[limitIdx].1
            dateCursor = limit1
            while sorted.count > 0 {
                if idxCursor >= sorted.count {
                    break
                }
                task = sorted[idxCursor]
                tempLimits = _getLimits(for: task)
                if tempLimits.first!.0 > limit2 {
                    limits = tempLimits
                    limit1 = limits[limitIdx].0
                    limit2 = limits[limitIdx].1
                    dateCursor = limit1
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
                    events.append(event)
                    dateCursor = endDate
                    sorted.remove(at: idxCursor)
                    if idxCursor == sorted.count {
                        if sorted.count > 0 {
                            idxCursor -= 1
                        } else {
                            return (events: events, notOrganizedTasks: notOrganized)
                        }
                    }
                }
            }
            limitIdx += 1
        }
        return (events: events, notOrganizedTasks: notOrganized)
    }
}
