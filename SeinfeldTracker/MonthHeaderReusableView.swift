//
//  MonthHeaderReusableView.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 13/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit

class MonthHeaderReusableView: UICollectionReusableView {
    @IBOutlet weak var monthLabel: UILabel!
    
    var callback: NavigateDate!
    
    @IBAction func navigate(sender: UIButton) {
        switch sender.titleLabel!.text! {
        case ">":
            callback.navigateDate(.Future)
        case "<":
            callback.navigateDate(.Past)
        default:
            fatalError("Unknown button text in \(self.dynamicType).")
        }
    }
}

protocol NavigateDate {
    func navigateDate(direction: DateDirection)
}

enum DateDirection {
    case Past
    case Future
}