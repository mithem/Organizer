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
        let t1 = lhs.title == rhs.title
        let d = lhs.date == rhs.date
        let t2 = lhs.time == rhs.time
        return t1 && d && t2
    }
}

extension Task: Comparable {
    static func < (lhs: Task, rhs: Task) -> Bool {
        return lhs.time > rhs.time
    }
}

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
