
import UIKit

extension String {
    public static func localize(key: String, comment: String) -> String {
        return NSLocalizedString(key, comment: comment)
    }
}