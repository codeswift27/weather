//
//  HomeView.swift
//  Weather
//
//  Created by Lexline Johnson on 6/26/21.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State var useCurrentLocation = UserDefaults.standard.bool(forKey: "useCurrentLocation")
    @State var locationModel: LocationModel = { () -> LocationModel in
        let latLong = UserDefaults.standard.array(forKey: "location") as? [CLLocationDegrees] ?? [37.3333, -122.0068]
        let clLocation = CLLocation(latitude: latLong[0], longitude: latLong[1])
        return LocationModel(clLocation: clLocation)
    }()
    @State var useMetric: Bool = Units(rawValue: UserDefaults.standard.integer(forKey: "units")) == .metric || (Units(rawValue: UserDefaults.standard.integer(forKey: "units")) == .system && Locale.current.usesMetricSystem)
    @State var showSettings = false
    
    // Take into account weather (pun intended) the user prefers to use their current location or a saved location
    var body: some View {
        if useCurrentLocation {
            NavigationView {
                LoadableView(object: locationManager) { location in
                    WeatherDetail(weatherDetailModel: WeatherDetailModel(location: location), useMetric: $useMetric)
                        .navigationTitle(getTitle(locality: location.locality ?? "unknown", administrativeArea: location.administrativeArea))
                }
                .toolbar {
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
                .sheet(isPresented: $showSettings, onDismiss: {
                    showSettings = false
                    refresh()
                }) {
                    Settings()
                }
            }
        } else {
            LoadableView(object: locationModel) { location in
                NavigationView {
                    WeatherDetail(weatherDetailModel: WeatherDetailModel(location: location), useMetric: $useMetric)
                        .navigationTitle(getTitle(locality: location.locality ?? "unknown", administrativeArea: location.administrativeArea))
                        .toolbar {
                            Button(action: { showSettings.toggle() }) {
                                Image(systemName: "gearshape.fill")
                            }
                        }
                        .sheet(isPresented: $showSettings, onDismiss: {
                            refresh()
                        }) {
                            Settings()
                        }
                }
            }
        }
    }
    
    func refresh() {
        let defaults = UserDefaults.standard
        useCurrentLocation = defaults.bool(forKey: "useCurrentLocation")
        if !useCurrentLocation {
            locationModel = { () -> LocationModel in
                let latLong = defaults.array(forKey: "location") as? [CLLocationDegrees] ?? [37.3333, -122.0068]
                let clLocation = CLLocation.init(latitude: latLong[0], longitude: latLong[1])
                return LocationModel(clLocation: clLocation)
            }()
        }
        useMetric = Units(rawValue: UserDefaults.standard.integer(forKey: "units")) == .metric || (Units(rawValue: UserDefaults.standard.integer(forKey: "units")) == .system && Locale.current.usesMetricSystem) ? true : false
    }
    
    func getTitle(locality: String, administrativeArea: String?) -> String {
        if let administrativeArea = administrativeArea {
            return locality + ", " + administrativeArea
        } else {
            return locality
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
