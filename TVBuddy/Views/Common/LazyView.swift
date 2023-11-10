//
//  LazyView.swift
//  TVBuddy
//
//  Created by Danny on 05.11.2023.
//

import Foundation
import SwiftUI

struct LazyView<T>: View where T: View {
    var view: () -> T
    var body: some View {
        self.view()
    }
}
