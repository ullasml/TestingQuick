//
//  MultiDayTimeOffViewController.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 03/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

enum Tag{
    static let userComments = 100
}

enum ID{
    static let leaveType = "LeaveTypeCell"
    static let date = "DateCell"
    static let expandCollapse = "ExpandCollapseHeader"
    static let balance = "BalanceCell"
    static let comments = "CommentsCell"
    static let udfs = "UDFsCell"
    static let actions = "ActionCell"
}
enum Height{
    enum Cell{ // Estimated Height For Cell
        static let leaveType:CGFloat = 50
        static let dateEntry:CGFloat = 133
        static let balance:CGFloat = 70
        static let comments:CGFloat = 100
        static let udfs:CGFloat = 44
        static let actions:CGFloat = 64
    }
    
    enum Section{
        static let expandCollapse:CGFloat = 44
    }
    
    enum HeaderAndFooters {
        static let statusHeader:CGFloat = 44
        static let approvalHeader:CGFloat = 55
        static let footer:CGFloat = 270
    }
}

enum TimeOffSection: Int {
    case leaveType, startDate, middleDate, endDate, balance, comments, udfs, actions
    
    static let count: Int = {
        var max: Int = 0
        while let _ = TimeOffSection(rawValue: max) { max += 1 }
        return max
    }()
}


class MultiDayTimeOffViewController: UIViewController {

// MARK: Private members
    
    fileprivate var timeOffDeserializer: TimeOffDeserializerProtocol
    fileprivate var timeOffRepository: TimeOffRepositoryProtocol
    fileprivate var timesheetModel: TimesheetModel?
    fileprivate weak var appDelegate: AppDelegate?
    fileprivate var theme:Theme
    fileprivate var reachabilityMonitor:ReachabilityMonitor
    fileprivate var timeOff:TimeOff?
    fileprivate var allTimeOffTypes: [TimeOffTypeDetails] = []
    fileprivate var activeField:Any?
    fileprivate weak var parentDelegate: AnyObject?
    fileprivate var timeSheetURI: String?
    fileprivate var timeOffUri: String?
    fileprivate var userName: String?
    fileprivate var timeoffType: String?
    fileprivate var approverComments: String?
    fileprivate var selectedIndexPath:IndexPath?
    fileprivate var timeoffModelType: TimeOffModelType = .timeOff
    fileprivate var navigationFlow: NavigationFlow = .TIMEOFF_BOOKING_NAVIGATION
    fileprivate var commentsHeight = Height.Cell.comments
    fileprivate var isDatesExpanded = false
    fileprivate var isEditEnabled = false
    fileprivate var isUserEditingTextView = false
    fileprivate var currentViewTag: Int = 0
    fileprivate var totalViewCount: Int = 0
    fileprivate var screenMode: Int = 0
    fileprivate var currentViewCount: Int {
        return self.currentViewTag+1
    }

    fileprivate var startDate: Date = Date()
    fileprivate var endDate: Date {
        get{
            return self.startDate
        }
    }
    
    fileprivate var timesheetFormat: String? {
        get {
            return self.timesheetModel?.getTimesheetFormatInfoFromDB(forTimesheetUri: self.timeSheetURI)
        }
    }
    
    fileprivate var tableHeaderHeight: CGFloat {
        get {
            if(self.timeoffModelType == .pendingApproval || self.timeoffModelType == .previousApproval){
                return 110
            }
            return 0
        }
    }

    
    @IBOutlet weak private(set) public var tableView: UITableView!
    
// MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(timeOffDeserializer:TimeOffDeserializerProtocol,
           timeOffRepository:TimeOffRepositoryProtocol,
              timesheetModel:TimesheetModel,
                 appDelegate:AppDelegate,
                       theme:Theme,
         reachabilityMonitor:ReachabilityMonitor){
        self.timeOffDeserializer = timeOffDeserializer
        self.theme = theme
        self.timeOffRepository = timeOffRepository
        self.reachabilityMonitor = reachabilityMonitor
        self.timesheetModel = timesheetModel
        self.appDelegate = appDelegate
        super.init(nibName: nil, bundle: nil)
    }
   
// MARK: Setup Methods
    
    func setup(withModelType timeoffModelType: TimeOffModelType, screenMode: Int, navigationFlow: NavigationFlow, delegate: AnyObject?, timeOffUri: String?, timeSheetURI: String?, date: Date?) {
        self.timeoffModelType = timeoffModelType
        self.screenMode = screenMode
        self.navigationFlow = navigationFlow
        self.parentDelegate = delegate
        self.timeSheetURI = timeSheetURI
        self.timeOffUri = timeOffUri
        if let aDate = date {
            self.startDate = aDate
        }
    }
    
    func setupForApproval(withUserName userName: String?, timeoffType: String?, currentViewTag: NSNumber?, totalViewCount: NSNumber?){
        self.userName = userName
        self.timeoffType = timeoffType
        if let viewTag = currentViewTag {
            self.currentViewTag = viewTag.intValue
        }
        if let viewCount = totalViewCount {
            self.totalViewCount = viewCount.intValue
        }
    }
    

// MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCellNib()
        configureTimeOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = false
        registerForKeyboardNotifications()
        self.title = ""
        if isNewBooking() {
            self.title = ConstStrings.bookTimeOff
        }else{
            self.title = ConstStrings.timeOffBooking
        }
        
        if self.isModal {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: ConstStrings.cancel, style: .plain, target: self, action: #selector(dissmiss))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeAllObservers()
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.setAndLayoutTableHeaderView(header: self.getTableHeaderView())
        self.tableView.tableFooterView = self.getTableFooterView()
        self.updateTableHeight()
    }
    
// MARK: Private Methods
    
    private func registerCellNib(){
        
        tableView.register(UINib(nibName: String(describing:SelectableHeader.self), bundle: nil), forHeaderFooterViewReuseIdentifier: ID.expandCollapse)
        tableView.register(UINib(nibName: String(describing:TimeOffTypeCell.self), bundle: nil), forCellReuseIdentifier: ID.leaveType)
        tableView.register(UINib(nibName: String(describing:TimeOffDateEntryCell.self), bundle: nil), forCellReuseIdentifier: ID.date)
        tableView.register(UINib(nibName: String(describing:TimeOffBalanceCell.self), bundle: nil), forCellReuseIdentifier: ID.balance)
        tableView.register(UINib(nibName: String(describing:TimeOffCommentsCell.self), bundle: nil), forCellReuseIdentifier: ID.comments)
        tableView.register(UINib(nibName: String(describing:TimeOffUDFCell.self), bundle: nil), forCellReuseIdentifier: ID.udfs)
        tableView.register(UINib(nibName: String(describing:TimeOffActionCell.self), bundle: nil), forCellReuseIdentifier: ID.actions)
    }
    
    private func configureTimeOff(){
        timeOffDeserializer.setTimeOffModelType(type: self.timeoffModelType)
        allTimeOffTypes.append(contentsOf: timeOffDeserializer.getAllTimeOffType())
        
        
        if let thisTimeOffUri = self.timeOffUri, thisTimeOffUri.characters.count > 0{
            timeOff = timeOffDeserializer.deserializeTimeOffDetails(timeOffUri: self.timeOffUri!)
            configureTableHeaderAndFooter()
            if let editPermission = timeOff?.details?.canEdit, editPermission == true{
                addEditOrSubmitButton()
            }
            tableView.reloadData()
            
        }else{
            
            let defaultTimeOffType:TimeOffTypeDetails
            if let timeOffType = timeOffDeserializer.getDefaultTimeOffType() {
                defaultTimeOffType = timeOffType
            }else{
                defaultTimeOffType = allTimeOffTypes.first!
            }
            let defaultUDFs = timeOffDeserializer.getTimeOffUDFsFromDB(forUri: nil)
            let timeOffDetails = TimeOffDetails(withUri: "", comments: "", resubmitComments: "", edit: true, delete: false)
            
            tableView.isHidden = true
            configureTableHeaderAndFooter()
            addEditOrSubmitButton()
            
            appDelegate?.showTransparentLoadingOverlay()

            let entriesAndDurationOptions = self.timeOffRepository.getUserEntriesAndDurationOptions(timeOffTypeUri: defaultTimeOffType.uri, startDate: self.startDate , endDate: self.endDate)
            entriesAndDurationOptions.then({[weak self] (dictionary) -> AnyObject? in
                if let responseDict = dictionary as? [String:Any]{
                    let allOptions = responseDict["TimeOffDurationOptions"] as? [TimeOffDurationOptions] ?? []
                    let allEntries = responseDict["TimeOffEntry"] as? [TimeOffEntry] ?? []
                    let startDayEntry = allEntries.first
                    let endDayEntry = allEntries.last
                    let middleDayEntries = allEntries.count > 2 ? Array(allEntries[1..<(allEntries.count-1)]) : []
                    self?.timeOff = TimeOff(withStartDayEntry: startDayEntry, endDayEntry: endDayEntry, middleDayEntries: middleDayEntries, allDurationOptions: allOptions, allUDFs: defaultUDFs, approvalStatus: nil, balanceInfo: nil, type: defaultTimeOffType, details: timeOffDetails)
                    
                    self?.tableView.reloadData()
                    self?.tableView.isHidden = false
                    self?.updateBalance()
                }else{
                    //TODO: Handle Error
                    
                }
                self?.appDelegate?.hideTransparentLoadingOverlay()

                return nil
            }) {(error) -> AnyObject? in
                self.appDelegate?.hideTransparentLoadingOverlay()
                //TODO: Handle Error
                return nil
            }
        }
        
    }
    
    private func addEditOrSubmitButton(){
        if(isNewBooking()){
            let submit = UIBarButtonItem(title: ConstStrings.submit, style: .plain, target: self, action: #selector(submitTimeOff))
            navigationItem.rightBarButtonItem = submit
            isEditEnabled = true
            
        }else{
            let edit = UIBarButtonItem(title: ConstStrings.edit, style: .plain, target: self, action: #selector(editTimeOff))
            navigationItem.rightBarButtonItem = edit
        }
    }
    
    private func updateTableHeight() {
        var frame = self.tableView.frame
        frame.size.height = frame.size.height-self.tableHeaderHeight
        self.tableView.frame = frame
    }
    
    private func configureTableHeaderAndFooter(){
        tableView.setAndLayoutTableHeaderView(header: self.getTableHeaderView())
    }
    
    private func getTableHeaderView() -> UIView {
        
        if (isNewBooking() || isEditEnabled) { return UIView() }
        
        let headerView = UIView()
        
        let statusHeader = self.stautsHeaderView()
        statusHeader.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(statusHeader)
        
        statusHeader.constrain(toHeight: Height.HeaderAndFooters.statusHeader)
        
        guard self.timeoffModelType == .pendingApproval || self.timeoffModelType == .previousApproval else {
            statusHeader.pin(toSuperviewEdges: .allEdges, inset: 0)
            headerView.frame = statusHeader.frame
            return headerView
        }
        
        let approvalHeader = self.approvalsHeaderView()
        approvalHeader.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(approvalHeader)
        
        approvalHeader.pin(toSuperviewEdges: [.leftEdge,.rightEdge,.topEdge] , inset: 0)
        approvalHeader.pinAttribute(.bottom, to: .top, ofItem: statusHeader)
        statusHeader.pin(toSuperviewEdges: [.leftEdge,.rightEdge,.bottomEdge], inset: 0)
        approvalHeader.constrain(toHeight: Height.HeaderAndFooters.approvalHeader)
        
        headerView.frame = CGRect(origin: CGPoint.zero,
                                  size: CGSize(width:self.view.width,height:statusHeader.height+approvalHeader.height))
        return headerView
    }
    
    private func getTableFooterView() -> UIView {
        
        guard self.timeoffModelType == .pendingApproval else { return UIView() }
        
        let footerView = UIView()
        
        let approvalFooterView = self.approvalFooterView()
        approvalFooterView.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(approvalFooterView)
        approvalFooterView.pin(toSuperviewEdges: .allEdges, inset: 0)
        approvalFooterView.constrain(toHeight: Height.HeaderAndFooters.footer)
        let frame =  approvalFooterView.frame
        footerView.frame = frame
        
        return footerView
    }
    
    
    private func stautsHeaderView() -> TimeOffStatusHeader {
        let header = TimeOffStatusHeader.instanceFromNib()
        header.configure(withStatus: timeOff?.approvalStatus, theme: self.theme, delegate: self)
        return header
    }
    
    private func approvalsHeaderView() -> ApprovalTablesHeaderView {
        let headerView = ApprovalTablesHeaderView.init(frame:CGRect(origin: CGPoint.zero, size: CGSize(width:self.view.width ,height:55)), withStatus: self.timeOff?.approvalStatus?.title, userName: self.userName, dateString: self.timeoffType, labelText: nil, withApprovalModuleName: self.timeoffModelType.description, isWidgetTimesheet: false, withErrorsAndWarning: nil)
        headerView?.delegate = self
        if let approvalScrollViewController = self.parentDelegate, approvalScrollViewController is ApprovalsScrollViewController {
            if !(approvalScrollViewController.hasPreviousTimeSheets) {
                headerView?.previousButton.isHidden = true
            }
            if !(approvalScrollViewController.hasNextTimeSheets) {
                headerView?.nextButton.isHidden = true
            }
            
            if self.timeoffModelType == .pendingApproval {
                headerView?.countLbl.text = "\(self.currentViewCount) of \(self.totalViewCount)"
            } else {
                headerView?.countLbl.text = ""
            }
        }
        
        return headerView!
    }
    
    private func approvalFooterView() -> ApprovalTablesFooterView {
        let footerView = ApprovalTablesFooterView.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width:self.view.width ,height:55)), withStatus: self.timeOff?.approvalStatus?.title)
        footerView?.delegate = self
        
        return footerView!
    }
    
    fileprivate func isMultiDay() -> Bool {
        guard let startDate = timeOff?.startDayEntry?.date, let endDate = (timeOff?.endDayEntry?.date) else {
            return false
        }
        return startDate.equalsIgnoreTime(endDate) ? false : true
    }
    
    fileprivate func isMiddleSectionHidden() -> Bool {
        guard let count = timeOff?.middleDayEntries.count else {
            return true
        }
        return count == 0
    }
    
    fileprivate func isNewBooking() -> Bool {
        guard let thisTimeOffUri = self.timeOffUri, thisTimeOffUri.characters.count > 0 else {
            return true
        }
        return false
    }
    
    fileprivate func canDelete() -> Bool {
        guard let deletePermission = timeOff?.details?.canDelete else{
            return false
        }
        return deletePermission
    }
    
    private func getLocalDate(from date: Date) -> Date{
        var calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let finalDate = calendar.date(from: components)!
        return finalDate
    }

    
    private func validateBooking() -> (isSuccess:Bool, msg:String){
        if(isMultiDay()){
            var allEntries:[TimeOffEntry] = (timeOff?.middleDayEntries)!
            allEntries.insert((timeOff?.startDayEntry)!, at: 0)
            allEntries.append((timeOff?.endDayEntry)!)
            for entry in allEntries{
                let result = validateForPartialDay(entry: entry)
                if !result.isSuccess {
                    return result
                }
            }
            return (true,"Success")
        }else{
            return validateForPartialDay(entry: (timeOff?.startDayEntry)!)
        }
    }
    
    private func validateForPartialDay(entry:TimeOffEntry) -> (isSuccess:Bool, msg:String){
        if(entry.durationType == .partialDay){
            let duration = entry.bookingDurationDetails?.duration
            if(duration?.characters.count == 0){
                return (false,ConstStrings.partialHoursValidationMsg)
            }
        }
        return (true,"Success")
    }
    
    @objc fileprivate func submitTimeOff() {
        self.view.endEditing(true)
        if self.reachabilityMonitor.isNetworkReachable() {
            let validation = validateBooking()
            if validation.isSuccess {
                
                guard let timeOffObj = timeOff else {
                    AlertHelper.showAlert(message: "Technical Error!!")
                    return
                }
                
                let result = self.timeOffRepository.submitTimeOff(timeOffObject: timeOffObj, isNewBooking: isNewBooking());
                appDelegate?.showTransparentLoadingOverlay()
                result.then({[weak self] (dictionary) -> AnyObject? in
                    self?.timeOffSubmittedAction()
                    return nil
                }) {(error) -> AnyObject? in
                    self.appDelegate?.hideTransparentLoadingOverlay()
                    return nil
                }
            }else{
                AlertHelper.showAlertOnTarget(self, message: validation.msg, title: "")
            }
        }else{
            AlertHelper.showOfflineAlertOnTarget(self)
        }
    }
    
    @objc private func resubmitCommentsAction() {
        
        if !(self.reachabilityMonitor.isNetworkReachable()) {
            AlertHelper.showOfflineAlertOnTarget(self)
            return
        }
        
        self.view.endEditing(true)
        let validation = validateBooking()
        if validation.isSuccess {
            let resubmitCommentCtrl = ApprovalActionsViewController()
            resubmitCommentCtrl.selectedSheet = DateHelper.getStringFromDate(date: (timeOff?.startDayEntry?.date)!, withFormat: DateFormat.format1)
            resubmitCommentCtrl.actionType = "Re-Submit"
            resubmitCommentCtrl.delegate = self
            resubmitCommentCtrl.allowBlankComments = false
            self.navigationController?.pushViewController(resubmitCommentCtrl, animated: true)
        }else{
            AlertHelper.showAlertOnTarget(self, message: validation.msg, title: "")
        }
    }
    
    @objc private func editTimeOff(){
        
        if !(self.reachabilityMonitor.isNetworkReachable()) {
            AlertHelper.showOfflineAlertOnTarget(self)
            return
        }
        
        let allTypesFromDB = self.timeOffDeserializer.getAllTimeOffType()
        if allTypesFromDB.count > 0 {
            isEditEnabled = true
            self.tableView.tableHeaderView = nil
            UIView.animate(withDuration: 0.35, animations: { [weak self] in
                self?.view.layoutIfNeeded()
                }, completion: {[weak self] (completed) in
                    self?.tableView.reloadData()
            })
            let reSubmit = UIBarButtonItem(title: ConstStrings.resubmit, style: .plain, target: self, action: #selector(resubmitCommentsAction))
            navigationItem.rightBarButtonItem = reSubmit
        }else{
            AlertHelper.showAlertOnTarget(self, message: ConstStrings.noTimeOffTypesAssigned, title: "")
        }
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(aNotification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(aNotification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWasShown(aNotification: NSNotification) {
        let info = aNotification.userInfo as! [String: AnyObject],
        kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size,
        contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        
        var aRect = self.view.frame
        aRect.size.height -= kbSize.height
        
        if let tf = activeField as? UITextField {
            let frame = self.view.convert(tf.bounds, from: tf)
            if aRect.contains(frame) == false {
                self.tableView.scrollRectToVisible(frame, animated: true)
            }
        }else if let tv = activeField as? UITextView{
            let frame = self.view.convert(tv.bounds, from: tv)
            if aRect.contains(frame) == false{
                let cell = tableView.cellForRow(at: IndexPath(row: 0, section: TimeOffSection.comments.rawValue))
                self.tableView.scrollRectToVisible((cell?.frame)!, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillBeHidden(aNotification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    private func  getAllDurationTypes(forSchedule scheduleDuration:String, allOptions:[TimeOffDurationOptions]) -> [TimeOffDuration]{
        guard let filteredValue = (allOptions.filter {$0.scheduleDuration == scheduleDuration}.map {$0.durationOptions}).first, let options = filteredValue else {
            return []
        }
        
        return options
    }
    
    fileprivate func getEntry(at indexPath:IndexPath) -> TimeOffEntry?{
        let timeOffSection = TimeOffSection(rawValue: indexPath.section)!
        switch timeOffSection{
        case .startDate:
            return timeOff?.startDayEntry
        case .endDate:
            return timeOff?.endDayEntry
        case .middleDate:
            let middleEntry = timeOff?.middleDayEntries[indexPath.row]
            return middleEntry
        default:
            return nil
        }
    }
    
    fileprivate func showActionSheetForCell(at indexPath:IndexPath){
        
        let entry = getEntry(at: indexPath)
        guard let allOptions = timeOff?.allDurationOptions else {
            return
        }
        
        let allDurationObj = getAllDurationTypes(forSchedule: entry?.scheduleDuration ?? String(format:Precision.twoDecimal, 0), allOptions: allOptions)
        
        let asController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for durationObj in allDurationObj{
            let action = UIAlertAction(title: durationObj.title?.localize(), style: .default, handler: { [weak self] (action) in
                self?.postActionForCell(at: indexPath, durationObj: durationObj)
            })
            asController.addAction(action)
        }
        
        let cancelButton = UIAlertAction(title: ConstStrings.cancel, style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })

        asController.addAction(cancelButton)
        
        self.present(asController, animated: true, completion: nil)
    }
    
    private func postActionForCell(at indexPath:IndexPath, durationObj:TimeOffDuration) {
        let entry = getEntry(at: indexPath)
        entry?.bookingDurationDetails = durationObj.copy()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        updateBalance()
    }
    
    fileprivate func updateEntries(withStartDate startDate:Date, andEndDate endDate:Date){

        let timeOffTypeUri = (timeOff?.type?.uri)!
        appDelegate?.showTransparentLoadingOverlay()
        let result = self.timeOffRepository.getUserEntriesAndDurationOptions(timeOffTypeUri: timeOffTypeUri, startDate: startDate, endDate: endDate)
        result.then({[weak self] (dictionary) -> AnyObject? in
            if let responseDict = dictionary as? [String:Any]{
                if let allOptions = responseDict["TimeOffDurationOptions"] as? [TimeOffDurationOptions], allOptions.count > 0{
                    self?.timeOff?.allDurationOptions = allOptions
                }
                let allEntries = responseDict["TimeOffEntry"] as? [TimeOffEntry] ?? []
                self?.timeOff?.startDayEntry = allEntries.first
                self?.timeOff?.endDayEntry = allEntries.last
                self?.timeOff?.middleDayEntries = allEntries.count > 2 ? Array(allEntries[1..<(allEntries.count-1)]) : []
                self?.tableView.reloadData()
                self?.updateBalance()
            }else{
                //TODO: Handle Error
            }
            self?.appDelegate?.hideTransparentLoadingOverlay()

            return nil
        }) {(error) -> AnyObject? in
            self.appDelegate?.hideTransparentLoadingOverlay()
            //TODO: Handle Error
            return nil
        }
    }
    
    fileprivate func updateBalance(){
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: TimeOffSection.balance.rawValue)) as? TimeOffBalanceCell
        cell?.timeRemaining.text = ConstStrings.loading
        cell?.timeTaken.text = ConstStrings.loading
        
        let timeOffBalance = self.timeOffRepository.getBalanceForTimeOff(timeOffObject: timeOff!)
        timeOffBalance.then({[weak self] (balanceInfo) -> AnyObject? in
            if let balance = balanceInfo as? TimeOffBalance{
                self?.timeOff?.balanceInfo = balance
            }else{
                self?.timeOff?.balanceInfo = TimeOffBalance()
            }
            self?.tableView.reloadSections(IndexSet(integer: TimeOffSection.balance.rawValue), with: .automatic)
            
            return nil
        }) {[weak self] (error) -> AnyObject? in
            self?.timeOff?.balanceInfo = TimeOffBalance()
            self?.tableView.reloadSections(IndexSet(integer: TimeOffSection.balance.rawValue), with: .automatic)
            return nil
        }
    }
    
    fileprivate func confirmDelete()
    {
        if !(self.reachabilityMonitor.isNetworkReachable()) {
            AlertHelper.showOfflineAlertOnTarget(self)
            return
        }
        
        AlertHelper.showAlertOnTarget(self, message: ConstStrings.deleteTimeOffMsg, title: "", cancelButtonTitle: ConstStrings.cancel, cancelButtonHandler: nil, otherButtonTitle: ConstStrings.ok) {
            let timeOffDelete =  self.timeOffRepository.deleteTimeOff(timeOffObject: self.timeOff!)
            self.appDelegate?.showTransparentLoadingOverlay()
            timeOffDelete.then({[weak self] (dictionary) -> AnyObject? in
                self?.appDelegate?.hideTransparentLoadingOverlay()
                self?.handleDeleteAction()
                return nil
            }) {(error) -> AnyObject? in
                self.appDelegate?.hideTransparentLoadingOverlay()
                return nil
            }
        }
    }

    
    private func removeAllObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BOOKEDTIMEOFF_DELETED_NOTIFICATION), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION), object: nil)
    }
    
    @objc private func dissmiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: TimeOffStatusProtocol

extension MultiDayTimeOffViewController: TimeOffStatusProtocol{
    func didSelectStatusHeader() {
        let approverCommentCtrl = ApproverCommentViewController()
        approverCommentCtrl.sheetIdentity = timeOff?.details?.uri
        approverCommentCtrl.viewType = "BookedTimeoff"
        approverCommentCtrl.delegate = self
        approverCommentCtrl.approvalsModuleName = self.timeoffModelType.description
        
        guard (self.navigationFlow == .PENDING_APPROVER_NAVIGATION || self.navigationFlow == .PREVIOUS_APPROVER_NAVIGATION) else {
            self.navigationController?.pushViewController(approverCommentCtrl, animated: true)
            return
        }
        
        guard self.parentDelegate is ApprovalsScrollViewController else {
            self.navigationController?.pushViewController(approverCommentCtrl, animated: true)
            return
        }
        
        self.parentDelegate?.push(to: approverCommentCtrl)
    }
}

// MARK: TimeOffActionsProtocol

extension MultiDayTimeOffViewController: TimeOffActionsProtocol{
    func deleteTimeOff(cell: TimeOffActionCell) {
        confirmDelete()
    }
}

// MARK: TimeOffTypeProtocol

extension MultiDayTimeOffViewController: TimeOffTypeProtocol{
    func timeOffTypeSelected(row: Int, cell: TimeOffTypeCell) {
        
        let type = allTimeOffTypes[row]
        timeOff?.type = type
        cell.timeOffType.text = type.title
        
        let currentStartDate = (timeOff?.startDayEntry?.date)!
        let currentEndDate = (timeOff?.endDayEntry?.date)!
        updateEntries(withStartDate: currentStartDate, andEndDate: currentEndDate)
    }
}

// MARK: DateCellProtocol

extension MultiDayTimeOffViewController: DateCellProtocol{
    func timeOffDurationTypeSelected(cell: TimeOffDateEntryCell) {
        self.view.endEditing(true)
        if !(self.reachabilityMonitor.isNetworkReachable()) {
            AlertHelper.showOfflineAlertOnTarget(self)
            return
        }
        showActionSheetForCell(at: cell.indexPath!)
    }

    func didSelectTime(at indexPath: IndexPath?, value: String) {
        if let index = indexPath, let type = TimeOffSection(rawValue: index.section) {
            switch type {
            case .startDate:
                timeOff?.startDayEntry?.timeStarted = value
            case .endDate:
                timeOff?.endDayEntry?.timeEnded = value
            case .middleDate:
                let dayEntry = timeOff?.middleDayEntries[index.row]
                dayEntry?.timeStarted = value
            default:
                print("Not a valid case")
            }
        }
    }
}

// MARK: DateUDFProtocol

extension MultiDayTimeOffViewController: DateUDFProtocol{
    func dateSelected(atCell cell: TimeOffUDFCell, withValue value: String) {
        if let indexPath = cell.indexPath, let udf = timeOff?.allUDFs[indexPath.row], udf.type == .date{
            udf.value = value
        }
    }
}

// MARK: TableViewHeaderDelegate

extension MultiDayTimeOffViewController: TableViewHeaderDelegate{
    func didSelect(header: SelectableHeader, selected: Bool) {
        if(selected){
            isDatesExpanded = !isDatesExpanded
            tableView.reloadSections(IndexSet(integer: TimeOffSection.middleDate.rawValue), with: .automatic)
        }
    }
}

// MARK: UITableViewDataSource

extension MultiDayTimeOffViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return TimeOffSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let timeOffSection = TimeOffSection(rawValue: section) else {
            print("Section \(section) : Not Handled")
            return 0
        }
        
        switch timeOffSection{
        case .leaveType:
            return 1
        case .startDate:
            return 1
        case .endDate:
            return 1
        case .middleDate:
            return isDatesExpanded ? (timeOff?.middleDayEntries.count)! : 0
        case .balance:
            return 1
        case .comments:
            return 1
        case .udfs:
            if let udfCount = timeOff?.allUDFs.count{
                return udfCount
            }
            return 0
            
        case .actions:
            return ((isNewBooking() || !canDelete() || self.timeoffModelType == .pendingApproval || self.timeoffModelType == .previousApproval)) ? 0 : 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timeOffSection = TimeOffSection(rawValue: indexPath.section)!
        switch timeOffSection{
        case .leaveType:
            let cell = tableView.dequeueReusableCell(withIdentifier: ID.leaveType) as! TimeOffTypeCell
            cell.configure(withType: timeOff?.type, delegate: self)
            cell.isUserInteractionEnabled = isEditEnabled
            return cell
        case .startDate,.endDate, .middleDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: ID.date) as! TimeOffDateEntryCell
            if let timeOffEntry = getEntry(at: indexPath){
                cell.configure(with: timeOffEntry, measurementUri: timeOff?.type?.measurementUri, delegate: self, atIndexPath: indexPath, isMultiDayTimeOff: isMultiDay(), editEnabled: isEditEnabled)
            }
            cell.isUserInteractionEnabled = isEditEnabled
            return cell
        case .balance:
            let cell = tableView.dequeueReusableCell(withIdentifier: ID.balance) as! TimeOffBalanceCell
            cell.configure(withBalanceInfo: timeOff?.balanceInfo, andMeasurementUri: timeOff?.type?.measurementUri)
            return cell
        case .comments:
            let cell = tableView.dequeueReusableCell(withIdentifier: ID.comments) as! TimeOffCommentsCell
            cell.isUserInteractionEnabled = isEditEnabled
            cell.configure(withComments: timeOff?.details?.userComments, delegate: self)
            return cell
        case .udfs:
            let cell = tableView.dequeueReusableCell(withIdentifier: ID.udfs) as! TimeOffUDFCell
            cell.configure(atIndexPath: indexPath, udf: (timeOff?.allUDFs[indexPath.row])!, isEditable: isEditEnabled, andDelegate: self)
            cell.isUserInteractionEnabled = isEditEnabled
            return cell
        case .actions:
            let cell = tableView.dequeueReusableCell(withIdentifier: ID.actions) as! TimeOffActionCell
            cell.configure(delegate: self)
            return cell
        }
    }

}

// MARK: BookedTimeOffDateSelectionDelegate

extension MultiDayTimeOffViewController : BookedTimeOffDateSelectionDelegate{
    
    func didSelectDate(forStart startDate: Date?, forEnd endDate: Date?) {
        
        guard let start = startDate, let end = endDate else {
            return
        }
        
        var selectedStartDate:Date = start
        var selectedEndDate:Date = end
        if(start.compare(end) == ComparisonResult.orderedDescending){
            selectedStartDate = end
            selectedEndDate = start
        }
        
        let currentStartDate = (timeOff?.startDayEntry?.date)!
        let currentEndDate = (timeOff?.endDayEntry?.date)!
        
        if !(currentStartDate.equalsIgnoreTime(selectedStartDate) && currentEndDate.equalsIgnoreTime(selectedEndDate)) {
            updateEntries(withStartDate: selectedStartDate, andEndDate: selectedEndDate)
        }
    }
}

// MARK: UITableViewDelegate

extension MultiDayTimeOffViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        let timeOffSection = TimeOffSection(rawValue: indexPath.section)!
        switch timeOffSection {
        case .leaveType:
            
            if !(self.reachabilityMonitor.isNetworkReachable()) {
                AlertHelper.showOfflineAlertOnTarget(self)
                return
            }
            
            let cell = tableView.cellForRow(at: indexPath) as! TimeOffTypeCell
            let matchIndex = allTimeOffTypes.index(){ $0.uri == timeOff?.type?.uri}
            self.activeField = nil //Reset active field to nil
            cell.launchPicker(with: matchIndex ?? 0)
            
        case .startDate,.endDate:
            
            if !(self.reachabilityMonitor.isNetworkReachable()) {
                AlertHelper.showOfflineAlertOnTarget(self)
                return
            }
            
            let bookedTimeOffDateSelectionViewController = BookedTimeOffDateSelectionViewController()
            bookedTimeOffDateSelectionViewController.delegate = self
            bookedTimeOffDateSelectionViewController.selectedStartDate = timeOff?.startDayEntry?.date
            bookedTimeOffDateSelectionViewController.selectedEndDate = timeOff?.endDayEntry?.date
            if(timeOffSection == .startDate){
                bookedTimeOffDateSelectionViewController.screenMode = 0
            }else{
                bookedTimeOffDateSelectionViewController.screenMode = 1
            }
            
            self.navigationController?.pushViewController(bookedTimeOffDateSelectionViewController, animated: true)
        case .udfs:
            if let udf = timeOff?.allUDFs[indexPath.row] {
                switch (udf.type) {
                case .dropdown:
                    
                    if !(self.reachabilityMonitor.isNetworkReachable()) {
                        AlertHelper.showOfflineAlertOnTarget(self)
                        return
                    }
                    
                    let udfDropdownVC = UdfDropDownViewController()
                    udfDropdownVC.delegate = self
                    
                    let udfDict = ["type":udf.type.rawValue, "uri":udf.uri, "name":udf.name, "dropDownOptionUri":udf.optionsUri ?? ""]
                    let udfObj = UdfObject(dictionary: udfDict)
                    
                    udfDropdownVC.intialiseDropDownView(with: udfObj, withNaviagtion: NavigationFlow.TIMEOFF_BOOKING_NAVIGATION, with: nil, withTimeOffObj: nil)
                    self.navigationController?.pushViewController(udfDropdownVC, animated: true)
                case .text:
                    let commentsController = CommentsViewController()
                    commentsController.commentsActionDelegate = self
                    let timeOffObj = TimeOffObject()
                    timeOffObj.canEdit = self.isEditEnabled
                    let udfDict = ["type":TEXT_UDF_TYPE, "uri":udf.uri, "name":udf.name, "defaultValue":udf.value]
                    commentsController.setUpWith(UdfObject(dictionary: udfDict), with: self.navigationFlow, with: nil, withTimeOffObj: timeOffObj)
                    self.navigationController?.pushViewController(commentsController, animated: true)
                case .numeric:
                    let cell = tableView.cellForRow(at: indexPath) as! TimeOffUDFCell
                    cell.enableEntry()
                case .date:
                    let cell = tableView.cellForRow(at: indexPath) as! TimeOffUDFCell
                    cell.launchDatePicker()
                default:
                    print("UDF Type Not Handled")
                }
            }
        default:
            print("Did Select Not Handled")
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let timeOffSection = TimeOffSection(rawValue: indexPath.section)!
        switch timeOffSection{
        case .leaveType:
            return Height.Cell.leaveType
        case .startDate,.endDate,.middleDate:
            return Height.Cell.dateEntry
        case .balance:
            return Height.Cell.balance
        case .comments:
            if !self.isUserEditingTextView, let comments = timeOff?.details?.userComments, comments.characters.count > 0 {
                return Height.Cell.comments
            }
            return commentsHeight > Height.Cell.comments ? commentsHeight : Height.Cell.comments
        case .udfs:
            return Height.Cell.udfs
        case .actions:
            return Height.Cell.actions
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let timeOffSection = TimeOffSection(rawValue: indexPath.section)!
        switch timeOffSection{
        case .leaveType, .udfs, .actions, .balance, .startDate,.endDate,.middleDate:
            return UITableViewAutomaticDimension
        case .comments:
            if !self.isUserEditingTextView, let comments = timeOff?.details?.userComments, comments.characters.count > 0 {
                return UITableViewAutomaticDimension
            }
            return commentsHeight > Height.Cell.comments ? commentsHeight : Height.Cell.comments
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let timeOffSection = TimeOffSection(rawValue: section), timeOffSection == .middleDate, !isMiddleSectionHidden(){
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ID.expandCollapse) as! SelectableHeader
            headerView.delegate = self
            let title = isDatesExpanded ? ConstStrings.collapseDays : ConstStrings.expandDays
            headerView.title .setTitle(title, for: .normal)
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let timeOffSection = TimeOffSection(rawValue: section), timeOffSection == .middleDate, !isMiddleSectionHidden(){
            return Height.Section.expandCollapse
        }
        return 0
    }
}

// MARK: CommentsActionDelegate

extension MultiDayTimeOffViewController: CommentsActionDelegate {
    func userEnteredComments(on udfObject: UdfObject!) {
        print("\(udfObject.defaultValue)")
        if let indexPath = selectedIndexPath, let timeOffSection = TimeOffSection(rawValue: indexPath.section) {
            switch timeOffSection {
            case .udfs:
                let udf = timeOff?.allUDFs[indexPath.row]
                udf?.value = udfObject.defaultValue
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            default:
                print("Not a valid section")
            }
        }
        selectedIndexPath = nil
    }
}

// MARK: UdfDropDownViewDelegate

extension MultiDayTimeOffViewController: UdfDropDownViewDelegate {

    func udfDropDownView(_ udfDropDownView: UdfDropDownView!, with udfObject: UdfObject!) {
        if let indexPath = selectedIndexPath, let timeOffSection = TimeOffSection(rawValue: indexPath.section) {
            switch timeOffSection {
            case .udfs:
                let udf = timeOff?.allUDFs[indexPath.row]
                udf?.optionsUri = udfObject.dropDownOptionUri
                udf?.value = udfObject.defaultValue
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            default:
                print("Not a valid section")
            }
        }
        selectedIndexPath = nil
    }
}

// MARK: UITextViewDelegate

extension MultiDayTimeOffViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.activeField = textView
        self.isUserEditingTextView = true
        textView.isScrollEnabled = true
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        commentsHeight = textView.contentSize.height + 46
        tableView.endUpdates()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.isUserEditingTextView = false
        if(textView.tag == Tag.userComments){
            timeOff?.details?.userComments = textView.text
        }
        textView.isScrollEnabled = false
    }
}

// MARK: UITextFieldDelegate

extension MultiDayTimeOffViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let rTextField = textField as? RTextField {
            let indexPath = rTextField.indexPath
            if let timeOffSection = TimeOffSection(rawValue: indexPath.section){
                switch timeOffSection {
                case .startDate:
                    if timeOff?.startDayEntry?.durationType == .partialDay {
                        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
                        return isValidNumber(num: result, withDecimalPlaces: 2)
                    }
                case .endDate:
                    if timeOff?.endDayEntry?.durationType == .partialDay {
                        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
                        return isValidNumber(num: result, withDecimalPlaces: 2)
                    }
                case .middleDate:
                    if let middleDayEntry = timeOff?.middleDayEntries[indexPath.row], middleDayEntry.durationType == .partialDay {
                        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
                        return isValidNumber(num: result, withDecimalPlaces: 2)
                    }
                case .udfs:
                    if let udf = timeOff?.allUDFs[indexPath.row], udf.type == .numeric {
                        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
                        return isValidNumber(num: result, withDecimalPlaces: udf.decimalPlaces)
                    }
                default:
                    print("Not a valid section")
                }
            }
        }
        return true
    }
    
    func isValidNumber(num:String, withDecimalPlaces decimalPlaces:Int) -> Bool{
        var regexExp = "^\\d+$" //only numbers
        if decimalPlaces > 0 {
            regexExp = String(format: "^(\\d+)?([.,]?\\d{0,%d})?$", decimalPlaces)
        }
        let regex = try? NSRegularExpression(pattern:regexExp, options: [])
        return regex?.firstMatch(in: num, options: [], range: NSRange(location: 0, length: num.characters.count)) != nil
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeField = textField
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        if let rTextField = textField as? RTextField{
            let indexPath = rTextField.indexPath
            if let timeOffSection = TimeOffSection(rawValue: indexPath.section){
                switch timeOffSection {
                case .startDate,.endDate,.middleDate:
                    if rTextField.tag == TextField.bookHours.rawValue {
                        updateValue(atIndexPath: indexPath, withValue:rTextField.text!)
                        updateBalance()
                    }
                case .udfs:
                    updateValue(atIndexPath: indexPath, withValue:rTextField.text!)
                default:
                    print("Section \(indexPath.section) : Not Handled")
                }
            }
        }else{
            self.activeField = nil
        }
    }
    
    
    private func updateValue(atIndexPath indexPath:IndexPath, withValue value:String){
        if let section = TimeOffSection(rawValue: indexPath.section) {
            switch section {
            case .startDate:
                if timeOff?.startDayEntry?.durationType == .partialDay {
                    timeOff?.startDayEntry?.bookingDurationDetails?.duration =  getDurationString(forValue: value)
                }
            case .endDate:
                if timeOff?.endDayEntry?.durationType == .partialDay {
                    timeOff?.endDayEntry?.bookingDurationDetails?.duration = getDurationString(forValue: value)
                }
            case .middleDate:
                if let middleDayEntry = timeOff?.middleDayEntries[indexPath.row], middleDayEntry.durationType == .partialDay {
                    middleDayEntry.bookingDurationDetails?.duration = getDurationString(forValue: value)
                }
            case .udfs:
                guard let udf = timeOff?.allUDFs[indexPath.row] else {
                    return
                }
                switch udf.type {
                case .numeric:
                    udf.value = value.replaceCommaWithDot()
                    let cell = tableView.cellForRow(at: indexPath) as? TimeOffUDFCell
                    cell?.disableEntry()
                case .text:
                    udf.value = value
                    let cell = tableView.cellForRow(at: indexPath) as? TimeOffUDFCell
                    cell?.disableEntry()
                default:
                    print("Unhandled Type")
                }

            default:
                print("Unhandled section")
            }

        }
    }
    
    func getDurationString(forValue value:String) -> String{
        var durationstr = ""
        if let duration = Double(value.replaceCommaWithDot()) {
            durationstr = String(format:Precision.twoDecimal, duration)
        }
        return durationstr
    }
}

// MARK: UIPickerViewDataSource

extension MultiDayTimeOffViewController : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allTimeOffTypes.count
    }
}

// MARK: UIPickerViewDelegate

extension MultiDayTimeOffViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let type = allTimeOffTypes[row]
        return type.title
    }
}

// MARK: TimeOffResubmitProtocol

extension MultiDayTimeOffViewController: TimeOffResubmitProtocol {
    func resubmitComments(_ comments: String!) {
        let details = timeOff?.details
        details?.resubmitComments = comments
        submitTimeOff()
    }
}

// MARK: ApprovalTablesHeaderViewDelegate

extension MultiDayTimeOffViewController: approvalTablesHeaderViewDelegate {
    public func handleButtonClick(forHeaderView senderTag: Int) {
        if self.parentDelegate is ApprovalsScrollViewController {
            self.parentDelegate?.handlePreviousNextButton!(fromApprovalsListforViewTag:self.currentViewTag, forbuttonTag: senderTag)
        }
    }
}

// MARK: ApprovalTablesFooterViewDelegate

extension MultiDayTimeOffViewController: approvalTablesFooterViewDelegate {
    func handleButtonClick(forFooterView senderTag: Int) {
        if self.parentDelegate is ApprovalsScrollViewController {
            self.parentDelegate?.handleApproveOrRejectAction!(withApproverComments: self.approverComments, andSenderTag: senderTag)
        }
    }
}


// MARK:- TimeSheet Model

extension MultiDayTimeOffViewController {
    
    func timeOffSubmittedAction()  {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION), object: nil)
        if self.screenMode == Int(EDIT_BOOKTIMEOFF) || self.screenMode == Int(VIEW_BOOKTIMEOFF) {
            if self.navigationFlow == NavigationFlow.TIMESHEET_PERIOD_NAVIGATION {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.receivedDataForSave), name: NSNotification.Name(rawValue:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION), object: nil)
                RepliconServiceManager.timesheetService().fetchTimeSheetSummaryData(forTimesheet: self.timeSheetURI, withDelegate: self)
            } else {
                appDelegate?.hideTransparentLoadingOverlay()
                self.navigationController?.popViewController(animated: true)
            }
        } else if self.screenMode == Int(ADD_BOOKTIMEOFF) {
            if self.navigationFlow == NavigationFlow.TIMESHEET_PERIOD_NAVIGATION {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.receivedDataForSave), name: NSNotification.Name(rawValue:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION), object: nil)
                RepliconServiceManager.timesheetService().fetchTimeSheetSummaryData(forTimesheet: self.timeSheetURI, withDelegate: self)
            } else {
                appDelegate?.hideTransparentLoadingOverlay()
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            appDelegate?.hideTransparentLoadingOverlay()
            if self.navigationFlow == NavigationFlow.TIMESHEET_PERIOD_NAVIGATION {
                self.navigationController?.popToViewController(self.parentDelegate as! UIViewController, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func receivedDataForSave() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION), object: nil)
        appDelegate?.hideTransparentLoadingOverlay()
        
        self.updateTimeSheets()
        
        if self.parentDelegate is TimesheetMainPageController {
            let timesheetMainPageController = self.parentDelegate as! TimesheetMainPageController
            timesheetMainPageController.hasUserChangedAnyValue = true
            timesheetMainPageController.reloadViewWithRefreshedDataAfterBookedTimeoffSave()
        }
        
        if self.screenMode == Int(ADD_BOOKTIMEOFF) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func handleDeleteAction () {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BOOKEDTIMEOFF_DELETED_NOTIFICATION), object: nil)
        appDelegate?.hideTransparentLoadingOverlay()
        
        self.updateTimeSheets()
        
        if self.screenMode == Int(ADD_BOOKTIMEOFF) {
            if self.navigationFlow == .TIMESHEET_PERIOD_NAVIGATION {
                let myDB = SQLiteDB.getInstance()
                myDB?.delete(fromTable: "Time_entries", where: "timesheetUri='\(String(describing: self.timeSheetURI))'", inDatabase: "")
                
                if isGen4Timesheet {
                    appDelegate?.showTransparentLoadingOverlay()
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION), object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.receivedTimesheetApprovalSummaryInfo(notification:)), name: NSNotification.Name(rawValue:TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION), object: nil)
                    RepliconServiceManager.timesheetService().sendRequestToGetTimesheetApprovalSummary(forTimesheetUri: self.timeSheetURI, delegate: self)
                } else {
                    appDelegate?.showTransparentLoadingOverlay()
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION), object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.receivedDataForSave), name: NSNotification.Name(rawValue:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION), object: nil)
                    RepliconServiceManager.timesheetService().fetchTimeSheetSummaryData(forTimesheet: self.timeSheetURI, withDelegate: self)
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            if self.navigationFlow == .TIMESHEET_PERIOD_NAVIGATION {
                if self.screenMode == Int(EDIT_BOOKTIMEOFF) || (self.screenMode == Int(VIEW_BOOKTIMEOFF) && self.canDelete()) {
                    let myDB = SQLiteDB.getInstance()
                    myDB?.delete(fromTable: "Time_entries", where: "timesheetUri= '\(String(describing: self.timeSheetURI))' AND rowUri = '\(String(describing: self.timeOffUri))' AND timeOffUri = '\(String(describing: self.timeOffUri))'", inDatabase: "")
                    
                    if isGen4Timesheet {
                        appDelegate?.showTransparentLoadingOverlay()
                        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION), object: nil)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedTimesheetApprovalSummaryInfo(notification:)), name: NSNotification.Name(rawValue:TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION), object: nil)
                        RepliconServiceManager.timesheetService().sendRequestToGetTimesheetApprovalSummary(forTimesheetUri: self.timeSheetURI, delegate: self)
                    } else {
                        appDelegate?.showTransparentLoadingOverlay()
                        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION), object: nil)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedDataForSave), name: NSNotification.Name(rawValue:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION), object: nil)
                        RepliconServiceManager.timesheetService().fetchTimeSheetSummaryData(forTimesheet: self.timeSheetURI, withDelegate: self)
                    }

                } else {
                    self.navigationController?.popToViewController(self.parentDelegate as! UIViewController, animated: true)
                }
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        if self.navigationFlow != .TIMESHEET_PERIOD_NAVIGATION {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func receivedTimesheetApprovalSummaryInfo(notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION), object: nil)
        appDelegate?.hideTransparentLoadingOverlay()
        
        if self.parentDelegate is TimesheetMainPageController {
            let timesheetMainPageController = self.parentDelegate as! TimesheetMainPageController
            timesheetMainPageController.hasUserChangedAnyValue = true
            timesheetMainPageController.reloadViewWithRefreshedDataAfterBookedTimeoffSave()
        }
        
        if self.screenMode == Int(ADD_BOOKTIMEOFF) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private var isGen4Timesheet: Bool {
        guard let timesheetFormat = self.timesheetFormat, (timesheetFormat.characters.count) > 0, timesheetFormat == GEN4_INOUT_TIMESHEET else {
            return false
        }
        return true
    }
    
    private func updateTimeSheets() {
        if self.navigationFlow == .TIMESHEET_PERIOD_NAVIGATION {
            if isGen4Timesheet {
                let updateWhereStr = "timesheetUri='\(String(describing: self.timeSheetURI))'"
                
                if let arrayDict = self.timesheetModel?.getTimeSheetInfoSheetIdentity(self.timeSheetURI), arrayDict.count > 0 {
                    let myDB = SQLiteDB.getInstance()
                    if let updateDataDict = arrayDict[0] as? NSMutableDictionary {
                        updateDataDict.removeObject(forKey: "timesheetFormat")
                        updateDataDict.setObject(self.timesheetFormat ?? "" , forKey: "timesheetFormat" as NSCopying)
                        myDB?.updateTable("Timesheets", data: updateDataDict as? [AnyHashable : Any], where: updateWhereStr, intoDatabase: "")
                    }
                }
            }
        }
    }
}

// MARK: Approver Comments Extension

extension MultiDayTimeOffViewController {
    
    func resetViewForApprovalsComment(isReset: Bool, comments:String) {
        self.tableView.isScrollEnabled = !isReset
        if isReset, let footerView = self.tableView.tableFooterView {
            self.tableView.scrollRectToVisible(footerView.frame, animated: true)
        }
        self.approverComments = comments
    }
}
