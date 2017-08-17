//
//  SelectableHeader.swift
//  TableView
//
//  Created by Prithiviraj Jayapal on 27/04/17.
//  Copyright © 2017 replicon. All rights reserved.
//

import UIKit
protocol TableViewHeaderDelegate: class {
    func didSelect(header: SelectableHeader, selected: Bool)
}

class SelectableHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var title: UIButton!
    weak var delegate : TableViewHeaderDelegate?

    @IBAction func selectedHeader(sender: AnyObject) {
        delegate?.didSelect(header: self, selected: true)
    }

}
