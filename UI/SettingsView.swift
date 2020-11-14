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
    @AppStorage(UserDefaultsKeys.eventAlarmOffset) var eventAlarmOffset = EventAlarmOffset.none.rawValue
    
    @State private var showingOnboardingView = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Show calendar app after export", isOn: $showCalendarAppAFterExport)
                Picker("Pause every", selection: $pauseEvery) {
                    ForEach(PauseEveryTimeInterval.allCases) { value in
                        Text(value.rawValue)
                            .tag(value.rawValue)
                    }
                }
                .accessibility(label: Text("Pause every"))
                Picker("Pause length", selection: $pauseLength) {
                    ForEach(PauseLengthTimeInterval.allCases) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                .accessibility(label: Text("Pause length"))
                Toggle("Enable reminder", isOn: Binding(get: {eventAlarmOffset != EventAlarmOffset.none.rawValue}, set: {eventAlarmOffset = $0 ? EventAlarmOffset.min15.rawValue : EventAlarmOffset.none.rawValue}))
                if eventAlarmOffset != EventAlarmOffset.none.rawValue {
                    Picker("Remind before", selection: $eventAlarmOffset) {
                        ForEach(EventAlarmOffset.allCases) { value in
                            if value != .none {
                                Text(value.rawValue).tag(value.rawValue)
                            }
                        }
                    }
                }
            }
            Section {
                Button("How to use") {
                    showingOnboardingView = true
                }
                .accessibility(hint: Text("Show how to use screen"))
                Button("Show next time") {
                    UserDefaults().set(false, forKey: UserDefaultsKeys.didShowOnboardingView)
                }
                .accessibility(hint: Text("Show hoe to use screen next time opening the app"))
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
