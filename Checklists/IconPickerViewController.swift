//
//  IconPickerViewController.swift
//  Checklists
//
//  Created by Jeffery Trotz on 3/5/19.
//  Class: CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import UIKit

// Protocol used to communicate with other objects in the app
protocol IconPickerViewControllerDelegate: class
{
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String)
}

class IconPickerViewController: UITableViewController
{
    // Delgate for communicating with other objects
    weak var delegate: IconPickerViewControllerDelegate?
    
    // Array of different icons supported by the app
    let icons = ["No Icon", "Appointments", "Birthdays", "Chores", "Drinks",
                 "Folder", "Groceries", "Inbox", "Photos", "Trips"]
    
    // Sets the icon for the checklist
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let delegate = delegate
        {
            let iconName = icons[indexPath.row]
            delegate.iconPicker(self, didPick: iconName)
        }
    }
    
    // Returns the number of icons in the icons array
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return icons.count
    }
    
    // Adds a title and image to a table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Get cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell", for: indexPath)
        
        // Get icon name
        let iconName = icons[indexPath.row]
        
        // Set cell title
        cell.textLabel!.text = iconName
        
        // Set icon
        cell.imageView!.image = UIImage(named: iconName)
        
        // Return the finished cell
        return cell
    }
}
