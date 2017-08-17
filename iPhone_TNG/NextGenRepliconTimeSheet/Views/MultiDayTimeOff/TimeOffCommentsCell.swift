//
//  TimeOffCommentsCell.swift
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 05/05/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import UIKit

class TimeOffCommentsCell: UITableViewCell {

    @IBOutlet weak var commentsTitle: UILabel!
    @IBOutlet weak var userComments: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(withComments comments:String?, delegate:UITextViewDelegate){
        
        self.commentsTitle.text = ConstStrings.comments
        self.userComments.delegate = delegate
        self.userComments.tag = Tag.userComments
        self.userComments.text = comments
    }
    
}
