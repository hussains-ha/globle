//
//  AppView.swift
//  Globle
//
//  Created by Hussain Hassan on 4/20/25.
//

import SwiftUI

struct AppView: View {
    public var GlobleVM: GlobeViewModel
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
                    .padding()
                    .disabled(AppVM.isGameOver)
                    .onSubmit {
                        AppVM.showGuessError = false

                        if AppVM.countryGuess == GlobleVM.targetCountryName {
                            AppVM.isGameOver = true
                        }

                        if !GlobleVM.revealCountry(name: AppVM.countryGuess) {
                            AppVM.showGuessError = true
                        }
                        AppVM.countryGuess = ""
                    }

                if AppVM.showGuessError {
                    Text("Country not found!")
                        .foregroundStyle(.red)
                }

                if AppVM.isGameOver {
                    Text("The mystery country is \(GlobleVM.targetCountryName)")
                        .foregroundStyle(.green)
                }

                GlobeView(GlobeVM: GlobleVM)

                Text("Cloest Country: \(GlobleVM.closestCountry)")
                Text("Distance to country: \(GlobleVM.closestDistance == 50000 ? "" : "\(Int(GlobleVM.closestDistance)) km") ")
            }
        }
    }
}

#Preview {
    @Previewable @State var AppVM = AppViewModel()
    @Previewable @State var GlobeVM = GlobeViewModel()
    AppView(GlobleVM: GlobeVM, AppVM: $AppVM)
}
