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
