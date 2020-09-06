//
//  TaskView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 06.09.20.
//

import SwiftUI

struct TaskView: View {
    let task: Task
    var body: some View {
        HStack {
            Text(task.title)
            Spacer()
            Text(task.dateInterval)
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView(task: tasksForPreview.first!)
    }
}
