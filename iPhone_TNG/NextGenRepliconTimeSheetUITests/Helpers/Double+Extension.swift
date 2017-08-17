
import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func roundDown(_ toNearest: Double) -> Double {
        return floor(self / toNearest) * toNearest
    }
}
