//
//  ShiftScheduleHolidayCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Someshubhra Karmakar on 20/07/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

class ShiftScheduleHolidayCell: BaseShiftCell {
    
    @IBOutlet private var holidayDescriptionLabel:UILabel!
    @IBOutlet private var holidayTextLabel:UILabel!
    
    
    class func getCellIdentifier()->String {
        return ShiftCellIDs.holiday.rawValue
    }
    
    class func register(tableView:UITableView) {
        let nib = UINib(nibName: ShiftCellNibs.holiday.rawValue, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: self.getCellIdentifier())
    }
    

    
    override func update(shiftItemPresenter: ShiftItemPresenter) {
        super.update(shiftItemPresenter:shiftItemPresenter)
        
        // holidayDescriptionLabel
        holidayDescriptionLabel.text = shiftItemPresenter.holidayDescriptionText
        holidayDescriptionLabel.textColor = shiftItemPresenter.theme.shiftCellsTextColor()
        holidayDescriptionLabel.font = shiftItemPresenter.theme.shiftCellsBoldFont()
        
        
        // holidayTextLabel
        holidayTextLabel.text = ConstStrings.holiday
        holidayTextLabel.textColor = shiftItemPresenter.theme.shiftCellsTextColor()
        holidayTextLabel.font = shiftItemPresenter.theme.shiftCellsLightFont()
    }
    
}
