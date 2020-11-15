//
//  LoadingIndicator.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 14.11.20.
//

import SwiftUI

struct LoadingIndicator: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Loading...")
        }
    }
}

struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicator()
    }
}
