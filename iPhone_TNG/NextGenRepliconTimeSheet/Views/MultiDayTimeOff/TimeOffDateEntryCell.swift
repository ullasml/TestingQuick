//
//  TimeOffDateEntryCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 04/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

protocol DateCellProtocol: class {
    func timeOffDurationTypeSelected(cell:TimeOffDateEntryCell)
    func didSelectTime(at indexPath:IndexPath?, value:String)
}

enum TextField: Int{
    case unknown
    case scheduledDay
    case bookHours
    case startingAt
}

@objc class TimeOffDateEntryCell: UITableViewCell {
    
    @IBOutlet weak var dayTitle: UILabel!
    @IBOutlet weak var weekDayDesc: UILabel!
    @IBOutlet weak var partialDayView: UIView!
    @IBOutlet weak var leaveType: UIButton!
    @IBOutlet weak var bookDuration: RTextField!
    @IBOutlet weak var startOrEndTime: RTextField!
    @IBOutlet weak var scheduleDuration: RTextField!
    @IBOutlet var startTimeLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var scheduleDurationTitle: UILabel!
    @IBOutlet weak var bookDurationTitle: UILabel!
    @IBOutlet weak var startOrEndTimeTitle: UILabel!
    @IBOutlet weak var launchTime: UIButton!
    @IBOutlet var weekDayBottomSpaceToPartialView: NSLayoutConstraint!
    var indexPath : IndexPath?
    weak var delegate : DateCellProtocol?
    
    lazy var datePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(with timeOff:TimeOffEntry, measurementUri:String?, delegate:UIViewController, atIndexPath indexPath:IndexPath, isMultiDayTimeOff:Bool = true, editEnabled: Bool){
        self.indexPath = indexPath
        self.delegate = delegate as? DateCellProtocol
        
        
        self.scheduleDuration.delegate = delegate as? UITextFieldDelegate
        self.bookDuration.delegate = delegate as? UITextFieldDelegate
        self.startOrEndTime.delegate = delegate as? UITextFieldDelegate
        
        self.scheduleDuration.indexPath = indexPath
        self.bookDuration.indexPath = indexPath
        self.startOrEndTime.indexPath = indexPath
        
        self.scheduleDuration.tag = TextField.scheduledDay.rawValue
        self.bookDuration.tag = TextField.bookHours.rawValue
        self.startOrEndTime.tag = TextField.startingAt.rawValue
        
        self.bookDuration.inputAccessoryView = getToolBar(withTitle: nil, andTag: self.bookDuration.tag)
        self.startOrEndTime.inputView = datePickerView
        self.startOrEndTime.inputAccessoryView = getToolBar(withTitle: ConstStrings.selectTime, andTag: self.startOrEndTime.tag)

        let isHours = (measurementUri == TimeOffConstants.MeasurementUnit.hours)
        setupUI(withTimeOff: timeOff, isHoursUnit: isHours, indexPath: indexPath, isMultiDayTimeOff: isMultiDayTimeOff, isEditEnabled: editEnabled)

    }
    
    private func getToolBar(withTitle title:String?, andTag tag:Int) -> UIToolbar{
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: height/6, width: width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: width/2, y: height-20.0)
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(donePressed))
        doneButton.tag = tag
        let clearButton = UIBarButtonItem(title: ConstStrings.clear, style: .plain, target: self, action: #selector(clearPressed))
        clearButton.tag = tag
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        var barItems:[UIBarButtonItem] = []
        if let barTitle = title{
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width / 3, height: height))
            label.font = UIFont(name: "Helvetica Neue", size: 16)
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.black
            label.text = barTitle
            label.textAlignment = NSTextAlignment.center
            let textBtn = UIBarButtonItem(customView: label)
            barItems.append(contentsOf:[clearButton,flexSpace,textBtn,flexSpace,doneButton])
        }else{
            barItems.append(contentsOf:[clearButton,flexSpace,doneButton])
        }
        toolBar.setItems(barItems, animated: true)
        return toolBar
    }

    
    private func setupUI(withTimeOff timeOff:TimeOffEntry, isHoursUnit:Bool, indexPath:IndexPath, isMultiDayTimeOff:Bool, isEditEnabled: Bool){
        leaveType.setTitle(timeOff.bookingDurationDetails?.title?.localize(), for: .normal)
        
        self.scheduleDuration.placeholder = "0".formatNumberStringWithTwoDecimals()
        self.bookDuration.placeholder = "0".formatNumberStringWithTwoDecimals()
        self.startOrEndTime.placeholder = ConstStrings.select
        
        self.scheduleDuration.text = timeOff.scheduleDuration.formatNumberStringWithTwoDecimals()
        self.bookDuration.text = timeOff.bookingDurationDetails?.duration.formatNumberStringWithTwoDecimals()
        setupDateFormat(date: timeOff.date!)
        
        let durationTitle = (isHoursUnit ? ConstStrings.hours.capitalized : ConstStrings.days.capitalized)
        self.scheduleDurationTitle.text = ConstStrings.schedule + " " + durationTitle
        self.bookDurationTitle.text = ConstStrings.book + " " + durationTitle
        self.selectionStyle = .none
        
        let section = TimeOffSection(rawValue: indexPath.section)!
        
        
        if let schedule = Double(timeOff.scheduleDuration), schedule > 0 {
            self.contentView.backgroundColor = UIColor.white
        }else{
            self.contentView.backgroundColor = UIColor.groupTableViewBackground
        }
        
        if (section == .endDate && !isMultiDayTimeOff) || timeOff.durationType == .unknown{
            partialDayView.isHidden = true
            leaveType.isHidden = true
            weekDayBottomSpaceToPartialView.isActive = false
            
        }else{
            partialDayView.isHidden = false
            leaveType.isHidden = false
            weekDayBottomSpaceToPartialView.isActive = true
        }
        
        updateFieldWithOptions(isEnabled: false, forType: .scheduledDay)
        updateFieldWithOptions(isEnabled: isEditEnabled, forType: .startingAt)
        if(timeOff.durationType == .partialDay){
            updateFieldWithOptions(isEnabled: isEditEnabled, forType: .bookHours)
        }else{
            updateFieldWithOptions(isEnabled: false, forType: .bookHours)
        }
        
        if(section == .middleDate){
            weekDayDesc.textColor = UIColor(r: 135, g: 135, b: 135)
            arrowImage.isHidden = true
        }else {
            weekDayDesc.textColor = UIColor.black
            arrowImage.isHidden = false
        }
        
        
        if(section == .endDate){
            startOrEndTimeTitle.text = ConstStrings.returningAt
            self.startOrEndTime.text = timeOff.timeEnded

        }else{
            startOrEndTimeTitle.text = ConstStrings.startingAt
            self.startOrEndTime.text = timeOff.timeStarted

        }
        
        switch section {
        case .startDate:
            dayTitle.text = ConstStrings.startDate
            dayTitle.isHidden = false
            
        case .endDate:
            dayTitle.text = ConstStrings.endDate
            dayTitle.isHidden = false
            
        default:
            dayTitle.text = nil
            dayTitle.isHidden = true
            
        }
        
        switch  timeOff.durationType{
        case .halfDay, .quarterDay, .threeQuarterDay, .partialDay:
            startTimeLeadingSpace.isActive = true
            startOrEndTime.isHidden = false
            launchTime.isHidden = false
            startOrEndTimeTitle.isHidden = false
        default:
            startTimeLeadingSpace.isActive = false
            startOrEndTime.isHidden = true
            launchTime.isHidden = true
            startOrEndTimeTitle.isHidden = true
        }

    }
    
    
    private func updateFieldWithOptions(isEnabled:Bool, forType type: TextField){
        var color = UIColor(r: 85, g: 85, b: 85)
        if(!isEnabled){
            color = UIColor(r: 179, g: 179, b: 179)
        }
        
        switch type {
        case .scheduledDay:
            scheduleDurationTitle.textColor = color
            scheduleDuration.textColor = color
            scheduleDuration.borderColor =  color
            scheduleDuration.isUserInteractionEnabled = isEnabled
        case .bookHours:
            bookDurationTitle.textColor = color
            bookDuration.textColor = color
            bookDuration.borderColor =  color
            bookDuration.isUserInteractionEnabled = isEnabled
        case .startingAt:
            startOrEndTimeTitle.textColor = color
            startOrEndTime.textColor = color
            startOrEndTime.borderColor =  color
            startOrEndTime.isUserInteractionEnabled = isEnabled
        default:
            print("Unknown Field")
        }
    }
    
    
    private func setupDateFormat(date:Date){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.format3
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let weekDayDesc = dateFormatter.string(from: date)
        
        self.weekDayDesc.text = weekDayDesc
    }
    
    @IBAction func timeOffSelection(_ sender: UIButton) {
        self.delegate?.timeOffDurationTypeSelected(cell: self)
    }
    
    @objc private func donePressed(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case TextField.bookHours.rawValue:
            self.bookDuration.resignFirstResponder()
        case TextField.startingAt.rawValue:
            self.startOrEndTime.resignFirstResponder()
        default:
            print("Not Implemented")
        }
    }
    
    @objc private func clearPressed(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case TextField.bookHours.rawValue:
            self.bookDuration.text = ""
        case TextField.startingAt.rawValue:
            self.startOrEndTime.text = ""
        default:
            print("Not Implemented")
        }
        self.delegate?.didSelectTime(at: indexPath, value: "")
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = TimeFormat.format1
        let date = dateFormatter.string(from: sender.date)
        self.startOrEndTime.text = date
        self.delegate?.didSelectTime(at: indexPath, value: date)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let touchpoint:CGPoint = touch.location(in: self)
        if self.partialDayView.isHidden || !self.partialDayView.frame.contains(touchpoint)  {
            super.touchesBegan(touches, with: event)
        }
    }
    
    @IBAction func launchTimePicker(_ sender: Any) {
        
        startOrEndTime.becomeFirstResponder()
        
        if(startOrEndTime.text?.characters.count == 0){
            datePickerView.date = Date()
            let time = DateHelper.getStringFromDate(date: datePickerView.date, withFormat: TimeFormat.format1)
            startOrEndTime.text = time
            self.delegate?.didSelectTime(at: indexPath, value: time)
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  TimeFormat.format1
            if let date = dateFormatter.date(from: startOrEndTime.text!){
                datePickerView.date = date
            }
        }
    }

    
}
