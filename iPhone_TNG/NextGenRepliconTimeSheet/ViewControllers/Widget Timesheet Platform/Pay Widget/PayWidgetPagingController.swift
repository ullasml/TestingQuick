

import UIKit

// MARK: <PayWidgetPagingControllerInterface>

 @objc protocol PayWidgetPagingControllerInterface {
    func setUpWithGrossViewControllers(_ viewControllers: [GrossPayOrHoursController]!,currentlySelectedIndex:Int,delegate:UIPageViewControllerDelegate?,datasource:UIPageViewControllerDataSource?)
}

/// This controller set up the pay widget related controllers embibed in a pageviewcontroller

class PayWidgetPagingController: UIPageViewController,PayWidgetPagingControllerInterface {
    

    func setUpWithGrossViewControllers(_ viewControllers: [GrossPayOrHoursController]!,currentlySelectedIndex:Int, delegate: UIPageViewControllerDelegate?, datasource: UIPageViewControllerDataSource?) {
        self.delegate = delegate
        self.dataSource = datasource
        let viewController = viewControllers[currentlySelectedIndex] as UIViewController
        self.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
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
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.black
        appearance.backgroundColor = UIColor.white
    }
}
