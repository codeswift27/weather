//
//  SearchView.swift
//  Weather
//
//  Created by Lexline Johnson on 9/19/21.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @StateObject var searchCompletion = LocationSearchCompletion()
    @ObservedObject var savedLocations: SavedLocations
    @State var text = ""
    @State var location: CLPlacemark?
    @State var locationView: WeatherDetail?
    @State var showWeather = false
    @State var saved = false
    @State var toggled = false
    
    var body: some View {
        NavigationView {
            Group {
                if text.isEmpty || searchCompletion.searchResults.isEmpty {
                    Text("No results")
                } else {
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
                            .background(NavigationLink(destination:
                                Group {
                                    if let _ = locationView {
                                        locationView
                                            .navigationTitle(getTitle(locality: location?.locality ?? "unknown", administrativeArea: location?.administrativeArea))
                                            .toolbar {
                                                Button(action: {
                                                    saved.toggle()
                                                    toggled.toggle()
                                                }) {
                                                    Image(systemName: saved ? "star.fill" : "star")
                                                        .foregroundColor(.yellow)
                                                }
                                            }
                                            .onAppear { toggled = false }
                                            .onDisappear {
                                                print("disappearing...")
                                                if toggled {
                                                    guard let lat = location?.location?.coordinate.latitude, let long = location?.location?.coordinate.longitude else { return }
                                                    let defaults = UserDefaults.standard
                                                    var array = defaults.array(forKey: "savedLocations") as? [[CLLocationDegrees]] ?? []
                                                    if saved {
                                                        array.append([lat, long])
                                                        defaults.set(array, forKey: "savedLocations")
                                                        savedLocations.addLocation(CLLocation(latitude: lat, longitude: long))
                                                    } else {
                                                        array.removeAll(where: { $0 == [lat, long] })
                                                        defaults.set(array, forKey: "savedLocations")
                                                        savedLocations.removeLocation(CLLocation(latitude: lat, longitude: long))
                                                    }
                                                }
                                            }
                                    } else {
                                        Text("Location not found")
                                    }
                                },
                                isActive: $showWeather) { }.hidden())
                            .onTapGesture() {
                                let request = MKLocalSearch.Request(completion: completion)
                                let search = MKLocalSearch(request: request)
                                search.start { response, error in
                                    guard let response = response else {
                                        print(error?.localizedDescription ?? "unknown error")
                                        return
                                    }
                                    
                                    let item = response.mapItems.first
                                    guard let location = item?.placemark else { return }
                                    self.location = location
//                                    let defaults = UserDefaults.standard
//                                    let savedLocations = defaults.array(forKey: "savedLocations") as? [[CLLocationDegrees]] ?? []
                                    saved = savedLocations.locations.contains(location)
                                    locationView = WeatherDetail(weatherDetailModel: WeatherDetailModel(location: location))
                                    showWeather = true
//                                        .contains([location?.location?.coordinate.latitude ?? 0, location?.location?.coordinate.longitude ?? 0])
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Locations")
            .searchable(text: $text, prompt: "Search for a city or zipcode")
            .onChange(of: text) { _ in
                searchCompletion.updateQueryFragment(to: text)
            }
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
