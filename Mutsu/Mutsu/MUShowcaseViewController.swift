//
//  MUShowcaseViewController.swift
//  Mutsu
//
//  Created by Seth on 2016-03-27.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class MUShowcaseViewController: NSViewController {
    
    /// The main window of this view controller
    var showcaseWindow : NSWindow = NSWindow();
    
    /// The visual effect view for the background of the window
    @IBOutlet var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The image view for setting the notification's icon
    @IBOutlet var iconImageView: NSImageView!
    
    /// The text field for setting the notification's title
    @IBOutlet var titleTextField: NSTextField!
    
    /// The text field for setting the notification's informative text
    @IBOutlet var informativeTextTextField: NSTextField!
    
    /// The text field for setting how long the notification should stay on screen
    @IBOutlet var stayTimeTextField: MUAlwaysActiveTextField!
    
    /// The popup button to choose what size of notification to use
    @IBOutlet var sizePopUpButton: NSPopUpButton!
    
    /// The image view for setting the image of the notification
    @IBOutlet var imageImageView: NSImageView!
    
    /// The checkbox to say if we want to use the light theme instead of dark
    @IBOutlet var useLightThemeCheckbox: NSButton!
    
    /// The checkbox to say if we should put the example actions in the notification
    @IBOutlet var exampleActionsCheckbox: NSButton!
    
    /// When we press the "Clear" button...
    @IBAction func clearButtonInteracted(sender: AnyObject) {
        // Clear all the notifications
        MUNotificationCenter().defaultCenter().clearNotifications();
    }
    
    /// When we press the "Show" button...
    @IBAction func showButtonInteracted(sender: AnyObject) {
        /// The actions to display in the notification
        var actions : [NSView] = [];
        
        // If we said to include the example actions...
        if(Bool(exampleActionsCheckbox.state)) {
            /// The first example button for the notification
            let ignoreButton : MUNotificationButton = MUNotificationButton(title: "Ignore", target: self, action: Selector("exampleAction"), dismissOnClick: true);
            
            /// The second example button for the notification
            let callButton : MUNotificationButton = MUNotificationButton(title: "Call", target: self, action: Selector("exampleAction"), dismissOnClick: true);
            
            // Set the actions to "Ignore" and "Call"
            actions = [ignoreButton, callButton];
        }
        
        /// The style for the notification
        var style : MUNotificationStyle = .Dark;
        
        // If we said to use the light style...
        if(Bool(useLightThemeCheckbox.state)) {
            // Set the style to light
            style = .Light;
        }
        
        /// The size for the notification
        var size : MUNotificationSize = .Banner;
        
        // if we selected image size...
        if(sizePopUpButton.selectedItem!.title == "Image") {
            // Set the size to Image
            size = .Image;
        }
        
        /// The notification so show
        let notification : MUNotification = MUNotification();
        
        // Set the notification's values
        notification.title = titleTextField.stringValue;
        notification.informativeText = informativeTextTextField.stringValue;
        notification.icon = iconImageView.image!;
        notification.image = imageImageView.image!;
        notification.actions = actions;
        notification.style = style;
        notification.size = size;
        notification.imageSizeView = nil;
        notification.stayTime = CGFloat(stayTimeTextField.floatValue);
        
        // Display the notification
        MUNotificationCenter().defaultCenter().deliverNotification(notification);
    }
    
    /// The example action for the notification's example actions to call
    func exampleAction() {
        // Print to the log
        print("Clicked action");
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        // Style the window
        styleWindow();
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the window
        showcaseWindow = NSApplication.sharedApplication().windows.last!;
        
        // Hide the titlebar background
        showcaseWindow.titlebarAppearsTransparent = true;
        
        // Hide the zoom button
        showcaseWindow.standardWindowButton(.ZoomButton)?.hidden = true;
        
        // Make the background more vibrant
        backgroundVisualEffectView.material = .Dark;
    }
}