//
//  Extensions.swift
//  Organizer
//
//  Created by Miguel Themann on 22.08.20.
//

import Foundation
import EventKit

extension String {
    // https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
}


extension NSRegularExpression {
    // https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}

extension EKEvent {
    open override func isEqual (_ object: Any?) -> Bool {
        let title = self.title == (object as? EKEvent)?.title
        let location = self.location == (object as? EKEvent)?.location
        let calendar = self.calendar == (object as? EKEvent)?.calendar
        let alarms = self.alarms == (object as? EKEvent)?.alarms
        let url = self.url == (object as? EKEvent)?.url
        let startDate = self.startDate == (object as? EKEvent)?.startDate
        let endDate = self.endDate == (object as? EKEvent)?.endDate
        let isAllDay = self.isAllDay == (object as? EKEvent)?.isAllDay
        return title && location && calendar && alarms && url && startDate && endDate && isAllDay
    }
    var timeInterval: String {
        let formatter = DateIntervalFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startDate, to: endDate)
    }
}

extension EKEvent: Identifiable {}

extension EKEvent: Comparable {
    public static func < (lhs: EKEvent, rhs: EKEvent) -> Bool {
        return lhs.startDate < rhs.startDate
    }
}
