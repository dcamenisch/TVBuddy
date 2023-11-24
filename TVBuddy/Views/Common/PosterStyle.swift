//
//  PosterStyle.swift
//  TVBuddy
//
//  Created by Danny on 16.09.2023.
//

import SwiftUI

struct PosterStyle: ViewModifier {
    enum Size {
        case tiny, small, medium, large

        func width() -> CGFloat {
            switch self {
            case .tiny: return 60
            case .small: return 80
            case .medium: return 100
            case .large: return 250
            }
        }

        func height() -> CGFloat {
            switch self {
            case .tiny: return 90
            case .small: return 120
            case .medium: return 150
            case .large: return 375
            }
        }
    }

    let size: Size

    func body(content: Content) -> some View {
        return
            content
                .frame(width: size.width(), height: size.height())
                .cornerRadius(6)
    }
}

extension View {
    func posterStyle(size: PosterStyle.Size) -> some View {
        return ModifiedContent(content: self, modifier: PosterStyle(size: size))
    }
}
