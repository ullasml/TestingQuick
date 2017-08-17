

import Foundation

@objc enum ShiftCellType:Int {
    case shiftInfo
    case timeOff
    case holiday
    case shiftDetail
    case udf
    case noShifts
    case notes
}

@objc enum Separator:Int {
    case frontSpacing
    case full
    case none
}

class ShiftItemPresenter : NSObject {
    //Theme
    public private(set)var theme:Theme
    
    //Shift
    public private(set) var shiftDescriptionText:String?
    public private(set) var shiftDetailsDescriptionText:String?
    public private(set) var notes:String?
    public private(set) var shiftColorHex:String?
    
    //UDF - User defined Fields
    public private(set) var udfName:String?
    public private(set) var udfValue:String?
    
    //Time Off
    public private(set) var timeOffDescText:String?
    public private(set) var timeOffStatus:String?
    
    //Holiday
    public private(set) var holidayDescriptionText:String?
    
    public private(set) var cellType:ShiftCellType = .shiftInfo
    public private(set) var cellReuseIdentifier:String = ShiftScheduleCell.getCellIdentifier()
    
    //Display adjustment params
    var bottomSeparator:Separator = Separator.frontSpacing
    var topSeparator:Separator = Separator.none
    
    init (theme: Theme){
        self.theme = theme
        super.init()
    }
    
    func setup(cellType:ShiftCellType,
               shiftDescriptionText: String? = nil,
               shiftDetailsDescriptionText : String? = nil,
               notes:String? = nil,
               shiftColorHex:String? = nil,
               udfName:String? = nil,
               udfValue:String? = nil,
               timeOffDescText:String? = nil,
               timeOffStatus:String? = nil,
               holidayDescriptionText:String? = nil) {
        
        self.cellType = cellType
        self.setUpCellIdentifier()
        
        self.shiftDescriptionText = shiftDescriptionText
        self.shiftDetailsDescriptionText = shiftDetailsDescriptionText
        self.notes = notes
        self.shiftColorHex = shiftColorHex
        self.udfName = udfName
        self.udfValue = udfValue
        self.timeOffDescText = timeOffDescText
        self.timeOffStatus = timeOffStatus
        self.holidayDescriptionText = holidayDescriptionText
 
    }
    
    private func setUpCellIdentifier() {
        switch cellType {
            
        case .shiftInfo:
            self.cellReuseIdentifier = ShiftScheduleCell.getCellIdentifier()
        case .timeOff:
            self.cellReuseIdentifier = ShiftScheduleTimeOffCell.getCellIdentifier()
        case .holiday:
            self.cellReuseIdentifier = ShiftScheduleHolidayCell.getCellIdentifier()
        case .shiftDetail:
            self.cellReuseIdentifier = ShiftDetailCell.getCellIdentifier()
        case .udf:
            self.cellReuseIdentifier = ShiftDetailCell.getCellIdentifier()
        case .noShifts:
            self.cellReuseIdentifier = ShiftDetailCell.getCellIdentifier()
        case .notes:
            self.cellReuseIdentifier = ShiftDetailCell.getCellIdentifier()
        }
        
    }
   
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherObject = object as? ShiftItemPresenter else{
            return false
        }
        
        if self.shiftDescriptionText != otherObject.shiftDescriptionText {
            return false
        }
        if self.notes != otherObject.notes {
            return false
        }
        if self.shiftColorHex != otherObject.shiftColorHex {
            return false
        }
        if self.timeOffDescText != otherObject.timeOffDescText {
            return false
        }
        if self.timeOffStatus != otherObject.timeOffStatus {
            return false
        }
        if self.holidayDescriptionText != otherObject.holidayDescriptionText {
            return false
        }
        if self.cellType != otherObject.cellType {
            return false
        }
        if self.cellReuseIdentifier != otherObject.cellReuseIdentifier {
            return false
        }
        return true
    }
    
    func timeOffStatusColorAndText() -> TimeOffApprovalStatusInfo {
        
        let statusInfo = TimeOffApprovalStatusInfo()
        if let status = timeOffStatus {
            statusInfo.statusText = status
            
            switch status {
            case APPROVED_STATUS:
                statusInfo.statusColor = theme.approvedColor()
                statusInfo.statusImageName = "approved"
                
            case WAITING_FOR_APRROVAL_STATUS:
                statusInfo.statusColor = theme.waitingForApprovalColor()
                statusInfo.statusImageName = "waiting-for-approval"
                
            case REJECTED_STATUS:
                statusInfo.statusColor = theme.rejectedColor()
                statusInfo.statusImageName = "rejected"
                
            default:
                statusInfo.statusColor = theme.shiftTimeOffNotSubmittedStatusColor()
            }
        }
        
        return statusInfo
    }
}


