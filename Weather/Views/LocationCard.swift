//
//  LocationCard.swift
//  Weather
//
//  Created by Lexline Johnson on 7/17/21.
//

import SwiftUI
import CoreLocation

struct LocationCard: View {
    @ObservedObject var weatherListModel: WeatherListModel
    
    var body: some View {
        LoadableView(object: weatherListModel) { weather in
            if let currentWeather = weather.data.timelines[0].intervals.first?.values, let hourlyWeather = weather.data.timelines[1].intervals {
                HStack(spacing: 0) {
                    Image(systemName: WeatherCode(rawValue: currentWeather.weatherCode)?.systemName(isMorning: true) ?? "cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 25)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(getTitle(locality: weatherListModel.location.locality ?? "unknown", administrativeArea: weatherListModel.location.administrativeArea))
                            .font(.system(size: 18, weight: .regular, design: .default))
                        Text(weatherListModel.location.country ?? "unknown")
                            .font(.system(size: 12, weight: .regular, design: .default))
                    }
                    Spacer()
                    VStack {
                        Text(Int(round(currentWeather.temperature)).description + "°")
                            .font(.system(size: 30, weight: .regular, design: .default))
                        HStack {
                            let highLow = getHighLow(hourlyWeather, days: 1).first ?? (0, 0)
                            Text("H: \(highLow.h.description)°") // Determine from hourly data
                            Text("L: \(highLow.l.description)°")
                        }
                        .font(.system(size: 12, weight: .regular, design: .default))
                    }
                }
                .padding(.horizontal, 25)
            }
        }
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
    
    func getTitle(locality: String, administrativeArea: String?) -> String {
        if let administrativeArea = administrativeArea {
            return locality + ", " + administrativeArea
        } else {
            return locality
        }
    }
}
