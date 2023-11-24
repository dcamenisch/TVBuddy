//
//  OffsettableScrollView.swift
//  TVBuddy
//
//  Created by Danny on 03.07.22.
//

import SwiftUI

struct OffsettableScrollView<T: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let onOffsetChanged: (CGPoint) -> Void
    let content: T

    init(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        onOffsetChanged: @escaping (CGPoint) -> Void = { _ in },
        @ViewBuilder content: () -> T
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onOffsetChanged = onOffsetChanged
        self.content = content()
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: OffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("ScrollViewOrigin")).origin
                )
            }
            .frame(width: 0, height: 0)
            content
        }
        .coordinateSpace(name: "ScrollViewOrigin")
        .onPreferenceChange(OffsetPreferenceKey.self, perform: onOffsetChanged)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value _: inout CGPoint, nextValue _: () -> CGPoint) {}
}
