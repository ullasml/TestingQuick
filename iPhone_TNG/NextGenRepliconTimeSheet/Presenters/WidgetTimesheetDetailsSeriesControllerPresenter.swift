
import UIKit

enum TimesheetActionType : String{
    case Submit = "Submit"
    case Resubmit = "Resubmit"
    case Reopen = "Reopen"    
}

// MARK: <WidgetTimesheetDetailsSeriesControllerPresenterInterface>

@objc protocol WidgetTimesheetDetailsSeriesControllerPresenterInterface{
    func navigationBarRightButtonItemForTimesheetPermittedActions(_ actions:TimeSheetPermittedActions) -> UIBarButtonItem?
    func navigationBarRightButtonItemWithSpinner() -> UIBarButtonItem?
    func setUpWithDelegate(_ delegate:WidgetTimesheetDetailsSeriesControllerPresenterDelegate)


}

// MARK: <WidgetTimesheetDetailsSeriesControllerPresenterDelegate>

@objc protocol WidgetTimesheetDetailsSeriesControllerPresenterDelegate{
    
    func userIntendsTo(_ action:RightBarButtonActionType, presenter :WidgetTimesheetDetailsSeriesControllerPresenter)
}

// MARK: WidgetTimesheetDetailsSeriesControllerPresenter

class WidgetTimesheetDetailsSeriesControllerPresenter: NSObject,WidgetTimesheetDetailsSeriesControllerPresenterInterface {

    weak var delegate: WidgetTimesheetDetailsSeriesControllerPresenterDelegate!
    weak var injector : BSInjector!

    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    func setUpWithDelegate(_ delegate:WidgetTimesheetDetailsSeriesControllerPresenterDelegate){
        self.delegate = delegate
    }

    func navigationBarRightButtonItemWithSpinner() -> UIBarButtonItem?{
        let activityIndicatorView  = self.injector.getInstance(InjectorKeyActivityIndicator) as! UIActivityIndicatorView
        activityIndicatorView.startAnimating()
        return UIBarButtonItem(customView: activityIndicatorView)
    }

    
    func navigationBarRightButtonItemForTimesheetPermittedActions(_ actions:TimeSheetPermittedActions) -> UIBarButtonItem? {
        let actionType = self.actionType(actions)
        let shouldShowRightBarButtonItem =  (actionType == RightBarButtonActionTypeNone) ? false : true
        
        if shouldShowRightBarButtonItem {
            let title = self.getButtonTitle(actions)
            let actionType = self.actionType(actions)
            let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.timeSheetRightBarButtonButtonAction))
            button.tag = Int(actionType.rawValue)
             return button
        }
        return nil
    }
    
    private func actionType(_ actions:TimeSheetPermittedActions) -> RightBarButtonActionType{
        if(actions.canAutoSubmitOnDueDate) {
            return RightBarButtonActionTypeSubmit;
        } else if(actions.canReSubmitTimeSheet) {
            return RightBarButtonActionTypeReSubmit;
        } else if(actions.canReOpenSubmittedTimeSheet) {
            return RightBarButtonActionTypeReOpen;
        }
        return RightBarButtonActionTypeNone;
    }


    private func getButtonTitle(_ actions:TimeSheetPermittedActions) -> String{
        var title = ""
        let actionType = self.actionType(actions)
        switch(actionType) {
        case RightBarButtonActionTypeSubmit:
            title = "\(Submit_Button_title)".localize()
            break;
        case RightBarButtonActionTypeReSubmit:
            title = "\(Resubmit_Button_title)".localize()
            break;
        case RightBarButtonActionTypeReOpen:
            title = "\(Reopen_Button_title)".localize()
            break;
        default:
            break;
        }
        return title;
    }
    
    @IBAction func timeSheetRightBarButtonButtonAction(_ sender: Any) {
        
        if let button = sender as? UIBarButtonItem{
            let actionType:RightBarButtonActionType = RightBarButtonActionType(rawValue: UInt32(button.tag)) 
            self.delegate.userIntendsTo(actionType, presenter: self)
        }
        
    }
    
}
