//
//  AppView.swift
//  Globle
//
//  Created by Hussain Hassan on 4/20/25.
//

import SwiftUI

struct AppView: View {
    public var GlobeVM: GlobeViewModel
    @Binding var AppVM: AppViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.globleGreen, Color.globleYellow]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            VStack {
                TextField("Enter Country Name Here", text: $AppVM.countryGuess)
                    .background(AppVM.isGameOver ? Color.gray : Color.white)
                    .foregroundStyle(.black)
                    .padding()
                    .disabled(AppVM.isGameOver)
                    .onSubmit {
                        AppVM.showGuessError = false
                        AppVM.alreadyGuessed = false

                        if AppVM.countryGuess.trimmingCharacters(in: .whitespacesAndNewlines) == GlobeVM.targetCountryName {
                            AppVM.isGameOver = true
                        }

                        if GlobeVM.revealedCountries.contains(AppVM.countryGuess.trimmingCharacters(in: .whitespacesAndNewlines)) {
                            AppVM.alreadyGuessed = true
                        }

                        if !GlobeVM.revealCountry(name: AppVM.countryGuess.trimmingCharacters(in: .whitespacesAndNewlines)) && !AppVM.alreadyGuessed {
                            AppVM.showGuessError = true
                        }
                        AppVM.countryGuess = ""
                    }

                if AppVM.showGuessError {
                    Text("Country not found!")
                        .foregroundStyle(.red)
                }

                if AppVM.isGameOver {
                    Text("The mystery country is \(GlobeVM.targetCountryName)")
                        .foregroundStyle(.green)
                }

                if AppVM.alreadyGuessed {
                    Text("Country already guessed!")
                        .foregroundStyle(.red)
                }

                GlobeView(GlobeVM: GlobeVM)

                Text("Closest Country: \(GlobeVM.closestCountry)")
                    .foregroundStyle(.black)
                Text("Distance to country: \(GlobeVM.closestDistance == 50000 ? "" : "\(Int(GlobeVM.closestDistance)) km") ")
                    .foregroundStyle(.black)
            }
        }
    }
}

#Preview {
    @Previewable @State var AppVM = AppViewModel()
    @Previewable @State var GlobeVM = GlobeViewModel()
    AppView(GlobeVM: GlobeVM, AppVM: $AppVM)
}
