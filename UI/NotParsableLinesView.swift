//
//  NotParsableLinesView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 30.08.20.
//

import SwiftUI
import EventKit

struct NotParsableLinesView: View {
    
    var manager: ModalSheetViewDataManager
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            Text("We were unable to parse the following lines of Markdown:")
                .padding()
            List(manager.notParsableLines, id: \.self) { line in
                Text(line)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Parsing error")
            .navigationBarItems(trailing: Button("Done") {presentationMode.wrappedValue.dismiss()})
        }
    }
}

struct NotParsableLinesView_Previews: PreviewProvider {
    static var previews: some View {
        NotParsableLinesView(manager: ModalSheetViewDataManager())
    }
}
