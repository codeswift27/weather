//
//  SearchCompletion.swift
//  Weather
//
//  Created by Lexline Johnson on 20/10/2021.
//

import Foundation
import MapKit
import SwiftUI

class LocationSearchCompletion: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    var searchCompleter = MKLocalSearchCompleter()

    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func updateQueryFragment(to text: String) {
        searchCompleter.queryFragment = text
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        print(searchResults, "Updated!")
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        searchResults = []
        print("Failed: \(error.localizedDescription)")
    }
}
