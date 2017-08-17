
import Foundation


class ShiftSummaryPresenter : NSObject {
    let theme: Theme
    let presenterHelper: ShiftPresenterHelper
    weak var injector:BSInjector!
    
    init(theme: Theme, presenterHelper: ShiftPresenterHelper){
        self.theme = theme
        self.presenterHelper = presenterHelper
        super.init()
    }
    
    func shiftItemPresenterSections(forShiftDataList shiftDataList: [[String:Any]]) -> [ShiftItemsSectionPresenter] {
        var presenters = [ShiftItemsSectionPresenter]()
        for shiftData in shiftDataList {
            if let shiftDay = shiftData["shiftDay"] as? String , let shiftDetail = shiftData["ShiftEntry"]{
                let sectionPresenter = self.createShiftItemsSectionPresenter(day: shiftDay, shifData: shiftDetail)
                presenters.append(sectionPresenter)
            }
        }
        return presenters
    }
    
    
    private func createShiftItemsSectionPresenter(day:String,shifData:Any )-> ShiftItemsSectionPresenter {
        var subText:String?
        var shiftItemPresenters = [ShiftItemPresenter]()
        
        if let entryDetail = shifData as? String { // If no shifts assigned, this comes as text("No Shifts Assigned")
            subText = entryDetail
        }
        else  if let entryDetail = shifData as? [[String:Any]] {
            
            for detailDict in entryDetail {
                if let element = detailDict["type"] as? String {
                    if element == TIME_OFF_ENTRY {
                        let timeOffitemPresenter = presenterHelper.createTimeOffItemPresenter(dataDict: detailDict, timeOffNameKey: "timeOffName", approvalStatusKey: "timeOffApprovalStatus")
                        shiftItemPresenters.append(timeOffitemPresenter)
                        
                    }
                    else if element == HOLIDAY_ENTRY {
                        let holidayitemPresenter = presenterHelper.createHolidayItemPresenter(dataDict: detailDict)
                        shiftItemPresenters.append(holidayitemPresenter)
                        
                    }
                    else {// Shifts
                        let shiftitemPresenter = createShiftItemPresenter(dataDict: detailDict)
                        shiftItemPresenters.append(shiftitemPresenter)
                        
                    }
                }
            }
        }
        
        let sectionPresenter = injector.getInstance(ShiftItemsSectionPresenter.self) as! ShiftItemsSectionPresenter
        sectionPresenter.setup(shiftDayText: day,
                               subText: subText,
                               shiftItemPresenters:shiftItemPresenters)
        
        // Examine the presenters to determine the separators
        if sectionPresenter.shiftItemPresenters.count == 0 {
            sectionPresenter.showFullBottomSeparator = true
        }
        
        if let shiftItemPresenter = sectionPresenter.shiftItemPresenters.first, shiftItemPresenter.cellType == .shiftInfo {
            sectionPresenter.showFullBottomSeparator = true
        }
        
        
        var previousItemPresenter:ShiftItemPresenter?
        for shiftItemPresenter in sectionPresenter.shiftItemPresenters {
            if shiftItemPresenter.cellType == .shiftInfo {
                shiftItemPresenter.bottomSeparator = .full
                previousItemPresenter?.bottomSeparator = .full
            }
            else {
                shiftItemPresenter.bottomSeparator = .frontSpacing
            }
            
            previousItemPresenter = shiftItemPresenter
        }
        
        
        
        if let shiftItemPresenter = sectionPresenter.shiftItemPresenters.last {
            shiftItemPresenter.bottomSeparator = .full
        }
        
        return sectionPresenter
    }
    
    
    //MARK: Shift cell model creation
    private func createShiftItemPresenter(dataDict:[String:Any])->ShiftItemPresenter {
        
        
        var shiftColorHex:String?
        if let shiftColorCode = dataDict["color"] as? String {
            shiftColorHex = String(format: "#%@", shiftColorCode)
        }
        
        // Populate shift description text
        var shiftDescText = ""
        let shiftName = dataDict["shiftName"] as? String
        if let shiftName_ = shiftName {
            shiftDescText = shiftName_
        }
        
        if let duration = dataDict["shiftDuration"] as? String, duration != NULL_STRING {
            let formattedDuration = duration.replacingOccurrences(of: "-", with: ConstStrings.to)
            if (shiftName != nil) {
                shiftDescText.append(" - ")
            }
            shiftDescText.append(formattedDuration)
        }
        
        
        // Decide on comments icon
        var notes:String?
        if let  note = dataDict["note"] as? String, !note.isEmpty, note != NULL_STRING {
            notes = note
        }
        
        
        let shiftItemPresenter = injector.getInstance(ShiftItemPresenter.self) as! ShiftItemPresenter
        shiftItemPresenter.setup(cellType:.shiftInfo,
                                 shiftDescriptionText: shiftDescText,
                                 notes: notes,
                                 shiftColorHex: shiftColorHex)
        
        return shiftItemPresenter
    }
    
}
