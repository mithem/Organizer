//
//  ModalSheetViewDataManager.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 30.08.20.
//

import EventKit

class ModalSheetViewDataManager {
    @Published var notScheduledEvents: [EKEvent]
    @Published var notOrganizedTasks: [Task]
    @Published var notParsableLines: [String]
    
    init() {
        notScheduledEvents = []
        notOrganizedTasks = []
        notParsableLines = []
    }
}
