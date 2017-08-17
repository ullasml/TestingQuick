//
//  SectionHeaderView.swift
//  NextGenRepliconTimeSheet
//
//  Created by Someshubhra Karmakar on 17/07/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

class ShiftSectionHeaderView: UIView,UIGestureRecognizerDelegate{
    
    var didSelectSectionHeader:(()->Void)?
    var bottomSeparatorLeadingSpace = 10
    @IBOutlet private var descriptionText:UILabel!
    @IBOutlet private var subDescriptionText:UILabel!
    @IBOutlet private var verticalSpacingConstraintBetweenDescriptionAndSubDescription:NSLayoutConstraint!
    @IBOutlet private var bottomSeparatorLeadingConstraint:NSLayoutConstraint!
    
    
    
    class func createView()->ShiftSectionHeaderView? {
        let nib = UINib(nibName: "ShiftSectionHeaderView", bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? ShiftSectionHeaderView else{
            return nil
        }
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
        
    }
    
    private func setup(){
        subDescriptionText.sizeToFit()
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap(recognizer:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        if let _didSelectSectionHeader = didSelectSectionHeader {
            _didSelectSectionHeader()
        }
    }
    
    func update(sectionPresenter: ShiftItemsSectionPresenter) {
        //Desc text
        descriptionText.text = sectionPresenter.shiftDayText
        descriptionText.font = sectionPresenter.theme.shiftCellsBoldFont()
        descriptionText.textColor = sectionPresenter.theme.shiftCellsTextColor()
        
        // subDescriptionText
        if let subText = sectionPresenter.subText {
            subDescriptionText.text = subText
            subDescriptionText.font = sectionPresenter.theme.shiftCellsLightFont()
            subDescriptionText.textColor = sectionPresenter.theme.shiftCellsTextColor()
            verticalSpacingConstraintBetweenDescriptionAndSubDescription.constant = 10
        }
        else {
            subDescriptionText.text = nil
            verticalSpacingConstraintBetweenDescriptionAndSubDescription.constant = 0
        }
        
        
        //bottomSeparator
        if(!sectionPresenter.showFullBottomSeparator) {
            bottomSeparatorLeadingConstraint.constant = CGFloat(bottomSeparatorLeadingSpace)
        }
        else {
            bottomSeparatorLeadingConstraint.constant = 0 
        }
        setNeedsLayout()
    }
}
