//
//  WeatherDetail.swift
//  Weather
//
//  Created by Lexline Johnson on 6/26/21.
//

import SwiftUI
import CoreLocation

struct WeatherDetail: View {
    @ObservedObject var weatherDetailModel: WeatherDetailModel
    @Binding var useMetric: Bool
    
    init(weatherDetailModel: WeatherDetailModel, useMetric: Binding<Bool> = Binding.constant(Units(rawValue: UserDefaults.standard.integer(forKey: "units")) == .metric || (Units(rawValue: UserDefaults.standard.integer(forKey: "units")) == .system && Locale.current.usesMetricSystem) ? true : false)) {
        self.weatherDetailModel = weatherDetailModel
        self._useMetric = useMetric
    }
    
    var body: some View {
        LoadableView(object: weatherDetailModel) { weather in
            ScrollView {
                if let currentWeather = weather.data.timelines[1].intervals.first?.values, let dailyWeather = weather.data.timelines[2].intervals, let hourlyWeather = weather.data.timelines[0].intervals {
                    VStack(spacing: 30) {
                        weatherAndTemp(currentWeather, hourlyWeather: hourlyWeather)
                        VStack {
                            Group {
//                                hourlyForecast(currentWeather)
                                fiveDayForecast(dailyWeather: dailyWeather, hourlyWeather: hourlyWeather)
                                Group {
                                    HStack {
                                        humidity(currentWeather)
                                        wind(currentWeather)
                                    }
                                    HStack {
                                        pressure(currentWeather)
                                        precipitation(currentWeather, hourlyWeather: hourlyWeather)
                                    }
                                    HStack {
                                        visibility(currentWeather)
                                        uvIndex(currentWeather)
                                    }
                                    HStack {
                                        airQuality(currentWeather)
                                        pollenIndex(currentWeather)
                                    }
                                }
                                .frame(height: 146)
                                .allowsTightening(true)
                                .groupBoxStyle(SecondaryGroupBoxStyle(alignLeft: true))
                            }
                            .groupBoxStyle(SecondaryGroupBoxStyle())
                            .labelStyle(CenteredLabelStyle())
                        }
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal, 14)
                }
            }
        }
        .onChange(of: useMetric) { _ in
            weatherDetailModel.loadData()
        }
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .light)
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
        }
    }
    
    func weatherAndTemp(_ weather: Values, hourlyWeather: [Interval]) -> some View {
        HStack {
            Spacer()
            Image(systemName: WeatherCode(rawValue: weather.weatherCode)?.systemName(isMorning: true) ?? "cloud")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            Spacer()
            VStack {
                Text(Int(round(weather.temperature)).description + "°")
                    .font(.system(size: 72, weight: .light, design: .default))
                HStack {
                    let highLow = getHighLow(hourlyWeather, days: 1).first ?? (0, 0)
                    Text("H: \(highLow.h.description)°") // Determine from hourly data
                    Text("L: \(highLow.l.description)°")
                }
                .font(.system(size: 24, weight: .regular, design: .default))
            }
            Spacer()
        }
        .padding(.bottom, 10)
    }
    
    func getHighLow(_ hourlyWeather: [Interval], days: Int) -> [(h: Int, l: Int)] {
        var highLow: [(h: Int, l: Int)] = []
        for i in 0...days - 1 {
            let today = Calendar.current.dateComponents([.day], from: Date(timeIntervalSinceNow: 86400 * Double(i))).day!
            let hourlyTemp = hourlyWeather.filter { Int($0.startTime[9...10]) == today }.map { Int(round($0.values.temperature)) }
            highLow.append((hourlyTemp.max() ?? 0, hourlyTemp.min() ?? 0))
        }
        return highLow
    }
    
//    func hourlyForecast(_ weather: Values) -> some View {
//        GroupBox(label: Label("Hourly Forecast", systemImage: "clock")) {
//            WeatherGraph()
//                .frame(height: 86)
//            // Use GeometryReader? to create a graph
//        }
//    }
    
    func fiveDayForecast(dailyWeather: [Interval], hourlyWeather: [Interval]) -> some View {
        let highLow = getHighLow(hourlyWeather, days: 5)
        let day = Calendar.current.dateComponents([.weekday], from: Date()).weekday!
        return GroupBox(label: Label("5-Day Forecast", systemImage: "calendar")) {
            ForEach(0...4, id: \.self) { i in //iterate through days
                HStack {
                    Text(i == 0 ? "Today" : getDay((day + i) % 7))
                        .frame(width: 60, alignment: .leading)
                    Spacer()
                    HStack {
                        Text(Int(round(dailyWeather[i].values.precipitationProbability ?? 0)).description + "%")
                            .frame(width: 40)
                        Spacer()
                        Image(systemName: "drop.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Spacer()
                        Text(highLow[i].h.description + "°")
                            .frame(width: 40)
                        Text(highLow[i].l.description + "°")
                            .frame(width: 40)
                            .opacity(0.5)
                        Spacer()
                        Image(systemName: WeatherCode(rawValue: dailyWeather[i].values.weatherCode)?.systemName(isMorning: true) ?? "cloud")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
    }
    
    func getDay(_ value: Int) -> String {
        switch value {
            case 0:
                return "Sat"
            case 1:
                return "Sun"
            case 2:
                return "Mon"
            case 3:
                return "Tue"
            case 4:
                return "Wed"
            case 5:
                return "Thu"
            case 6:
                return "Fri"
            default:
                fatalError()
        }
    }
    
    func humidity(_ weather: Values) -> some View {
        GroupBox(label: Label("Humidity", systemImage: "humidity")) {
            VStack(alignment: .leading) {
                Text(Int(round(weather.humidity ?? 0)).description + "%")
                    .font(.largeTitle)
                Spacer()
                Text("Dew point is \(Int(round(weather.dewPoint ?? 0)).description)°.")
                    .font(.caption)
            }
        }
    }
    
    func wind(_ weather: Values) -> some View {
        GroupBox(label: Label("Wind", systemImage: "wind")) {
            VStack(alignment: .leading) {
                Text(Int(round(weather.windSpeed ?? 0)).description + (useMetric ? " m/s" : " mph"))
                    .font(.largeTitle)
                Spacer()
                Text("\(convertToDirection(from: weather.windDirection ?? 0)) wind with gusts of up to \(Int(round(weather.windGust ?? 0)).description)" + (useMetric ? " m/s." : " mph."))
                    .font(.caption)
            }
        }
    }
    
    func convertToDirection(from degrees: Float) -> String {
        switch degrees {
            case 337.50...360, 0..<22.50:
                return "Northern"
            case 22.50..<67.50:
                return "Northwest"
            case 67.50..<112.50:
                return "Western"
            case 112.50..<157.50:
                return "Southwest"
            case 157.50..<202.50:
                return "Southern"
            case 202.50..<247.50:
                return "Southeast"
            case 247.50..<292.50:
                return "Eastern"
            case 292.50..<337.5:
                return "Northeast"
            default:
                fatalError()
        }
    }
    
    func pressure(_ weather: Values) -> some View {
        GroupBox(label: Label("Pressure", systemImage: "barometer")) {
            VStack(alignment: .leading) {
                Text(Int(round(weather.pressureSurfaceLevel ?? 0)).description + (useMetric ? " hPa" : " inHg"))
                    .font(.largeTitle)
                Spacer()
                Text("Pressure is \(pressureConcern(for: (weather.pressureSurfaceLevel ?? 0))).")
                    .font(.caption)
            }
        }
    }
    
    func pressureConcern(for value: Float) -> String {
        let value = useMetric ? value : (value * 33.864)
        switch value {
            case 0..<996.27555:
                return "low"
            case 996.27555..<1030.1394:
                return "normal"
            case 1030.1394...:
                return "high"
            default:
                fatalError()
        }
    }
    
    func precipitation(_ weather: Values, hourlyWeather: [Interval]) -> some View {
        GroupBox(label: Label("Precipitation", systemImage: "drop")) {
            VStack(alignment: .leading) {
                Text(Int(round(weather.precipitationProbability ?? 0)).description + "%")
                    .font(.largeTitle)
                Spacer()
                let precipitationValue = hourlyWeather.first?.values.precipitationType ?? 0
                Text("\(precipitationAmount(precipitationValue, rain: hourlyWeather.first?.values.rainAccumulation ?? 0, snow: hourlyWeather.first?.values.snowAccumulation ?? 0, ice: hourlyWeather.first?.values.iceAccumulation ?? 0)) \(useMetric ? "mm" : "in") of \(precipitationType(for: precipitationValue)) in the past hour.")
                    .font(.caption)
            }
        }
    }
    
    func precipitationAmount(_ value: Int, rain: Float, snow: Float, ice: Float) -> Int {
        switch value {
            case 0, 1:
                return Int(round(rain))
            case 2:
                return Int(round(snow))
            case 3, 4:
                return Int(round(ice))
            default:
                fatalError()
        }
    }
    
    func precipitationType(for value: Int) -> String {
        switch value {
            case 0, 1:
                return "rain"
            case 2:
                return "snow"
            case 3:
                return "freezing rain"
            case 4:
                return "ice pellets"
            default:
                fatalError()
        }
    }
    
    func visibility(_ weather: Values) -> some View {
        GroupBox(label: Label("Visibility", systemImage: "eye")) {
            VStack(alignment: .leading) {
                Text(Int(round(weather.visibility ?? 0)).description + (useMetric ? " km" : " mi"))
                    .font(.largeTitle)
                Spacer()
                Text(visibilityConcern(for: weather.visibility ?? 0))
                    .font(.caption)
            }
        }
    }
    
    func visibilityConcern(for value: Float) -> String {
        let value = useMetric ? value : (value * 1.609)
        switch value {
            case 0..<0.04572:
                return "Visibility is poor. There may be dense fog."
            case 0.04572..<0.185623:
                return "Visibility is poor. There may be thick fog."
            case 0.185623..<0.370332:
                return "Visibility is poor. There may be fog."
            case 0.370332..<0.926:
                return "Visibility is low. There may be moderate fog."
            case 0.926..<1.852:
                return "Visibility is low. There may be thin fog or mist."
            case 1.852..<3.704:
                return "Visibility is low. There may be thin fog or mist."
            case 3.704..<9.26:
                return "Visibility is moderate. There may be thin fog or mist."
            case 9.26..<12.8748:
                return "Visibility is moderate. It is almost clear right now."
            case 12.8748..<14:
                return "Visibility is good. It is clear right now."
            case 14...:
                return "Visibility is high. It is perfectly clear right now."
            default:
                fatalError()
        }
    }
    
    func uvIndex(_ weather: Values) -> some View {
        GroupBox(label: Label("UV Index", systemImage: "sun.max")) {
            VStack(alignment: .leading) {
                Text(weather.uvIndex?.description ?? "unknown")
                    .font(.largeTitle)
                Spacer()
                Text("UV levels are \(uvHeathConcern(for: weather.uvIndex ?? 0)).")
                    .font(.caption)
            }
        }
    }
    
    func uvHeathConcern(for value: Int) -> String {
        switch value {
            case 0...2:
                return "low"
            case 3...5:
            return "moderate"
            case 6...7:
                return "high"
            case 8...10:
                return "very high"
            case 11...:
                return "extreme"
            default:
                fatalError()
        }
    }
    
    func airQuality(_ weather: Values) -> some View {
        GroupBox(label: Label("Air Quality", systemImage: "aqi.medium")) {
            VStack(alignment: .leading) {
                Text(weather.epaIndex?.description ?? "unknown")
                    .font(.largeTitle)
                Spacer()
                Text("Air quality is \(epaHealthConcern(for: weather.epaIndex ?? 0)).")
                    .font(.caption)
            }
        }
    }
    
    func epaHealthConcern(for value: Int) -> String {
        switch value {
            case 0...50:
                return "good"
            case 51...100:
                return "moderate"
            case 101...150:
                return "unhealthy for sensitive groups"
            case 151...200:
                return "unhealthy"
            case 201...300:
                return "very unhealthy"
            case 301...:
                return "hazardous"
            default:
                fatalError()
        }
    }
    
    func pollenIndex(_ weather: Values) -> some View {
        GroupBox(label: Label("Pollen Index", systemImage: "allergens")) {
            VStack(alignment: .leading) {
                let pollenValues = highestPollenIndex(tree: weather.treeIndex ?? 0, grass: weather.grassIndex ?? 0, weed: weather.weedIndex ?? 0)
                Text(pollenValues.value)
                    .font(.largeTitle)
                Spacer()
                Text("\(pollenValues.source) pollen levels are \(pollenValues.value.lowercased()).")
                    .font(.caption)
            }
        }
    }
    
    func highestPollenIndex(tree: Int, grass: Int, weed: Int) -> (value: String, source: String) {
        let pollenIndices = [tree, grass, weed]
        guard let max = pollenIndices.max() else { return ("unknown", "unknown") }
        let sources = pollenIndices.filter { $0 == max }
        var sourceString = ""
        if sources.count == 3 {
            sourceString = "Tree, grass, and weed"
        } else {
            for source in sources {
                if sourceString == "" {
                    switch source {
                        case 0:
                            sourceString += "Tree"
                        case 1:
                            sourceString += "Grass"
                        case 2:
                            sourceString += "Weed"
                        default:
                            fatalError()
                    }
                } else {
                    switch source {
                        case 0:
                            sourceString += "and tree"
                        case 1:
                            sourceString += "and grass"
                        case 2:
                            sourceString += "and weed"
                        default:
                            fatalError()
                    }
                }
            }
        }
        
        switch max {
            case 0:
                return ("None", sourceString)
            case 1:
                return ("Very low", sourceString)
            case 2:
                return ("Low", sourceString)
            case 3:
                return ("Medium", sourceString)
            case 4:
                return ("High", sourceString)
            case 5:
                return ("Very High", sourceString)
            default:
                fatalError()
        }
    }
}

// Custom LabelStyle to align icons and text
struct CenteredLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            configuration.title
        }
    }
}

// Custom GroupBoxStyle for secondary background and alignment
struct SecondaryGroupBoxStyle: GroupBoxStyle {
    let alignLeft: Bool
    
    init(alignLeft: Bool = false) {
        self.alignLeft = alignLeft
    }
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 10) {
            configuration.label
                .frame(maxWidth: .infinity, alignment: .topLeading)
            Group {
                if alignLeft {
                    HStack {
                        configuration.content
                        Spacer(minLength: 0)
                    }
                } else {
                    configuration.content
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// Extension to subscript string
extension String {
    subscript(_ range: ClosedRange<Int>) -> String {
        return String(prefix(range.upperBound).suffix(range.count))
    }
}
