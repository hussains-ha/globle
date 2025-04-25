//
//  HomeView.swift
//  Globle
//
//  Created by Hussain Hassan on 4/20/25.
//

import SwiftUI

struct HomeView: View {
    var GlobeVM: GlobeViewModel
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
                Text("Welcome to Globle")
                    .font(Font.custom("Montserrat", size: 30))
                    .foregroundStyle(.black)

                NavigationLink(destination:
                    AppView(GlobeVM: GlobeVM, AppVM: $AppVM)
                        .toolbar()

                ) {
                    Text("Click to Play")
                        .padding()
                        .font(Font.custom("Montserrat", size: 25))
                        .foregroundStyle(.white)
                        .background(Color.globleBlue.opacity(0.7))
                }
                .padding()
            }
        }
    }
}

#Preview {
    @Previewable @State var AppVM = AppViewModel()
    @Previewable @State var GlobeVM = GlobeViewModel()
    HomeView(GlobeVM: GlobeViewModel(), AppVM: $AppVM)
}
