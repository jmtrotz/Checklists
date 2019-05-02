//
//  DataModel.swift
//  Checklists
//
//  Created by Jeffery Trotz on 2/27/19.
//  Class: CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import Foundation

class DataModel
{
    // Checklist object array
    var lists = [Checklist]()
    
    var indexOfSelectedChecklist: Int
    {
        get
        {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Loads Checklist array from storage
    init()
    {
        loadChecklists()
        registerDefaults()
        handleFirstTime()
    }
    
    // Gets the current "ChecklistItemID" from UserDefaults, adds 1 to it,
    // and writes it back to UserDefaults
    class func nextChecklistItemID() -> Int
    {
        // Create UserDefaults object
        let userDefaults = UserDefaults.standard
        
        // Get the item ID from UserDefaults and add 1 to it
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        
        // Force UserDefaults to write changes to disk immediately
        userDefaults.synchronize()
        return itemID
    }
    
    // Checks if the app is being run for the first time or not
    func handleFirstTime()
    {
        // Get user defalults
        let userDefaults = UserDefaults.standard
        
        // Get boolean value of "FirstTime"
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        // If firstTime is true, then this is the first time the app is being run
        if firstTime
        {
            let checklist = Checklist(name: "List")
            lists.append(checklist)
            
            // Set index of the newly added Checklist object
            indexOfSelectedChecklist = 0
            
            // Set "FirstTime" to false so the code won't be executed again
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
    
    // Creates new Dictionary instance and adds the value -1 for the key "ChecklistIndex"
    func registerDefaults()
    {
        let dictionary: [String: Any] = ["ChecklistIndex": -1, "FirstTime": true]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    // Gets full path to the documents directory
    func documentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    // Appends path to the directory where data for this app
    // is stored to the path returned by the function above
    func dataFilePath() -> URL
    {
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    // Saves items in the checklist
    func saveChecklists()
    {
        // Create instance of data encoder
        let encoder = PropertyListEncoder()
        
        do
        {
            // Try to encode the Checklist array
            let data = try encoder.encode(lists)
            
            // Try to write the data to disk
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        }
            
            // Catch error and print message
        catch
        {
            print("Error encoding item array: \(error.localizedDescription)")
        }
    }
    
    // Loads items for the checklist when the app starts
    func loadChecklists()
    {
        // Get the file path
        let path = dataFilePath()
        
        // Try to load the file into an object
        if let data = try? Data(contentsOf: path)
        {
            // Create decoder instance
            let decoder = PropertyListDecoder()
            
            do
            {
                // Try to load the saved data into the Checklists array and sort it
                lists = try decoder.decode([Checklist].self, from: data)
                sortChecklists()
            }
                
            // Catch error and print message
            catch
            {
                print("Error decoding item array: \(error.localizedDescription)")
            }
        }
    }
    
    // Sorts the checklists and orders them alphabetically
    func sortChecklists()
    {
        // Performs the sort using a closure
        lists.sort(by:
        {
            list1, list2 in
            
            // Actual sorting code starts after "return"
            return list1.name.localizedStandardCompare(list2.name) == .orderedAscending
        })
    }
}
