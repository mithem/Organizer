//
//  CalendarPreview.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 14.11.20.
//

import SwiftUI
import EventKitUI

struct CalendarPreview: View {
    let store: EKEventStore
    @State private var events = [EKEvent]()
    @State private var loading = true
    var body: some View {
        NavigationView {
            Group {
                if loading {
                    List(events) { event in
                        EventView(event: event)
                    }
                } else {
                    LoadingIndicator()
                        .onAppear(perform: loadEvents)
                }
            }
            .navigationTitle("Overview")
        }
    }
    
    func loadEvents() {
        loading = true
        events = getEventsForToday(from: store)
        loading = false
    }
}

struct CalendarPreview_Previews: PreviewProvider {
    static var previews: some View {
        CalendarPreview(store: EKEventStore())
    }
}
