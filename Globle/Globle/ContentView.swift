//
//  ContentView.swift
//  Globle
//
//  Created by Hussain Hassan on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    @State var GlobeVM: GlobeViewModel = .init()
    @State var AppVM: AppViewModel = .init()
    var body: some View {
        NavigationStack {
            HomeView(GlobeVM: GlobeVM, AppVM: $AppVM)
                .toolbar()
        }
    }
}

#Preview {
    ContentView()
}
