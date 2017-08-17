
import Foundation

struct Constants{
    //MARK: - System Elements Ids
    static let navigationbarPlusButton = "icon task plus button"
    static let navigationbarAddButton = "Add"
    static let navigationbarBackButton = "Back"
    static let barButtonAddId = "icon task plus button"
    
    //uri
    static let textOefUri = "urn:replicon:object-extension-definition-type:object-extension-type-text"
    static let numericOefUri = "urn:replicon:object-extension-definition-type:object-extension-type-numeric"
    static let dropDownOefUri = "urn:replicon:object-extension-definition-type:object-extension-type-tag"
    
    static let punch_flow_scroll_view_identifier = "uia_punch_astro_flow_scroll_view"
    static let delete_button_identifier = "Delete"
    static let timesheet_day_view_details_identifier = "uia_timesheet_day_view_details_table_identifier"
    static let punch_flow_select_value_tableview_identifier = "uia_select_table_identifier"
    static let punch_flow_timesheet_breakdown_scrollview_identifier = "uia_timesheet_breakdown_scrollview_identifier"
}

enum PunchType:String {
    case ClockIn = "Clocked In"
    case TakeBreak = "TakeBreak"
    case ClockOut = "Clocked Out"
    case ResumeWork = "Resume Work"
    case Transfer = "Transfer"
}

enum ViolationType:String {
    case Error = "Error"
    case Warning = "Warning"
    case Information = "Information"
}

enum UdfType:String {
    case DropDownUdf = "Drop-down"
    case NumericUdf = "Numeric"
    case DateUdf = "Date"
    case TextUdf = "Text"
}

enum EntryType:String {
    case Time = "Time"
    case Break = "Break"
    case Timeoff = "Timeoff"
}

