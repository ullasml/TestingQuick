

import UIKit

// MARK: <GrossPayOrHoursControllerDelegate>

@objc protocol GrossPayOrHoursControllerDelegate {
    
    func grossPayOrHoursController(_ controller:GrossPayOrHoursController!,intendsToUpdateItsContainerWithHeight height:CGFloat)
    
    func grossPayOrHoursController(_ controller:GrossPayOrHoursController!,intendsToRefreshWithViewMode viewMode:ViewMode)

}


// MARK: <GrossPayOrHoursControllerInterface>

@objc protocol GrossPayOrHoursControllerInterface {
    func setupWithPayWidgetData(_ payWidgetData:PayWidgetData!,screenType:GrossSummaryScreenType ,delegate:GrossPayOrHoursControllerDelegate!,viewMode:ViewMode,displayPayTotals:Bool)
}

/// This controller shows the pie chart,  gross pay or hours totals 

class GrossPayOrHoursController: UIViewController,GrossPayOrHoursControllerInterface {

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var showMoreOrLessButton:UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var payCodeContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var grossHeaderLabel: UILabel!
    @IBOutlet weak var grossValueLabel: UILabel!
    @IBOutlet weak var grossPayLegendsContainerView: UIView!
    @IBOutlet weak var donutWidgetView: UIView!
    
    weak var injector : BSInjector!
    var childControllerHelper:ChildControllerHelper!
    var theme:Theme!
    fileprivate weak var delegate:GrossPayOrHoursControllerDelegate!
    fileprivate var payWidgetData:PayWidgetData!
    fileprivate var screenType:GrossSummaryScreenType!
    fileprivate var viewMode:ViewMode!
    fileprivate var numberFormatter:NumberFormatter!
    fileprivate var displayPayTotals:Bool = false

    
    // MARK: - NSObject
    init(childControllerHelper:ChildControllerHelper!,
         theme:Theme!) {
        self.childControllerHelper = childControllerHelper
        self.theme = theme
        self.numberFormatter = NumberFormatter()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupWithPayWidgetData(_ payWidgetData:PayWidgetData!,screenType:GrossSummaryScreenType ,delegate:GrossPayOrHoursControllerDelegate!,viewMode:ViewMode,displayPayTotals:Bool){
        self.payWidgetData = payWidgetData
        self.delegate = delegate
        self.screenType = screenType
        self.viewMode = viewMode
        self.displayPayTotals = displayPayTotals
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
        self.view.backgroundColor = UIColor.white
        self.scrollView.isScrollEnabled = false
        self.donutWidgetView.backgroundColor = UIColor.clear
        self.displayGrossHoursOrPayHeaderAndItsValue()

        let displayText = (self.screenType == GrossSummaryScreenType.payScreen) ? self.payWidgetData.grossPay?.currencyDisplayText : nil
        let actuals = (self.screenType == GrossSummaryScreenType.payScreen) ? self.payWidgetData.actualsByPaycode! : self.payWidgetData.actualsByDuration!
        let donutChartViewController = self.injector.getInstance(DonutChartViewController.self) as! DonutChartViewController
        donutChartViewController.setup(withActualsPayCode: actuals, currencyDisplayText: displayText, donutChartViewBounds: self.donutWidgetView.bounds)
        self.childControllerHelper.addChildController(donutChartViewController, toParentController: self, inContainerView: self.donutWidgetView)
        
        if actuals.count <= 4 {
            self.showMoreOrLessButton.removeFromSuperview()
        }
        self.showMoreOrLessButton.tag = self.viewMode.rawValue
        let title = (self.viewMode == ViewMode.ShowActualsMore) ? "Show Less".localize() : "Show More".localize()
        self.showMoreOrLessButton.setTitle(title, for: .normal)
        self.showMoreOrLessButton.backgroundColor = UIColor.clear
        
        if actuals.count > 0 {
            let actualsForUser = self.actualsForViewMode(self.viewMode)
            let grossPayCodeCollectionController = self.injector.getInstance(GrossPayCodeCollectionController.self) as! GrossPayCodeCollectionControllerInterface
            grossPayCodeCollectionController.setupWithActualsByPayCode(actualsForUser, delegate: self)
            self.childControllerHelper.addChildController(grossPayCodeCollectionController as! UIViewController, toParentController: self, inContainerView: self.grossPayLegendsContainerView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.widthConstraint.constant = self.view.bounds.width
        self.delegate.grossPayOrHoursController(self, intendsToUpdateItsContainerWithHeight: self.scrollView.contentSize.height)
    }
    
    //MARK: - Private
    
    fileprivate func displayGrossHoursOrPayHeaderAndItsValue(){
        
        if (!self.displayPayTotals){
            self.grossHeaderLabel.isHidden = true
            self.grossValueLabel.isHidden = true
        }
        else{
            let headerText = (self.screenType == GrossSummaryScreenType.payScreen) ? "Gross Pay".localize(): "Total Time".localize()
            self.grossHeaderLabel.font = self.theme.grossPayHeaderFont()
            self.grossHeaderLabel.text = headerText
            self.grossHeaderLabel.textColor = self.theme.grossPayTextColor()
            
            var grossValueText = "" 
            if (self.screenType == GrossSummaryScreenType.payScreen) {
                self.numberFormatter.numberStyle = .currency
                self.numberFormatter.currencySymbol = self.payWidgetData.grossPay!.currencyDisplayText
                grossValueText = self.numberFormatter.string(from: (self.payWidgetData.grossPay!.amount)!)!
            }
            else{
                let hours =  "\(self.payWidgetData.grossHours!.hours!)"
                let minutes =  "\(self.payWidgetData.grossHours!.minutes!)"
                grossValueText = "\(hours)h:\(minutes)m"
            }
            self.grossValueLabel.textColor = self.theme.grossPayTextColor()
            self.grossValueLabel.font = self.theme.grossPayFont()
            self.grossValueLabel.text = grossValueText
            self.grossValueLabel.sizeToFit()
        }
       
    }
    
    fileprivate func actualsForViewMode(_ viewMode:ViewMode) -> [Paycode]{
        let actuals = (self.screenType == GrossSummaryScreenType.payScreen) ? self.payWidgetData.actualsByPaycode! : self.payWidgetData.actualsByDuration!
        if (viewMode == ViewMode.ShowActualsMore){
            return actuals
        }
        else{
            if (actuals.count >= 4) {
                return Array(actuals.prefix(4))
            }
            return actuals
        }
    }
    
    @IBAction func showMoreOrLessUserAction(_ sender: Any) {
        
        let button = sender as! UIButton
        if (button.tag == ViewMode.ShowActualsLess.rawValue){
            self.delegate.grossPayOrHoursController(self, intendsToRefreshWithViewMode: ViewMode.ShowActualsMore)
            self.showMoreOrLessButton.tag = ViewMode.ShowActualsLess.rawValue
            self.showMoreOrLessButton.setTitle("Show More".localize(), for: .normal)
        }
        else{
            self.delegate.grossPayOrHoursController(self, intendsToRefreshWithViewMode: ViewMode.ShowActualsLess)
            self.showMoreOrLessButton.tag = ViewMode.ShowActualsMore.rawValue
            self.showMoreOrLessButton.setTitle("Show Less".localize(), for: .normal)
        }
    }

}

extension GrossPayOrHoursController:GrossPayCodeCollectionControllerDelegate{
    func grossPayCodeCollectionController(_ controller: GrossPayCodeCollectionController!, intendsToUpdateItsContainerWithHeight height: CGFloat) {
        self.payCodeContainerHeight.constant = height
        self.delegate.grossPayOrHoursController(self, intendsToUpdateItsContainerWithHeight: self.scrollView.contentSize.height)
    }
}
