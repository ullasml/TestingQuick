//
//  BaseShiftCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Someshubhra Karmakar on 20/07/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

enum ShiftCellIDs: String {
    case shiftSchedule = "ShiftScheduleCell"
    case holiday = "ShiftScheduleHolidayCell"
    case timeOff = "ShiftScheduleTimeOffCell"
    case shiftDetail = "ShiftDetailCell"
}

enum ShiftCellNibs: String {
    case shiftSchedule = "ShiftScheduleCell"
    case holiday = "ShiftScheduleHolidayCell"
    case timeOff = "ShiftScheduleTimeOffCell"
    case shiftDetail = "ShiftDetailCell"
}

class BaseShiftCell: UITableViewCell {
    private var cellBottomSeparatorLeadingSpaceConstraint:NSLayoutConstraint?
    private var cellBottomSeparator:UIView?
    
    private var cellTopSeparatorLeadingSpaceConstraint:NSLayoutConstraint?
    private var cellTopSeparator:UIView?
    
    
    var shiftCellBottomSeparatorLeadingSpace = 10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupTopSeparator()
        setupBottomSeparator()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupTopSeparator() {
        let cellSeparator = UIView()
        cellSeparator.backgroundColor = UIColor.lightGray
        self.contentView.addSubview(cellSeparator)
        cellSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        //leading
        let constraint = NSLayoutConstraint(item: cellSeparator, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0)
        self.contentView.addConstraint(constraint)
        cellTopSeparatorLeadingSpaceConstraint = constraint
 
        
        // top
        self.contentView.addConstraint(NSLayoutConstraint(item: cellSeparator, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute:.top, multiplier: 1, constant: 0))
        
        // height
        self.contentView.addConstraint(NSLayoutConstraint(item: cellSeparator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.5))
        
        //trailing
        self.contentView.addConstraint(NSLayoutConstraint(item: cellSeparator, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0))
        
        self.cellTopSeparator = cellSeparator
        self.cellTopSeparator?.isHidden = true
    }
    
    private func setupBottomSeparator() {
        let cellSeparator = UIView()
        cellSeparator.backgroundColor = UIColor.lightGray
        self.contentView.addSubview(cellSeparator)
        cellSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        //leading
        let constraint = NSLayoutConstraint(item: cellSeparator, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 0)
            cellBottomSeparatorLeadingSpaceConstraint = constraint
            self.contentView.addConstraint(constraint)
        
        
        
        // bottom
        self.contentView.addConstraint(NSLayoutConstraint(item: cellSeparator, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute:.bottom, multiplier: 1, constant: 0))
        
        // height
        self.contentView.addConstraint(NSLayoutConstraint(item: cellSeparator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.5))
        
        //trailing
        self.contentView.addConstraint(NSLayoutConstraint(item: cellSeparator, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0))
        
        cellBottomSeparator = cellSeparator
    }
    
   
    func update(shiftItemPresenter: ShiftItemPresenter)  {
        if let topSeparator = cellTopSeparator , let constraint = cellTopSeparatorLeadingSpaceConstraint {
            updateLeadingConstraint(leadingConstraint: constraint , leadingSpace:CGFloat(shiftCellBottomSeparatorLeadingSpace), separatorView:topSeparator, separator:shiftItemPresenter.topSeparator)
        }
        
        if let bottomSeparator = cellBottomSeparator, let constraint = cellBottomSeparatorLeadingSpaceConstraint {
            updateLeadingConstraint(leadingConstraint: constraint , leadingSpace:CGFloat(shiftCellBottomSeparatorLeadingSpace), separatorView:bottomSeparator, separator:shiftItemPresenter.bottomSeparator)
        }
    }
    
    private func updateLeadingConstraint(leadingConstraint: NSLayoutConstraint , leadingSpace:CGFloat, separatorView:UIView, separator:Separator) {
        switch separator {
        case .frontSpacing:
            leadingConstraint.constant = leadingSpace
            separatorView.isHidden = false
            
        case .full:
            leadingConstraint.constant = 0
            separatorView.isHidden = false
            
        case .none:
            separatorView.isHidden = true
            
        }
    }
}
