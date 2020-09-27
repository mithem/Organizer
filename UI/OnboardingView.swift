//
//  OnboardingView.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 12.09.20.
//

import SwiftUI

struct OnboardingView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    
    let armed: Bool
    
    init(armed: Bool = true) {
        self.armed = armed
    }
    
    var body: some View {
        VStack() {
            Text("Organizer")
                .bold()
                .font(.largeTitle)
                .padding(.top, 50)
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 30) {
                    OnboardingFeatureListItem(image: "checkmark", color: Color("niceBlue"), title: "Export from Things", subtitle: "Select tasks > Share > Copy", subtitleAccessibilityValue: "Export from Things by selecting tasks, then tapping share, then copy.")
                    OnboardingFeatureListItem(image: "calendar", color: Color("niceGreen"), title: "Plan", subtitle: "Select times available", subtitleAccessibilityValue: nil)
                    OnboardingFeatureListItem(image: "square.and.arrow.up", color: .yellow, title: "Export to Calendar", subtitle: "You'll see your day in your calendar", subtitleAccessibilityValue: "Export to calendar and have a plan of your day.")
                }
                .padding(.horizontal, 60)
            }
            Spacer()
            Button(action: {
                save()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Finish")
                    .padding(.vertical)
                    .padding(.horizontal, 100)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(.bottom, 100)
            .accessibility(hint: Text("Close this screen"))
        }
    }
    
    func save() {
        if armed {
            UserDefaults().set(true, forKey: UserDefaultsKeys.didShowOnboardingView)
        }
    }
}

fileprivate struct OnboardingFeatureListItem: View {
    let image: String
    let color: Color
    let title: String
    let subtitle: String
    let subtitleAccessibilityValue: String?
    var body: some View {
        HStack {
            Image(systemName: image)
                .foregroundColor(color)
                .font(.system(size: 40, design: .rounded))
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                Group {
                    if let subtitleAccessibilityValue = subtitleAccessibilityValue {
                        Text(subtitle)
                            .accessibility(value: Text(subtitleAccessibilityValue))
                    } else {
                        Text(subtitle)
                    }
                }
                .font(.subheadline)
            }
            .padding(.leading)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
        
    }
}
