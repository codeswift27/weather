//
//  SavedView.swift
//  Weather
//
//  Created by Lexline Johnson on 7/17/21.
//

import SwiftUI
import CoreLocation

struct SavedView: View {
    @ObservedObject var savedLocations: SavedLocations
    @State var locationCards: [CLPlacemark: LocationCard]?
    @State var text = ""
    
    var body: some View {
        NavigationView {
            Group {
                if savedLocations.locations.isEmpty {
                    Text("No saved locations")
                } else {
                    ScrollView {
                        VStack {
                            ForEach(savedLocations.locations.filter { text.isEmpty || (($0.locality?.localizedStandardContains(text)) == true) || (($0.administrativeArea?.localizedStandardContains(text)) == true) || (($0.country?.localizedStandardContains(text)) == true) }, id: \.self) { location in
                                NavigationLink(destination: WeatherDetail(weatherDetailModel: WeatherDetailModel(location: location)).navigationBarTitle(getTitle(locality: location.locality ?? "unknown", administrativeArea: location.administrativeArea))) {
                                    locationCards?[location]
                                        .frame(height: 80)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(10)
                                        .swipeToDelete(cornerRadius: 10, delete: {
                                            guard let lat = location.location?.coordinate.latitude, let long = location.location?.coordinate.longitude else { return }
                                            let defaults = UserDefaults.standard
                                            var array = defaults.array(forKey: "savedLocations") as? [[CLLocationDegrees]] ?? []
                                            array.removeAll(where: { $0 == [lat, long] })
                                            defaults.set(array, forKey: "savedLocations")
                                            
                                            locationCards?.removeValue(forKey: location)
                                            savedLocations.removeLocation(CLLocation(latitude: lat, longitude: long))
                                    })
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .searchable(text: $text, prompt: "Search for a city or zipcode")
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.top)
                    }
                    .onAppear {
                        locationCards = locationCards ?? savedLocations.locations.reduce(into: [CLPlacemark: LocationCard]()) { $0[$1] = LocationCard(weatherListModel: WeatherListModel(location: $1)) }
                    }
                }
            }
            .navigationTitle("My Locations")
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

struct SwipeToDelete: ViewModifier {
    @State var offset: CGFloat = 0
    @State var fixedOffset: CGFloat = 0
    var cornerRadius: CGFloat
    var delete: () -> Void
    
    init(cornerRadius: CGFloat = 7, delete: @escaping () -> Void) {
        self.cornerRadius = cornerRadius
        self.delete = delete
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            Button(action: {
                withAnimation {
                    offset = -1000
                    delete()
                }
            }, label: {
                HStack {
                    Spacer()
                    Label("Delete", systemImage: "trash.fill")
                        .labelStyle(StackLabelStyle())
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.red)
                .cornerRadius(cornerRadius)
            })
                .mask({
                    HStack {
                        Spacer()
                        Rectangle()
                            .frame(width: offset + 6 < 0 ? -offset - 6 : 0, alignment: .trailing)
                            .cornerRadius(cornerRadius)
                    }
                })
            content
                .offset(x: offset, y: 0)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = fixedOffset + value.translation.width
                        }
                        .onEnded { value in
                            if offset < -200 {
                                withAnimation {
                                    offset = -1000
                                    delete()
                                }
                            } else if offset < -50 {
                                 withAnimation {
                                     offset = -90
                                 }
                             } else {
                                withAnimation {
                                    offset = 0
                                }
                            }
                            fixedOffset = offset
                        }
                )
        }
    }
}

struct StackLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
            configuration.title
        }
    }
}

extension View {
    func swipeToDelete(cornerRadius: CGFloat = 7, delete: @escaping () -> Void) -> some View {
        modifier(SwipeToDelete(cornerRadius: cornerRadius, delete: delete))
    }
}
