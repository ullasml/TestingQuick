//
//  ShortcutParser.swift
//  NextGenRepliconTimeSheet
//

import Foundation
///ShortcutKey (enum) contains all deeplinks that are available for "Home Screen Quick Action".
enum ShortcutKey: String {
    case login = "Sign in"
    case timeSheet = "Enter time"
    case timeOff = "Book time off"
    case expense = "New expense sheet"
    case shift = "View my schedule"
    case timeoffApproval = "Approve time offs"
    case timesheetApproval = "Approve timesheets"
    case expenseApproval = "Approve expenses"
    
    var type: String {
        return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
    }
    
    var imageName:String {
        switch self {
        case .login:
            return "signin"
        case .timeSheet:
            return "entertime"
        case .timeOff, .timeoffApproval:
            return "timeoff"
        case .expense, .expenseApproval:
            return "expenses"
        case .shift:
            return "schedule"
        case .timesheetApproval:
            return "timesheets"
        }
    }
    
    @available(iOS 9.0, *)
    var icon: UIApplicationShortcutIcon {
        return UIApplicationShortcutIcon(templateImageName: self.imageName)
    }
}

///ShortcutParser acknowledges a deeplink if it can be handled. All Shortcuts are dynamically added and synced when app goes to background state.
@objc class ShortcutParser : NSObject {
    static let shared = ShortcutParser()
    private override init() {} //This prevents others from using the default '()' initializer for this class.
    private let accessDict = [(FeatureAccessKey.timeSheet , ShortcutKey.timeSheet),
                      (FeatureAccessKey.timeSheetApproval , ShortcutKey.timesheetApproval),
                      (FeatureAccessKey.timeOffApproval , ShortcutKey.timeoffApproval),
                      (FeatureAccessKey.expenseApproval , ShortcutKey.expenseApproval),
                      (FeatureAccessKey.shift , ShortcutKey.shift),
                      (FeatureAccessKey.timeOff , ShortcutKey.timeOff),
                      (FeatureAccessKey.expense , ShortcutKey.expense)]
    @available(iOS 9.0, *)
    func handleShortcut(_ shortcut: UIApplicationShortcutItem) -> DeeplinkType? {
        switch shortcut.type {
        case ShortcutKey.login.type:
            return .login
        case ShortcutKey.timeSheet.type:
            return .timeSheet
        case ShortcutKey.timeOff.type:
            return .timeOff
        case ShortcutKey.expense.type:
            return .expense
        case ShortcutKey.shift.type:
            return .shift
        case ShortcutKey.timesheetApproval.type:
            return .timesheetApproval
        case ShortcutKey.timeoffApproval.type:
            return .timeoffApproval
        case ShortcutKey.expenseApproval.type:
            return .expenseApproval
        default:
            return nil
        }
    }
    
    func syncShortcut() {
        
        if #available(iOS 9.0, *) {
            var newShortcuts = [UIMutableApplicationShortcutItem]()
            
            let isLoggedIn = UserDefaults.standard.bool(forKey: FeatureAccessKey.login)
            let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
            let userInfo = ["CFBundleVersion": version]
            if(!isLoggedIn){
                let loginShortCut = UIMutableApplicationShortcutItem(type: ShortcutKey.login.type, localizedTitle: ShortcutKey.login.rawValue.localize(), localizedSubtitle: nil, icon: ShortcutKey.login.icon, userInfo: userInfo)
                newShortcuts.append(loginShortCut)
            }else{
                
                let supportModel = SupportDataModel()
                let dbUserDetails = supportModel.getUserDetailsFromDatabase()
                guard let userDetails = dbUserDetails?.firstObject as? Dictionary<String, Any> else { return }
                for (accessKey,accessValue) in accessDict {
                    if Array(userDetails.keys).contains(accessKey), let access = userDetails[accessKey] as? Bool, access{
                        let shortCutItem = UIMutableApplicationShortcutItem(type: accessValue.type, localizedTitle: accessValue.rawValue.localize(), localizedSubtitle: nil, icon: accessValue.icon, userInfo: userInfo)
                        newShortcuts.append(shortCutItem)
                    }
                }
            }
            
            UIApplication.shared.shortcutItems = newShortcuts
        } else {
            // Fallback on earlier versions
        }
    }
    
}
