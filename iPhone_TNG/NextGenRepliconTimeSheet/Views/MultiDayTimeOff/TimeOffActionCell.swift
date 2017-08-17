//
//  TimeOffActionCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 10/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

protocol TimeOffActionsProtocol: class {
    func deleteTimeOff(cell:TimeOffActionCell)
}

class TimeOffActionCell: UITableViewCell {

    @IBOutlet weak var deleteBtn: UIButton!
    weak var delegate : TimeOffActionsProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(delegate:TimeOffActionsProtocol){
        self.delegate = delegate
        self.deleteBtn .setTitle(ConstStrings.delete, for: .normal)
        self.selectionStyle = .none
    }
    
    @IBAction func postAction(_ sender: Any) {
        self.delegate?.deleteTimeOff(cell: self)
    }

}
