//
//  SettingsView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 23.08.20.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("showCalendarAppAfterExport") var showCalendarAppAFterExport: Bool = false
    
    var body: some View {
        ScrollView {
            Toggle("Show calendar app after export", isOn: $showCalendarAppAFterExport)
                .padding(.horizontal)
        }
        .navigationTitle("Settigs")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
