
import UIKit

@objc class RootController: UIViewController,URLSessionClientObserver {

    var urlSessionClient : URLSessionClientProtocol!
    var presenter : PresenterProtocol!

    weak var injector: BSInjector!

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var testResultsStatus: UILabel!

    init(urlSessionClient: URLSessionClientProtocol!,
         presenter:PresenterProtocol!) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = presenter
        self.urlSessionClient = urlSessionClient
        self.urlSessionClient.addListener(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.testResultsStatus.text = "Getting Results..."
        self.presenter.fetchTimesheet("")
        let url = "http://jsonplaceholder.typicode.com/users"
        let requestPromise = self.urlSessionClient.requestWithURL(url)
        requestPromise?.then({ (data) -> AnyObject? in
            self.testResultsStatus.text = "Success"
            return nil;
        }) { (error) -> AnyObject? in
            self.testResultsStatus.text = "Failure"
            return nil;
        }
    }
    
    func URLSessionClientDidRequestData(){
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        
        let objectiveController = self.injector.getInstance("ObjectiveController") as! ObjectiveController
        self.navigationController?.pushViewController(objectiveController, animated: true)
    }
    
}
