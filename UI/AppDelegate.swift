//
//  AppDelegate.swift
//  Organizer (iOS)
//
//  Created by Miguel Themann on 20.09.20.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Starting!")
        print(launchOptions) // doesn't seem to hold something when launched from Shortcuts..
        return true
    }
}
