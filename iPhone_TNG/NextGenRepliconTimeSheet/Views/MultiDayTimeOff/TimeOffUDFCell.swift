//
//  TimeOffUDFCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 09/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

protocol DateUDFProtocol: class {
    func dateSelected(atCell cell:TimeOffUDFCell, withValue value:String)
}

class TimeOffUDFCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueField: RTextField!
    weak var delegate:DateUDFProtocol?
    var indexPath : IndexPath?
    lazy var datePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private var allowEntry = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(atIndexPath indexPath:IndexPath, udf:TimeOffUDF, isEditable:Bool, andDelegate delegate:UIViewController){
        
        self.indexPath = indexPath
        self.title.text = udf.name
        self.valueLabel.text = getDisplayText(forType: udf.type, value: udf.value, decimalPlace: udf.decimalPlaces, isEditable: isEditable)
        self.valueField.delegate = delegate as? UITextFieldDelegate
        self.valueField.indexPath = indexPath
        self.delegate = delegate as? DateUDFProtocol
        
        switch udf.type {
        case .text:
            valueField.keyboardType = .default
            allowEntry = true
            valueField.text = udf.value
            valueField.inputView = nil
        case .numeric:
            valueField.keyboardType = .decimalPad
            allowEntry = true
            valueField.text = udf.value.characters.count == 0 ? udf.value : udf.value.formatNumberString(withDecimalPlaces: udf.decimalPlaces)
            valueField.inputView = nil
            valueField.inputAccessoryView = getToolBar(withTitle: nil, andTag: indexPath.row)
        case .date:
            valueField.isHidden = true
            valueField.inputView = datePickerView
            if let date = DateHelper.getDateFrom(dateString: udf.value, withFormat: DateFormat.format1) {
                datePickerView.date = date
            }
            valueField.inputAccessoryView = getToolBar(withTitle: ConstStrings.selectDate, andTag: indexPath.row)
            allowEntry = false
        default:
            valueField.keyboardType = .default
            allowEntry = false
            self.valueField.text = udf.value
            valueField.inputView = nil
        }
    }
    
    func enableEntry(){
        if(allowEntry && !valueField.isFirstResponder){
            valueLabel.isHidden = true
            valueField.isHidden = false
            valueField.becomeFirstResponder()
        }
    }
    
    func disableEntry(){
        if(allowEntry){
            valueLabel.text = valueField.text
            valueLabel.isHidden = false
            valueField.isHidden = true
        }
    }
    
    private func getDisplayText(forType type:TimeOffUDFType, value:String, decimalPlace:Int, isEditable:Bool) -> String{
        if(value.characters.count == 0){
            if(isEditable){
                switch type {
                case .text, .numeric:
                    return ConstStrings.add
                case .date,.dropdown:
                    return ConstStrings.select
                default:
                    return ConstStrings.add
                }
            }
            return ConstStrings.none
        }else{
            if type == .numeric{
                return value.formatNumberString(withDecimalPlaces: decimalPlace)
            }
            return value
        }
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
    
    @objc private func donePressed(_ sender: UIBarButtonItem) {
        valueField.resignFirstResponder()
    }
    
    @objc private func clearPressed(_ sender: UIBarButtonItem) {
        valueLabel.text = ""
        valueField.text = ""
        self.delegate?.dateSelected(atCell: self, withValue: "")
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.format1
        let date = dateFormatter.string(from: sender.date)
        valueLabel.text = date
        self.delegate?.dateSelected(atCell: self, withValue: date)
    }
    
    func launchDatePicker(){
        valueField.becomeFirstResponder()
        if(valueLabel.text == ConstStrings.select || valueLabel.text?.characters.count == 0){
            datePickerView.date = Date()
            let date = DateHelper.getStringFromDate(date: datePickerView.date, withFormat: DateFormat.format1)
            valueLabel.text = date
            self.delegate?.dateSelected(atCell: self, withValue: date)
        }
    }

}
