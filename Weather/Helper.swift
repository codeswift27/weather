//
//  Helper.swift
//  Weather
//
//  Created by Lexline Johnson on 6/27/21.
//

import Foundation
import CoreLocation

enum Units: Int, CaseIterable, Identifiable {
    case imperial = 0
    case metric = 1
    case system = 2
    
    var id: Int { self.rawValue }
    var value: String? {
        switch self {
        case .imperial:
            return "imperial"
        case .metric:
            return "metric"
        case .system:
            return nil
        }
    }
}

enum WeatherCode: Int {
    case heavyRain = 4201
    case rain = 4001
    case lightRain = 4200
    case heavyFreezingRain = 6201
    case freezingRain = 6001
    case lightFreezingRain = 6200
    case freezingDrizzle = 6000
    case drizzle = 4000
    case heavyIcePellets = 7101
    case icePellets = 7000
    case lightIcePellets = 7102
    case heavySnow = 5101
    case snow = 5000
    case lightSnow = 5100
    case flurries = 5001
    case thunderstorm = 8000
    case lightFog = 2100
    case fog = 2000
    case cloudy = 1001
    case mostlyCloudy = 1102
    case partlyCloudy = 1101
    case mostlyClear = 1100
    case clear = 1000
    
    func systemName(isMorning: Bool) -> String {
        switch self {
            case .heavyRain:
                return "cloud.heavyrain.fill"   // 􀇉
            case .rain:
                return "cloud.rain.fill"        // 􀇇
            case .lightRain:
                return "cloud.drizzle.fill"     // 􀇅
            case .heavyFreezingRain:
                return "cloud.sleet.fill"       // 􀇑
            case .freezingRain:
                return "cloud.sleet.fill"       // 􀇑
            case .lightFreezingRain:
                return "cloud.sleet.fill"       // 􀇑
            case .freezingDrizzle:
                return "cloud.sleet.fill"       // 􀇑
            case .drizzle:
                return "cloud.drizzle.fill"     // 􀇅
            case .heavyIcePellets:
                return "cloud.hail.fill"        // 􀇍
            case .icePellets:
                return "cloud.hail.fill"        // 􀇍
            case .lightIcePellets:
                return "cloud.hail.fill"        // 􀇍
            case .heavySnow:
                return "cloud.snow.fill"        // 􀇏
            case .snow:
                return "cloud.snow.fill"        // 􀇏
            case .lightSnow:
                return "cloud.snow.fill"        // 􀇏
            case .flurries:
                return "cloud.snow.fill"        // 􀇏
            case .thunderstorm:
                return "cloud.bolt.rain.fill"   // 􀇟
            case .lightFog:
                return "cloud.fog.fill"         // 􀇋
            case .fog:
                return "cloud.fog.fill"         // 􀇋
            case .cloudy:
                return "cloud.fill"             // 􀇃
            case .mostlyCloudy:
                return "cloud.fill"             // 􀇃
            case .partlyCloudy:
                return isMorning ? "cloud.sun.fill" : "cloud.moon.fill" // 􀇕 / 􀇛
            case .mostlyClear:
                return isMorning ? "sun.max.fill" : "moon.stars.fill"   // 􀆮 / 􀇁
            case .clear:
                return isMorning ? "sun.max.fill" : "moon.stars.fill"   // 􀆮 / 􀇁
        }
    }
}

