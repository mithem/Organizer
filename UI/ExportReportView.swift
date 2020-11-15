//
//  ExportReportView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 15.11.20.
//

import SwiftUI
import EventKit

struct ExportReportView: View {
    
    @ObservedObject var manager: ExportReportDataManager
    let store: EKEventStore
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if let error = manager.error {
                    Text(error.localizedDescription)
                    NavigationLink("Next", destination: NextStep)
                        .buttonStyle(CustomButtonStyle())
                } else {
                    NextStep
                }
            }
            .navigationTitle("Report")
        }
    }
    
    var NextStep: some View {
        Group {
            if manager.hasItems {
                UnsuccessfulDataView(manager: manager, store: store, delegate: self)
            } else {
                CalendarPreview(manager: manager, delegate: self)
            }
        }
    }
}

extension ExportReportView: ModalSheetDelegate {
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct ExportReportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportReportView(manager: ExportReportDataManager(), store: EKEventStore())
    }
}
