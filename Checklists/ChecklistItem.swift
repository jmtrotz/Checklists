//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Jeffery Trotz on 2/6/19.
//  Class: CS 330
//
//  Used to create objects shown in the check list
//
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//

import Foundation
import UserNotifications

class ChecklistItem: NSObject, Codable
{
    // Stores the name of the item
    var text = ""
    
    // Stores if the item has been checked off the list or not
    var checked = false
    
    // Stores when the item is due
    var dueDate = Date()
    
    // Stores if the user should be reminded of it or not
    var shouldRemind = false
    
    // Stores the ID of the item
    var itemID = -1
    
    // Removes pending notifications if an item is deleted
    deinit
    {
        removeNotification()
    }
    
    // Asks for a new item ID every time a new ChecklistItem object is created
    override init()
    {
        super.init()
        itemID = DataModel.nextChecklistItemID()
    }
    
    // Changes the "checked" property
    func toggleChecked()
    {
        checked = !checked
    }
    
    // Schedules a notification for the checklist item
    func scheduleNotification()
    {
        // Remove any pending notifications
        removeNotification()
        
        if shouldRemind && dueDate > Date()
        {
            // Put item's text in the notification message
            let content = UNMutableNotificationContent()
            content.title = "Reminder:"
            content.body = text
            content.sound = UNNotificationSound.default
            
            // Extract year, month, day,etc from dueDate
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            
            // Set properties to trigger notification at the specified date
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // Create notification request and add it
            let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request)
            
            // For debugging purpouses
            print("Scheduled \(request) for itemID: \(itemID)")
        }
    }
    
    // Removes scheduled notifications for an item
    func removeNotification()
    {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
    }
}
