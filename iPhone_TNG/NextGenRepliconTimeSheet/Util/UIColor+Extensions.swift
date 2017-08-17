//
//  UIColor+Extensions.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 17/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

extension UIColor{
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
}
