//
//  ExportReportDataManager.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 06.09.20.
//

import Foundation
import EventKit

class ExportReportDataManager: ObservableObject {
    @Published var notScheduledEvents: [EKEvent]
    @Published var notOrganizedTasks: [Task]
    @Published var notParsableLines: [String]
    @Published var exportedEvents: [EKEvent]
    @Published var error: Error?
    
    init() { // Kinda not so cool I cannot use self.reset() 😢
        notScheduledEvents = [EKEvent]()
        notOrganizedTasks = [Task]()
        notParsableLines = [String]()
        exportedEvents = [EKEvent]()
        error = nil
    }
    
    var hasItems: Bool {
        return !notScheduledEvents.isEmpty || !notOrganizedTasks.isEmpty || !notParsableLines.isEmpty
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.notScheduledEvents = [EKEvent]()
            self.notOrganizedTasks = [Task]()
            self.notParsableLines = [String]()
            self.exportedEvents = [EKEvent]()
            self.error = nil
        }
    }
}
