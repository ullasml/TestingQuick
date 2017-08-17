
import UIKit

// MARK: <NoticeWidgetControllerDelegate>

@objc protocol NoticeWidgetControllerDelegate{
    func noticeWidgetController(_ noticeWidgetController: NoticeWidgetController,didIntendToUpdateItsContainerHeight height: CGFloat)
}

// MARK: <NoticeWidgetControllerInterface>

@objc protocol NoticeWidgetControllerInterface {
    func setupWith(title:String!,description:String!,delegate:NoticeWidgetControllerDelegate!)
}

/// This controller shows notice widget information

class NoticeWidgetController: UIViewController,NoticeWidgetControllerInterface {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    private var titleText:String!
    private var descriptionText:String!
    private weak var delegate:NoticeWidgetControllerDelegate!

    var theme:Theme!
    // MARK: - NSObject
    init(theme:Theme!) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWith(title:String!,description:String!,delegate:NoticeWidgetControllerDelegate!){
        self.titleText = title
        self.descriptionText = description
        self.delegate = delegate
    }
    
    // MARK: - UIViewController
    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.backgroundColor = UIColor.clear
        self.descriptionLabel.backgroundColor = UIColor.clear
        self.titleLabel.text = self.titleText ?? "Notice".localize()
        self.titleLabel.font = self.theme.timesheetWidgetTitleFont()!
        self.titleLabel.textColor = self.theme.timesheetWidgetTitleTextColor()
        self.descriptionLabel.text = self.descriptionText
        self.descriptionLabel.textColor = self.theme.timesheetWidgetTitleTextColor()
        self.descriptionLabel.font = self.theme.timesheetNoticeWidgetDescriptionFont()!

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.widthConstraint.constant = self.view.bounds.size.width
        self.delegate.noticeWidgetController(self, didIntendToUpdateItsContainerHeight: self.scrollView.contentSize.height)
    }
}
