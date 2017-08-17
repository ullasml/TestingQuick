
import Foundation
class ShiftItemsSectionPresenter:NSObject {
    public private(set) var shiftDayText:String?
    public private(set) var subText:String?
    public private(set) var theme:Theme
    
    var shiftItemPresenters:[ShiftItemPresenter] = [ShiftItemPresenter]()
    
    var showFullBottomSeparator = false
    
    init (theme: Theme){
        self.theme = theme
        super.init()
    }
    
    func setup(shiftDayText: String?, subText: String?, shiftItemPresenters:[ShiftItemPresenter]) {
        self.shiftDayText = shiftDayText
        self.subText = subText
        self.shiftItemPresenters = shiftItemPresenters
    }

    
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherObject = object as? ShiftItemsSectionPresenter else {
            return false
        }
        
        if self.shiftDayText != otherObject.shiftDayText {
            return false
        }
        if self.subText != otherObject.subText {
            return false
        }
        if self.shiftItemPresenters != otherObject.shiftItemPresenters {
            return false
        }
        
        return true
    }
}
