//
//  UITableView+Extensions.swift
//  NextGenRepliconTimeSheet
//
//  Created by Ravikumar Duvvuri on 02/06/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

import Foundation

extension UITableView {
    //set the tableHeaderView so that the required height can be determined, update the header's frame and set it again
    func setAndLayoutTableHeaderView(header: UIView) {
        self.tableHeaderView = header
        header.setNeedsLayout()
        header.layoutIfNeeded()
        let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = header.frame
        frame.size.height = height
        header.frame = frame
        self.tableHeaderView = header
    }
}
