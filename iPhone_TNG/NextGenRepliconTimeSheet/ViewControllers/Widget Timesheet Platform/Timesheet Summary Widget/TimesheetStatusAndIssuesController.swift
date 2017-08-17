

import UIKit

enum WidgetTimesheetStatus : String{
    case waiting = "urn:replicon:timesheet-status:waiting"
    case approved = "urn:replicon:timesheet-status:approved"
    case rejected = "urn:replicon:timesheet-status:rejected"
    case notsubmitted = "urn:replicon:timesheet-status:open"
    case submitting = "urn:replicon:timesheet-status:submitting"
    case Unknown

}

// MARK: <TimesheetStatusAndIssuesControllerDelegate>

@objc protocol TimesheetStatusAndIssuesControllerDelegate {
    func timesheetStatusAndIssuesControllerIntendToViewViolationsWidget(_ controller:TimesheetStatusAndIssuesController!)
}

@objc protocol TimesheetStatusAndIssuesControllerInterface {
    func setupWith( widgetTimesheet:WidgetTimesheet!,delegate:TimesheetStatusAndIssuesControllerDelegate!)
}

/// This controller presents shows status and issues on timesheet
/**
 **Responsibilty**
 - shows the timesheet status
 - shows the timesheet issues count
 */

class TimesheetStatusAndIssuesController: UIViewController,TimesheetStatusAndIssuesControllerInterface {

    fileprivate var widgetTimesheet:WidgetTimesheet!
    fileprivate weak var delegate:TimesheetStatusAndIssuesControllerDelegate!
    var theme : Theme!

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var approvalStatusImageView:UIImageView!
    @IBOutlet weak var approvalStatusLabel:UILabel!
    @IBOutlet weak var issuesStatusImageView:UIImageView!
    @IBOutlet weak var issuesStatusLabel:UILabel!
    @IBOutlet weak var issuesButton:UIButton!
    @IBOutlet weak var approvalStatusButton:UIButton!
    @IBOutlet weak var issuesStatusView:UIView!
    @IBOutlet weak var issuesCountLabel:UILabel!
    
    // MARK: - NSObject
    init(theme:Theme!) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWith( widgetTimesheet:WidgetTimesheet!,delegate:TimesheetStatusAndIssuesControllerDelegate!){
        self.widgetTimesheet = widgetTimesheet
        self.delegate = delegate
    }
    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.issuesStatusImageView.backgroundColor = UIColor.clear
        self.issuesStatusLabel.backgroundColor = UIColor.clear
        self.issuesCountLabel.backgroundColor = UIColor.clear
        self.styleButton(self.issuesButton, borderColor: self.theme.issuesButtonDefaultTitleOrBorderColor())

        if let summary = self.widgetTimesheet.summary, summary.issuesCount > 0 {
            let issuesImage = UIImage(named: "violation-active")
            self.issuesStatusImageView.image = issuesImage
            self.issuesStatusLabel.font = self.theme.timesheetStatusLabelFont()
            self.issuesStatusLabel.textColor = self.theme.issuesButtonDefaultTitleOrBorderColor()
            let violationsTitle = summary.issuesCount > 1 ? "Validations".localize() :"Validation".localize()
            self.issuesStatusLabel.text = violationsTitle
            self.issuesCountLabel.text = "\(summary.issuesCount)";
            self.issuesCountLabel.textColor = self.theme.issuesCountColor();
            self.issuesCountLabel.font = self.theme.timesheetIssuesCountLabelFont();
        }
        else{
            self.issuesButton.removeFromSuperview()
            self.issuesStatusView.removeFromSuperview()
        }
        if let summary = self.widgetTimesheet.summary{
            let approvalStatusUri = summary.timesheetStatus.approvalStatusUri
            self.statusTitleAndColorForTimesheetStatus(approvalStatusUri) 
        }
        
        self.approvalStatusLabel.font = self.theme.timesheetStatusLabelFont()
        self.approvalStatusLabel.backgroundColor = UIColor.clear
        self.approvalStatusImageView.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Private
    
    @IBAction func viewIssuesButtonTapped(_ sender: Any) {
        self.delegate.timesheetStatusAndIssuesControllerIntendToViewViolationsWidget(self)
    }
    
    private func styleButton(_ button:UIButton!,borderColor:UIColor){
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = self.theme.timesheetViolationsLabelFont()
        button.setTitleColor(UIColor.clear, for: .normal)
        button.layer.cornerRadius = 14
        button.layer.borderColor = borderColor.cgColor
        button.layer.borderWidth = 2
        button.clipsToBounds = true
    }
    
    private func statusTitleAndColorForTimesheetStatus(_ status:String!){
        let statusImage: UIImage!
        let titleColor : UIColor
        let statusTitle : String
        
        let timesheetStatus = WidgetTimesheetStatus(rawValue: status)

        if (timesheetStatus == .notsubmitted)  {
            statusTitle =  "Not Submitted".localize();
            titleColor =  self.theme.notSubmittedColor()
            statusImage =  UIImage(named: "not-submitted")
        }
        else if (timesheetStatus == .approved) {
            statusTitle =  "Approved".localize()
            titleColor =  self.theme.approvedColor()
            statusImage =  UIImage(named: "approved")
        }
        else if (timesheetStatus == .rejected){
            statusTitle =  "Rejected".localize()
            titleColor =  self.theme.rejectedColor()
            statusImage =  UIImage(named: "rejected")
        }
        else if (timesheetStatus == .waiting){
            statusTitle =  "Waiting for Approval".localize()
            titleColor =  self.theme.waitingForApprovalButtonBorderColor()
            statusImage =  UIImage(named: "waiting-for-approval")
        }
        else if (timesheetStatus == .submitting){
            statusTitle =  "Submitting".localize();
            titleColor =  self.theme.notSubmittedColor()
            statusImage =  UIImage(named: "submitting")
        }
        else{
            statusTitle =  "Not Submitted".localize();
            titleColor =  self.theme.notSubmittedColor()
            statusImage =  UIImage(named: "not-submitted")
        }
        self.styleButton(self.approvalStatusButton, borderColor: titleColor)
        self.approvalStatusImageView.image = statusImage;
        self.approvalStatusLabel.text = statusTitle;
        self.approvalStatusLabel.textColor = titleColor;
    }

}
