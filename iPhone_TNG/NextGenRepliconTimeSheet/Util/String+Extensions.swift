//
//  String+Extensions.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 17/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

extension String {
    
    func localize() -> String {
        return Util.getLocalisedString(forKey: self)
    }
    
    func replaceCommaWithDot() -> String{
        return self.replacingOccurrences(of: ",", with: ".")
    }
    
    func formatNumberStringWithTwoDecimals() -> String {
        return formatNumberString(withDecimalPlaces: 2)
    }
    
    func formatNumberString(withDecimalPlaces decimalPlaces:Int) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        numberFormatter.minimumFractionDigits = decimalPlaces
        numberFormatter.minimumIntegerDigits = 1
        if let doubleVal = Double(self) {
            return numberFormatter.string(from: NSNumber(value: doubleVal)) ?? ""
        }else{
            return ""
        }
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
