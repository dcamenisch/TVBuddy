//
//  TVBuddyMediaItem.swift
//  TVBuddy
//
//  Created by Danny on 11.11.2023.
//

import Foundation
import SwiftUI

protocol TVBuddyMediaItem: Identifiable, Equatable, Hashable {
    var id: Int { get }
    var name: String { get }
    
    associatedtype T: View
    @ViewBuilder var detailView: T { get }
    
    func getPosterURL() async -> URL?
}
