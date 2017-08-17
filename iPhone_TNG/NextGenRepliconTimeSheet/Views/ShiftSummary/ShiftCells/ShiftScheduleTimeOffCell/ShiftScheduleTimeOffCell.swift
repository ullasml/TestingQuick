//
//  ShiftScheduleTimeOffCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Someshubhra Karmakar on 17/07/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit


class ShiftScheduleTimeOffCell: BaseShiftCell {
    
    @IBOutlet private var descriptionLabel:UILabel!
    @IBOutlet private var statusLabel:UILabel!
    @IBOutlet private var statusImageView:UIImageView!
    @IBOutlet private var cellIconImageView:UIImageView!
    @IBOutlet private var statusView:UIView!
    
    class func getCellIdentifier()->String {
        return ShiftCellIDs.timeOff.rawValue
    }
    
    class func register(tableView:UITableView) {
        let nib = UINib(nibName: ShiftCellNibs.timeOff.rawValue, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: self.getCellIdentifier())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusView.layer.cornerRadius = 5.0;
        statusView.layer.borderWidth = 3.0;
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        //actual height is known at the time of layout
        self.statusView.layer.cornerRadius = self.statusView.bounds.size.height / 2
    }
    
    
    override func update(shiftItemPresenter: ShiftItemPresenter) {
        super.update(shiftItemPresenter:shiftItemPresenter)
        
        // DescriptionText
        descriptionLabel.text = shiftItemPresenter.timeOffDescText
        descriptionLabel.textColor = shiftItemPresenter.theme.shiftCellsTextColor()
        descriptionLabel.font = shiftItemPresenter.theme.shiftCellsLightFont()
        
        // StatusView

        let statusInfo = shiftItemPresenter.timeOffStatusColorAndText()
        statusLabel.text =  statusInfo.statusText

        
        statusView.layer.borderColor = statusInfo.statusColor?.cgColor;
        statusLabel.textColor = statusInfo.statusColor;
        statusLabel.font = shiftItemPresenter.theme.shiftCellStatusFont()
        
        let image = UIImage(named: statusInfo.statusImageName);
        statusImageView.image = image
    }
    
}
