//
//  ViewController.swift
//  Checklists
//
//  Created by Jeffery Trotz on 2/5/19.
//  Class: CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate
{
    // Checklist object
    var checklist: Checklist!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Make the nav bar title small
        navigationItem.largeTitleDisplayMode = .never
        
        // Set the title for the screen
        title = checklist.name
    }
    
    // Disposes of any resources that can be recreated
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // Sets properties for the new view controller before it becomes visible
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "AddItem"
        {
            // Set destination view controller
            let controller = segue.destination as! ItemDetailViewController
            
            // Set delegate property
            controller.delegate = self
        }
            
        else if segue.identifier == "EditItem"
        {
            // Same as above
            let controller = segue.destination as! ItemDetailViewController
            controller.delegate = self
            
            // Pass the data to the main screen
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            {
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        }
    }
    
    // Toggles check mark and de-selects a row when the user taps on it
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let cell = tableView.cellForRow(at: indexPath)
        {
            let item = checklist.items[indexPath.row]
            item.toggleChecked()
            configureCheckmarks(for: cell, with: item)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Deletes an item from the checklist
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        // Remove item from the data model
        checklist.items.remove(at: indexPath.row)
        
        // Delete corresponding row from the table view
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // Tells the view how many rows to display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return checklist.items.count
    }
    
    // Adds text to the labels in the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        let item = checklist.items[indexPath.row]
        configureText(for: cell, with: item)
        configureCheckmarks(for: cell, with: item)
        return cell
    }
    
    // Cancels adding an item to the list
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    {
        navigationController?.popViewController(animated: true)
    }
    
    // Adds a new item to the list
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem)
    {
        // Get index of the next available spot
        let newRowIndex = checklist.items.count
        
        // Add the item to the array
        checklist.items.append(item)
        
        // Add the item to the table
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        // "Pops" the item detail view controller off the navigation stack
        navigationController?.popViewController(animated:true)
    }
    
    // Edits an existing item in the list
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem)
    {
        // Get the index of the item
        if let index = checklist.items.index(of: item)
        {
            let indexPath = IndexPath(row: index, section: 0)
            
            // Get the data from the table cell
            if let cell = tableView.cellForRow(at: indexPath)
            {
                // Update the data
                configureText(for: cell, with: item)
            }
        }
        
        // "Pops" the item detail view controller off the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Configures the text shown in the list
    func configureText(for cell: UITableViewCell, with item: ChecklistItem)
    {
        let label = cell.viewWithTag(1000) as! UILabel
        //label.text = item.text
        label.text = "\(item.itemID): \(item.text)"
    }
    
    // Configures the checkmarks shown in the list
    func configureCheckmarks(for cell: UITableViewCell, with item: ChecklistItem)
    {
        let label = cell.viewWithTag(1001) as! UILabel
        label.textColor = view.tintColor
        
        if item.checked
        {
            label.text = "√"
        }
            
        else
        {
            label.text = ""
        }
    }
}
