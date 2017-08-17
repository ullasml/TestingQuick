//
//  ShiftScheduleCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Someshubhra Karmakar on 17/07/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

class ShiftScheduleCell: BaseShiftCell {
    @IBOutlet private var  descriptionLabel:UILabel!
    @IBOutlet private var  cellIconImageView:UIImageView!
    @IBOutlet private var  shiftColorView:UIView!
    
    class func getCellIdentifier()->String {
        return ShiftCellIDs.shiftSchedule.rawValue
    }
    
    class func register(tableView:UITableView) {
        let nib = UINib(nibName: ShiftCellNibs.shiftSchedule.rawValue, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: self.getCellIdentifier())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func update(shiftItemPresenter: ShiftItemPresenter) {
        super.update(shiftItemPresenter:shiftItemPresenter)
        
        descriptionLabel.text = shiftItemPresenter.shiftDescriptionText
        descriptionLabel.textColor = shiftItemPresenter.theme.shiftCellsTextColor()
        descriptionLabel.font = shiftItemPresenter.theme.shiftCellsLightFont()
        
        //Shift Color
        if let shiftColor = shiftItemPresenter.shiftColorHex , let color = Util.color(withHex: shiftColor, alpha: 1) {
            shiftColorView.backgroundColor = color
            self.contentView.bringSubview(toFront: shiftColorView)
        }
	else {
            shiftColorView.backgroundColor = .clear
        }
        if shiftItemPresenter.notes != nil {
            cellIconImageView.image =  UIImage(named: "CommentsActive")
        }
        else {
            cellIconImageView.image =  nil
        }
    }
}

