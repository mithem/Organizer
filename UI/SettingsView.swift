//
//  SettingsView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 23.08.20.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(UserDefaultsKeys.showCalendarAppAfterExport) var showCalendarAppAFterExport = false
    @AppStorage(UserDefaultsKeys.pauseEveryTimeInterval) var pauseEvery = PauseEveryTimeInterval.h3.rawValue
    @AppStorage(UserDefaultsKeys.pauseLengthTimeInterval) var pauseLength = PauseLengthTimeInterval.min45.rawValue
    
    var body: some View {
        Form {
            Toggle("Show calendar app after export", isOn: $showCalendarAppAFterExport)
            Picker("Pause every", selection: $pauseEvery) {
                ForEach(PauseEveryTimeInterval.allCases) { value in
                    Text(value.rawValue).tag(value.rawValue)
                }
            }
            Picker("Pause length", selection: $pauseLength) {
                ForEach(PauseLengthTimeInterval.allCases) { value in
                    Text(value.rawValue).tag(value)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
