

import Foundation
import XCTest

class ImageSelectionTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func selectAnImage() {
        let momentsElement = XCUIApplication().tables.cells.element(boundBy: 1)
        waitForElementToAppear(momentsElement)
        waitForHittable(momentsElement, waitSeconds: 120)
        momentsElement.tap()

        let photosGridViewElement = XCUIApplication().collectionViews.cells.element(boundBy: 0)
        waitForElementToAppear(photosGridViewElement)
        waitForHittable(photosGridViewElement, waitSeconds: 120)
        photosGridViewElement.tap()
    }
}
