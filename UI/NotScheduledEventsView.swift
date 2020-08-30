//
//  NotScheduledEventsView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 28.08.20.
//

import SwiftUI
import EventKit

struct NotScheduledEventsView: View {
    
    let manager: ModalSheetViewDataManager
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            Text("We were unable to export/schedule the following events.")
            List(manager.notScheduledEvents) { event in
                EventView(event: event)
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

struct NotScheduledEventsView_Previews: PreviewProvider {
    static var previews: some View {
        NotScheduledEventsView(manager: ModalSheetViewDataManager())
    }
}
