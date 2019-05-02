//
//  AddItemViewController.swift
//  Checklists
//
//  Created by Jeffery Trotz on 2/12/19.
//  Class: CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import UIKit
import UserNotifications

protocol ItemDetailViewControllerDelegate: class
{
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController, UITextFieldDelegate
{
    // Outlet for the text entry box for a new item
    @IBOutlet weak var textField: UITextField!
    
    // Outlet for the done button in the nav bar
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    // Outlet for the "Remind Me" switch
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    
    // Outlet for the chosen date to be displayed
    @IBOutlet weak var dueDateLabel: UILabel!
    
    // Outlet for the table cell to be inserted
    @IBOutlet weak var datePickerCell: UITableViewCell!
    
    // Outlet for the date picker
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // Property to access functions in the protocol above
    weak var delegate: ItemDetailViewControllerDelegate?
    
    // Object from the checklist to be edited
    var itemToEdit: ChecklistItem?
    
    // Stores the item's completion date
    var dueDate = Date()
    
    // Keeps track if the date picker is visible or not
    var datePickerVisible = false
    
    // Cancels adding a new item
    @IBAction func cancel()
    {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    // Adds a new item
    @IBAction func done()
    {
        // If they're editing an item, update the model
        if let item = itemToEdit
        {
            // Set item properties
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = dueDate
            item.scheduleNotification()
            
            // Save the item
            delegate?.itemDetailViewController(self, didFinishEditing: item)
        }
            
        // If they're adding an item, add it to the model
        else
        {
            // Create new item object and set properties
            let item = ChecklistItem()
            item.text = textField.text!
            item.checked = false
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = dueDate
            item.scheduleNotification()
            
            // Save the item
            delegate?.itemDetailViewController(self, didFinishAdding: item)
        }
    }
    
    // Listens for date picker events
    @IBAction func dateChanged(_ datePicker: UIDatePicker)
    {
        // Get the chosen date and call the function to update the label
        dueDate = datePicker.date
        updateDueDateLabel()
    }
    
    // Enables/disables notifications if the reminder switch is toggled or not
    @IBAction func shouldRemindToggled(_ switchControl: UISwitch)
    {
        // Hide keyboard
        textField.resignFirstResponder()
        
        // If the switch is on, request notification access
        if switchControl.isOn
        {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound])
            {
                granted, error in
                // Do nothing...
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Disable large titles
        navigationItem.largeTitleDisplayMode = .never
        
        // If they select to edit an item rather than add,
        // change the title at the top of the screen and
        // set the properties for the switch/date
        if let item = itemToEdit
        {
            title = "Edit Item"
            textField.text = item.text
            doneBarButton.isEnabled = true
            shouldRemindSwitch.isOn = item.shouldRemind
            dueDate = item.dueDate
        }
        
        updateDueDateLabel()
    }
    
    // Sets focus on the text box when the view loads
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // Calls ShowDatePicker() when the due date row was tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Hide keyboard
        tableView.deselectRow(at: indexPath, animated: true)
        textField.resignFirstResponder()
        
        // Show/hide date picker if the proper cell was selected
        if indexPath.section == 1 && indexPath.row == 1
        {
            if !datePickerVisible
            {
                showDatePicker()
            }
            
            else
            {
                hideDatePicker()
            }
        }
    }
    
    // Gives the cells their own unique height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        // If the cell is the date picker, set the height to 217
        if indexPath.section == 1 && indexPath.row == 2
        {
            return 217
        }
        
        // If not, pass it through to the super class to set the height
        else
        {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    // Returns the number of rows in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // If the date picker is visible, then it thas 3 sections
        if section == 1 && datePickerVisible
        {
            return 3
        }
        
        // If not, then pass through to the origional data source
        else
        {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    // Required to inform the data source for the a static table view of the cell at row 2 section 1
    // (the one with the date picker) because that cell isn't part of the table view's design in the storyboard
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int
    {
        var newIndexPath = indexPath
        
        if indexPath.section == 1 && indexPath.row == 2
        {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    // Inserts the date picker cell into the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Checks if cellForRowAt is being called with the index path
        // for the date picker row If so, returns a new datePickerCell
        if indexPath.section == 1 && indexPath.row == 2
        {
            return datePickerCell
        }
        
        // For any index paths that are not the date picker cell, call
        // super to make sure other static cells still work as expected
        else
        {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    // Makes the row that launches the date picker tappable
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        if indexPath.section == 1 && indexPath.row == 1
        {
            return indexPath
        }
            
        else
        {
            return nil
        }
    }
    
    // Formats the date shown in the detail label
    func updateDueDateLabel()
    {
        // Create formatter object to convert the date to text
        let formatter = DateFormatter()
        
        // Set date/time styles
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        // Set the label text
        dueDateLabel.text = formatter.string(from: dueDate)
    }
    
    // Shows the date picker
    func showDatePicker()
    {
        // Update visibility status
        datePickerVisible = true
        
        // Insert new row below the due date cell
        let indexPathDatePicker = IndexPath(row: 2, section: 1)
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        
        // Pass proper date to UIDatePicker component and set the label to
        // the tint color when the date picker is active
        datePicker.setDate(dueDate, animated: false)
        dueDateLabel.textColor = dueDateLabel.tintColor
    }
    
    // Hides the date picker
    func hideDatePicker()
    {
        // If the date picker is visible, remove it and
        // set the label color back to the origional color
        if datePickerVisible
        {
            datePickerVisible = false
            let indexPathDatePicker = IndexPath(row: 2, section: 1)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
            dueDateLabel.textColor = UIColor.black
        }
    }
    
    // Hides the date picker if the text field becomes active
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        hideDatePicker()
    }
    
    // Enables/disables the done button depending on if the text field is empty or not
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // Figure out what the new text will be
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        // If newText is not empty then the done button is enabled, else it is disabled
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
}
