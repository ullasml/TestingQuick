
import UIKit

// MARK: <AttestationWidgetControllerDelegate>

@objc protocol AttestationWidgetControllerDelegate{
    func attestationWidgetController(_ attestationWidgetController: AttestationWidgetController,didIntendToUpdateItsContainerHeight height: CGFloat)
}

// MARK: <AttestationWidgetControllerInterface>

@objc protocol AttestationWidgetControllerInterface {
    func setupWith(title:String!,description:String!,status:AttestationStatus,delegate:AttestationWidgetControllerDelegate!)
}

/// This controller shows notice widget information

class AttestationWidgetController: UIViewController,AttestationWidgetControllerInterface {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var attestationStatusLabel: UILabel!
    @IBOutlet weak var attestationSwitch: UISwitch!

    private var titleText:String!
    private var descriptionText:String!
    private weak var delegate:AttestationWidgetControllerDelegate!
    private var status:AttestationStatus!

    var theme:Theme!
    // MARK: - NSObject
    init(theme:Theme!) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWith(title:String!,description:String!,status:AttestationStatus,delegate:AttestationWidgetControllerDelegate!){
        self.titleText = title
        self.descriptionText = description
        self.delegate = delegate
        self.status = status
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
        self.titleLabel.text = self.titleText ?? "Attestation".localize()
        self.titleLabel.font = self.theme.timesheetWidgetTitleFont()!
        self.titleLabel.textColor = self.theme.timesheetWidgetTitleTextColor()
        self.descriptionLabel.text = self.descriptionText
        self.descriptionLabel.textColor = self.theme.timesheetWidgetTitleTextColor()
        self.descriptionLabel.font = self.theme.timesheetNoticeWidgetDescriptionFont()!
        
        self.attestationStatusLabel.text = (self.status == .Attested) ? "I Accept".localize() : "I don't Accept".localize()
        self.attestationStatusLabel.textColor = (self.status == .Attested) ? self.theme.attestationSwitchColor() : self.theme.timesheetWidgetTitleTextColor()
        self.attestationStatusLabel.backgroundColor = UIColor.clear
        
        self.attestationSwitch.isUserInteractionEnabled = false
        let value = (self.status == .Attested) ? true : false
        self.attestationSwitch.setOn(value, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.widthConstraint.constant = self.view.bounds.size.width
        self.delegate.attestationWidgetController(self, didIntendToUpdateItsContainerHeight: self.scrollView.contentSize.height)
    }
}
