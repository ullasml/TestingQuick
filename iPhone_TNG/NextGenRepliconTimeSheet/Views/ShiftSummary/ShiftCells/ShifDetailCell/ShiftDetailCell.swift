//
//  ShiftDetailCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Someshubhra Karmakar on 26/07/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

class ShiftDetailCell: BaseShiftCell {
    
    @IBOutlet private var descriptionLabel:UILabel!
    @IBOutlet private var detailedDescriptionLabel:UILabel!
    @IBOutlet private var shiftColorView:UIView!
    @IBOutlet private var verticalSpacingConstraintDescriptionDetailedDescription:NSLayoutConstraint!
    @IBOutlet private var shiftColorViewWidthConstraint:NSLayoutConstraint!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.shiftCellBottomSeparatorLeadingSpace = 25
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        detailedDescriptionLabel.sizeToFit()
    }

    class func getCellIdentifier()->String {
        return ShiftCellIDs.shiftDetail.rawValue
    }
    
    class func register(tableView:UITableView) {
        let nib = UINib(nibName: ShiftCellNibs.shiftDetail.rawValue, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: self.getCellIdentifier())
    }
    
    
    override func update(shiftItemPresenter: ShiftItemPresenter) {
        super.update(shiftItemPresenter:shiftItemPresenter)
        
        let theme = shiftItemPresenter.theme
        
        var decriptionText:String?
        var detailedDescriptionText:String?
        
        var descriptionLabelFont:UIFont?
        let descriptionLabelTextColor:UIColor? = theme.shiftCellsTextColor()
        
        var detailedDescriptionLabelFont:UIFont?
        let detailedDescriptionLabelTextColor:UIColor? = theme.shiftCellsTextColor()
        switch shiftItemPresenter.cellType {
        case .shiftDetail:
            decriptionText = shiftItemPresenter.shiftDescriptionText
            detailedDescriptionText = shiftItemPresenter.shiftDetailsDescriptionText
            
            descriptionLabelFont = theme.shiftCellsBoldFont()
            detailedDescriptionLabelFont = theme.shiftCellsLightFont()
            
        case .notes:
            decriptionText = ConstStrings.notesFromShiftManager
            detailedDescriptionText = shiftItemPresenter.notes
            
            descriptionLabelFont = theme.shiftCellsBoldSmallFont()
            detailedDescriptionLabelFont = theme.shiftCellsLightBigFont()
            
        case .udf:
            decriptionText = shiftItemPresenter.udfName
            detailedDescriptionText = shiftItemPresenter.udfValue
            
            descriptionLabelFont = theme.shiftCellsBoldSmallFont()
            detailedDescriptionLabelFont = theme.shiftCellsLightBigFont()
            
        case .noShifts:
            decriptionText = shiftItemPresenter.shiftDescriptionText
            detailedDescriptionText = nil
            
            descriptionLabelFont = theme.shiftCellsLightFont()
            
        default:
            decriptionText = nil
            detailedDescriptionText = nil
            
        }
                
        descriptionLabel.text = decriptionText
        descriptionLabel.font = descriptionLabelFont
        descriptionLabel.textColor = descriptionLabelTextColor
        
        // detailedDescriptionText
        if let _detailedDescriptionText = detailedDescriptionText, !_detailedDescriptionText.isEmpty {
            detailedDescriptionLabel.text = _detailedDescriptionText
            detailedDescriptionLabel.font = detailedDescriptionLabelFont
            detailedDescriptionLabel.textColor = detailedDescriptionLabelTextColor
            verticalSpacingConstraintDescriptionDetailedDescription.constant = 10
            
        }
        else {
            detailedDescriptionLabel.text = nil
            verticalSpacingConstraintDescriptionDetailedDescription.constant = 0
        }

        // Shift color
        if let shiftColor = shiftItemPresenter.shiftColorHex , let color = Util.color(withHex: shiftColor, alpha: 1) {
            shiftColorView.backgroundColor = color
            shiftColorViewWidthConstraint.constant = 15
        }
        else {
            shiftColorViewWidthConstraint.constant = 0
        }
    }
}
