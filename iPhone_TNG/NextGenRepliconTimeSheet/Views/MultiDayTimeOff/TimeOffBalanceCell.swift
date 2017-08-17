//
//  TimeOffBalanceCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 05/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

class TimeOffBalanceCell: UITableViewCell {

    @IBOutlet weak var requestedTitle: UILabel!
    @IBOutlet weak var timeRemaining: UILabel!
    @IBOutlet weak var timeTaken: UILabel!
    @IBOutlet weak var balanceTitle: UILabel!
    @IBOutlet weak var spaceBetween: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(withBalanceInfo balanceInfo:TimeOffBalance?, andMeasurementUri measurementUri:String?){
        self.selectionStyle = .none
        self.requestedTitle.text = ConstStrings.requested + " :"
        self.balanceTitle.text = ConstStrings.balance + " :"
        
        if let remaining = balanceInfo?.timeRemaining, let taken = balanceInfo?.timeTaken {
            spaceBetween.constant = 11
            timeRemaining.text = getDurationString(forDuration: remaining, andMeasurementUri: measurementUri)
            timeTaken.text = getDurationString(forDuration: taken, andMeasurementUri: measurementUri)
            hide(requested: false, balance: false)
        }else if balanceInfo?.timeRemaining == nil  && balanceInfo?.timeTaken == nil {
            spaceBetween.constant = 11
            timeRemaining.text = ConstStrings.NA
            timeTaken.text = ConstStrings.NA
            hide(requested: false, balance: false)
        }else if balanceInfo?.timeRemaining == nil, let taken = balanceInfo?.timeTaken {
            spaceBetween.constant = 0
            timeRemaining.text = nil
            timeTaken.text = getDurationString(forDuration: taken, andMeasurementUri: measurementUri)
            balanceTitle.text = nil
            hide(requested: false, balance: true)
        }else if let remaining = balanceInfo?.timeRemaining{
            spaceBetween.constant = 0
            timeRemaining.text = getDurationString(forDuration: remaining, andMeasurementUri: measurementUri)
            timeTaken.text = nil
            requestedTitle.text = nil
            hide(requested: true, balance: false)
        }
        
    }
    
    private func getDurationString(forDuration duration:String, andMeasurementUri measurementUri:String?) -> String{
        return duration.formatNumberStringWithTwoDecimals() + " " + getDurationTypeString(forDuration: duration, andMeasurementUri: measurementUri)
    }
    
    private func getDurationTypeString(forDuration duration:String, andMeasurementUri measurementUri:String?) -> String{
        let isHours = (measurementUri == TimeOffConstants.MeasurementUnit.hours)
        return ((abs(Double(duration) ?? 0.0) > 1.0) ? (isHours ? ConstStrings.hours : ConstStrings.days) : (isHours ? ConstStrings.hour : ConstStrings.day))
    }
    
    private func hide(requested:Bool, balance:Bool){
        requestedTitle.isHidden = requested
        timeTaken.isHidden = requested
        balanceTitle.isHidden = balance
        timeRemaining.isHidden = balance
    }
}
