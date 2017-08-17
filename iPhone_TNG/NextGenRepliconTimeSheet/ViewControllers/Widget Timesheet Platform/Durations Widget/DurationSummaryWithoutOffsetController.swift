

import UIKit

enum TimesheetDurationSummaryType : String{
    case Work = "Work"
    case Break = "Break"
    case TimeOff = "TimeOff"
}

// MARK: <DurationSummaryWithoutOffsetControllerInterface>

@objc protocol DurationSummaryWithoutOffsetControllerInterface {
    func setupWithTimesheetDuration(_ duration:TimesheetDuration!,delegate:DurationSummaryWithoutOffsetControllerDelegate!,hasBreakAccess:Bool)
}

// MARK: <DurationSummaryWithoutOffsetControllerDelegate>

@objc protocol DurationSummaryWithoutOffsetControllerDelegate {
    func durationSummaryWithoutOffsetControllerIntendsToUpdateItsContainerWithHeight(_ height:CGFloat)
}

/// This controller shows durations for work,break and timesoff durations for timesheet

// MARK:- <DurationSummaryWithoutOffsetController>

class DurationSummaryWithoutOffsetController: UIViewController,DurationSummaryWithoutOffsetControllerInterface {

    @IBOutlet weak var collectionView: UICollectionView!
    var duration: TimesheetDuration!
    var theme : Theme!
    fileprivate var hasBreakAccess:Bool = false
    fileprivate let identifier = "CellIdentifier"
    fileprivate weak var delegate:DurationSummaryWithoutOffsetControllerDelegate!
    fileprivate var dataArray = [[String:DateComponents]]()
    // MARK: - NSObject
    init(theme:Theme!) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWithTimesheetDuration(_ duration:TimesheetDuration!,delegate:DurationSummaryWithoutOffsetControllerDelegate!,hasBreakAccess:Bool){
        self.duration = duration
        self.delegate = delegate
        self.hasBreakAccess = hasBreakAccess
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
        let cellNib = UINib(nibName: String(describing:DurationCollectionCell.self), bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: self.identifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isScrollEnabled = false
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        self.collectionView.collectionViewLayout = flowLayout
        
        var zeroDateComponents = DateComponents()
        zeroDateComponents.hour = 0
        zeroDateComponents.minute = 0
        zeroDateComponents.second = 0
        
        let timeoffComponents = self.duration.timeOffHours ?? zeroDateComponents
        let workComponents = self.duration.regularHours ?? zeroDateComponents
        let breakComponents = self.duration.breakHours ?? zeroDateComponents
        
        self.dataArray.append([TimesheetDurationSummaryType.Work.rawValue:workComponents])
        if isZeroComponents(breakComponents) {
            if self.hasBreakAccess {
                self.dataArray.append([TimesheetDurationSummaryType.Break.rawValue:breakComponents])
            }
        }
        else{
            self.dataArray.append([TimesheetDurationSummaryType.Break.rawValue:breakComponents])
        }
        
        if !isZeroComponents(timeoffComponents){
            self.dataArray.append([TimesheetDurationSummaryType.TimeOff.rawValue:timeoffComponents])
        }


    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.delegate.durationSummaryWithoutOffsetControllerIntendsToUpdateItsContainerWithHeight(self.collectionView.contentSize.height)
    }
    // MARK:- Private
    
    fileprivate func isZeroComponents(_ components:DateComponents) -> Bool{
        return components.hour == 0 && components.minute == 0 && components.second == 0
    }

}

// MARK:-
extension DurationSummaryWithoutOffsetController : UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifier,for:indexPath) as! DurationCollectionCell
        let dataInfo = self.dataArray[indexPath.row]
        var timeDurationComponents = DateComponents()
        timeDurationComponents.hour = 0
        timeDurationComponents.minute = 0
        timeDurationComponents.second = 0
        
        var image = UIImage()
        var color = UIColor.black
        
        if let breakTimeComponents = dataInfo[TimesheetDurationSummaryType.Break.rawValue]{
            image = UIImage(named: "icon_timeline_break")!
            cell.nameLabel.text = "Break".localize()
            color = self.theme.breakTimeDurationColor()
            timeDurationComponents = breakTimeComponents
        }
        else if let timeoffTimeComponents = dataInfo[TimesheetDurationSummaryType.TimeOff.rawValue]{
            image = UIImage(named: "icon_time_off")!
            color = self.theme.timeOffTimeDurationColor()
            cell.nameLabel.text = "Time Off".localize()
            timeDurationComponents = timeoffTimeComponents
        }
        else if let workTimeComponents = dataInfo[TimesheetDurationSummaryType.Work.rawValue]{
            image = UIImage(named: "icon_timeline_clock_in")!
            cell.nameLabel.text = "Work".localize()
            color = self.theme.workTimeDurationColor()
            timeDurationComponents = workTimeComponents
        }
        
        
        cell.typeImageView.image = image
        cell.typeImageView.backgroundColor = UIColor.clear
        cell.nameLabel.font = self.theme.timeDurationNameLabelFont()
        cell.nameLabel.textColor = color
        let durationText = durationStringWithHours(timeDurationComponents.hour!,minutes: timeDurationComponents.minute!)
        cell.durationHoursLabel.text = durationText
        cell.durationHoursLabel.font = self.theme.timeDurationValueLabelFont()
        cell.durationHoursLabel.textColor = color;
        
        cell.typeImageView.backgroundColor = UIColor.clear
        cell.nameLabel.backgroundColor = UIColor.clear
        cell.durationHoursLabel.backgroundColor = UIColor.clear
        cell.rightItemDivider.isHidden = true
        return cell
    }
    
    // MARK: Private
    
    private func durationStringWithHours(_ hours: Int, minutes: Int) -> String {
        let hoursString = String(format: "%d", hours)
        let minutesString = String(format: "%02d", minutes)
        let punchDurationText = "\(hoursString)h:\(minutesString)m"
        return punchDurationText
    }
    
    
}

// MARK:-
extension DurationSummaryWithoutOffsetController : UICollectionViewDelegate {
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
}

// MARK:-
extension DurationSummaryWithoutOffsetController: UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectioViewDelegateFlowLayout methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let availableWidth = view.frame.width
        let widthPerItem = availableWidth / CGFloat(self.dataArray.count)
        return CGSize(width: widthPerItem, height: 80)
    }
}
