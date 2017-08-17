//
//  TestTwo.swift
//  repliconkit
//
//  Created by Anil Reddy on 3/28/16.
//  Copyright © 2016 replicon. All rights reserved.
//

import Foundation

@objc
open class TestTwo : NSObject {
    open func getHelloFromSwift(_ str:String)->String{
        return "Hello from swift: \(str)"
    }
    
    open func sayHelloToObjc(_ str:String)->String{
        let one:TestOne = TestOne()
        return one.getHelloFromObjc("swifty")
    }
}
