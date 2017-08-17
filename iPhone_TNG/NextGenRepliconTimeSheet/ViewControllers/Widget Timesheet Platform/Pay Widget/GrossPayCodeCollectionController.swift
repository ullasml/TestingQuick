

import UIKit

// MARK: <GrossPayCodeCollectionControllerDelegate>

@objc protocol GrossPayCodeCollectionControllerDelegate {
    
    func grossPayCodeCollectionController(_ controller:GrossPayCodeCollectionController!,intendsToUpdateItsContainerWithHeight height:CGFloat)
}


// MARK: <GrossPayCodeCollectionControllerInterface>

@objc protocol GrossPayCodeCollectionControllerInterface {
    func setupWithActualsByPayCode(_ actualsByPayCode:[Paycode]!,delegate:GrossPayCodeCollectionControllerDelegate!)
}

/// This controller shows pay codes associated with the pay widget

class GrossPayCodeCollectionController: UIViewController,GrossPayCodeCollectionControllerInterface {

    @IBOutlet weak var collectionView: UICollectionView!
    weak var injector : BSInjector!
    var theme:Theme!
    fileprivate weak var delegate:GrossPayCodeCollectionControllerDelegate!
    fileprivate let identifier = "CellIdentifier"
    fileprivate var actualsByPayCode:[Paycode]!
    fileprivate var colorCodeArray:[UIColor]!
    
    // MARK: - NSObject
    init(theme:Theme!) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWithActualsByPayCode(_ actualsByPayCode:[Paycode]!,delegate:GrossPayCodeCollectionControllerDelegate!){
        self.actualsByPayCode = actualsByPayCode
        self.delegate = delegate
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
        self.colorCodeArray = Util.getColorList(Int32(self.actualsByPayCode.count)) as! [UIColor]
        let cellNib = UINib(nibName: String(describing:GrossPayHoursCell.self), bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: self.identifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isScrollEnabled = false
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.delegate.grossPayCodeCollectionController(self, intendsToUpdateItsContainerWithHeight: self.collectionView.contentSize.height)
    }
}

// MARK: - UICollectionViewDataSource

extension GrossPayCodeCollectionController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.actualsByPayCode.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifier,for:indexPath) as! GrossPayHoursCell
        let payCode = self.actualsByPayCode[indexPath.row]
        cell.valueLabel.text = payCode.textValue
        cell.valueLabel.font = self.theme.legendsGrossPayFont()
        cell.colorView.cornerRadius = cell.colorView.frame.size.height/2
        cell.colorView.backgroundColor = self.colorCodeArray[indexPath.row]
        cell.titleLabel.text = payCode.titleText
        cell.titleLabel.font = self.theme.legendsGrossPayHeaderFont()!
        return cell
    }
    
}

// MARK: - UICollectioViewDelegateFlowLayout

extension GrossPayCodeCollectionController: UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let availableWidth = self.collectionView.bounds.size.width
        let cellWidth = (availableWidth / 2.0) - 20        
        return CGSize(width: cellWidth, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsetsMake(5, 25, 5, 0)
    }
}

