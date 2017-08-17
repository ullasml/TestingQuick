
import Foundation
import XCTest

class BaseScenario: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    lazy var welcomeTestStep : WelcomeTestStep = {
        return WelcomeTestStep(testCase: self)
    }()
    
    lazy var loginTestStep:LoginTestStep = {
        return LoginTestStep(testCase: self)
    }()

    lazy var progressIndicatorTestStep:ProgressIndicatorTestStep = {
        return ProgressIndicatorTestStep(testCase: self)
    }()

    lazy var tabBarTestStep:TabBarTestStep = {
        return TabBarTestStep(testCase: self)
    }()

    lazy var logoutTestStep:LogoutTestStep = {
        return LogoutTestStep(testCase: self)
    }()

    lazy var timesheetListTestStep:TimesheetListTestStep = {
        return TimesheetListTestStep(testCase: self)
    }()

    lazy var timesheetDetailsTestStep:TimesheetDetailsTestStep = {
        return TimesheetDetailsTestStep(testCase: self)
    }()

    lazy var timesheetDayEntriesTestStep:TimesheetDayEntriesTestStep = {
        return TimesheetDayEntriesTestStep(testCase: self)
    }()

    lazy var dashboardTestStep:DashboardTestStep = {
        return DashboardTestStep(testCase: self)
    }()

    lazy var approveTimesheetsTestStep:ApproveTimesheetsTestStep = {
        return ApproveTimesheetsTestStep(testCase: self)
    }()

    lazy var widgetTimesheetDetailsTestStep:WidgetTimesheetDetailsTestStep = {
        return WidgetTimesheetDetailsTestStep(testCase: self)
    }()

    lazy var punchInTestStep:PunchInTestStep = {
        return PunchInTestStep(testCase: self)
    }()

    lazy var punchOutTestStep:PunchOutTestStep = {
        return PunchOutTestStep(testCase: self)
    }()

    lazy var startBreakTestStep:StartBreakTestStep = {
        return StartBreakTestStep(testCase: self)
    }()

    lazy var workAndBreakHoursTestStep:WorkAndBreakHoursTestStep = {
        return WorkAndBreakHoursTestStep(testCase: self)
    }()

    lazy var timeLineTestStep:TimeLineTestStep = {
        return TimeLineTestStep(testCase: self)
    }()

    lazy var addressTestStep:AddressTestStep = {
        return AddressTestStep(testCase: self)
    }()

    lazy var manualPunchTestStep:ManualPunchTestStep = {
        return ManualPunchTestStep(testCase: self)
    }()
    
    lazy var punchOverViewTestStep:PunchOverViewTestStep = {
        return PunchOverViewTestStep(testCase: self)
    }()

    lazy var scrollTestStep:ScrollTestStep = {
        return ScrollTestStep(testCase: self)
    }()

    lazy var imageSelectionTestStep:ImageSelectionTestStep = {
        return ImageSelectionTestStep(testCase: self)
    }()

    lazy var breakTypeSelectTestStep:BreakTypeSelectTestStep = {
        return BreakTypeSelectTestStep(testCase: self)
    }()
    
    lazy var viewMyTimesheetsTestStep:ViewMyTimesheetsTestStep = {
        return ViewMyTimesheetsTestStep(testCase: self)
    }()

    lazy var timesheetBreakDownTestStep:TimesheetBreakDownTestStep = {
        return TimesheetBreakDownTestStep(testCase: self)
    }()

    lazy var baseTestStep:BaseTestStep = {
        return BaseTestStep(testCase: self)
    }()

    lazy var previousOrNextTimesheetNavigationTestStep:PreviousOrNextTimesheetNavigationTestStep = {
        return PreviousOrNextTimesheetNavigationTestStep(testCase: self)
    }()

    lazy var violationsTestStep:ViolationsTestStep = {
        return ViolationsTestStep(testCase: self)
    }()

    lazy var spinnerTestStep:SpinnerTestStep = {
        return SpinnerTestStep(testCase: self)
    }()

    lazy var addTextUDFTestStep:AddTextUDFTestStep = {
        return AddTextUDFTestStep(testCase: self)
    }()

    lazy var sheetLevelUDFTestStep:SheetLevelUDFTestStep = {
        return SheetLevelUDFTestStep(testCase: self)
    }()

    lazy var cellLevelUDFTestStep:CellLevelUDFTestStep = {
        return CellLevelUDFTestStep(testCase: self)
    }()

    lazy var rowLevelUDFTestStep:RowLevelUDFTestStep = {
        return RowLevelUDFTestStep(testCase: self)
    }()
    
    lazy var selectDropDownEntryTestStep:SelectDropDownEntryTestStep = {
        return SelectDropDownEntryTestStep(testCase: self)
    }()
    
    lazy var timesheetDayEntryDetailsTestStep:TimesheetDayEntryDetailsTestStep = {
        return TimesheetDayEntryDetailsTestStep(testCase: self)
    }()
    
    lazy var timeoffTestStep:TimeoffTestStep = {
        return TimeoffTestStep(testCase: self)
    }()

    lazy var approvalDetailsTestStep:ApprovalDetailsTestStep = {
        return ApprovalDetailsTestStep(testCase: self)
    }()

    lazy var punchInOEFTestStep:PunchInOEFTestStep = {
        return PunchInOEFTestStep(testCase: self)
    }()

    lazy var punchOutOEFTestStep:PunchOutOEFTestStep = {
        return PunchOutOEFTestStep(testCase: self)
    }()
    
    lazy var breakOEFTestStep:BreakOEFTestStep = {
        return BreakOEFTestStep(testCase: self)
    }()
    
    lazy var resumeOEFTestStep:ResumeOEFTestStep = {
        return ResumeOEFTestStep(testCase: self)
    }()
    
    lazy var dropDownOefSelectTestStep:DropDownOefSelectTestStep = {
        return DropDownOefSelectTestStep(testCase: self)
    }()
    
    lazy var verifyPunchOEFsTestStep:VerifyPunchOEFsValuesTestStep = {
        return VerifyPunchOEFsValuesTestStep(testCase: self)
    }()
    
    lazy var punchAttributeValueTestStep:PunchAttributeValueTestStep = {
        return PunchAttributeValueTestStep(testCase: self)
    }()
    
    lazy var oefCardTestStep:OEFCardTestStep = {
        return OEFCardTestStep(testCase: self)
    }()
}
