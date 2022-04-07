//
//  WeatherApp.swift
//  Weather
//
//  Created by Lexline Johnson on 6/26/21.
//

import SwiftUI

@main
struct WeatherApp: App {
    @StateObject var locationManager = LocationManager()
    
    init() {
        // Register default UserDefaults values
        guard let path = Bundle.main.path(forResource: "Defaults", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String : Any] else { return }
        print(plist)
        let defaults = UserDefaults.standard
        defaults.register(defaults: plist)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
        }
    }
}
