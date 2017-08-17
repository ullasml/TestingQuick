
import UIKit

// MARK: <PayWidgetHomeControllerDelegate>

@objc protocol PayWidgetHomeControllerDelegate {
    func payWidgetHomeController(_ controller:PayWidgetHomeController!,intendsToUpdateItsContainerWithHeight:CGFloat)
}


// MARK: <PayWidgetHomeControllerInterface>

@objc protocol PayWidgetHomeControllerInterface {
    func setupWithPayWidgetData(_ payWidgetData:PayWidgetData!,displayPayAmount:Bool,displayPayTotals:Bool,delegate:PayWidgetHomeControllerDelegate!)
}

/// This controller presents the pay widget related controllers

class PayWidgetHomeController: UIViewController,PayWidgetHomeControllerInterface {

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var payCodesContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControllerContainerView: UIView!

    
    weak var injector : BSInjector!
    var payWidgetPagingControllerPresenter:PayWidgetPagingControllerPresenter
    var childControllerHelper:ChildControllerHelper!
    var theme:Theme!
    fileprivate weak var delegate:PayWidgetHomeControllerDelegate!
    fileprivate var payWidgetData:PayWidgetData!
    fileprivate var currentlySelectedIndex = 0
    fileprivate var viewControllers : [GrossPayOrHoursController]!
    fileprivate var displayPayAmount:Bool = false
    fileprivate var displayPayTotals:Bool = false

    // MARK: - NSObject
    init(payWidgetPagingControllerPresenter:PayWidgetPagingControllerPresenter,
         childControllerHelper:ChildControllerHelper!,
         theme:Theme!) {
        self.payWidgetPagingControllerPresenter = payWidgetPagingControllerPresenter
        self.childControllerHelper = childControllerHelper
        self.theme = theme
        self.viewControllers = [GrossPayOrHoursController]()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWithPayWidgetData(_ payWidgetData:PayWidgetData!,displayPayAmount:Bool,displayPayTotals:Bool,delegate:PayWidgetHomeControllerDelegate!){
        self.payWidgetData = payWidgetData
        self.delegate = delegate
        self.displayPayAmount = displayPayAmount
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
        self.scrollView.isScrollEnabled = false
        self.view.backgroundColor = UIColor.white
        self.titleLabel.font = self.theme.timesheetWidgetTitleFont()!
        self.titleLabel.textColor = self.theme.timesheetWidgetTitleTextColor()!
        self.titleLabel.text = "Payroll Summary".localize()
        self.titleLabel.backgroundColor = UIColor.white
        self.loadGrossPayControllersWithWithViewMode(.ShowActualsLess)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.widthConstraint.constant = self.view.bounds.width
        self.delegate.payWidgetHomeController(self, intendsToUpdateItsContainerWithHeight: self.scrollView.contentSize.height)
    }
    
    //MARK: - Private
    
    fileprivate func loadGrossPayControllersWithWithViewMode(_ viewMode: ViewMode!) {
        
        let payWidgetPagingControllerPresenterInterface = self.payWidgetPagingControllerPresenter as PayWidgetPagingControllerPresenterInterface
        let controllers = payWidgetPagingControllerPresenterInterface.pagingViewControllersWithPayWidgetData(self.payWidgetData, delegate: self, viewMode: viewMode, displayPay: self.displayPayAmount, displayPayTotals: self.displayPayTotals)
        self.viewControllers = controllers
        let dataSource = (self.viewControllers.count > 1) ? self : nil
        let payWidgetPagingController = self.injector.getInstance(PayWidgetPagingController.self) as! PayWidgetPagingControllerInterface
        payWidgetPagingController.setUpWithGrossViewControllers(self.viewControllers, currentlySelectedIndex: self.currentlySelectedIndex,delegate: nil, datasource: dataSource)
        if self.childViewControllers.count > 0 {
            self.childControllerHelper.replaceOldChildController(self.childViewControllers.first, withNewChildController: payWidgetPagingController as! UIViewController, onParentController: self, onContainerView: self.pageControllerContainerView)
        }
        else{
            self.childControllerHelper.addChildController(payWidgetPagingController as! UIViewController, toParentController: self, inContainerView: self.pageControllerContainerView)
        }

    }
}


// MARK: - GrossPayOrHoursControllerDelegate

extension PayWidgetHomeController: GrossPayOrHoursControllerDelegate {
    func grossPayOrHoursController(_ controller: GrossPayOrHoursController!, intendsToUpdateItsContainerWithHeight height: CGFloat) {
        self.payCodesContainerHeightConstraint.constant = height
        self.delegate.payWidgetHomeController(self, intendsToUpdateItsContainerWithHeight: self.scrollView.contentSize.height)
    }
    func grossPayOrHoursController(_ controller:GrossPayOrHoursController!,intendsToRefreshWithViewMode viewMode:ViewMode){
        self.loadGrossPayControllersWithWithViewMode(viewMode)
    }
}
// MARK: - UIPageViewControllerDataSource

extension PayWidgetHomeController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        
        guard var currentIndex = self.viewControllers.index(of: viewController as! GrossPayOrHoursController) else {
            return nil
        }
        if ((currentIndex == 0) || (currentIndex == NSNotFound)) {
            return nil
        }
        currentIndex -= 1
        self.currentlySelectedIndex = currentIndex
        return self.viewControllers[currentIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        
        guard var currentIndex = self.viewControllers.index(of: viewController as! GrossPayOrHoursController) else {
            return nil
        }
        if (currentIndex == NSNotFound) {
            return nil
        }
        currentIndex += 1
        
        if (currentIndex == self.viewControllers.count) {
            return nil
        }
        self.currentlySelectedIndex = currentIndex
        return self.viewControllers[currentIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int{
        return (self.viewControllers.count > 1) ? self.viewControllers.count : 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int{
        return self.currentlySelectedIndex
    }
}
