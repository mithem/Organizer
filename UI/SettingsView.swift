//
//  SettingsView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 23.08.20.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(UserDefaultsKeys.showCalendarAppAfterExport) var showCalendarAppAFterExport = false
    @AppStorage(UserDefaultsKeys.clearEventsAfterExport) var clearEventsAfterExport = true
    
    var body: some View {
        Form {
            Toggle("Show calendar app after export", isOn: $showCalendarAppAFterExport)
            Toggle("Clear parsed events after export", isOn: $clearEventsAfterExport)
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
