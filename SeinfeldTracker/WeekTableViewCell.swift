//
//  WeekTableViewCell.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 13/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    var days: [Bool]!
    
    @IBOutlet weak var column1: UILabel!
    @IBOutlet weak var column2: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}