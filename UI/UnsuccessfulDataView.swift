//
//  UnsuccessfulDataView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 06.09.20.
//

import SwiftUI
import EventKit

struct UnsuccessfulDataView: View {
    
    @ObservedObject var manager: ExportReportDataManager
    let store: EKEventStore
    let delegate: ModalSheetDelegate
    
    var body: some View {
        List {
            if !manager.notScheduledEvents.isEmpty {
                Section(header: Text("Unscheduled events")) {
                    ForEach(manager.notScheduledEvents) { event in
                        EventView(event: event)
                    }
                }
            }
            if !manager.notOrganizedTasks.isEmpty {
                Section(header: Text("Not organized tasks")) {
                    ForEach(manager.notOrganizedTasks) { task in
                        TaskView(task: task)
                    }
                }
            }
            if !manager.notParsableLines.isEmpty {
                Section(header: Text("Not parsable lines")) {
                    ForEach(manager.notParsableLines, id: \.self) { line in
                        Text(line)
                    }
                }
            }
            NavigationLink("Next", destination: CalendarPreview(manager: manager, delegate: self))
                .buttonStyle(CustomButtonStyle())
        }
    }
}

extension UnsuccessfulDataView: ModalSheetDelegate {
    func dismiss() {
        delegate.dismiss()
    }
}

struct UnsuccessfulDataView_Previews: PreviewProvider, ModalSheetDelegate {
    func dismiss() {}
    
    static var previews: some View {
        UnsuccessfulDataView(manager: ExportReportDataManager(), store: EKEventStore(), delegate: self as! ModalSheetDelegate)
    }
}
