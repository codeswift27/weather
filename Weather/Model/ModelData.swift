//
//  ModelData.swift
//  Weather
//
//  Created by Lexline Johnson on 23/11/2021.
//

import Foundation
import CoreLocation
import SwiftUI

class ModelData: LoadableObject {
    @Published var loadingState: LoadingState<Weather> = .idle
    let location: CLPlacemark
    
    init(location: CLPlacemark) {
        self.location = location
    }
    
    func convertToISO8601(date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        print(formatter.string(from: date))
        return formatter.string(from: date)
    }

    func fetchData(location: String, fields: String, units: String? = nil, timesteps: String = "current", startTime: String? = nil, endTime: String? = nil, timezone: String = TimeZone.current.identifier) {
        let units = units ?? (Locale.current.usesMetricSystem ? "metric" : "imperial")
        let startTime = startTime ?? convertToISO8601(date: Date())
        let endTime = endTime ?? convertToISO8601(date: Date(timeIntervalSinceNow: 60))
        
        let apikey = "yjrwUameGJ5pwGsQCrMWPfr1rRq7qHg0"
        
        print("location is \(location)")        // location will either be current, selected, or saved (with UserDefaults)
        print("fields are \(fields)")           // fields will be hardcoded, depending on what data is needed
        print("units are \(units)")             // units will be saved with UserDefaults
        print("timesteps are \(timesteps)")     // timesteps will be hardcoded, depending on what data is needed
        print("startTime is \(startTime)")      // startTime will be "hardcoded", depending on what data is needed
        print("endTime is \(endTime)")          // endTime will be "hardcoded", depending on what data is needed
        print("timezone is \(timezone)")        // timezone will either be current (from user location) or saved (with UserDefaults)
        print("apikey is \(apikey)")            // API key will be hardcoded
            
        guard let url = URL(string: "https://api.tomorrow.io/v4/timelines?location=\(location)&fields=\(fields)&units=\(units)&timesteps=\(timesteps)&startTime=\(startTime)&endTime=\(endTime)&timezone=\(timezone)&apikey=\(apikey)"
        ) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    print("failed", error!)
                    self.loadingState = .failed(error!)
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Weather.self, from: data)
                DispatchQueue.main.async {
                    self.loadingState = .loaded(result)
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadingState = .failed(error)
                    print("failed", error)
                    self.loadingState = .failed(error)
                }
            }
        }.resume()
    }
    
    func loadData() { }
}

class WeatherDetailModel: ModelData {
    override func loadData() {
        self.loadingState = .loading
        let location_ = String(self.location.location?.coordinate.latitude ?? 37.3333) + "," + String(self.location.location?.coordinate.longitude ?? -122.0068)
        let defaults = UserDefaults.standard
        let units: String? = Units(rawValue: defaults.integer(forKey: "units"))?.value
        self.fetchData(location: location_, fields: "temperature,dewPoint,humidity,windSpeed,windDirection,windGust,pressureSurfaceLevel,precipitationProbability,precipitationType,rainAccumulation,snowAccumulation,iceAccumulation,visibility,uvIndex,weatherCode,epaIndex,epaHealthConcern,treeIndex,grassIndex,weedIndex", units: units, timesteps: "current,1d,1h", startTime: convertToISO8601(date: Date()), endTime: convertToISO8601(date: Date(timeIntervalSinceNow: 432000)))
    }
}

class WeatherListModel: ModelData {
    override func loadData() {
        self.loadingState = .loading
        let location_ = String(self.location.location?.coordinate.latitude ?? 37.3333) + "," + String(self.location.location?.coordinate.longitude ?? -122.0068)
        let defaults = UserDefaults.standard
        let units: String? = Units(rawValue: defaults.integer(forKey: "units"))?.value
        self.fetchData(location: location_, fields: "temperature,weatherCode", units: units, timesteps: "current,1h", startTime: convertToISO8601(date: Date()), endTime: convertToISO8601(date: Date(timeIntervalSinceNow: 86400)))
    }
}

// Based on a blog post by John Sundell (accessed 15 December 2021)
// https://www.swiftbysundell.com/articles/handling-loading-states-in-swiftui/
enum LoadingState<Value> {
    case idle, loading, loaded(Value), failed(Error)
}

protocol LoadableObject: ObservableObject {
    associatedtype Output
    var loadingState: LoadingState<Output> { get }
    func loadData()
}

struct LoadableView<Object, Content>: View where Object: LoadableObject, Content: View {
    @ObservedObject var object: Object
    var content: (Object.Output) -> Content
    
    init(object: Object, @ViewBuilder content: @escaping (Object.Output) -> Content) {
        self.object = object
        self.content = content
    }
    
    var body: some View {
        switch object.loadingState {
        case .idle:
            Color.clear.onAppear { object.loadData() }
        case .loading:
            ProgressView()
        case .loaded(let output):
            content(output)
        case .failed(let error):
            RefreshableScrollView(refresh: { complete in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    object.loadData()
                    complete()
                }
            }) {
                ZStack {
                    Color(UIColor.systemBackground)
                    Text("Unable to load page: \(error.localizedDescription)")
                }
            }
        }
    }
}

enum RefreshingState {
    case idle, willRefresh, refreshing
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [CGFloat] = []
    
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

struct RefreshableScrollView<Content>: View where Content: View {
    @State var refreshingState: RefreshingState = .idle
    var refresh: (@escaping () -> Void) -> Void
    var content: () -> Content
    
    let threshold: CGFloat = 50
    
    init(refresh: @escaping (@escaping () -> Void) -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.refresh = refresh
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if refreshingState != .idle {
                ProgressView()
            }
            ScrollView {
                ZStack(alignment: .top) {
                    content()
                        .alignmentGuide(.top, computeValue: { _ in
                            if refreshingState == .refreshing {
                                return -threshold / 2
                            } else {
                                return 0
                            }
                        })
                    GeometryReader { geometry in
                        let offset = geometry.frame(in: .named("scrollView")).minY
                        Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: [offset])
                    }
                }
            }
            .coordinateSpace(name: "scrollView")
        }
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { values in
            guard let value = values.last else { return }
            if value > threshold && refreshingState == .idle {
                print("will refresh")
                refreshingState = .willRefresh
            } else if value <= threshold && refreshingState == .willRefresh {
                refreshingState = .refreshing
                refresh({ withAnimation { refreshingState = .idle }})
            }
        }
    }
}

class LocationModel: LoadableObject {
    @Published var loadingState: LoadingState<CLPlacemark> = .idle
    let clLocation: CLLocation
    
    init(clLocation: CLLocation) {
        self.clLocation = clLocation
    }
    
    func loadData() {
        self.loadingState = .loading
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            print("geocoding...")
            guard let placemarks = placemarks else {
                self.loadingState = .failed(error!)
                print("error")
                return
            }
            if let placemark = placemarks.last {
                self.loadingState = .loaded(placemark)
                print("completed!")
            }
        }
    }
}
