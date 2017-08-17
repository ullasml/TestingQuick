

import UIKit

// MARK: <PayWidgetPagingControllerPresenterInterface>

@objc protocol PayWidgetPagingControllerPresenterInterface{
    func pagingViewControllersWithPayWidgetData(_ payWidgetData:PayWidgetData!,delegate:GrossPayOrHoursControllerDelegate!,viewMode:ViewMode,displayPay:Bool,displayPayTotals:Bool) -> [GrossPayOrHoursController]!

}

class PayWidgetPagingControllerPresenter: NSObject,PayWidgetPagingControllerPresenterInterface {
    weak var injector : BSInjector!

    func pagingViewControllersWithPayWidgetData(_ payWidgetData:PayWidgetData!,delegate:GrossPayOrHoursControllerDelegate!,viewMode:ViewMode,displayPay:Bool,displayPayTotals:Bool) -> [GrossPayOrHoursController]!{
        let grossHoursController = self.injector.getInstance(GrossPayOrHoursController.self) as! GrossPayOrHoursControllerInterface
        grossHoursController.setupWithPayWidgetData(payWidgetData, screenType: GrossSummaryScreenType.hoursScreen, delegate: delegate, viewMode: viewMode, displayPayTotals: displayPayTotals)
        
        let grossPayController = self.injector.getInstance(GrossPayOrHoursController.self) as! GrossPayOrHoursControllerInterface
        grossPayController.setupWithPayWidgetData(payWidgetData, screenType: GrossSummaryScreenType.payScreen, delegate: delegate, viewMode: viewMode, displayPayTotals: displayPayTotals)
        
        var controllers = [GrossPayOrHoursController]()
        if displayPay{
            controllers.append(grossPayController as! GrossPayOrHoursController)
        }
        controllers.append(grossHoursController as! GrossPayOrHoursController)
        return controllers
    }

}
