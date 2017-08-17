
import XCTest

protocol ScrollViewDelegate{
    func scrollViewUpAction(withName name: String)
    func scrollViewDownAction(withName name: String)
}

extension ScrollViewDelegate where Self:BaseTestStep{
    func scrollViewUpAction(withName name: String){
        let scrollViewElement = getScrollView(withName: name)
        scrollViewElement.swipeUp()
    }
    
    func scrollViewDownAction(withName name: String){
        let scrollViewElement = getScrollView(withName: name)
        scrollViewElement.swipeDown()
    }
    
    private func getScrollView(withName name: String) -> XCUIElement{
        let scrollViewElement = XCUIApplication().scrollViews[name]
        waitForElementToAppear(scrollViewElement)
        waitForHittable(scrollViewElement)
        return scrollViewElement
    }
}
