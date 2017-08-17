

import Foundation
import XCTest

class BaseTestStep : ScrollViewDelegate, TableViewDelegate  {

    //MARK: - Properties, Initializers
    let testCase:XCTestCase

    init(testCase:XCTestCase){
        self.testCase = testCase
    }
    

    //MARK: - Wait Methods
    func waitForElementToAppear(_ element: XCUIElement, waitSeconds:Double=120){
        self.waitForElementWithPredicate(element, predicate: NSPredicate(format: "exists == true"), waitSeconds: waitSeconds)
    }

    func waitForElementToDisappear(_ element: XCUIElement, waitSeconds:Double=120){
        self.waitForElementWithPredicate(element, predicate: NSPredicate(format: "exists == false"), waitSeconds: waitSeconds)
    }

    func waitForHittable(_ element: XCUIElement, waitSeconds:Double=120) {
        self.waitForElementWithPredicate(element, predicate: NSPredicate(format: "hittable == true"), waitSeconds: waitSeconds)
    }

    func waitForVisible(_ element: XCUIElement, waitSeconds:Double=120) {
        self.waitForElementWithPredicate(element, predicate: NSPredicate(format: "visible == true"), waitSeconds: waitSeconds)
    }

    func waitForNotHittable(_ element: XCUIElement, waitSeconds:Double=120) {
        self.waitForElementWithPredicate(element, predicate: NSPredicate(format: "hittable == false"), waitSeconds: waitSeconds)
    }

    func waitForElementWithPredicate(_ element: XCUIElement, predicate:NSPredicate, waitSeconds:Double=120, file:String=#file, line:UInt=#line){
        testCase.expectation(for: predicate, evaluatedWith: element, handler: nil)

        testCase.waitForExpectations(timeout: waitSeconds) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(waitSeconds) seconds."
                self.testCase.recordFailure(withDescription: message,
                    inFile: file, atLine: line, expected: true)
            }
        }
    }


    func waitForSeconds(_ seconds:UInt32){
        sleep(seconds)
    }

    //MARK: - Assert Methods
    func assertElementExists(_ element:XCUIElement){
        XCTAssertTrue(element.exists)
    }


    //MARK: - Assert Methods
    func assertEqualStrings(_ value1 : String, value2 : String){
        XCTAssertEqual(value1, value2)
    }
    
    //MARK: - Assert Methods
    func assertCompareValue(_ value : String){
        XCTAssertGreaterThan("0", value)
    }

    func getHourString(_ text: String) -> String {
        let hourAndMinuteArray = text.components(separatedBy: ":")
        let hourString: String = hourAndMinuteArray[0]
        return hourString
    }
    
    func getMinuteString(_ text: String) -> String {
        let hourAndMinuteArray = text.components(separatedBy: ":")
        let minuteString: String = hourAndMinuteArray[1]
        return minuteString
    }


    func allowAppToUseLocation() {
        self.testCase.addUIInterruptionMonitor(withDescription: "Location Dialog") { (alert) -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
        XCUIApplication().tap() // need to interact with the app for the handler to fire
    }

    func allowAppToUsePhoto() {
        self.testCase.addUIInterruptionMonitor(withDescription: "Photo Permissions") { (alert) -> Bool in
            alert.buttons["OK"].tap()
            return true
        }
        XCUIApplication().tap() // need to interact with the app for the handler to fire
    }

    func acceptSystemAlert() {
        XCUIApplication().tap() // need to interact with the app for the handler to fire
    }
    
    func waitForActivityIndicatorToFinish() {
        waitForSeconds(3)
        let spinnerQuery = XCUIApplication().activityIndicators["uia_view_timesheet_spinner_identifier"]

        let expression = { () -> Bool in
            return (spinnerQuery.value! as AnyObject).intValue != 1
        }
        waitFor(expression, failureMessage: "Timed out waiting for spinner to finish.")
    }

    // MARK: Private

    fileprivate func waitFor(_ expression: () -> Bool, failureMessage: String) {
        let startTime = Date.timeIntervalSinceReferenceDate

        while (!expression()) {
            if (Date.timeIntervalSinceReferenceDate - startTime > 30.0) {
                NSException(name: NSExceptionName(rawValue: "JAMTestHelper Timeout Failure"), reason: "Activity indicator", userInfo: nil).raise()

            }
            CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.1, Bool(0))
        }
    }

    func toUint(_ signed: Int) -> UInt {

        let unsigned = signed >= 0 ?
            UInt(signed) :
            UInt(signed  - Int.min) + UInt(Int.max) + 1

        return unsigned
    }

    func toInt(_ unsigned: UInt) -> Int {

        let signed = (unsigned <= UInt(Int.max)) ?
            Int(unsigned) :
            Int(unsigned - UInt(Int.max) - 1) + Int.min

        return signed
    }


    func scrollUpUntilElementAppears(_ element: XCUIElement, threshold: Int = 1) {
        var iteration = 0
        while !elementIsWithinWindow(element) {
            guard iteration < threshold else { break }
            scrollUp()
            iteration += 1
        }
        if !elementIsWithinWindow(element) { scrollUp(threshold) }
    }

    func scrollDownUntilElementAppears(_ element: XCUIElement, threshold: Int = 1) {
        var iteration = 0
        while !elementIsWithinWindow(element) {
            guard iteration < threshold else { break }
            scrollDown()
            iteration += 1
        }

        if !elementIsWithinWindow(element) { scrollDown(threshold) }
    }



    fileprivate func elementIsWithinWindow(_ element: XCUIElement) -> Bool {
        guard element.exists && !element.frame.isEmpty && element.isHittable && element.visible() else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(element.frame)
    }

    fileprivate func scrollDown(_ times: Int = 1) {
        let mainWindow = XCUIApplication().windows.element(boundBy: 0)
        let topScreenPoint = mainWindow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05))
        let bottomScreenPoint = mainWindow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.90))
        for _ in 0..<times {
            bottomScreenPoint.press(forDuration: 0, thenDragTo: topScreenPoint)
        }
    }

    fileprivate func scrollUp(_ times: Int = 1) {
        let mainWindow = XCUIApplication().windows.element(boundBy: 0)
        let topScreenPoint = mainWindow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05))
        let bottomScreenPoint = mainWindow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.90))
        for _ in 0..<times {
            topScreenPoint.press(forDuration: 0, thenDragTo: bottomScreenPoint)
        }
    }

}
