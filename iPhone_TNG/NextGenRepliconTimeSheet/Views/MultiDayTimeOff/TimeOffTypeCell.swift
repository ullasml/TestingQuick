//
//  TimeOffTypeCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 04/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

protocol TimeOffTypeProtocol: class {
    func timeOffTypeSelected(row:Int, cell:TimeOffTypeCell)
}

class TimeOffTypeCell: UITableViewCell {

    @IBOutlet weak var typetitle: UILabel!
    @IBOutlet weak var timeOffType: UILabel!
    @IBOutlet weak var pickerField: UITextField!
    let pickerView = UIPickerView()
    weak var timeOffTypeDelegate:TimeOffTypeProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(withType type:TimeOffTypeDetails?, delegate:UIViewController){
        
        typetitle.text = ConstStrings.type + " :"
        
        if let title = type?.title{
            self.timeOffType.text = title
        }else{
            self.timeOffType.text = ""
        }
        
        self.selectionStyle = .none
        timeOffTypeDelegate = delegate as? TimeOffTypeProtocol
        pickerView.delegate = delegate as? UIPickerViewDelegate
        pickerView.dataSource = delegate as? UIPickerViewDataSource
        pickerView.backgroundColor = UIColor.white
        pickerField.inputView = pickerView
        
        let toolBar = getToolBar()
        pickerField.inputAccessoryView = toolBar

    }
    
    private func getToolBar() -> UIToolbar{
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: height/6, width: width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: width/2, y: height-20.0)
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(TimeOffTypeCell.donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width / 3, height: height))
        label.font = UIFont(name: "Helvetica Neue", size: 16)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.text = ConstStrings.type
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexSpace,textBtn,flexSpace,doneButton], animated: true)
        return toolBar
    }
    
    @objc private func donePressed(_ sender: UIBarButtonItem) {
        pickerField.resignFirstResponder()
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        timeOffTypeDelegate?.timeOffTypeSelected(row: selectedRow, cell: self)
    }
    
    func launchPicker(with selectedRow:Int){
        pickerField.becomeFirstResponder()
        pickerView.selectRow(selectedRow, inComponent: 0, animated: true)
        
    }
}
