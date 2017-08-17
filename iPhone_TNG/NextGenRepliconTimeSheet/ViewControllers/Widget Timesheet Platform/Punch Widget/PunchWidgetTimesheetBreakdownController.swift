
import UIKit


// MARK: <PunchWidgetTimesheetBreakdownControllerDelegate>

@objc protocol PunchWidgetTimesheetBreakdownControllerDelegate {
    func punchWidgetTimesheetBreakdownController(_ controller:PunchWidgetTimesheetBreakdownController!,intendsToUpdateItsContainerWithHeight:CGFloat)
    
    func punchWidgetTimesheetBreakdownController(_ controller:PunchWidgetTimesheetBreakdownController!,didSelectDayWithTimesheetDaySummary:TimesheetDaySummary!)
}


// MARK: <PunchWidgetTimesheetBreakdownControllerInterface>

@objc protocol PunchWidgetTimesheetBreakdownControllerInterface {
    func setupWithPunchWidgetData(_ punchWidgetData:PunchWidgetData!,delegate:PunchWidgetTimesheetBreakdownControllerDelegate!,hasBreakAccess:Bool)
}

class PunchWidgetTimesheetBreakdownController: UIViewController,PunchWidgetTimesheetBreakdownControllerInterface {

    @IBOutlet weak var breakDownContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewMoreOrLessContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widgetDurationContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widgetDurationContainerView: UIView!
    @IBOutlet weak var viewMoreOrLessContainerView: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!

    weak var injector : BSInjector!
    var dayTimeSummaryCellPresenter:DayTimeSummaryCellPresenter!
    var childControllerHelper:ChildControllerHelper!
    var theme:Theme!
    fileprivate var punchWidgetData:PunchWidgetData!
    fileprivate weak var delegate:PunchWidgetTimesheetBreakdownControllerDelegate!
    fileprivate let CellIdentifier: String = "!!@@"
    fileprivate var viewItemsAction : ViewItemsAction?
    fileprivate var hasBreakAccess:Bool!

    // MARK: - NSObject
    
    init(dayTimeSummaryCellPresenter: DayTimeSummaryCellPresenter!,
         childControllerHelper:ChildControllerHelper,
         theme: Theme!) {
        super.init(nibName: nil, bundle: nil)
        self.dayTimeSummaryCellPresenter = dayTimeSummaryCellPresenter
        self.theme = theme
        self.childControllerHelper = childControllerHelper
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    override func didReceiveMemoryWarning() { 
        super.didReceiveMemoryWarning()
    }
    
    func setupWithPunchWidgetData(_ punchWidgetData:PunchWidgetData!,delegate:PunchWidgetTimesheetBreakdownControllerDelegate!,hasBreakAccess:Bool){
        self.punchWidgetData = punchWidgetData
        self.delegate = delegate
        self.hasBreakAccess = hasBreakAccess
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.backgroundColor = UIColor.white
        self.widgetDurationContainerView.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.white
        self.viewMoreOrLessContainerView.backgroundColor = UIColor.white

        self.titleLabel.text = "Time Punches".localize()
        self.titleLabel.font = self.theme.timesheetWidgetTitleFont()!
        self.titleLabel.textColor = self.theme.timesheetWidgetTitleTextColor()

        self.scrollView.isScrollEnabled = false
        let cellNib = UINib(nibName:String(describing: DayTimeSummaryCell.self) , bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: CellIdentifier)
        self.tableView.rowHeight = 70
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = (self.delegate != nil) ? .singleLine : .none;

        let timesheetDuration = self.punchWidgetData.widgetLevelDuration
        let durationSummaryWithoutOffsetController = self.injector.getInstance(DurationSummaryWithoutOffsetController.self) as! DurationSummaryWithoutOffsetControllerInterface
        durationSummaryWithoutOffsetController.setupWithTimesheetDuration(timesheetDuration, delegate: self, hasBreakAccess: self.hasBreakAccess)
        self.childControllerHelper.addChildController(durationSummaryWithoutOffsetController as! UIViewController, toParentController: self, inContainerView: self.widgetDurationContainerView)
        
        let daySummariesCount = self.punchWidgetData.daySummaries?.count ?? 0
        if daySummariesCount > 7 {
            let viewMoreOrLessButtonController = self.injector.getInstance(ViewMoreOrLessButtonController.self) as! ViewMoreOrLessButtonControllerInterface
            self.viewItemsAction = ViewItemsAction.Less
            viewMoreOrLessButtonController.setupWithViewItemsAction(ViewItemsAction.More, delegate: self)
            self.childControllerHelper.addChildController(viewMoreOrLessButtonController as! UIViewController, toParentController: self, inContainerView: self.viewMoreOrLessContainerView)
        }
        else{
            self.viewMoreOrLessContainerView.removeFromSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.widthConstraint.constant = self.view.bounds.width
        self.breakDownContainerHeightConstraint.constant = self.tableView.contentSize.height
        self.delegate.punchWidgetTimesheetBreakdownController(self, intendsToUpdateItsContainerWithHeight: self.scrollView.contentSize.height)
    }
}

// MARK: - <UITableViewDataSource>

extension PunchWidgetTimesheetBreakdownController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let viewItemsAction = self.viewItemsAction{
            if viewItemsAction == ViewItemsAction.More {
                return self.punchWidgetData.daySummaries?.count ?? 0
            }
            return 7  
        }
        return self.punchWidgetData.daySummaries?.count ?? 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dayTimeSummary = self.punchWidgetData.daySummaries![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! DayTimeSummaryCell
        cell.backgroundColor = self.theme.timesheetBreakdownBackgroundColor();
        cell.separator.backgroundColor = self.theme.timesheetBreakdownSeparatorColor();
        if (self.delegate != nil){
            cell.selectionStyle = .default;
            cell.accessoryType = .disclosureIndicator;
        }
        else{
            cell.selectionStyle = .none;
            cell.accessoryType = .none;
        }
        
        cell.dateLabel.attributedText = self.dayTimeSummaryCellPresenter.dateString(forDayTimeSummary: dayTimeSummary)
        cell.regularTimeLabel.attributedText = self.dayTimeSummaryCellPresenter.regularTimeString(forDayTimeSummary: dayTimeSummary);
        cell.breakTimeLabel.attributedText = self.dayTimeSummaryCellPresenter.breakTimeString(forDayTimeSummary: dayTimeSummary);
        
        if let timeoffComponents = dayTimeSummary.timeOffComponents {
            if (timeoffComponents.hour != 0 ||  timeoffComponents.minute != 0 || timeoffComponents.second != 0){
                cell.timeOffTimeLabel.attributedText = self.dayTimeSummaryCellPresenter.timeOffTimeString(forDayTimeSummary: dayTimeSummary);
            }
            else{
                cell.timeOffTimeLabel.isHidden = true
                cell.separator.isHidden = true
            }
        }
        let issueCount = dayTimeSummary.totalViolationMessageCount;
        if (issueCount > 0){
            let image = UIImage(named: "violation-active-day")
            cell.violationImage.image = image
            cell.issueCount.textColor = self.theme.timesheetBreakdownViolationCountColor()
            cell.issueCount.text = "\(issueCount)"
            cell.issueCount.highlightedTextColor = self.theme.timesheetBreakdownViolationCountColor()
            cell.issueCount.font = self.theme.timesheetBreakdownViolationCountFont()
            cell.violationImage.highlightedImage = image
        }
        else{
            cell.violationImage?.removeFromSuperview()
            cell.issueCount?.removeFromSuperview()
        }
        
        if (!dayTimeSummary.isScheduledDay){
            cell.dateLabel.alpha = 0.55
            cell.breakTimeLabel.alpha = 0.55
            cell.timeOffTimeLabel.alpha = 0.55
            cell.regularTimeLabel.alpha = 0.55
        }
        else{
            cell.dateLabel.alpha = 1.0
            cell.breakTimeLabel.alpha = 1.0
            cell.timeOffTimeLabel.alpha = 1.0
            cell.regularTimeLabel.alpha = 1.0
        }

        return cell
    }
}

// MARK: - <UITableViewDelegate>

extension PunchWidgetTimesheetBreakdownController : UITableViewDelegate{
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let dayTimeSummary = self.punchWidgetData.daySummaries![indexPath.row]
        self.delegate.punchWidgetTimesheetBreakdownController(self, didSelectDayWithTimesheetDaySummary: dayTimeSummary)
    }
}

// MARK: - <DurationSummaryWithoutOffsetControllerDelegate>

extension PunchWidgetTimesheetBreakdownController: DurationSummaryWithoutOffsetControllerDelegate{
    
    func durationSummaryWithoutOffsetControllerIntendsToUpdateItsContainerWithHeight(_ height:CGFloat){
        self.widgetDurationContainerHeightConstraint.constant = height
    }
}

// MARK: - <ViewMoreOrLessButtonControllerInterface>

extension PunchWidgetTimesheetBreakdownController: ViewMoreOrLessButtonControllerDelegate{
    
    func viewMoreOrLessButtonController(_ controller:ViewMoreOrLessButtonController!,intendsToUpdateItsContainerWithHeight height:CGFloat){
        self.viewMoreOrLessContainerHeightConstraint.constant = height
    }
    
    func viewMoreOrLessButtonControllerIntendsToViewMoreItems(_ controller:ViewMoreOrLessButtonController!){
        self.viewItemsAction = ViewItemsAction.More
        self.reloadTableViewAndUpdateTheContainerHeightConstraint()
    }
    
    func viewMoreOrLessButtonControllerIntendsToViewLessItems(_ controller:ViewMoreOrLessButtonController!){
        self.viewItemsAction = ViewItemsAction.Less
        self.reloadTableViewAndUpdateTheContainerHeightConstraint()
    } 
    
    private func reloadTableViewAndUpdateTheContainerHeightConstraint(){
        self.tableView.reloadData()
        self.breakDownContainerHeightConstraint.constant = self.tableView.contentSize.height
        self.scrollView.layoutIfNeeded()
        self.delegate.punchWidgetTimesheetBreakdownController(self, intendsToUpdateItsContainerWithHeight: self.scrollView.contentSize.height)
    }
}


