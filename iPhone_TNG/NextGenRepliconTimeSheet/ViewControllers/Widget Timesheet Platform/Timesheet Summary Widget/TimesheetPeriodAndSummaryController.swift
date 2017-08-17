
import UIKit

// MARK: <TimesheetPeriodAndSummaryControllerDelegate>

@objc protocol TimesheetPeriodAndSummaryControllerDelegate {
    func timesheetPeriodAndSummaryControllerIntendsToUpdateItsContainerWithHeight(_ height:CGFloat)
}

// MARK: <TimesheetPeriodAndSummaryControllerNavigationDelegate>

@objc protocol TimesheetPeriodAndSummaryControllerNavigationDelegate {
    func timesheetPeriodAndSummaryControllerDidTapPreviousButton(_ controller:TimesheetPeriodAndSummaryController)
    func timesheetPeriodAndSummaryControllerDidTapNextButton(_ controller:TimesheetPeriodAndSummaryController)
}

// MARK: <TimesheetPeriodAndSummaryControllerInterface>

@objc protocol TimesheetPeriodAndSummaryControllerInterface {
    func setupWith( widgetTimesheet:WidgetTimesheet!,delegate:TimesheetPeriodAndSummaryControllerDelegate!,navigationDelegate:TimesheetPeriodAndSummaryControllerNavigationDelegate!)
}

/// This controller presents the timesheet summary details
/**
 **Responsibilty**
 - presents previous and next timesheet navigation buttons 
 - presents the timesheet status
 - presents the timesheet issues count
 */

class TimesheetPeriodAndSummaryController: UIViewController,TimesheetPeriodAndSummaryControllerInterface {

    var theme : Theme!
    var childControllerHelper:ChildControllerHelper!
    var timesheetDetailsPresenter:TimesheetDetailsPresenter!
    
    weak var injector : BSInjector!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateRangeLabel:UILabel!
    @IBOutlet weak var currentPeriodLabel:UILabel!
    @IBOutlet weak var previousTimesheetButton:UIButton!
    @IBOutlet weak var nextTimesheetButton:UIButton!
    fileprivate var widgetTimesheet: WidgetTimesheet!
    fileprivate weak var delegate:TimesheetPeriodAndSummaryControllerDelegate!
    fileprivate weak var navigationDelegate:TimesheetPeriodAndSummaryControllerNavigationDelegate?
    
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
                    delegate:TimesheetPeriodAndSummaryControllerDelegate!,
                    navigationDelegate:TimesheetPeriodAndSummaryControllerNavigationDelegate?){
        self.widgetTimesheet = widgetTimesheet
        self.delegate = delegate
        self.navigationDelegate = navigationDelegate
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
        self.currentPeriodLabel.font = self.theme.timesheetDetailCurrentPeriodFont()
        self.dateRangeLabel.font = self.theme.timesheetDetailDateRangeFont()
        self.currentPeriodLabel.textColor = self.theme.timesheetDetailCurrentPeriodTextColor()
        self.dateRangeLabel.textColor = self.theme.timesheetDetailDateRangeTextColor()
        self.dateRangeLabel.backgroundColor = UIColor.clear
        self.currentPeriodLabel.backgroundColor = UIColor.clear
        self.nextTimesheetButton.backgroundColor = UIColor.clear
        self.previousTimesheetButton.backgroundColor = UIColor.clear
        
        let currentTimesheet = self.timesheetDetailsPresenter.isCurrentTimesheet(for: self.widgetTimesheet.period)
        if currentTimesheet {
            self.currentPeriodLabel.text = "Current Period".localize()
        }
        else{
            self.currentPeriodLabel.removeFromSuperview()
        }
        
        if (self.navigationDelegate) != nil{
            self.previousTimesheetButton.isHidden = false
            self.nextTimesheetButton.isHidden = currentTimesheet
        }
        else{
            self.previousTimesheetButton.isHidden = true
            self.nextTimesheetButton.isHidden = true
        }
        
        guard let timesheetPeriodText = self.timesheetDetailsPresenter.dateRangeText(with:self.widgetTimesheet.period) else {
            return
        }
        
        guard let _ = self.widgetTimesheet.summary?.lastUpdatedDateString else {
            self.dateRangeLabel.text = timesheetPeriodText
            return
        }
        self.dateRangeLabel.text = "\(timesheetPeriodText) *"
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.widthConstraint.constant = self.view.bounds.size.width
        self.delegate.timesheetPeriodAndSummaryControllerIntendsToUpdateItsContainerWithHeight(self.scrollView.contentSize.height)
    }
    
    //MARK: - Private
    
    @IBAction func previousTimesheetButtonTapped(_ sender: Any) {
        self.navigationDelegate?.timesheetPeriodAndSummaryControllerDidTapPreviousButton(self)
    }
    
    @IBAction func nextTimesheetButtonTapped(_ sender: Any) {
        self.navigationDelegate?.timesheetPeriodAndSummaryControllerDidTapNextButton(self)
    }
    
}
