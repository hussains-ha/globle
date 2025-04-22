//
//  ToolBar.swift
//  Globle
//
//  Created by Hussain Hassan on 4/21/25.
//

import Foundation
import SwiftUI

struct Toolbar: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Globle")
                        .font(Font.custom("Montserrat", size: 50))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gear")
                            .resizable()
                            .foregroundStyle(.black)
                            .frame(width: 30, height: 30)
                    }
                }
            }
    }
}

extension View {
    func toolbar() -> some View {
        self.modifier(Toolbar())
    }
}
