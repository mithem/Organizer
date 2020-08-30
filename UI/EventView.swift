//
//  EventView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 28.08.20.
//

import SwiftUI
import EventKit

struct EventView: View {
    let event: EKEvent
    var body: some View {
        HStack {
            Text(event.title)
            Spacer()
            Text(event.timeInterval)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: EKEvent())
    }
}
