//
//  UnsuccessfulDataView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 06.09.20.
//

import SwiftUI

struct UnsuccessfulDataView: View {
    @ObservedObject var manager: UnsuccessfulDataManager
    @Environment(\.presentationMode) private var presentationMode
    var body: some View {
        NavigationView {
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
                if !manager.hasItems {
                    EmptyView()
                        .onAppear {
                            presentationMode.wrappedValue.dismiss()
                        }
                }
            }
            .navigationTitle("Errors")
            .navigationBarItems(trailing: Button("Done"){
                presentationMode.wrappedValue.dismiss()
            }.padding())
        }
    }
}

struct UnsuccessfulDataView_Previews: PreviewProvider {
    static var previews: some View {
        UnsuccessfulDataView(manager: UnsuccessfulDataManager())
    }
}
