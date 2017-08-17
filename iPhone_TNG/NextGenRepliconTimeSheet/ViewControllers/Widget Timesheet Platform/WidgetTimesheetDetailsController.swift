

import UIKit

enum TimesheetWidgetContainerType : String{
    case PayWidgetContainer
    case PunchWidgetContainer
    case AttestationWidgetContainer
    case NoticeWidgetContainer
    case TimeoffInLieuWidgetContainer
    case TimeDistributionWidgetContainer
    case DailyFieldWidgetContainer
    case TimesheetPeriodWidgetContainer
    case TimesheetStatusWidgetContainer
    case TimesheetSummaryDurationWidgetContainer
    case UnknownWidget
}

private enum ContainerViewUserInteraction{
    case Enable 
    case Disable
}

private enum TimesheetSummaryFetchType{
    case UserAction
    case Polling
}

private enum WidgetsLoadType{
    case WithShimmering
    case WithoutShimmering
}


class TimesheetWidgetContainerMetaData: NSObject {
    
    var viewController: UIViewController!
    var containerType: TimesheetWidgetContainerType!
    var containerView: UIView!

    init(viewController: UIViewController!,
         containerType: TimesheetWidgetContainerType!,
         containerView: UIView!) {
        self.viewController = viewController
        self.containerType = containerType
        self.containerView = containerView
        super.init()
    }
}


// MARK: <WidgetTimesheetDetailsControllerInterface>

@objc protocol WidgetTimesheetDetailsControllerInterface{
    func setupWith(widgetTimesheet:WidgetTimesheet!,delegate:WidgetTimesheetDetailsControllerDelegate!,hasBreakAccess:Bool,isSupervisorContext:Bool,userUri:String!)
}

// MARK: <WidgetTimesheetDetailsControllerDelegate>

@objc protocol WidgetTimesheetDetailsControllerDelegate : class {
    func widgetTimesheetDetailsControllerRequestsPreviousTimesheet(_ controller: WidgetTimesheetDetailsController)
    func widgetTimesheetDetailsControllerRequestsNextTimesheet(_ controller: WidgetTimesheetDetailsController)
    func widgetTimesheetDetailsController(_ controller: WidgetTimesheetDetailsController, actionButton: UIBarButtonItem)
}

/// This controller which presents the widgets of the timesheet
/**
 **Responsibilty**
 - presents all the supported widgets in a specific order defined in web
 */

class WidgetTimesheetDetailsController: UIViewController,WidgetTimesheetDetailsControllerInterface {

    weak var injector : BSInjector!
    @IBOutlet var widgetHeightConstraints: [NSLayoutConstraint]!
    @IBOutlet var widgetContainerViews: [UIView]!
    @IBOutlet weak var timesheetDurationSummaryContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timesheetDurationsSummaryContainerView: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var timesheetPeriodAndSummaryContainerView: UIView!
    @IBOutlet weak var timesheetPeriodAndSummaryContainerHeightConstraint:NSLayoutConstraint!
    @IBOutlet weak var timesheetStatusAndSummaryContainerView: UIView!
    @IBOutlet weak var timesheetStatusAndSummaryContainerHeightConstraint:NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    var widgetTimesheet: WidgetTimesheet!
    var childControllerHelper:ChildControllerHelper!
    var theme:Theme!
    var widgetTimesheetSummaryRepository:WidgetTimesheetSummaryRepository!
    var viewHelper:ViewHelper!
    var userActionForTimesheetRepository:UserActionForTimesheetRepository!
    var punchWidgetRepository:PunchWidgetRepository!
    var widgetTimesheetDetailsSeriesControllerPresenter: WidgetTimesheetDetailsSeriesControllerPresenter!
    var widgetTimesheetRepository:WidgetTimesheetRepository!
    var userPermissionsStorage: UserPermissionsStorage!
    
    fileprivate var allChildControllers  = [TimesheetWidgetContainerMetaData]()
    fileprivate weak var delegate:WidgetTimesheetDetailsControllerDelegate!
    fileprivate var hasBreakAccess : Bool = false
    fileprivate var isSupervisorContext : Bool = false
    fileprivate var timesheetSummaryPromise : KSPromise<AnyObject>?
    fileprivate var userUri : String!
    fileprivate var refresher : UIRefreshControl!
    

    // MARK: - NSObject
    init(widgetTimesheetDetailsSeriesControllerPresenter: WidgetTimesheetDetailsSeriesControllerPresenter!,
         userActionForTimesheetRepository:UserActionForTimesheetRepository!,
         widgetTimesheetSummaryRepository:WidgetTimesheetSummaryRepository!,
         widgetTimesheetRepository:WidgetTimesheetRepository!,
         userPermissionsStorage: UserPermissionsStorage!,
         punchWidgetRepository:PunchWidgetRepository!,
         childControllerHelper:ChildControllerHelper!,
         viewHelper:ViewHelper!,
         theme:Theme!) {
        super.init(nibName: nil, bundle: nil)
        self.widgetTimesheetSummaryRepository = widgetTimesheetSummaryRepository
        self.childControllerHelper = childControllerHelper
        self.widgetTimesheetDetailsSeriesControllerPresenter = widgetTimesheetDetailsSeriesControllerPresenter
        self.userPermissionsStorage = userPermissionsStorage
        self.userActionForTimesheetRepository = userActionForTimesheetRepository
        self.widgetTimesheetRepository = widgetTimesheetRepository
        self.punchWidgetRepository = punchWidgetRepository
        self.viewHelper = viewHelper
        self.theme = theme
        let presenter = self.widgetTimesheetDetailsSeriesControllerPresenter as WidgetTimesheetDetailsSeriesControllerPresenterInterface
        presenter.setUpWithDelegate(self)
        let timesheetSummaryRepository = self.widgetTimesheetSummaryRepository as WidgetTimesheetSummaryRepositoryInterface
        timesheetSummaryRepository.addListener(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWith( widgetTimesheet:WidgetTimesheet!,delegate:WidgetTimesheetDetailsControllerDelegate!,hasBreakAccess:Bool,isSupervisorContext:Bool,userUri:String!){
        self.widgetTimesheet = widgetTimesheet
        self.delegate = delegate
        self.hasBreakAccess = hasBreakAccess
        self.isSupervisorContext = isSupervisorContext
        self.userUri = userUri
    }
    

    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    // MARK: UIViewController
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayRightNavigationButtonItemForWidgetTimesheet(self.widgetTimesheet)
        self.edgesForExtendedLayout = []
        self.timesheetDurationsSummaryContainerView.backgroundColor = UIColor.white
        self.timesheetPeriodAndSummaryContainerView.backgroundColor = UIColor.white
        self.timesheetStatusAndSummaryContainerView.backgroundColor = UIColor.white
        self.stackView.backgroundColor = UIColor.white
        self.view.backgroundColor = UIColor.white
        for containerView in self.widgetContainerViews {
            containerView.layer.masksToBounds = false
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 0.5
            containerView.layer.shadowOffset = CGSize(width: -1, height: 2)
            containerView.layer.shadowRadius = 6
            containerView.backgroundColor = UIColor.white
        }
        self.setupPullToRefreshControl()
        self.presentAllWidgets(.WithShimmering)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.widthConstraint.constant = self.view.bounds.size.width
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentTimesheetSummaryWidgets()
        self.presentAllWidgets(.WithoutShimmering)
    }
    
    // MARK:- Widget Presenters
    
    fileprivate func presentAllWidgets(_ widgetsLoadType:WidgetsLoadType!){
        if let allEnabledTimesheetWidgets = self.widgetTimesheet.widgetsMetaData, allEnabledTimesheetWidgets.count > 0 {            
            for widget in allEnabledTimesheetWidgets {
                let widgetType = TimesheetWidgetType(rawValue: widget.timesheetWidgetTypeUri)
                if widgetType == .PunchWidget{
                    
                    if widgetsLoadType == .WithShimmering {
                        if let containerView = self.containerViewForWidgetWithUri(TimesheetWidgetType.PunchWidget.rawValue){
                            let placeholderController = self.injector.getInstance(PlaceholderController.self) as! PlaceholderControllerInterface
                            placeholderController.setUpWithDelegate(self, widgetUri: TimesheetWidgetType.PunchWidget.rawValue)
                            self.addOrReplaceController(placeholderController as! UIViewController, containerType: .PunchWidgetContainer,containerView: containerView)
                            let punchWidgetRepository = self.punchWidgetRepository as PunchWidgetRepositoryInterface
                            let punchWidgetPromise = punchWidgetRepository.fetchPunchWidgetInfoForTimesheetWithUri(self.widgetTimesheet.uri)
                            self.presentPunchWidgetWithPromise(punchWidgetPromise)
                        }
                    }
                    else{
                        self.presentPunchWidgetTimesheetBreakdownControllerWithTimesheet(self.widgetTimesheet,widgetsLoadType:widgetsLoadType)
                    }
                }
                else if widgetType == .PayWidget{
                    self.presentPayWidgetControllerWithTimesheet(self.widgetTimesheet)
                }
                else if widgetType == .NoticeWidget{
                    self.presentNoticeWidgetControllerWithTimesheet(self.widgetTimesheet)
                }
                else if widgetType == .AttestationWidget{
                    self.presentAttestationWidgetControllerWithTimesheet(self.widgetTimesheet)
                }
            }
        }
        self.removeUnusedPlaceholderContainerViews()
    }
    
    fileprivate func presentTimesheetPeriodAndSummaryControllerWithTimesheet(_ timesheet:WidgetTimesheet!){
        let navigationDelegate:TimesheetPeriodAndSummaryControllerNavigationDelegate? = self.isSupervisorContext ? nil : self
        let timesheetPeriodAndSummaryController = self.injector.getInstance(TimesheetPeriodAndSummaryController.self) as! TimesheetPeriodAndSummaryControllerInterface
        timesheetPeriodAndSummaryController.setupWith(widgetTimesheet: timesheet, delegate: self,navigationDelegate: navigationDelegate)
        self.addOrReplaceController(timesheetPeriodAndSummaryController as! UIViewController, containerType: .TimesheetPeriodWidgetContainer,containerView:self.timesheetPeriodAndSummaryContainerView )
    }
    
    fileprivate func presentNoticeWidgetControllerWithTimesheet(_ timesheet:WidgetTimesheet!){
        let widgetUri = TimesheetWidgetType.NoticeWidget.rawValue
        if let  punchWidgetDataArray = timesheet.widgetsMetaData?.filter({ $0.timesheetWidgetTypeUri == widgetUri}),punchWidgetDataArray.count > 0{
            let widgetData = punchWidgetDataArray.first
            if let  noticeWidgetData = widgetData?.timesheetWidgetMetaData as? NoticeWidgetData{
                if let containerView = self.containerViewForWidgetWithUri(widgetUri){
                    let noticeWidgetController = self.injector.getInstance(NoticeWidgetController.self) as! NoticeWidgetControllerInterface
                    noticeWidgetController.setupWith(title: noticeWidgetData.titleText, description: noticeWidgetData.descriptionText, delegate: self)
                    self.addOrReplaceController(noticeWidgetController as! UIViewController, containerType: .NoticeWidgetContainer,containerView:containerView )
                }
            }
        }
    }
    
    fileprivate func presentAttestationWidgetControllerWithTimesheet(_ timesheet:WidgetTimesheet!){
        let widgetUri = TimesheetWidgetType.AttestationWidget.rawValue
        if let  punchWidgetDataArray = timesheet.widgetsMetaData?.filter({ $0.timesheetWidgetTypeUri == widgetUri}),punchWidgetDataArray.count > 0{
            let widgetData = punchWidgetDataArray.first
            if let  attestationWidgetData = widgetData?.timesheetWidgetMetaData as? AttestationWidgetData{
                if let containerView = self.containerViewForWidgetWithUri(widgetUri){
                    let attestationWidgetController = self.injector.getInstance(AttestationWidgetController.self) as! AttestationWidgetControllerInterface
                    attestationWidgetController.setupWith(title: attestationWidgetData.titleText, description: attestationWidgetData.descriptionText, status: timesheet.attestationStatus, delegate: self)
                    self.addOrReplaceController(attestationWidgetController as! UIViewController, containerType: .AttestationWidgetContainer,containerView:containerView )
                }
            }
        }
    }
    
    fileprivate func presentTimesheetStatusAndSummaryControllerWithTimesheet(_ timesheet:WidgetTimesheet!){
        let timesheetStatusAndSummaryController = self.injector.getInstance(TimesheetStatusAndSummaryController.self) as! TimesheetStatusAndSummaryControllerInterface
        timesheetStatusAndSummaryController.setupWith(widgetTimesheet: timesheet, delegate: self)
        self.addOrReplaceController(timesheetStatusAndSummaryController as! UIViewController, containerType: .TimesheetStatusWidgetContainer,containerView: self.timesheetStatusAndSummaryContainerView)
    }
    
    fileprivate func presentDurationSummaryWithoutOffsetControllerWithTimesheet(_ timesheet:WidgetTimesheet!){
        let durationSummaryWithoutOffsetController = self.injector.getInstance(DurationSummaryWithoutOffsetController.self) as! DurationSummaryWithoutOffsetControllerInterface
        durationSummaryWithoutOffsetController.setupWithTimesheetDuration(timesheet.summary?.workBreakAndTimeoffDuration, delegate: self, hasBreakAccess: self.hasBreakAccess)
        self.addOrReplaceController(durationSummaryWithoutOffsetController as! UIViewController, containerType: .TimesheetSummaryDurationWidgetContainer,containerView: self.timesheetDurationsSummaryContainerView)
    }
    
    fileprivate func presentPunchWidgetTimesheetBreakdownControllerWithTimesheet(_ timesheet:WidgetTimesheet!,widgetsLoadType:WidgetsLoadType!){
        
        if let  punchWidgetDataArray = timesheet.widgetsMetaData?.filter({ $0.timesheetWidgetTypeUri == TimesheetWidgetType.PunchWidget.rawValue}),punchWidgetDataArray.count > 0{
            
            if widgetsLoadType == .WithShimmering {
                if let containerView = self.containerViewForWidgetWithUri(TimesheetWidgetType.PunchWidget.rawValue){
                    let placeholderController = self.injector.getInstance(PlaceholderController.self) as! PlaceholderControllerInterface
                    placeholderController.setUpWithDelegate(self, widgetUri: TimesheetWidgetType.PunchWidget.rawValue)
                    self.addOrReplaceController(placeholderController as! UIViewController, containerType: .PunchWidgetContainer,containerView: containerView)
                    let punchWidgetRepository = self.punchWidgetRepository as PunchWidgetRepositoryInterface
                    let punchWidgetPromise = punchWidgetRepository.fetchPunchWidgetInfoForTimesheetWithUri(self.widgetTimesheet.uri)
                    self.presentPunchWidgetWithPromise(punchWidgetPromise)
                }
            }
            else{
                let widgetData = punchWidgetDataArray.first
                if let  punchWidgetData = widgetData?.timesheetWidgetMetaData as? PunchWidgetData{
                    let  daySummaries = punchWidgetData.daySummaries
                    let  breakComponents = punchWidgetData.widgetLevelDuration.breakHours
                    let  regularComponents = punchWidgetData.widgetLevelDuration.regularHours
                    let  timeOffComponents = punchWidgetData.widgetLevelDuration.timeOffHours
                    let timePeriodSummary =  TimePeriodSummary(regularTime: regularComponents, breakTime: breakComponents, timesheetPermittedActions: nil, overtimeComponents: nil, payDetailsPermission: false, dayTimeSummaries: daySummaries, totalPay: nil, totalHours: nil, actualsByPayCode: nil, actualsByPayDuration: nil, payAmountPermission: false, scriptCalculationDate: nil, timeOffComponents: timeOffComponents, isScheduledDay: false)
                    let timesheetInfo = TimesheetInfo(timeSheetApprovalStatus: timesheet.summary?.timesheetStatus, nonActionedValidationsCount: 0, timePeriodSummary: timePeriodSummary, issuesCount:  timesheet.summary?.issuesCount ?? 0, period: timesheet.period, uri: timesheet.uri)
                    let deferred = KSDeferred<AnyObject>()
                    deferred.resolve(withValue: timesheetInfo as AnyObject)
                    let timesheetInfoPromise = deferred.promise
                    self.presentPunchWidgetWithPromise(timesheetInfoPromise)
                }
            }
        }
    }
    
    fileprivate func presentPayWidgetControllerWithTimesheet(_ timesheet:WidgetTimesheet!){
        if let containerView = self.containerViewForWidgetWithUri(TimesheetWidgetType.PayWidget.rawValue){
            if let widgetsMetaData = self.widgetTimesheet.widgetsMetaData,widgetsMetaData.count > 0 {
                if let widgetDataArray = widgetsMetaData.filter({ $0.timesheetWidgetTypeUri == TimesheetWidgetType.PayWidget.rawValue}) as [WidgetData]?,widgetDataArray.count > 0{
                    let widgetData = widgetDataArray.first!
                    let payWidgetData = widgetData.timesheetWidgetMetaData as! PayWidgetData
                    var isActualsForPayPresent = false 
                    if let actualsByPaycode = payWidgetData.actualsByPaycode, actualsByPaycode.count > 0{
                        isActualsForPayPresent = true
                    }
                    var isActualsForDurationPresent = false 
                    if let actualsByDuration = payWidgetData.actualsByDuration, actualsByDuration.count > 0{
                        isActualsForDurationPresent = true
                    }
                    let isActualsPresent = (isActualsForPayPresent || isActualsForDurationPresent)
                    let isPayWidgetEnabledForUser = self.isSupervisorContext ? self.userPermissionsStorage.canViewPayDetails() : self.widgetTimesheet.canOwnerViewPayrollSummary;
                    let displayPayAmount = self.widgetTimesheet.displayPayAmount
                    if (isActualsPresent && isPayWidgetEnabledForUser){
                        containerView.isHidden = false
                        let payWidgetHomeController = self.injector.getInstance(PayWidgetHomeController.self)  as! PayWidgetHomeControllerInterface  
                        payWidgetHomeController.setupWithPayWidgetData(payWidgetData, displayPayAmount: displayPayAmount, displayPayTotals: self.widgetTimesheet.displayPayTotals, delegate: self)
                        self.addOrReplaceController(payWidgetHomeController as! UIViewController, containerType: .PayWidgetContainer,containerView:containerView)
                    }
                    else{
                        containerView.isHidden = true 
                    }
                }
            }
        }
    }
    
    private func presentTimesheetSummaryWidgets(){
        if self.widgetTimesheet.summary?.timesheetStatus.approvalStatusUri == WidgetTimesheetStatus.submitting.rawValue {
            self.changeInteractionsOnWidgetContainerWhileSubmittingWithStatus(.Disable)
        }
        else{
            self.changeInteractionsOnWidgetContainerWhileSubmittingWithStatus(.Enable)
        }
        self.presentTimesheetPeriodAndSummaryControllerWithTimesheet(self.widgetTimesheet)
        self.presentDurationSummaryWithoutOffsetControllerWithTimesheet(self.widgetTimesheet)
        self.presentTimesheetStatusAndSummaryControllerWithTimesheet(self.widgetTimesheet)
    }
    
    // MARK:- Private
    
    fileprivate func removeUnusedPlaceholderContainerViews(){
        if let allEnabledTimesheetWidgets = self.widgetTimesheet.widgetsMetaData, allEnabledTimesheetWidgets.count > 0 {
            if let filterContainerViews = self.widgetContainerViews.filter({$0.tag > allEnabledTimesheetWidgets.count-1}) as [UIView]?{
                for containerView in filterContainerViews {
                    self.stackView.removeArrangedSubview(containerView)
                }
            }
        }
        else{
            for containerView in self.widgetContainerViews {
                self.stackView.removeArrangedSubview(containerView)
            }
        }
    }
    
    fileprivate func setupPullToRefreshControl(){
        self.refresher = self.injector.getInstance(InjectorKeyUIRefreshControl) as! UIRefreshControl
        if #available(iOS 10.0, *) {
            self.scrollView.refreshControl = self.refresher
        } else {
            self.scrollView.addSubview(self.refresher)
        }
        self.refresher.addTarget(self, action: #selector(refreshTimesheetData), for: .valueChanged)
    }
    
    fileprivate func displayRightNavigationButtonItemForWidgetTimesheet(_ timesheet:WidgetTimesheet!){
        
        if let summary = timesheet.summary{
            let presenter = self.widgetTimesheetDetailsSeriesControllerPresenter as WidgetTimesheetDetailsSeriesControllerPresenterInterface
            let rightBarButtonItem = presenter.navigationBarRightButtonItemForTimesheetPermittedActions(summary.timeSheetPermittedActions)
            guard let actionButton = rightBarButtonItem, let delegate = self.delegate else{
                return
            }
           delegate.widgetTimesheetDetailsController(self, actionButton: actionButton)
        }
    }
    
    fileprivate func fetchTimesheetSummary(_ actionType:TimesheetSummaryFetchType) -> KSPromise<AnyObject>?{
        if actionType == .UserAction{
            self.timesheetSummaryPromise?.cancel()
        }
        let widgetTimesheetSummaryRepository = self.widgetTimesheetSummaryRepository as WidgetTimesheetSummaryRepositoryInterface
        self.timesheetSummaryPromise = widgetTimesheetSummaryRepository.fetchSummaryForTimesheet(self.widgetTimesheet)!
         return self.timesheetSummaryPromise?.then({ (response) -> AnyObject? in
            let summary = response as! Summary
            let lastSuccessfullScriptCalculationDate = self.widgetTimesheet.summary?.lastSuccessfulScriptCalculationDate
            self.widgetTimesheet.summary = summary
            if let widgetsMetaData = self.widgetTimesheet.widgetsMetaData,widgetsMetaData.count > 0 {
                if let index = widgetsMetaData.index(where: { $0.timesheetWidgetTypeUri == TimesheetWidgetType.PayWidget.rawValue}) {
                    let widgetData = WidgetData(timesheetWidgetMetaData: summary.payWidgetData, timesheetWidgetTypeUri: TimesheetWidgetType.PayWidget.rawValue)
                    self.widgetTimesheet.widgetsMetaData?[index] = widgetData
                }
            }
            if self.needsUpdateToUIBasedOnTheLastSuccessfullAttemptOnScriptCalculation(lastSuccessfullScriptCalculationDate,newDate:summary.lastSuccessfulScriptCalculationDate ){
                let viewHelper = self.viewHelper as ViewHelperInterface
                if (viewHelper.isViewControllerCurrentlyOnWindow(self)){
                    if summary.timesheetStatus.approvalStatusUri == WidgetTimesheetStatus.submitting.rawValue {
                        self.changeInteractionsOnWidgetContainerWhileSubmittingWithStatus(.Disable)
                    }
                    else{
                        self.changeInteractionsOnWidgetContainerWhileSubmittingWithStatus(.Enable)
                        self.presentTimesheetPeriodAndSummaryControllerWithTimesheet(self.widgetTimesheet)
                        self.presentTimesheetStatusAndSummaryControllerWithTimesheet(self.widgetTimesheet)
                    }
                }
                self.displayRightNavigationButtonItemForWidgetTimesheet(self.widgetTimesheet)
            }
            return summary
        }) { (error) -> AnyObject? in
            return error as NSError?
        }
    }
    
    fileprivate func needsUpdateToUIBasedOnTheLastSuccessfullAttemptOnScriptCalculation(_ oldDate:Date?, newDate:Date?) -> Bool{
        if let lastSuccessfulScriptCalculationDate = oldDate{
            if let currentSuccessfullDate = newDate{
                return lastSuccessfulScriptCalculationDate.compare(currentSuccessfullDate as Date) == .orderedAscending
            }
            return false
        }
        return true
    }
    
    fileprivate func containerViewForWidgetWithUri(_ widgetUri:String!) -> UIView?{
        var containerView : UIView? = nil
        if let widgetsMetaData = self.widgetTimesheet.widgetsMetaData,widgetsMetaData.count > 0 {
            if let index = widgetsMetaData.index(where: { $0.timesheetWidgetTypeUri == widgetUri}) {
                if let filterContainerViews = widgetContainerViews.filter({$0.tag == index}) as [UIView]?,filterContainerViews.count > 0{
                    containerView = filterContainerViews.first!
                }
            }
        }
        return containerView
    }
    
    fileprivate func containerHeightConstraintForWidgetWithUri(_ widgetUri:String!) -> NSLayoutConstraint?{
        var containerHeightConstraint : NSLayoutConstraint? = nil
        if let widgetsMetaData = self.widgetTimesheet.widgetsMetaData,widgetsMetaData.count > 0 {
            if let index = widgetsMetaData.index(where: { $0.timesheetWidgetTypeUri == widgetUri}) {
                if let filterContainerViews = self.widgetHeightConstraints.filter({$0.identifier == "\(index)"}) as [NSLayoutConstraint]?,filterContainerViews.count > 0{
                    containerHeightConstraint = filterContainerViews.first!
                }
            }
        }
        return containerHeightConstraint
    }
    
    fileprivate func childControllerForContainerWithType(_ containerType:TimesheetWidgetContainerType!) -> TimesheetWidgetContainerMetaData?{
        if self.allChildControllers.count == 0{
            return nil
        }
        let filteredArray = self.allChildControllers.filter({$0.containerType == containerType})
        if filteredArray.count > 0 {
            let controllerMetaData = filteredArray.first!
            return controllerMetaData
        }
        return nil
    }
    
    fileprivate func addOrReplaceController(_ controller:UIViewController,containerType:TimesheetWidgetContainerType!,containerView : UIView!){
        
        if let timesheetWidgetContainerMetaData = self.childControllerForContainerWithType(containerType){
            let viewController = timesheetWidgetContainerMetaData.viewController
            let containerView = timesheetWidgetContainerMetaData.containerView
            let index = self.allChildControllers.index(of: timesheetWidgetContainerMetaData)
             self.allChildControllers.remove(at: index!)
            let metaData = TimesheetWidgetContainerMetaData(viewController: controller, containerType: containerType, containerView: containerView)
            self.allChildControllers.append(metaData)                     
            self.childControllerHelper.replaceOldChildController(viewController, withNewChildController: controller, onParentController: self, onContainerView: containerView)
        }
        else{
            let metaData = TimesheetWidgetContainerMetaData(viewController: controller, containerType: containerType, containerView: containerView)
            self.allChildControllers.append(metaData)
            self.childControllerHelper.addChildController(controller, toParentController: self, inContainerView: containerView)
        }
    }
    
    fileprivate func showRightBarButtonItemWithSpinner(){
        let presenter = self.widgetTimesheetDetailsSeriesControllerPresenter as WidgetTimesheetDetailsSeriesControllerPresenterInterface
        let barButtonItemWithActivity = presenter.navigationBarRightButtonItemWithSpinner()
        if let actionButton = barButtonItemWithActivity{
            self.delegate.widgetTimesheetDetailsController(self, actionButton: actionButton)
        }
    }

    fileprivate func changeInteractionsOnWidgetContainerWhileSubmittingWithStatus(_ action : ContainerViewUserInteraction){
        var containers = [self.timesheetStatusAndSummaryContainerView,self.timesheetDurationsSummaryContainerView]
        containers = containers + self.widgetContainerViews
        for container in containers {
            self.changeInteractionsOnContainer(container!,action:action)
        }
    }
    
    fileprivate func changeInteractionsOnContainer(_ containerView:UIView ,action :ContainerViewUserInteraction){
        containerView.isUserInteractionEnabled = (action == .Enable)
        containerView.alpha = (action == .Enable) ? 1.0 : 0.7 
    }
    
    fileprivate func timesheetAction(_ actionType: RightBarButtonActionType, comments:String!){
        
        let oldTimesheetStatus = self.widgetTimesheet.summary?.timesheetStatus
        let needsContainerUpdateWithSubmittingWithStatus = (actionType ==  RightBarButtonActionTypeSubmit || actionType == RightBarButtonActionTypeReSubmit)
        self.showRightBarButtonItemWithSpinner()
        if needsContainerUpdateWithSubmittingWithStatus{
            self.changeInteractionsOnWidgetContainerWhileSubmittingWithStatus(.Disable)
            let temporarySubmittingstatus = TimeSheetApprovalStatus(approvalStatusUri: WidgetTimesheetStatus.submitting.rawValue, approvalStatus: "Submitting")
            self.widgetTimesheet.summary?.timesheetStatus = temporarySubmittingstatus
            self.presentTimesheetPeriodAndSummaryControllerWithTimesheet(self.widgetTimesheet)
            self.presentTimesheetStatusAndSummaryControllerWithTimesheet(self.widgetTimesheet)

        }
        let userActionForTimesheetRepository = self.userActionForTimesheetRepository as UserActionForTimesheetRepositoryInterface
        let promise = userActionForTimesheetRepository.userActionOnTimesheetWithType(actionType, timesheetUri: self.widgetTimesheet.uri, comments: comments)
        promise.then({ (response) -> AnyObject? in
            let timesheetSummaryPromise = self.fetchTimesheetSummary(.UserAction)
            timesheetSummaryPromise?.then({ (response) -> AnyObject? in
                return nil
            }) { (error) -> AnyObject? in
                
                self.widgetTimesheet.summary?.timesheetStatus = oldTimesheetStatus
                if needsContainerUpdateWithSubmittingWithStatus{
                    self.presentTimesheetPeriodAndSummaryControllerWithTimesheet(self.widgetTimesheet)
                    self.presentTimesheetStatusAndSummaryControllerWithTimesheet(self.widgetTimesheet)
                    self.changeInteractionsOnWidgetContainerWhileSubmittingWithStatus(.Enable)
                }
                self.displayRightNavigationButtonItemForWidgetTimesheet(self.widgetTimesheet)
                return nil
            }
            return nil
        }) { (error) -> AnyObject? in
            self.widgetTimesheet.summary?.timesheetStatus = oldTimesheetStatus
            if needsContainerUpdateWithSubmittingWithStatus{
                self.presentTimesheetPeriodAndSummaryControllerWithTimesheet(self.widgetTimesheet)
                self.presentTimesheetStatusAndSummaryControllerWithTimesheet(self.widgetTimesheet)
                self.changeInteractionsOnWidgetContainerWhileSubmittingWithStatus(.Enable)
            }
            self.displayRightNavigationButtonItemForWidgetTimesheet(self.widgetTimesheet)
            return nil
        }
    } 
    
    fileprivate func presentPunchWidgetWithPromise(_ punchWidgetPromise:KSPromise<AnyObject>){
        punchWidgetPromise.then({ (response) -> AnyObject? in
            let timesheetInfo : TimesheetInfo = response as! TimesheetInfo
            let regularHours = timesheetInfo.timePeriodSummary.regularTimeComponents
            let breakHours = timesheetInfo.timePeriodSummary.breakTimeComponents
            let timeoffHours = timesheetInfo.timePeriodSummary.timeOffComponents
            let timesheetDuration = TimesheetDuration(regularHours: regularHours, breakHours: breakHours, timeOffHours: timeoffHours)
            let dayTimeSummaries = timesheetInfo.timePeriodSummary.dayTimeSummaries as? [TimesheetDaySummary]
            
            if let widgetsMetaData = self.widgetTimesheet.widgetsMetaData,widgetsMetaData.count > 0 {
                if let index = widgetsMetaData.index(where: { $0.timesheetWidgetTypeUri == TimesheetWidgetType.PunchWidget.rawValue}) {
                    let punchWidgetData = PunchWidgetData(daySummaries: dayTimeSummaries, widgetLevelDuration: timesheetDuration)
                    let widgetData = WidgetData(timesheetWidgetMetaData: punchWidgetData, timesheetWidgetTypeUri: TimesheetWidgetType.PunchWidget.rawValue)
                    self.widgetTimesheet.widgetsMetaData?[index] = widgetData
                    let viewHelper = self.viewHelper as ViewHelperInterface
                    if (viewHelper.isViewControllerCurrentlyOnWindow(self)){
                        if let containerView = self.containerViewForWidgetWithUri(TimesheetWidgetType.PunchWidget.rawValue){
                            let punchWidgetTimesheetBreakdownController = self.injector.getInstance(PunchWidgetTimesheetBreakdownController.self) as! PunchWidgetTimesheetBreakdownControllerInterface
                            punchWidgetTimesheetBreakdownController.setupWithPunchWidgetData(punchWidgetData, delegate: self, hasBreakAccess: self.hasBreakAccess)
                            self.addOrReplaceController(punchWidgetTimesheetBreakdownController as! UIViewController, containerType: .PunchWidgetContainer,containerView: containerView)
                        }
                    }
                }
            }
            
            return timesheetInfo
        }) { (error) -> AnyObject? in
            return error! as NSError
        }

    }
    
    @objc private func refreshTimesheetData(){
        self.view.isUserInteractionEnabled = false
        let repository = self.widgetTimesheetRepository as WidgetTimesheetRepositoryInterface
        let widgetTimesheetPromise = repository.fetchWidgetTimesheetForTimesheetWithUri(self.widgetTimesheet.uri)
        widgetTimesheetPromise.then({ (widgetTimesheetValue) -> AnyObject? in
            let widgetTimesheet = widgetTimesheetValue as! WidgetTimesheet
            self.widgetTimesheet = widgetTimesheet
            self.presentTimesheetSummaryWidgets()
            self.presentAllWidgets(.WithShimmering)
            self.refresher.endRefreshing()
            self.displayRightNavigationButtonItemForWidgetTimesheet(self.widgetTimesheet)
            self.view.isUserInteractionEnabled = true
            return nil
        }) { (error) -> AnyObject? in
            self.refresher.endRefreshing()
            self.view.isUserInteractionEnabled = true
            return nil
        }
    }
}

// MARK: - <TimesheetPeriodAndSummaryControllerDelegate>

extension WidgetTimesheetDetailsController: TimesheetPeriodAndSummaryControllerDelegate{
    
    func timesheetPeriodAndSummaryControllerIntendsToUpdateItsContainerWithHeight(_ height:CGFloat){
        self.timesheetPeriodAndSummaryContainerHeightConstraint.constant = height
    }
}

// MARK: - <TimesheetPeriodAndSummaryControllerNavigationDelegate>

extension WidgetTimesheetDetailsController: TimesheetPeriodAndSummaryControllerNavigationDelegate{
    
    func timesheetPeriodAndSummaryControllerDidTapPreviousButton(_ controller:TimesheetPeriodAndSummaryController){
        self.delegate.widgetTimesheetDetailsControllerRequestsPreviousTimesheet(self)
    }
    func timesheetPeriodAndSummaryControllerDidTapNextButton(_ controller:TimesheetPeriodAndSummaryController){
        self.delegate.widgetTimesheetDetailsControllerRequestsNextTimesheet(self)
    }
}

// MARK: - <DurationSummaryWithoutOffsetControllerDelegate>

extension WidgetTimesheetDetailsController: DurationSummaryWithoutOffsetControllerDelegate{
    
    func durationSummaryWithoutOffsetControllerIntendsToUpdateItsContainerWithHeight(_ height:CGFloat){
        self.timesheetDurationSummaryContainerHeightConstraint.constant = height
    }
}

// MARK: - <ViolationsSummaryControllerDelegate>

extension WidgetTimesheetDetailsController: ViolationsSummaryControllerDelegate{
    
    func violationsSummaryControllerDidRequestViolationSectionsPromise(_ violationsSummaryController: ViolationsSummaryController!) -> KSPromise<AnyObject>! {
        let deferred = KSDeferred<AnyObject>()
        let timesheetPromise = self.fetchTimesheetSummary(.UserAction)
        timesheetPromise?.then({ (response) -> AnyObject? in
            let summary = response as! Summary
            deferred.resolve(withValue: summary.violationsAndWaivers)
            return nil
        }) { (error) -> AnyObject? in
            deferred.rejectWithError(error)
            return nil
        }
        return deferred.promise
    }
}

// MARK: - <WidgetTimesheetDetailsSeriesControllerPresenterDelegate>

extension WidgetTimesheetDetailsController: WidgetTimesheetDetailsSeriesControllerPresenterDelegate{
    
    func userIntendsTo(_ action:RightBarButtonActionType, presenter :WidgetTimesheetDetailsSeriesControllerPresenter){
        
        if action ==  RightBarButtonActionTypeSubmit{
            self.timesheetAction(action,comments: nil)
        }
        else if action == RightBarButtonActionTypeReOpen || action == RightBarButtonActionTypeReSubmit {
            let actionTitle = (action == RightBarButtonActionTypeReOpen) ? "Reopen" : "Resubmit"
            let commentViewController = self.injector.getInstance(CommentViewController.self) as! CommentViewController
            commentViewController.setupAction(actionTitle, delegate: self)
            self.navigationController?.pushViewController(commentViewController, animated: true)
        }
    }
}

// MARK: - <CommentViewControllerDelegate>

extension WidgetTimesheetDetailsController: CommentViewControllerDelegate{
    
    func commentsViewController(_ commentViewController: CommentViewController!, actionType: RightBarButtonActionType, comments: String!) {
        self.timesheetAction(actionType, comments: comments)
    }
}

// MARK: - <WidgetTimesheetSummaryRepositoryObserver>

extension WidgetTimesheetDetailsController: WidgetTimesheetSummaryRepositoryObserver{
    
    func widgetTimesheetSummaryRepository(_ repository:WidgetTimesheetSummaryRepository!, fetchedNewSummary:Summary) {
        if fetchedNewSummary.status == SummaryStatus.OutOfDate.rawValue {
            let _ = fetchTimesheetSummary(.Polling)
        }
        else if (fetchedNewSummary.status == SummaryStatus.Current.rawValue){
            if let  punchWidgetDataArray = self.widgetTimesheet.widgetsMetaData?.filter({ $0.timesheetWidgetTypeUri == TimesheetWidgetType.PunchWidget.rawValue}),punchWidgetDataArray.count > 0{
                let punchWidgetRepository = self.punchWidgetRepository as PunchWidgetRepositoryInterface
                let punchWidgetPromise = punchWidgetRepository.fetchPunchWidgetSummaryForTimesheetWithUri(self.widgetTimesheet.uri)
                self.presentPunchWidgetWithPromise(punchWidgetPromise)
            }
        }
    }
}

// MARK: - <TimesheetPeriodAndSummaryControllerDelegate>

extension WidgetTimesheetDetailsController: TimesheetStatusAndSummaryControllerDelegate{
    
    func timesheetStatusAndSummaryControllerIntendsToUpdateItsContainerWithHeight(_ height:CGFloat){
        self.timesheetStatusAndSummaryContainerHeightConstraint.constant = height
    }
    
    func timesheetStatusAndSummaryControllerDidTapissuesButton(_ controller:TimesheetStatusAndSummaryController){
        if let summary = self.widgetTimesheet.summary{
            let deferred = KSDeferred<AnyObject>()
            let violationsSummaryController = self.injector.getInstance(ViolationsSummaryController.self) as! ViolationsSummaryController
            deferred.resolve(withValue: summary.violationsAndWaivers)
            violationsSummaryController.setup(withViolationSectionsPromise: deferred.promise, delegate: self)
            self.navigationController?.pushViewController(violationsSummaryController, animated: true)
        }
    }
}

// MARK: - <PunchWidgetTimesheetBreakdownControllerDelegate>

extension WidgetTimesheetDetailsController: PunchWidgetTimesheetBreakdownControllerDelegate{
    func punchWidgetTimesheetBreakdownController(_ controller:PunchWidgetTimesheetBreakdownController!,intendsToUpdateItsContainerWithHeight height:CGFloat){
        if let constraint = self.containerHeightConstraintForWidgetWithUri(TimesheetWidgetType.PunchWidget.rawValue){
            constraint.constant = height
        }
    }
    
    func punchWidgetTimesheetBreakdownController(_ controller:PunchWidgetTimesheetBreakdownController!,didSelectDayWithTimesheetDaySummary timesheetDaySummary:TimesheetDaySummary!){
        
        let calendar = self.injector.getInstance(InjectorKeyCalendarWithLocalTimeZone) as! NSCalendar
        let date = calendar.date(from: timesheetDaySummary.dateComponents)
        let dayController = self.injector.getInstance(DayController.self) as! DayController
        dayController.setup(with: nil, timesheetDaySummary: timesheetDaySummary, hasBreakAccess: self.hasBreakAccess, delegate: self, userURI: self.userUri, date: date)
        self.navigationController?.pushViewController(dayController, animated: true)
    }
}

// MARK: - <NoticeWidgetControllerDelegate>

extension WidgetTimesheetDetailsController: NoticeWidgetControllerDelegate{
    func noticeWidgetController(_ noticeWidgetController: NoticeWidgetController, didIntendToUpdateItsContainerHeight height: CGFloat) {
        if let constraint = self.containerHeightConstraintForWidgetWithUri(TimesheetWidgetType.NoticeWidget.rawValue){
            constraint.constant = height
        }
    }
}

// MARK: - <AttestationWidgetControllerDelegate>

extension WidgetTimesheetDetailsController: AttestationWidgetControllerDelegate{
    func attestationWidgetController(_ attestationWidgetController: AttestationWidgetController, didIntendToUpdateItsContainerHeight height: CGFloat) {
        if let constraint = self.containerHeightConstraintForWidgetWithUri(TimesheetWidgetType.AttestationWidget.rawValue){
            constraint.constant = height
        }
    }
}

// MARK: - <PlaceholderControllerDelegate>

extension WidgetTimesheetDetailsController: PlaceholderControllerDelegate{
    func placeholderController(_ controller:PlaceholderController!,intendsToUpdateItsContainerWithHeight height:CGFloat, forWidgetWithUri uri:String!){
        if let constraint = self.containerHeightConstraintForWidgetWithUri(uri){
            constraint.constant = height
        }
    }
}

// MARK: - <PayWidgetHomeControllerDelegate>

extension WidgetTimesheetDetailsController: PayWidgetHomeControllerDelegate{
    func payWidgetHomeController(_ controller: PayWidgetHomeController!, intendsToUpdateItsContainerWithHeight height: CGFloat) {
        if let constraint = self.containerHeightConstraintForWidgetWithUri(TimesheetWidgetType.PayWidget.rawValue){
            constraint.constant = height
        }
    }
}

// MARK: - <DayControllerDelegate>

extension WidgetTimesheetDetailsController: DayControllerDelegate{
    
    func needsTimePunchesPromiseWhenUserEditOrAddOrDeletePunch(for dayController: DayController!) -> KSPromise<AnyObject>! {
        let deferred = KSDeferred<AnyObject>()
        let summaryPromise = self.fetchTimesheetSummary(.UserAction)
        summaryPromise?.then({ (response) -> AnyObject? in
            let summary = response as! Summary
            deferred.resolve(withValue: summary)
            return nil
        }) { (error) -> AnyObject? in
            deferred.rejectWithError(error)
            return nil
        }
        let punchWidgetRepository = self.punchWidgetRepository as PunchWidgetRepositoryInterface
        let punchWidgetPromise = punchWidgetRepository.fetchPunchWidgetInfoForTimesheetWithUri(self.widgetTimesheet.uri)
        self.presentPunchWidgetWithPromise(punchWidgetPromise)
        return punchWidgetPromise
    }
    
}

