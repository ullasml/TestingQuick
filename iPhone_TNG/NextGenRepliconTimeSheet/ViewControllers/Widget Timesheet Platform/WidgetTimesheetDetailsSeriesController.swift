
import UIKit

/// This controller which presents the widget timesheet details
/**
 **Responsibilty**
 - fetch timesheet and present details when user intends to navigate to previous or next timesheet
 - presents the navigation bar right button with options for user to either submit,resubmit or reopen
 */

class WidgetTimesheetDetailsSeriesController: UIViewController {

    var childControllerHelper:ChildControllerHelper!
    var timesheetRepository:WidgetTimesheetRepository!
    var dateProvider:DateProvider!
    var userPermissionsStorage: UserPermissionsStorage!
    var widgetTimesheetSummaryRepository:WidgetTimesheetSummaryRepository!
    var userSession:UserSession!

    weak var injector : BSInjector!
    fileprivate var widgetTimesheet:WidgetTimesheet!
    fileprivate var timesheetFetchPromise: KSPromise<AnyObject>? = nil
    fileprivate var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - NSObject
    init(widgetTimesheetSummaryRepository:WidgetTimesheetSummaryRepository,
         childControllerHelper:ChildControllerHelper!,
         timesheetRepository:WidgetTimesheetRepository!,
         dateProvider:DateProvider!,
         userPermissionsStorage: UserPermissionsStorage,
         userSession:UserSession!) {
        self.childControllerHelper = childControllerHelper
        self.timesheetRepository = timesheetRepository
        self.dateProvider = dateProvider
        self.userPermissionsStorage = userPermissionsStorage
        self.widgetTimesheetSummaryRepository = widgetTimesheetSummaryRepository
        self.userSession = userSession
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController

    deinit{
        self.removeAllWidgetTimesheetSummaryObservers()
        print("Deallocated: \(String(describing:self))")   
    }
    
    override func didReceiveMemoryWarning() { 
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        let viewController = UIViewController()
        self.childControllerHelper.addChildController(viewController, toParentController: self, inContainerView: self.view)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "My Timesheet".localize()
        self.activityIndicatorView  = self.injector.getInstance(InjectorKeyActivityIndicator) as! UIActivityIndicatorView
        let todayDate = self.dateProvider.date()!
        self.fetchAndDisplayWidgetTimesheetDetailsControllerForDate(todayDate)
    }
    
    fileprivate func fetchAndDisplayWidgetTimesheetDetailsControllerForDate(_ todayDate:Date){
        
        let oldRightActionButton = self.navigationItem.rightBarButtonItem
        self.displayLoadingNavigationButtonItem()
        self.timesheetFetchPromise?.cancel()
        let repository = self.timesheetRepository as WidgetTimesheetRepositoryInterface
        let widgetTimesheetPromise = repository.fetchWidgetTimesheetForDate(todayDate)
        self.activityIndicatorView.startAnimating()
        self.timesheetFetchPromise = widgetTimesheetPromise
        widgetTimesheetPromise.then({ (widgetTimesheetValue) -> AnyObject? in
            self.removeAllWidgetTimesheetSummaryObservers()
            let widgetTimesheet = widgetTimesheetValue as! WidgetTimesheet
            self.widgetTimesheet = widgetTimesheet
            self.activityIndicatorView.stopAnimating()
            let widgetTimesheetDetailsController = self.injector.getInstance(WidgetTimesheetDetailsController.self) as! WidgetTimesheetDetailsControllerInterface
            widgetTimesheetDetailsController.setupWith(widgetTimesheet: widgetTimesheet,delegate: self, hasBreakAccess: self.userPermissionsStorage.breaksRequired(), isSupervisorContext: false,userUri:self.userSession.currentUserURI!()!)
            self.childControllerHelper.replaceOldChildController(self.childViewControllers[0], withNewChildController: widgetTimesheetDetailsController as! UIViewController, onParentController: self, onContainerView: self.view)
            return nil
        }) { (error) -> AnyObject? in
            self.activityIndicatorView.stopAnimating()
            self.navigationItem.rightBarButtonItem = oldRightActionButton
            return nil
        }

    }
    
    fileprivate func displayLoadingNavigationButtonItem(){
        let barButtonItemWithActivity = UIBarButtonItem(customView: activityIndicatorView)
        self.navigationItem.rightBarButtonItem = barButtonItemWithActivity
    }
    
    fileprivate func removeAllWidgetTimesheetSummaryObservers(){
        let widgetTimesheetSummaryRepository = self.widgetTimesheetSummaryRepository as  WidgetTimesheetSummaryRepositoryInterface
        widgetTimesheetSummaryRepository.removeAllListeners()
    }
    
}

// MARK: - <WidgetTimesheetDetailsControllerDelegate>

extension WidgetTimesheetDetailsSeriesController: WidgetTimesheetDetailsControllerDelegate{
    
    func widgetTimesheetDetailsControllerRequestsPreviousTimesheet(_ controller: WidgetTimesheetDetailsController){
        let todayDate = Calendar.current.date(byAdding:.day,value: -1,to: self.widgetTimesheet.period.startDate)!
        self.fetchAndDisplayWidgetTimesheetDetailsControllerForDate(todayDate)
    }
    func widgetTimesheetDetailsControllerRequestsNextTimesheet(_ controller: WidgetTimesheetDetailsController){
        let todayDate = Calendar.current.date(byAdding:.day,value: 1,to: self.widgetTimesheet.period.endDate)!
        self.fetchAndDisplayWidgetTimesheetDetailsControllerForDate(todayDate)
    }
    
    func widgetTimesheetDetailsController(_ controller: WidgetTimesheetDetailsController, actionButton: UIBarButtonItem){
         self.navigationItem.rightBarButtonItem = actionButton
    }
}

