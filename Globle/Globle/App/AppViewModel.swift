//
//  AppViewModel.swift
//  Globle
//
//  Created by Hussain Hassan on 4/20/25.
//

import Foundation
import Observation
import SwiftUI

@Observable class AppViewModel {
    var countryGuess: String = ""
    var isGameOver: Bool = false
    var showGuessError: Bool = false
    var showSettings: Bool = false
}
