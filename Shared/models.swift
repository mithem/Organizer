//
//  models.swift
//  Organizer
//
//  Created by Miguel Themann on 22.08.20.
//

import Foundation

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var time: TimeInterval
}

extension Task {
    var dateInterval: String {
        let formatter = DateIntervalFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date, to: date + time)
    }
}

extension Task: Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        let title = lhs.title == rhs.title
        let date = lhs.date == rhs.date
        let time = lhs.time == rhs.time
        return title && date && time
    }
}

extension Task: Comparable {
    static func < (lhs: Task, rhs: Task) -> Bool {
        
        if lhs.date < rhs.date { return true }
        else if lhs.date > rhs.date { return false }
        else if lhs.time > rhs.time { return true } // bigger times first
        else if lhs.time < rhs.time { return false }
        else if lhs.title < rhs.title { return true }
        
        return false
    }
}

//MARK: The ugliest enums in the world
// seriously, how can I do this beeettter??
// problem seems to be with the SwiftUI Picker?
enum PauseEveryTimeInterval: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case min15 = "15 min"
    case min30 = "30 min"
    case min45 = "45 min"
    case h1 = "1h"
    case h1m30 = "1h 30m"
    case h2 = "2h"
    case h2m30 = "2h 30m"
    case h3 = "3h"
    case h3m30 = "3h 30m"
    case h4 = "4h"
    case h4m30 = "4h 30m"
    case h5 = "5h"
    
    var timeInterval: TimeInterval {
        switch(self){
        case .min15:
            return 15 * 60
        case .min30:
            return 30 * 60
        case .min45:
            return 45 * 60
        case .h1:
            return 3600
        case .h1m30:
            return 3600 + 30 * 60
        case .h2:
            return 7200
        case .h2m30:
            return 7200 + 30 * 60
        case .h3:
            return 10800
        case .h3m30:
            return 10800 + 30 * 60
        case .h4:
            return 14400
        case .h4m30:
            return 14400 + 30 * 60
        case .h5:
            return 18000
        }
    }
}

enum PauseLengthTimeInterval: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case min15 = "15 min"
    case min30 = "30 min"
    case min45 = "45 min"
    case h1 = "1h"
    case h1m30 = "1h 30m"
    case h2 = "2h"
    case h2m30 = "2h 30m"
    case h3 = "3h"
    case h3m30 = "3h 30m"
    case h4 = "4h"
    case h4m30 = "4h 30m"
    case h5 = "5h"
    
    var timeInterval: TimeInterval {
        switch(self){
        case .min15:
            return 15 * 60
        case .min30:
            return 30 * 60
        case .min45:
            return 45 * 60
        case .h1:
            return 3600
        case .h1m30:
            return 3600 + 30 * 60
        case .h2:
            return 7200
        case .h2m30:
            return 7200 + 30 * 60
        case .h3:
            return 10800
        case .h3m30:
            return 10800 + 30 * 60
        case .h4:
            return 14400
        case .h4m30:
            return 14400 + 30 * 60
        case .h5:
            return 18000
        }
    }
}

enum EventAlarmOffset: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case none = "None"
    case zero = "At begin"
    case min1 = "1 min"
    case min2 = "2 min"
    case min3 = "3 min"
    case min5 = "5 min"
    case min10 = "10 min"
    case min15 = "15 min"
    case min20 = "20 min"
    case min25 = "25 min"
    case min30 = "30 min"
    
    var timeInterval: TimeInterval? {
        switch(self) {
        case .none:
            return nil
        case .zero:
            return 0
        case .min1:
            return -60
        case .min2:
            return -120
        case .min3:
            return -180
        case .min5:
            return -300
        case .min10:
            return -600
        case .min15:
            return -900
        case .min20:
            return -1200
        case .min25:
            return -1500
        case .min30:
            return -1800
        }
    }
}
