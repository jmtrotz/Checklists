//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Jeffery Trotz on 2/25/19.
//  Class: CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate
{
    // DataModel object for accessing app data storage methods
    var dataModel: DataModel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Make the nav bar title large
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    // Calls this method after the view becomes visible
    override func viewDidAppear(_ animated: Bool)
    {
        // Calls this method when the view controller becomes visible
        super.viewDidAppear(animated)
        
        // Set itself as the delegate for the navigation controller
        navigationController?.delegate = self
        
        let index = dataModel.indexOfSelectedChecklist
        
        // Check if index is valid. Should be between 0 and the number of checklists in the data model
        if index >= 0 && index < dataModel.lists.count
        {
            let checklist = dataModel.lists[index]
            performSegue(withIdentifier: "ShowChecklist", sender: checklist)
        }
    }
    
    
    // Calls this method before the view becomes visible
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Reload the table view
        tableView.reloadData()
    }
    
    // Disposes of any resources that can be recreated
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // Sets properties for the new view controller before it becomes visible
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowChecklist"
        {
            // Set destination view controller
            let controller = segue.destination as! ChecklistViewController
            
            // Set sender
            controller.checklist = sender as! Checklist
        }
            
        else if segue.identifier == "AddChecklist"
        {
            // Set destination view controller
            let controller = segue.destination as! ListDetailViewController
            
            // Set delegate
            controller.delegate = self
        }
    }
    
    // Returns the number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataModel.lists.count
    }
    
    // Fills in cells for the table rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell
    {
        // Get cell
        let cell = makeCell(for: tableView)
        
        // Update cell information
        let checklist = dataModel.lists[indexPath.row]
        
        // Get the number of unchecked items
        let count = checklist.countUncheckedItems()
        
        // Set cell info
        cell.textLabel!.text = checklist.name
        cell.accessoryType = .detailDisclosureButton
        
        // If the list is empty, display "No Items"
        if checklist.items.count == 0
        {
            cell.detailTextLabel!.text = "(No Items)"
        }
            
            // If the list is not empty, display the number of remaining items to be
            // completed in the list. If there are none, then it displays "All Done"
        else
        {
            cell.detailTextLabel!.text = count == 0 ? "All Done" : "\(count) Remaining"
        }
        
        // Set the icon for the checklist
        cell.imageView!.image = UIImage(named: checklist.iconName)
        
        // Return the cell
        return cell
    }
    
    // Transfers to the detailed checklist screen when the user selects a table row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        dataModel.indexOfSelectedChecklist = indexPath.row
        
        let checklist = dataModel.lists[indexPath.row]
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
    
    // Allows the user to delete checklists from the table
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        dataModel.lists.remove(at: indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // Creates view controller object for the add/edit checklist screen
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        // Create controller object
        let controller = storyboard!.instantiateViewController(withIdentifier: "ListDetailViewController") as! ListDetailViewController
        controller.delegate = self
        
        // Get checklist
        let checklist = dataModel.lists[indexPath.row]
        controller.checklistToEdit = checklist
        
        // "Pops" view controller off of the navigation stack
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // Called when the navigation controller shows a new screen. If the back
    // button is pressed, the new view controller is AllListsViewController itself
    // and "ChecklistIndex" value in UserDefaults is -1, meaning nothing is selected
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool)
    {
        // Was the back button tapped?
        // 3 equal sings means checking if 2 variables refer to the same object
        if viewController === self
        {
            dataModel.indexOfSelectedChecklist = -1
        }
    }
    
    // "Pops" list detail view off the navigation stack
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    {
        navigationController?.popViewController(animated: true)
    }
    
    
    // Returns to the main screen when the user finishes adding a checklist
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist)
    {
        // Add new checklist to the array
        dataModel.lists.append(checklist)
        
        // Sort the checklists and reload data
        dataModel.sortChecklists()
        tableView.reloadData()
        
        // "Pops" list detail view off the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Returns to the main screen when the user finishes editing a checklist
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist)
    {
        // Sort the checklists and reload data
        dataModel.sortChecklists()
        tableView.reloadData()
        
        // "Pops" list detail view off the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Creates a new cell in the table view
    func makeCell(for tableView: UITableView) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        {
            return cell
        }
            
        else
        {
            return UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
    }
}
