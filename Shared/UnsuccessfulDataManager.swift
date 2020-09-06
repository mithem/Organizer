//
//  UnsuccessfulDataManager.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 06.09.20.
//

import Foundation
import EventKit

class UnsuccessfulDataManager: ObservableObject {
    @Published var notScheduledEvents: [EKEvent]
    @Published var notOrganizedTasks: [Task]
    @Published var notParsableLines: [String]
    
    init() {
        notScheduledEvents = [EKEvent]()
        notOrganizedTasks = [Task]()
        notParsableLines = [String]()
    }
    
    var hasItems: Bool {
        return !notScheduledEvents.isEmpty || !notOrganizedTasks.isEmpty || !notParsableLines.isEmpty
    }
}
