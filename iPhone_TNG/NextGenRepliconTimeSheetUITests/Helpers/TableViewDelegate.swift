
import XCTest

protocol TableViewDelegate{
    func tableScrollViewUpAction(withName name: String)
    func tableScrollViewDownAction(withName name: String)
}

extension TableViewDelegate where Self:BaseTestStep{
    func tableScrollViewUpAction(withName name: String){
        let tableViewElement = getTableView(withName: name)
        tableViewElement.cells.element(boundBy: 0).swipeUp()
    }
    
    func tableScrollViewDownAction(withName name: String){
        let tableViewElement = getTableView(withName: name)
        tableViewElement.cells.element(boundBy: 0).swipeDown()
    }
    
    private func getTableView(withName name: String) -> XCUIElement{
        let tableViewElement = XCUIApplication().tables[name]
        waitForElementToAppear(tableViewElement)
        waitForHittable(tableViewElement)
        return tableViewElement
    }
}
