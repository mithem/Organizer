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
    
    @State private var showingOnboardingView = false
    
    var body: some View {
        Form {
            Section {
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
            Section {
                Button("How to use") {
                    showingOnboardingView = true
                }
                Button("Show next time") {
                    UserDefaults().set(false, forKey: UserDefaultsKeys.didShowOnboardingView)
                }
                .sheet(isPresented: $showingOnboardingView) {
                    OnboardingView()
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
