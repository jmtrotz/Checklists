//
//  AddItemViewController.swift
//  Checklists
//
//  Created by Jeffery Trotz on 2/12/19.
//  Class: CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import UIKit

protocol AddItemViewControllerDelegate: class
{
    func addItemViewControllerDidCancel(_ controller: ItemDetailViewController)
    func addItemViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem)
    func addItemViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController, UITextFieldDelegate
{
    // Object from the checklist to be edited
    var itemToEdit: ChecklistItem?
    
    // Property to access functions in the protocol above
    weak var delegate: AddItemViewControllerDelegate?
    
    // Outlet for the text entry box for a new item    
    @IBOutlet weak var textField: UITextField!
    
    // Outlet for the done button in the nav bar
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Disable large titles
        navigationItem.largeTitleDisplayMode = .never
        
        if let item = itemToEdit
        {
            title = "Edit Titem"
            textField.text = item.text
            doneBarButton.isEnabled = true
        }
    }
    
    // Sets focus on the text box when the view loads
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // Disables ability to select a cell in the table view
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        return nil
    }
    
    // Cancels adding a new item
    @IBAction func cancel()
    {
        delegate?.addItemViewControllerDidCancel(self)
    }
    
    // Adds a new item
    @IBAction func done()
    {
        if let item = itemToEdit
        {
            item.text = textField.text!
            delegate?.addItemViewController(self, didFinishEditing: item)
        }
        
        else
        {
            let item = ChecklistItem()
            item.text = textField.text!
            item.checked = false
            delegate?.addItemViewController(self, didFinishAdding: item)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Figure out what the new text will be
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        // If newText is not empty then the done button is enabled, else it is disabled
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
}
