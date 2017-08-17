

import UIKit


// MARK: <ViewMoreOrLessButtonControllerDelegate>

@objc protocol ViewMoreOrLessButtonControllerDelegate {
    func viewMoreOrLessButtonController(_ controller:ViewMoreOrLessButtonController!,intendsToUpdateItsContainerWithHeight:CGFloat)
    func viewMoreOrLessButtonControllerIntendsToViewMoreItems(_ controller:ViewMoreOrLessButtonController!)
    func viewMoreOrLessButtonControllerIntendsToViewLessItems(_ controller:ViewMoreOrLessButtonController!)

}

// MARK: <ViewMoreOrLessButtonControllerInterface>

@objc protocol ViewMoreOrLessButtonControllerInterface {
    func setupWithViewItemsAction(_ viewItemsAction:ViewItemsAction,delegate:ViewMoreOrLessButtonControllerDelegate!)
}

class ViewMoreOrLessButtonController: UIViewController,ViewMoreOrLessButtonControllerInterface {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewMoreOrLessButton: UIButton!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    fileprivate var viewItemsAction:ViewItemsAction!
    fileprivate var delegate:ViewMoreOrLessButtonControllerDelegate!
    
    func setupWithViewItemsAction(_ viewItemsAction:ViewItemsAction,delegate:ViewMoreOrLessButtonControllerDelegate!){
        self.viewItemsAction = viewItemsAction
        self.delegate = delegate
    }
    
    deinit{
        print("Deallocated: \(String(describing:self))")   
    }
    
    // MARK: UIViewController
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewMoreOrLessButton.tag = self.viewItemsAction.rawValue
        if self.viewItemsAction == ViewItemsAction.More {
            self.viewMoreOrLessButton.setTitle("Show More".localize(), for: .normal)
        }
        else{            
            self.viewMoreOrLessButton.setTitle("Show Less".localize(), for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.widthConstraint.constant = self.view.bounds.size.width
        self.delegate.viewMoreOrLessButtonController(self, intendsToUpdateItsContainerWithHeight: self.scrollView.contentSize.height)
    } 

    @IBAction func viewMoreOrLessAction(_ sender: Any) {
        let button = sender as! UIButton
        if button.tag == ViewItemsAction.More.rawValue {
            self.viewMoreOrLessButton.setTitle("Show Less".localize(), for: .normal)
            self.viewMoreOrLessButton.tag = ViewItemsAction.Less.rawValue
            self.delegate.viewMoreOrLessButtonControllerIntendsToViewMoreItems(self)
        }
        else{            
            self.viewMoreOrLessButton.setTitle("Show More".localize(), for: .normal)
            self.viewMoreOrLessButton.tag = ViewItemsAction.More.rawValue
            self.delegate.viewMoreOrLessButtonControllerIntendsToViewLessItems(self)
        }
    }

}
