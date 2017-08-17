import Foundation
import XCTest

class TabBarTestStep: BaseTestStep {

    override init(testCase:XCTestCase){
        super.init(testCase:testCase)
    }

    func tapOnSettings() {
        
        let settingsTabItem = XCUIApplication().tabBars.buttons["settings_tabbar_item"];
        waitForElementToAppear(settingsTabItem)
        waitForHittable(settingsTabItem);
        settingsTabItem.tap();
    }

    func tapOnDashboards() {

        let dashboardsTabItem = XCUIApplication().tabBars.buttons["Dashboard"];
        waitForElementToAppear(dashboardsTabItem)
        waitForHittable(dashboardsTabItem);
        dashboardsTabItem.tap();
    }
}
