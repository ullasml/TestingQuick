//
//  TimeOffStatusHeader.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 10/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

protocol TimeOffStatusProtocol: class {
    func didSelectStatusHeader()
}

class TimeOffStatusHeader: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    weak var delegate : TimeOffStatusProtocol?

    
    @IBAction func selection(_ sender: Any) {
        self.delegate?.didSelectStatusHeader()
    }
    
    func configure(withStatus status:TimeOffStatusDetails?, theme:Theme, delegate:TimeOffStatusProtocol){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = delegate
        if let statusDetails = status {
            switch (statusDetails.uri) {
            case TimeOffConstants.ApprovalStatus.waiting:
                self.backgroundColor = theme.timeOffStatusWaitingForApprovalColor()
            case TimeOffConstants.ApprovalStatus.approved:
                self.backgroundColor = theme.timeOffStatusApprovedColor()
            case TimeOffConstants.ApprovalStatus.rejected:
                self.backgroundColor = theme.timeOffStatusRejectedColor()
            default:
                self.backgroundColor = theme.approvalStatusNotSubmittedColor()
            }
        }
        
        if let statusTitle = status?.title {
            titleLabel.text = statusTitle.localize()
        }else{
            titleLabel.text = ""
        }
    }
    class func instanceFromNib() -> TimeOffStatusHeader {
        return UINib(nibName: String(describing: TimeOffStatusHeader.self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TimeOffStatusHeader
    }
}
