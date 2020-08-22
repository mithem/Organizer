//
//  MainScreen.swift
//  Organizer
//
//  Created by Miguel Themann on 22.08.20.
//

import SwiftUI

struct MainScreen: View {
    @State private var tasks = [Task]()
    @State private var showingDidNotFindValidMarkdownActionSheet = false
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    copyFromPasteboard()
                }) {
                    Text("Paste from clipboard/pasteboard")
                        .foregroundColor(.blue)
                }
                ForEach(tasks) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        Text(ISO8601DateFormatter().string(from: task.date))
                    }
                }
            }
            .navigationTitle("Organizer")
            .actionSheet(isPresented: $showingDidNotFindValidMarkdownActionSheet) {
                ActionSheet(title: Text("No data found"), message: Text("Unable to find valid markdown from Things."), buttons: [.default(Text("OK"))])
            }
        }
    }
    
    func copyFromPasteboard() {
        var tasks = [Task]()
        if UIPasteboard.general.hasStrings {
            if let strings = UIPasteboard.general.strings {
                let parser = MarkdownParser()
                for string in strings {
                    tasks.append(contentsOf: parser.parseTasks(from: string))
                }
            }
        }
        if tasks.count == 0 {
            showingDidNotFindValidMarkdownActionSheet = true
        } else {
            self.tasks = tasks
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
