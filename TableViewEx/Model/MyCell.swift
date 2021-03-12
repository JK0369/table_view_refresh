//
//  MyCell.swift
//  TableViewEx
//
//  Created by 김종권 on 2021/03/13.
//

import UIKit

class MyCell: UITableViewCell {

    @IBOutlet weak var lbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func bind(_ text: String) {
        lbl.text = text
    }
    
}
