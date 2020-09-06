//
//  ContentView.swift
//  OrganizerAppClip
//
//  Created by Miguel Themann on 06.09.20.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @State private var label = "Hello. Paste below to export to your calendar."
    let store = EKEventStore()
    var body: some View {
        VStack {
            Text(label)
            Button(action: {
            copyFromPasteboardAndOrganizeTasks(delegate: self, beginComponents: Calendar.current.dateComponents([.hour, .minute], from: Date()), endComponents: Calendar.current.dateComponents([.hour, .minute], from: Date() + 86400))
            }) {
                ZStack {
                    Rectangle()
                        .frame(width: 100, height: 40)
                        .cornerRadius(10)
                        .foregroundColor(.blue)
                    Text("Paste")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            checkAuthStatus(with: store)
            checkForCalendar(with: store)
        }
    }
}

extension ContentView: CopyFromPasteboardAndOrganizeTasksDelegate {
    func beginOrganizing() {
        label = "Parsing & Organizing..."
    }
    
    func finishedOrganizing(events: [EKEvent], notOrganizedTasks: [Task], notParsableLines: [String]) {
        exportToCalendar(events: events, delegate: self)
    }
    
    func didNotFindValidMarkdown() {
        label = "Did not find valid Markdown."
    }
    
    func updateProgress(_ progress: Float) {}
}

extension ContentView: ExportToCalendarDelegate {
    func beginExport() {
        label = "Exporting to calendar..."
    }
    
    func exportComplete(unexportedItems: [EKEvent], showActionSheet: Bool) {
        label = "Exported to calendar. Couldn't export \(unexportedItems.count) items."
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
