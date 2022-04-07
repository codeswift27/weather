//
//  Settings.swift
//  Weather
//
//  Created by Lexline Johnson on 20/12/2021.
//

import SwiftUI
import CoreLocation
import MapKit

struct Settings: View {
    @State var units: Units = Units(rawValue: UserDefaults.standard.integer(forKey: "units")) ?? .system
    @State var useCurrentLocation: Bool = UserDefaults.standard.bool(forKey: "useCurrentLocation")
    @State var location: CLPlacemark?
    @StateObject var locationModel: LocationModel = { () -> LocationModel in
        let defaults = UserDefaults.standard
        let latLong = defaults.array(forKey: "location") as? [CLLocationDegrees] ?? [37.3333, -122.0068]
        let clLocation = CLLocation.init(latitude: latLong[0], longitude: latLong[1])
        return LocationModel(clLocation: clLocation)
    }()
    
    var body: some View {
        LoadableView(object: locationModel) { location_ in
            NavigationView {
                List {
                    NavigationLink(destination: UnitsPicker(selection: $units)) {
                        HStack {
                            Text("Units")
                            Spacer()
                            Text(units.value?.capitalized ?? "System")
                                .foregroundColor(.secondary)
                        }
                    }
                    NavigationLink(destination: LocationSettings(useCurrentLocation: $useCurrentLocation, location: $location)) {
                        HStack {
                            Text("Location")
                            Spacer()
                            Group {
                                if useCurrentLocation {
                                    Image(systemName: "location.fill")
                                } else {
                                    if let location = location {
                                        Text(getTitle(locality: location.locality ?? "Unknown", administrativeArea: location.administrativeArea))
                                    } else {
                                        Text("None")
                                    }
                                }
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Settings")
            }
            .onAppear { location = location_ }
        }
    }
    
    func getTitle(locality: String, administrativeArea: String?) -> String {
        if let administrativeArea = administrativeArea {
            return locality + ", " + administrativeArea
        } else {
            return locality
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}

struct UnitsPicker: View {
    @Binding var selection: Units
    let defaults = UserDefaults.standard
    
    var body: some View {
        List {
            ForEach(Units.allCases) { units in
                Button(action: {
                    selection = units
                    defaults.set(units.rawValue, forKey: "units")
                }) {
                    HStack {
                        Text(units.value?.capitalized ?? "System")
                        Spacer()
                        if selection == units {
                            Text(Image(systemName: "checkmark"))
                                .fontWeight(.medium)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationBarTitle("Units", displayMode: .inline)
    }
}

struct LocationSettings: View {
    @Binding var useCurrentLocation: Bool
    @Binding var location: CLPlacemark?
    @State var showLocationPicker = false
    
    var body: some View {
        List {
            withAnimation {
                Toggle("Use Current Location", isOn: $useCurrentLocation)
            }
            if !useCurrentLocation {
                HStack {
                    Text("Location")
                    Spacer()
                    Group {
                        if let location = location {
                            Text((location.locality ?? "Unknown") + ", " + (location.administrativeArea ?? "Unknown"))
                        } else {
                            Text("None")
                        }
                    }
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        showLocationPicker.toggle()
                    }
                }
            }
        }
        .animation(.easeInOut)
        .navigationBarTitle("Location", displayMode: .inline)
        .onChange(of: useCurrentLocation) { newState in
            let defaults = UserDefaults.standard
            defaults.set(newState, forKey: "useCurrentLocation")
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPicker(location: $location)
        }
    }
}


struct LocationPicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var location: CLPlacemark?
    @StateObject var searchCompletion = LocationSearchCompletion()
    @State var text = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(searchCompletion.searchResults, id: \.title) { completion in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(completion.title)
                            Text(completion.subtitle)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let request = MKLocalSearch.Request(completion: completion)
                        let search = MKLocalSearch(request: request)
                        search.start { response, error in
                            guard let response = response else {
                                print(error?.localizedDescription ?? "unknown error")
                                return
                            }
                            
                            let item = response.mapItems.first
                            guard let placemark = item?.placemark else { return }
                            location = placemark
                            guard let lat = placemark.location?.coordinate.latitude, let long = placemark.location?.coordinate.longitude else { return }
                            let defaults = UserDefaults.standard
                            defaults.set([lat, long], forKey: "location")
                            dismiss()
                        }
                    }
                }
            }
            .navigationBarTitle("Location", displayMode: .inline)
            .searchable(text: $text, prompt: "Search for a city or zipcode")
            .onChange(of: text) { _ in
                searchCompletion.updateQueryFragment(to: text)
            }
        }
    }
}
