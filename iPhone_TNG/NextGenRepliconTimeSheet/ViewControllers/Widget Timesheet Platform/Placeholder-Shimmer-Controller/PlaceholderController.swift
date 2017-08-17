

import UIKit

// MARK: <PlaceholderControllerDelegate>

@objc protocol PlaceholderControllerDelegate {
    func placeholderController(_ controller:PlaceholderController!,intendsToUpdateItsContainerWithHeight:CGFloat, forWidgetWithUri uri:String!)
}

// MARK: <PlaceholderControllerInterface>

@objc protocol PlaceholderControllerInterface {
    func setUpWithDelegate(_ delegate:PlaceholderControllerDelegate!, widgetUri:String!)
}

/// This controller shows placeholder shimmers for widget containers

// MARK:- <PlaceholderController>

class PlaceholderController: UIViewController,PlaceholderControllerInterface {

    @IBOutlet weak var fbShimmerView: FBShimmeringView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    fileprivate weak var delegate:PlaceholderControllerDelegate!
    fileprivate var widgetUri:String!

    func setUpWithDelegate(_ delegate:PlaceholderControllerDelegate!, widgetUri:String!){
        self.delegate = delegate
        self.widgetUri = widgetUri
    }
    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        var shimmeringImageView = UIImageView(image: UIImage(named: "punch-widget-default"))
        let timesheetWidgetType = TimesheetWidgetType(rawValue: self.widgetUri)
        if timesheetWidgetType == .PunchWidget {
            shimmeringImageView = UIImageView(image: UIImage(named: "punch-widget-shimmer"))
        }
        
        
        self.fbShimmerView.contentView = shimmeringImageView
        self.heightConstraint.constant = shimmeringImageView.frame.height
        self.fbShimmerView.isShimmering = true
        self.fbShimmerView.shimmeringPauseDuration = 0.4
        self.fbShimmerView.shimmeringAnimationOpacity = 0.5
        self.fbShimmerView.shimmeringOpacity = 1.0
        self.fbShimmerView.shimmeringSpeed = 230
        self.fbShimmerView.shimmeringHighlightLength = 1.0
        self.fbShimmerView.shimmeringDirection = FBShimmerDirection.right
    }


    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.widthConstraint.constant = self.view.bounds.size.width
        self.delegate.placeholderController(self, intendsToUpdateItsContainerWithHeight: self.scrollView.contentSize.height, forWidgetWithUri: self.widgetUri)
    }

}
