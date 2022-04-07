//
//  Weather.swift
//  Weather
//
//  Created by Lexline Johnson on 6/27/21.
//

import Foundation

struct Weather: Codable {
    let data: ResultType
}

struct ResultType: Codable {
    let timelines: [Timeline]
}

struct Timeline: Codable {
    let timestep: String
    let startTime: String
    let endTime: String
    let intervals: [Interval]
}

struct Interval: Codable {
    let startTime: String
    let values: Values
}

struct Values: Codable {
    let temperature: Float
    let dewPoint: Float?
    let humidity: Float?
    let windSpeed: Float?
    let windDirection: Float?
    let windGust: Float?
    let pressureSurfaceLevel: Float?
    let precipitationProbability: Float?
    let precipitationType: Int?
    let rainAccumulation: Float?   // use different time & timesteps
    let snowAccumulation: Float?   // use different time & timesteps
    let iceAccumulation: Float?    // use different time & timesteps
    let visibility: Float?
    let uvIndex: Int?
    let weatherCode: Int
    let epaIndex: Int?
    let treeIndex: Int?
    let grassIndex: Int?
    let weedIndex: Int?
}
