//
//  Checklist.swift
//  Checklists
//
//  Created by Jeffery Trotz on 2/25/19.
//  Class: CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import UIKit

class Checklist: NSObject, Codable
{
    // Name of the Checklist item
    var name = ""
    
    // Array to hold ChecklistItem objects
    var items = [ChecklistItem]()
    
    // Name of the icon for the list
    var iconName = "No Icon"
    
    // Initializes the Checklist object when it is created
    init(name: String, iconName: String = "No Icon")
    {		
        self.name = name
        self.iconName = iconName
        super.init()
    }
    
    // Returns the number of unchecked items
    func countUncheckedItems() -> Int
    {
        // Looks at each item in an array and runs the code in the braces
        return items.reduce(0)
        {
            // Starts at 0, then increments by 1 or 0 depending
            // on if the item is checked or not
            count, item in count + (item.checked ? 0 : 1)
        }
    }
}
