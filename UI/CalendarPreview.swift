//
//  CalendarPreview.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 14.11.20.
//

import SwiftUI
import EventKitUI

struct CalendarPreview: View {
    @ObservedObject var manager: ExportReportDataManager
    let delegate: ModalSheetDelegate
    var body: some View {
        List {
            if manager.exportedEvents.isEmpty {
                Text("No events were exported.")
            } else {
                Text("The following events were exported.")
                ForEach(manager.exportedEvents) { event in
                    EventView(event: event)
                }
            }
            Button("Finish") {
                delegate.dismiss()
            }
            .buttonStyle(CustomButtonStyle())
        }
        .navigationTitle("Calendar preview")
    }
}

struct CalendarPreview_Previews: PreviewProvider, ModalSheetDelegate {
    func dismiss() {}
    
    static var previews: some View {
        CalendarPreview(manager: ExportReportDataManager(), delegate: self as! ModalSheetDelegate)
    }
}
