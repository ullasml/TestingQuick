//
//  Array+Extensions.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 15/06/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

extension Array {
    static func ==<T: Equatable>(lhs:[T], rhs: [T]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        let matches = zip(lhs, rhs).enumerated().filter { (offset: Int, element: (T, T)) -> Bool in
            element.0 == element.1
        }
        return matches.count == rhs.count
    }
}
