//
//  DeepLinkManager.swift
//  NextGenRepliconTimeSheet
//

import Foundation

/// DeeplinkType (enum) contains all possible deeplinks that our application supports.
@objc enum DeeplinkType : Int {
    case login
    case timeSheet
    case timeOff
    case expense
    case shift
    case timeoffApproval
    case timesheetApproval
    case expenseApproval
}

/// DeepLinkManager acts as a public interface for all types of deeplinks (Shortcuts, Notification & Universal links).
/// Shortcuts related deeplinks are in ShortcutParser.swift. Likewise create a new parser when implementing deeplinks via notification / universal links.

@objc class DeepLinkManager : NSObject {
    static let shared = DeepLinkManager()
    private override init() {} //This prevents others from using the default '()' initializer for this class.
    private var deeplinkType: DeeplinkType?

    
    @available(iOS 9.0, *)
    func handleShortcut(item: UIApplicationShortcutItem) -> Bool {
        deeplinkType = ShortcutParser.shared.handleShortcut(item)
        return deeplinkType != nil
    }
    
    // check existing deepling and perform action
    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let deepLinkNavigator = appDelegate.injector.getInstance(DeepLinkNavigator.self) as? DeepLinkNavigator else { return }
        let success = deepLinkNavigator.proceedToDeeplink(deeplinkType)
        
        // reset deeplink after handling
        if success {
            self.deeplinkType = nil
        }
    }
}
