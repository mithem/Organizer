//
//  NotOrganizedTasksView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 27.08.20.
//

import SwiftUI

struct NotOrganizedTasksView: View {
    
    let tasks: [Task]
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            Text("We were unable to organize/schedule some tasks. Please take care to export them manually or deal with them overwise")
            List(tasks) { task in
                HStack {
                    Text(task.title)
                    Spacer()
                    Text(task.dateInterval)
                }
            }
            .navigationTitle("Tasks not organized")
            .navigationBarItems(trailing: Button("Done")
            {
                presentationMode.wrappedValue.dismiss()
            }
            )
        }
    }
}

struct NotOrganizedTasksView_Previews: PreviewProvider {
    static var previews: some View {
        NotOrganizedTasksView(tasks: [Task(title: "Some task", date: Calendar.current.date(from: DateComponents(year: 2020, month: 8, day: 23, hour: 12, minute: 11, second: 36))!, time: 3600)])
    }
}
