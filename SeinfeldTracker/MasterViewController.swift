//
//  MasterViewController.swift
//  SeinfeldTracker
//
//  Created by Tjen Wellens on 11/01/16.
//  Copyright © 2016 TjenWellens. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "showHabit":
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let habitMO = self.fetchedResultsController.objectAtIndexPath(indexPath) as! HabitMO
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! MonthDetailViewController
                
                controller.habit = habitMO
                controller.dataMgr = self
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
            addHabit(habit)
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("habitCell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            do {
                try context.save()
            } catch {
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let habitMO = self.fetchedResultsController.objectAtIndexPath(indexPath) as! HabitMO
        cell.textLabel!.text = habitMO.name
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Habit", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             abort()
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

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
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

protocol DataManager {
    func addHabit(habit: Habit)
//    func addDatesToHabit(habitMO: HabitMO, dates: [NSDate])
//    func addDateToHabit(habitMO: HabitMO, date: NSDate)
    func toggleDate(habitMO: HabitMO, date: NSDate)

}

extension MasterViewController:DataManager {
    func addHabit(habit: Habit) {
        let context = self.fetchedResultsController.managedObjectContext
        
        let habitMO = NSEntityDescription.insertNewObjectForEntityForName("Habit", inManagedObjectContext: context) as! HabitMO
        habitMO.name = habit.name
        habitMO.reminder = habit.reminder
        
        addDatesToHabit(habitMO, dates: habit.succeededDates)
        
        save()
    }
    
    func addDatesToHabit(habitMO: HabitMO, dates: [NSDate]) {
        let context = self.fetchedResultsController.managedObjectContext
        
        for date in dates {
            let dayDate = Month.stripTime(date)
            let succeededDateMO = NSEntityDescription.insertNewObjectForEntityForName("HabitSucceeded",
                inManagedObjectContext: context) as! HabitSucceededMO
            succeededDateMO.date = dayDate
            habitMO.addSucceededDate(succeededDateMO)
        }
    }
    
    func addDateToHabit(habitMO: HabitMO, date: NSDate){
        addDatesToHabit(habitMO, dates: [date])
    }
    
    func removeDateFromHabit(habitMO: HabitMO, date: NSDate) {
        habitMO.deleteDate(date)
    }
    
    func toggleDate(habitMO: HabitMO, date: NSDate) {
        print("toggleDate(habitMO: \(habitMO), date: \(date))")
        if habitMO.containsDate(date) {
            if let habitSucceededMO: HabitSucceededMO = habitMO.findDate(date){
                deleteObject(habitSucceededMO)
                habitMO.removeSucceededDate(habitSucceededMO)
            }
        } else {
            addDateToHabit(habitMO, date: date)
        }
        save()
    }
    
    func save() {
        let context = self.fetchedResultsController.managedObjectContext
        
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
    }
    
//    func saveDelete(){
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext:NSManagedObjectContext = appDelegate.managedObjectContext
//        
//        do {
//            try managedContext.save()
//        } catch {
//            fatalError("Failure to save context: \(error)")
//        }
    //    }
    
    func deleteObject(date: HabitSucceededMO){
        let context = self.fetchedResultsController.managedObjectContext
        context.deleteObject(date)
    }
    
//    func deleteDateFromHabit(habit: HabitMO, date: NSDate) {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext:NSManagedObjectContext = appDelegate.managedObjectContext
//        
//        managedContext.deleteObject(date)
//        
//        do {
//            try managedContext.save()
//        } catch {
//            fatalError("Failure to save context: \(error)")
//        }
//    }
    
    func deleteDateFromHabit(habit: HabitMO, date: NSDate) {
        
        //        var personRef: HabitMO = existingItem as! HabitMO
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext:NSManagedObjectContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName:"HabitSucceeded")
        let predicate = NSPredicate(format: "habit == %@", habit)
        fetchRequest.predicate = predicate
        
//        var error: NSError? = nil
        var locationArray: [AnyObject]
        
        do{
            try locationArray = managedContext.executeFetchRequest(fetchRequest)
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        var deleteThisObject:HabitSucceededMO? = nil
        
        for obj in locationArray {
            let dateMO = obj as! HabitSucceededMO
            if dateMO.date == date {
                deleteThisObject = dateMO
                break
            }
        }
        
        if let object = deleteThisObject {
            managedContext.deleteObject(object as NSManagedObject)
        }
        
//        managedContext.deleteObject(locationArray[rowIndex.row] as NSManagedObject)
//        locationArray.removeAtIndex(rowIndex.row)
//        tableview.deleteRowsAtIndexPaths([rowIndex], withRowAnimation: UITableViewRowAnimation.Fade)
        
//        if (!managedContext.save(&error)){
//            abort()
//        }
        
        do {
            try managedContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
    }
    
//    func deleteTrigger(habit: HabitMO){
//        
//        //        var personRef: HabitMO = existingItem as! HabitMO
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext:NSManagedObjectContext = appDelegate.managedObjectContext
//        
//        let fetchRequest = NSFetchRequest(entityName:"HabitSucceeded")
//        let predicate = NSPredicate(format: "Habit == %@", habit)
//        fetchRequest.predicate = predicate
//        
//        var error: NSError? = nil
//        var locationArray: [AnyObject]
//        
//        do{
//            try locationArray = managedContext.executeFetchRequest(fetchRequest)
//        } catch {
//            fatalError("Failure to save context: \(error)")
//        }
//        
//        managedContext.deleteObject(locationArray[rowIndex.row] as NSManagedObject)
//        locationArray.removeAtIndex(rowIndex.row)
//        tableview.deleteRowsAtIndexPaths([rowIndex], withRowAnimation: UITableViewRowAnimation.Fade)
//        
//        if (!managedContext.save(&error)){
//            abort()
//        }
//        
//    }
}

