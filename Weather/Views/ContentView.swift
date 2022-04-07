//
//  ContentView.swift
//  Weather
//
//  Created by Lexline Johnson on 6/26/21.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var savedLocations = SavedLocations()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            SavedView(savedLocations: savedLocations)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }

            SearchView(savedLocations: savedLocations)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .onAppear {
            // Set tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .light)

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class SavedLocations: ObservableObject {
    @Published var locations: [CLPlacemark]
    
    init() {
        self.locations = []
        let defaults = UserDefaults.standard
        guard let locations = defaults.array(forKey: "savedLocations") as? [[CLLocationDegrees]] else { return }
        for location in locations {
            self.addLocation(CLLocation(latitude: location[0], longitude: location[1]))
        }
    }
    
    func addLocation(_ clLocation: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            print("geocoding in class...")
            guard let placemarks = placemarks else { return }
            if let placemark = placemarks.last {
                self.locations.append(placemark)
            }
        }
    }
    
    func removeLocation(_ clLocation: CLLocation) {
        print(locations, "before", "removing:", clLocation)
        locations.removeAll(where: { $0.location?.coordinate == clLocation.coordinate })
        print(locations, "after")
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
