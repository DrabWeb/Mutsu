//
//  MUNotificationCenter.swift
//  Mutsu
//
//  Created by Seth on 2016-03-28.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

/// The manager for sending notifications with Mutsu
class MUNotificationCenter: NSObject {
    /// The vertical padding between notifications
    let notificationTopPadding : CGFloat = 10.0;
    
    /// The current notifications that are on screen
    var currentNotifications : [MUNotificationViewController] = [];
    
    /// The regular width of any notification(Default 324)
    let notificationWidth : CGFloat = 324;
    
    /// The speed of the animation for the notification closing(Default 0.25)
    let notificationCloseSpeed : CGFloat = 0.25;
    
    /// The speed of the animation for the banner notification appearing(Default 0.5)
    let bannerAnimateSpeed : CGFloat = 0.5;
    
    /// The speed of the animation for the image notification appearing(Default 0.75)
    let imageAnimateSpeed : CGFloat = 0.75;
    
    /// The height of the bottom bar(Default 39)
    let bottomBarHeight : CGFloat = 39;
    
    /// The regular height of the banner notification(Default 63)
    let bannerHeight : CGFloat = 63;
    
    /// The regular height of the image notification(Default 300)
    let imageHeight : CGFloat = 300;
    
    /// Delivers the given notification, returns the displayed MUNotificationViewController
    func deliverNotification(notification : MUNotification) -> MUNotificationViewController {
        // Print to the log that we are delivering a notification
        print("Delivering notification...");
        
        /// The window controller for notificationViewController
        var notificationWindowController : NSWindowController = NSWindowController();
        
        /// The notification view controller for displaying the given notification
        var notificationViewController : MUNotificationViewController = MUNotificationViewController();
        
        // Get a notification view controller
        // Get the window controller
        notificationWindowController = NSStoryboard(name: "MUNotificationView", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("MUNotificationWindowController") as! NSWindowController;
        
        // Load the window
        notificationWindowController.loadWindow();
        
        // Set the notification view controller
        notificationViewController = notificationWindowController.contentViewController as! MUNotificationViewController;
        
        // Add the notification to the screen
        addNotificationToScreen(notificationViewController);
        
        // Show the notification
        notificationViewController.showNotification(notification);
        
        // Return the notification view controller
        return notificationViewController;
    }
    
    /// Clears all the on screen notifications
    func clearNotifications() {
        // For every notification in currentNotifications...
        for(_, currentNotification) in currentNotifications.enumerate() {
            // Tell the current notification not to perform the close action
            currentNotification.performCloseAction = false;
            
            // Dismiss the current notification
            currentNotification.dismiss();
        }
    }
    
    /// Called by the notification view controllers to say that a notification has been dismissed and to remove it from currentNotifications
    func removeNotificationViewController(notification : NSNotification) {
        // Get the notification view controller
        /// The view controller to remove from currentNotifications
        let notificationViewController : MUNotificationViewController = notification.object as! MUNotificationViewController;
        
        // Remove the notification
        removeNotificationFromScreen(notificationViewController);
    }
    
    /// Adds the given MUNotificationViewController to the onscreen notifications, while properly settings it's frame
    func addNotificationToScreen(notificationViewController : MUNotificationViewController) {
        /// The combined height and padding of all the notifications already in the on screen notifications
        var aboveNotificationsHeight : CGFloat = 0.0;
        
        // For every item in the currentNotifications array...
        for(_, currentViewController) in currentNotifications.enumerate() {
            // Add the current notifications height plus the vertical notification padding to the above notifications height
            aboveNotificationsHeight += currentViewController.window.originalHeight + notificationTopPadding;
        }
        
        // Move the notification below all the others
        notificationViewController.window.setFrameOrigin(NSPoint(x: notificationViewController.window.frame.origin.x, y: notificationViewController.window.frame.origin.y - aboveNotificationsHeight));
        
        // Add the notification view controller to the onscreen notifications array
        currentNotifications.append(notificationViewController);
    }
    
    /// Removes the given MUNotificationViewController from the onscreen notifications
    func removeNotificationFromScreen(notificationViewController : MUNotificationViewController) {
        /// The currentNotifications array as an NSMutableArray
        let currentNotificationsMutableArray : NSMutableArray = NSMutableArray(array: currentNotifications);
        
        /// The index of the view controller to remove in the array
        let notificationViewControllerIndex : Int = currentNotificationsMutableArray.indexOfObject(notificationViewController) - 1;
        
        /// All the items after notificationViewController
        var notificationViewControllersAfter : [MUNotificationViewController] = [];
        
        // For every item in the currentNotifications array...
        for(currentIndex, currentViewController) in currentNotifications.enumerate() {
            // If the current index is above the notification VC's index...
            if(currentIndex > notificationViewControllerIndex) {
                // Add the current VC to the after array
                notificationViewControllersAfter.append(currentViewController);
            }
        }
        
        // Remove the notification view controller from currentNotifications, and then put back the modified array
        currentNotificationsMutableArray.removeObject(notificationViewController);
        currentNotifications = Array(currentNotificationsMutableArray) as! [MUNotificationViewController];
        
        // This was painful to write
        // For every notification after the notification to remove...
        for(_, currentViewController) in notificationViewControllersAfter.enumerate() {
            // Set the resize time
            currentViewController.window.resizeTime = currentViewController.window.closeSpeed;
            
            /// The Y position to move the notification to
            var moveToY : CGFloat = (NSScreen.mainScreen()!.frame.height - 24) - currentViewController.window.originalHeight;
            
            /// The combined height of all the notifications above this notification
            var aboveHeight : CGFloat = 0;
            
            // For every item in the currentNotifications array...
            for(currentIndexForBefore, currentViewControllerForBefore) in currentNotifications.enumerate() {
                // If the current index is above the notification VC's index...
                if(currentIndexForBefore < currentNotificationsMutableArray.indexOfObject(currentViewController)) {
                    // Add the current VC to the after array
                    aboveHeight += currentViewControllerForBefore.window.originalHeight + notificationTopPadding;
                }
            }
            
            // Remove 4 from the above height(For some reason it adds an extra 4 somewhere)
            aboveHeight -= 4;
            
            // Substract the above height from the move to Y
            moveToY -= aboveHeight;
            
            // Animate to the new position
            currentViewController.window.animateToFrame(NSRect(x: currentViewController.window.frame.origin.x, y: moveToY, width: currentViewController.window.frame.width, height: currentViewController.window.frame.height));
        }
    }
    
    /// Returns the default MUNotificationCenter for the application
    func defaultCenter() -> MUNotificationCenter {
        return MUNotificationCenterStruct.defaultCenter;
    }
    
    override init() {
        super.init();
        
        // Subscribe to the MUNotificationViewController.Dismissed notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("removeNotificationViewController:"), name: "MUNotificationViewController.Dismissed", object: nil);
    }
}

struct MUNotificationCenterStruct {
    /// The default notification center for the application
    static var defaultCenter : MUNotificationCenter = MUNotificationCenter();
}

/// A notification that can be posted with Mutsu
class MUNotification {
    /// The icon to show for the notification(Defaults to the app's icon)
    var icon : NSImage = NSApplication.sharedApplication().applicationIconImage;
    
    /// The title of the notification(Defaults to the app's name)
    var title : String = NSProcessInfo.processInfo().processName;
    
    /// The informative text of the notification
    var informativeText : String = "";
    
    /// The image to show in the Image size notifications
    var image : NSImage = NSImage();
    
    /// The action views to show in the notifications(Defaults to blank)
    var actions : [NSView] = [];
    
    /// Gow long the notification should stay on screen untill auto dismissing. Set to -1 to never auto dismiss
    var stayTime : CGFloat = -1.0;
    
    /// The theme to use for the notification(Defaults to dark)
    var style : MUNotificationStyle = .Dark;
    
    /// The size of the notification(Defaults to Banner)
    var size : MUNotificationSize = .Banner;
    
    /// The custom view to use if the notification is image sized(Optional)
    var imageSizeView : NSView? = nil;
    
    /// The Selector to perform when the notification is closed(Optional)
    var closeAction : Selector? = nil;
    
    /// The target for closeAction
    var closeActionTarget : AnyObject? = nil;
    
    // Blank init
    init() {
        self.icon = NSApplication.sharedApplication().applicationIconImage;
        self.title = NSProcessInfo.processInfo().processName;
        self.informativeText = "";
        self.image = NSImage();
        self.actions = [];
        self.stayTime = -1.0;
        self.style = .Dark;
        self.size = .Banner;
        self.imageSizeView = nil;
        self.closeAction = nil;
        self.closeActionTarget = nil;
    }
}

/// A nice default style for notification buttons
class MUNotificationButton : NSButton {
    /// Should the notification hide when this button is pressed?
    var dismissOnClick : Bool = true;
    
    /// The target for the dismiss action
    var dismissTarget : AnyObject? = nil;
    
    /// The selector for the dismiss action
    var dismissAction : Selector? = nil;
    
    // Init with a title, target and action
    init(title : String, target: AnyObject, action : Selector, dismissOnClick : Bool) {
        super.init(frame: NSRect.zero);
        
        self.title = title;
        self.target = target;
        self.action = action;
        self.dismissOnClick = dismissOnClick;
        
        // Disable the border
        bordered = false;
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    override func sendAction(theAction: Selector, to theTarget: AnyObject?) -> Bool {
        // Perform the button's action
        target!.performSelector(action);
        
        // If the dismiss target and action are set...
        if(dismissTarget != nil && dismissAction != nil) {
            // Perform the dismiss selector
            dismissTarget!.performSelector(dismissAction!);
        }
        
        return true;
    }
}

/// A nice default style for notification text fields
class MUNotificationTextField: MUAlwaysActiveTextField {
    
    // Init with a placeholder, target and action
    init(placeholder : String, target: AnyObject, action : Selector) {
        super.init(frame: NSRect.zero);
        
        // Style and set action
        self.placeholderString = placeholder;
        self.target = target;
        self.action = action;
        self.bezelStyle = .RoundedBezel;
        self.focusRingType = .None;
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
}

enum MUNotificationSize {
    /// The regular notification size
    case Banner
    
    /// The size meant for displaying large images
    case Image
}

enum MUNotificationStyle {
    /// Dark vibrant notification
    case Dark
    
    /// Light vibrant notification
    case Light
}