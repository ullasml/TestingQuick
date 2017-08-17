//
//  Date+Extensions.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 17/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

extension Date{
    /// Compare two Date values without time
    /// and returns YES if both dates are equal
    func equalsIgnoreTime(_ date: Date) -> Bool {
        return Calendar.current.compare(self, to: date, toGranularity: .day) == .orderedSame
    }
}
