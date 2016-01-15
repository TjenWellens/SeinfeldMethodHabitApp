//
//  DetailViewController.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 11/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit

class AddHabitViewController: UITableViewController {
    
    @IBOutlet weak var nameTxt: UITextField!

    @IBOutlet weak var datePicker: UIDatePicker!

    @IBAction func hideKeyboard(sender: AnyObject) {
        if let sender = sender as? UITextField {
            sender.resignFirstResponder()
        }
    }
    
    var habit: Habit?
    
    @IBAction func done() {
        guard let name = nameTxt.text where name.characters.count > 1 else {
            return
        }

        let reminder = datePicker.date
        habit = Habit(name: name, reminder: reminder, succeededDates: [])
        performSegueWithIdentifier("didAdd", sender: self)
    }
    
}
