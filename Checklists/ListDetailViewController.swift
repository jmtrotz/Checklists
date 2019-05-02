//
//  ListDetailViewController.swift
//  Checklists
//
//  Created by Jeffery Trotz on 2/26/19.
// Class: CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import Foundation
import UIKit

// Protocol used to communicate with other objects in the app
protocol ListDetailViewControllerDelegate: class
{
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist)
}

class ListDetailViewController: UITableViewController, UITextFieldDelegate, IconPickerViewControllerDelegate
{
    // Outlet for the text entry box for a new item   
    @IBOutlet weak var textField: UITextField!
    
    // Outlet for the done button in the nav bar
    @IBOutlet var doneBarButton: UIBarButtonItem!
    
    // Outlet for choosing an image
    @IBOutlet weak var iconImageView: UIImageView!
    
    // Property to access functions in the protocol above
    weak var delegate: ListDetailViewControllerDelegate?
    
    // Checklist being edited
    var checklistToEdit: Checklist?
    
    // Temporary variable for the icon name to be used when no
    // checklist objects exist yet (i.e. when adding a new checklist)
    var iconName = "Folder"
    
    // Cancels adding a new item
    @IBAction func cancel()
    {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    // Adds a new item
    @IBAction func done()
    {
        // If they're editing a checklist, change the the model
        if let checklist = checklistToEdit
        {
            checklist.name = textField.text!
            checklist.iconName = iconName
            delegate?.listDetailViewController(self, didFinishEditing: checklist)
        }
            
        // If they're adding a checklist, add it to the model
        else
        {
            let checklist = Checklist(name: textField.text!, iconName: iconName)
            delegate?.listDetailViewController(self, didFinishAdding: checklist)
        }
    }
    
    // Executed after the view loads
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Disable large titles
        navigationItem.largeTitleDisplayMode = .never
        
        // If they select to edit an item rather than add,
        // change the title at the top of the screen
        if let checklist = checklistToEdit
        {
            title = "Edit Checklist"
            textField.text = checklist.name
            doneBarButton.isEnabled = true
            iconName = checklist.iconName
        }
        
        // Set the icon for the checklist
        iconImageView.image = UIImage(named: iconName)
    }
    
    // Sets focus on the keyboard when the view loads
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // Sets properties for the new view before it becomes visible
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "PickIcon"
        {
            // Set the destination view controlelr
            let controller = segue.destination as! IconPickerViewController
            
            // Set delegate property
            controller.delegate = self
        }
    }
    
    // Returns the index path for the selected cell
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        return indexPath.section == 1 ? indexPath : nil
    }
    
    // Sets the icon for the checklist
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String)
    {
        // Set the icon name
        self.iconName = iconName
        
        // Update the image view with the new image
        iconImageView.image = UIImage(named: iconName)
        
        // "Pops" the icon picker off the navigation stack
        navigationController?.popViewController(animated: true)
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
