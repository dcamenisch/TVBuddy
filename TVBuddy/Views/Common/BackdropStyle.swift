//
//  BackdropStyle.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftUI

struct BackdropStyle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .cornerRadius(15)
    }
}

extension View {
    func backdropStyle() -> some View {
        return ModifiedContent(content: self, modifier: BackdropStyle())
    }
}
