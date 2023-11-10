//
//  DateFormatter+year.swift
//  TVBuddy
//
//  Created by Danny on 02.07.22.
//

import Foundation

extension DateFormatter {
    static var year: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter
    }
}
