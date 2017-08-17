
import UIKit

// MARK: <TimesheetStatusAndSummaryControllerDelegate>

@objc protocol TimesheetStatusAndSummaryControllerDelegate {
    func timesheetStatusAndSummaryControllerIntendsToUpdateItsContainerWithHeight(_ height:CGFloat)
    func timesheetStatusAndSummaryControllerDidTapissuesButton(_ controller:TimesheetStatusAndSummaryController)
}

// MARK: <TimesheetStatusAndSummaryControllerInterface>

@objc protocol TimesheetStatusAndSummaryControllerInterface {
    func setupWith( widgetTimesheet:WidgetTimesheet!,delegate:TimesheetStatusAndSummaryControllerDelegate!)
}

/// This controller presents the timesheet summary details
/**
 **Responsibilty**
 - presents previous and next timesheet navigation buttons 
 - presents the timesheet status
 - presents the timesheet issues count
 */

class TimesheetStatusAndSummaryController: UIViewController,TimesheetStatusAndSummaryControllerInterface {

    var theme : Theme!
    var childControllerHelper:ChildControllerHelper!
    var timesheetDetailsPresenter:TimesheetDetailsPresenter!
    
    weak var injector : BSInjector!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var updatedDateLabel: UILabel!
    @IBOutlet weak var violationsAndStatusButtonContainerView:UIView!
    fileprivate var widgetTimesheet: WidgetTimesheet!
    fileprivate weak var delegate:TimesheetStatusAndSummaryControllerDelegate!
    
    // MARK: - NSObject
    init(timesheetDetailsPresenter:TimesheetDetailsPresenter!,
         childControllerHelper:ChildControllerHelper!,
         theme:Theme!) {
        self.theme = theme
        self.childControllerHelper = childControllerHelper
        self.timesheetDetailsPresenter = timesheetDetailsPresenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWith( widgetTimesheet:WidgetTimesheet!,
                    delegate:TimesheetStatusAndSummaryControllerDelegate!){
        self.widgetTimesheet = widgetTimesheet
        self.delegate = delegate
    }
    
    // MARK: UIViewController
    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.violationsAndStatusButtonContainerView.backgroundColor = self.theme.cardContainerBackgroundColor()
        self.updatedDateLabel.backgroundColor = UIColor.clear
        self.updatedDateLabel.font = self.theme.lastUpdateTimeFont();
        let timesheetStatusAndIssuesController = self.injector.getInstance(TimesheetStatusAndIssuesController.self) as! TimesheetStatusAndIssuesControllerInterface
        timesheetStatusAndIssuesController.setupWith(widgetTimesheet: self.widgetTimesheet, delegate: self)
        self.childControllerHelper.addChildController(timesheetStatusAndIssuesController as! UIViewController, toParentController: self, inContainerView: self.violationsAndStatusButtonContainerView)
        
        guard let _ = self.timesheetDetailsPresenter.dateRangeText(with:self.widgetTimesheet.period) else {
            return
        }
        
        guard let lastUpdatedDateString = self.widgetTimesheet.summary?.lastUpdatedDateString else {
            self.updatedDateLabel.removeFromSuperview()
            return
        }
        
        self.updatedDateLabel.text = "* Data as of".localize() + " " + lastUpdatedDateString
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.widthConstraint.constant = self.view.bounds.size.width
        self.delegate.timesheetStatusAndSummaryControllerIntendsToUpdateItsContainerWithHeight(self.scrollView.contentSize.height)
    }
    
}
//MARK: - <TimesheetStatusAndIssuesControllerDelegate>

extension TimesheetStatusAndSummaryController: TimesheetStatusAndIssuesControllerDelegate {
    func timesheetStatusAndIssuesControllerIntendToViewViolationsWidget(_ controller:TimesheetStatusAndIssuesController){
        self.delegate.timesheetStatusAndSummaryControllerDidTapissuesButton(self)
    }
}
