//
//  DeepLinkNavigator.swift
//  NextGenRepliconTimeSheet
//

import Foundation

///DeepLinkNavigator handles navigation for all deeplinks (Shortcuts, Notification & Universal links).

@objc class DeepLinkNavigator : NSObject {

    private let applicationDelegate:AppDelegate?
    
    init(withAppdelegate appDelegate:AppDelegate) {
        self.applicationDelegate = appDelegate
        super.init()
    }
    
    
    func proceedToDeeplink(_ type: DeeplinkType) -> Bool{
        guard let appDelegate = applicationDelegate else { return false }
        if let modules = appDelegate.moduleStorage.modules() as? [String], modules.count > 0 {
            switch type {
            case .timeSheet:
                if let index = modules.index(of: FeatureModule.nonAstroTimeSheet){
                    return timeSheetPage(at: index)
                }else if let index = modules.index(of: FeatureModule.astroTimeSheet){
                    return timeSheetPage(at: index)
                }else if let index = modules.index(of: FeatureModule.punchTimeSheet){
                    return timeSheetPage(at: index)
                }
                return false
            case .timeOff:
                guard let index = modules.index(of: FeatureModule.timeOff)
                    else { return false }
                return timeOffPage(at: index)
            case .expense:
                guard let index = modules.index(of: FeatureModule.expense)
                    else { return false }
                return expensePage(at: index)
            case .shift:
                guard let index = modules.index(of: FeatureModule.shift)
                    else { return false }
                return shiftPage(at: index)
            case .timesheetApproval:
                guard let index = modules.index(of: FeatureModule.approvals)
                    else { return false }
                return approvalsPage(at: index, forType: .timesheetApproval)
            case .timeoffApproval:
                guard let index = modules.index(of: FeatureModule.approvals)
                    else { return false }
                return approvalsPage(at: index, forType: .timeoffApproval)
            case .expenseApproval:
                guard let index = modules.index(of: FeatureModule.approvals)
                    else { return false }
                return approvalsPage(at: index, forType: .expenseApproval)
            default:
                return true
            }
        }else{
            switch type {
            case .login:
                return loginPage()
            default:
                return true
            }
        }
    }
    
    private func loginPage() -> Bool{
        guard let appDelegate = applicationDelegate else { return false }
        dismissPresentedViewsAndExecute { 
            appDelegate.launchLoginViewController(false)
        }
        return true
    }
    
    private func timeSheetPage(at index:Int) -> Bool{
        
        let page = getSelectedViewController(at: index)
        if let timeSheetListVC = page as? ListOfTimeSheetsViewController{
            dismissPresentedViewsAndExecute {
                timeSheetListVC.launchCurrentTimeSheet()
            }
            return true
        }else if let _ = page{
            dismissPresentedViewsAndExecute(block: nil)
            return true
        }
        return false
    }
    
    private func timeOffPage(at index:Int) -> Bool{
        guard let timeOffListVC = getSelectedViewController(at: index) as? ListOfBookedTimeOffViewController else { return false }
        dismissPresentedViewsAndExecute {
            timeOffListVC.launchBookTimeOff()
        }
        
        return true
    }
    
    private func expensePage(at index:Int) -> Bool{
        guard let expenseListVC = getSelectedViewController(at: index) as? ListOfExpenseSheetsViewController else { return false }
        dismissPresentedViewsAndExecute {
            expenseListVC.addExpenseSheetAction(nil)
        }
        return true
    }
    
    private func shiftPage(at index:Int) -> Bool{
        guard let shiftsListVC = getSelectedViewController(at: index) as? ShiftsViewController else { return false }
        dismissPresentedViewsAndExecute {
            shiftsListVC.launchCurrentShift()
        }
        return true
    }
    
    private func approvalsPage(at index:Int, forType type:DeeplinkType) -> Bool{
        guard let dashboardVC = getSelectedViewController(at: index) as? SupervisorDashboardController else { return false }
        dismissPresentedViewsAndExecute {
            switch type {
            case .timesheetApproval:
                dashboardVC.selectApprovals(forModule: FeatureModule.timeSheetApproval)
            case .timeoffApproval:
                dashboardVC.selectApprovals(forModule: FeatureModule.timeOffApproval)
            case .expenseApproval:
                dashboardVC.selectApprovals(forModule: FeatureModule.expenseApproval)
            default:
                print("Not a valid case")
            }
        }
        return true
    }
    
    
    private func dismissPresentedViewsAndExecute(block: (()->())?){
        if let rootVC = applicationDelegate?.window.rootViewController, (rootVC.presentedViewController) != nil {
            rootVC.presentedViewController?.dismiss(animated: false, completion: {
                DispatchQueue.main.async {
                    block?()
                }
            })
        }else{
            block?()
        }
    }
    
    private func getSelectedViewController(at index:Int)-> UIViewController?{
        guard let appDelegate = applicationDelegate,
            let tabBar = appDelegate.window.rootViewController as? UITabBarController,
            let controllersCount = tabBar.viewControllers?.count, controllersCount > 0
            else { return nil }
  
        
        if index > 3 {
            tabBar.moreNavigationController.popToRootViewController(animated: false)
            tabBar.selectedIndex = index
            return tabBar.moreNavigationController.topViewController
        }else{
            tabBar.selectedIndex = index
            let navigationController = tabBar.selectedViewController as? UINavigationController
            navigationController?.popToRootViewController(animated: false)
            return navigationController?.viewControllers.first
        }
        
    }
    
}
