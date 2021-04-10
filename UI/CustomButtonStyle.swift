//
//  CustomButtonStyle.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 15.11.20.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.accentColor)
                    .opacity(colorScheme == .dark ? 0.7 : 1)
            )
    }
}


struct CustomButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Button("Hello world", action: {})
                .preferredColorScheme(.dark)
            Button("Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum", action: {})
        }
        .buttonStyle(CustomButtonStyle())
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
