//
//  Constants.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 10/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

enum ConstStrings{
    
    //Localized Const Strings

    static let startingAt = "Starting At".localize()
    static let returningAt = "Returning At".localize()
    static let startDate = "Start Date".localize()
    static let endDate = "End Date".localize()
    static let hours = "hours".localize()
    static let days = "days".localize()
    static let hour = "hour".localize()
    static let day = "day".localize()
    static let select = "Select".localize()
    static let clear = "Clear".localize()
    static let selectDate = "Select Date".localize()
    static let selectTime = "Select Time".localize()
    static let schedule = "Scheduled".localize()
    static let book = "Book".localize()
    static let type = "Type".localize()
    static let NA = "N/A".localize()
    static let add = "Add".localize()
    static let none = "None".localize()
    static let partialHoursValidationMsg = "Please enter booking hours".localize()
    static let submit = "Submit".localize()
    static let resubmit = "Resubmit".localize()
    static let edit = "Edit".localize()
    static let collapseDays = "Collapse Days".localize()
    static let expandDays = "Expand Days".localize()
    static let ok = "OK".localize()
    static let cancel = "Cancel".localize()
    static let loading = "Loading...".localize()
    static let requested = "Requested".localize()
    static let balance = "Balance".localize()
    static let comments = "Comments".localize()
    static let delete = "Delete".localize()
    static let bookTimeOff = "Book Time Off".localize()
    static let timeOffBooking = "Time Off Booking".localize()
    
    static let deleteTimeOffMsg = "Are you sure you want to delete this time off booking?".localize()
    static let deviceOfflineMsg = "Your device is offline.  Please try again when your device is online.".localize()
    static let noTimeOffTypesAssigned = "You do not have any time off types assigned. Please contact your Admin.".localize()

    //Shift schedules
    static let allDay = "All Day".localize()
    static let to = "to".localize()
    static let holiday = "holiday".localize()
    static let noShiftsAssigned = "No Shifts Assigned".localize()
    static let totalHours = "Total Hours".localize()
    static let work = "Work".localize()
    static let breakInShift = "Break".localize()
    static let notesFromShiftManager = "Notes from Shift Manager".localize()
    
    
    static let pendingApproval = "Pending approval".localize()

    //Non Localized Const Strings
    static let module = "TimeOff_UDF"

}

enum TimeOffConstants{
    
    enum DurationType{
        static let fullDay = "urn:replicon:time-off-relative-duration:full-day"
        static let quarterDay = "urn:replicon:time-off-relative-duration:quarter-day"
        static let halfDay = "urn:replicon:time-off-relative-duration:half-day"
        static let threeQuarterDay = "urn:replicon:time-off-relative-duration:three-quarter-day"
        static let partialDay = "urn:replicon:time-off-relative-duration:partial-day"
        static let none = "urn:replicon:time-off-relative-duration:none"
        static let unknown = "unknown"
    }
    
    enum MeasurementUnit{
        static let hours = "urn:replicon:time-off-measurement-unit:hours"
        static let days = "urn:replicon:time-off-measurement-unit:work-days"
    }
    
    enum ApprovalStatus{
        static let waiting = "urn:replicon:approval-status:waiting"
        static let approved = "urn:replicon:approval-status:approved"
        static let rejected = "urn:replicon:approval-status:rejected"
    }
}

enum FeatureModule{
    static let nonAstroTimeSheet = "Timesheets_Module";
    static let astroTimeSheet = "New_Punch_Widget_System";
    static let punchTimeSheet = "punchInProject_Module"
    static let expense = "Expenses_Module";
    static let timeOff = "BookedTimeOff_Module";
    static let shift = "Shifts_Module";
    static let approvals = "Approvals_Module";
    static let timeSheetApproval = "timesheets_approvals";
    static let timeOffApproval = "timeoffs_approvals";
    static let expenseApproval = "expenses_approvals";
}

enum FeatureAccessKey{
    static let login = "isSuccessLogin"
    static let timeSheet = "hasTimesheetAccess";
    static let expense = "hasExpenseAccess";
    static let timeOff = "hasTimeoffBookingAccess";
    static let shift = "canViewShifts";
    static let timeSheetApproval = "isTimesheetApprover";
    static let timeOffApproval = "isTimeOffApprover";
    static let expenseApproval = "isExpenseApprover";
}

enum UserDefaultsKey{
    static let pendingTimesheetApprovalCount = "pendingTimesheetApprovalCount"
    static let pendingTimeOffApprovalCount = "pendingTimeOffApprovalCount"
    static let pendingExpenseSheetApprovalCount = "pendingExpenseSheetApprovalCount"
}

enum Precision{
    static let twoDecimal = "%.2f"
}

struct DateFormat{
    static let format1 = "MMM dd, yyyy"
    static let format2 = "yyyy-MM-dd"
    static let format3 = "EEE, MMM dd"
}

struct TimeFormat{
    static let format1 = "hh:mm a"
}
