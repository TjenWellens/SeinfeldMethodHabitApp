//
//  MasterViewController.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 11/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    var dataController: DataController!
    
    lazy var fetchedHabits: NSFetchedResultsController = {
        return self.dataController.fetchedHabits(self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "showHabit":
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let habitMO = self.fetchedHabits.objectAtIndexPath(indexPath) as! HabitMO
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! MonthDetailViewController
                
                controller.habit = habitMO
                controller.dataMgr = dataController
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        case "showAdd":
            break
        default:
            fatalError("Unknown segue in \(self.dynamicType).")
        }
    }
    
    @IBAction func unwindFromAdd(segue: UIStoryboardSegue) {
        let addController = segue.sourceViewController as! AddHabitViewController
        if let habit = addController.habit {
            dataController.addHabit(habit)
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedHabits.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedHabits.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("habitCell", forIndexPath: indexPath)
        self._configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true // editable
    }

    // Delete row
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let habitMO = self.fetchedHabits.objectAtIndexPath(indexPath) as! HabitMO
            dataController.deleteHabit(habitMO)
        }
    }

    func _configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let habitMO = self.fetchedHabits.objectAtIndexPath(indexPath) as! HabitMO
        cell.textLabel!.text = "\(habitMO.name) (\(habitMO.streak ?? 0))"
    }
}


// Update when changes in data
extension MasterViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self._configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}

