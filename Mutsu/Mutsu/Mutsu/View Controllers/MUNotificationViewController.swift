//
//  ViewController.swift
//  Mutsu
//
//  Created by Seth on 2016-02-26.
//

import Cocoa

class MUNotificationViewController: NSViewController {
    
    /// The main window of this controller
    var window : MUNotificationWindow = MUNotificationWindow();
    
    /// The visual effect view for the background of the window
    @IBOutlet var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The visual effect view for the top bar in the image size notifications
    @IBOutlet var topBarVisualEffectView: NSVisualEffectView!
    
    /// The divider on the bottom of the top bar that shows when showing a banner notification with actions
    @IBOutlet var topBarBottomDivider: NSView!
    
    /// The view in the top bar that makes it so we can click the top bar and dismiss the notification
    @IBOutlet var topBarCloseNotificationView: MUDismissOnClickView!
    
    /// The visual effect view for the bottom bar that hodls the notification actions
    @IBOutlet var bottomBarVisualEffectView: NSVisualEffectView!
    
    /// The container for the view when the notification is image size
    @IBOutlet var imageSizeNotificationView: NSView!
    
    /// The top constraint for imageSizeNotificationView
    @IBOutlet var imageSizeNotificationViewTopConstraint: NSLayoutConstraint!
    
    /// The bottom constraint for imageSizeNotificationView
    @IBOutlet var imageSizeNotificationViewBottomConstraint: NSLayoutConstraint!
    
    /// The image view for the icon of the notification
    @IBOutlet var iconImageView: NSImageView!
    
    /// The image view for the image sized notifications
    @IBOutlet var imageView: NSImageView!
    
    /// The label for the title of the notification
    @IBOutlet var titleLabel: NSTextField!
    
    /// The label for the informative text of the notification
    @IBOutlet var informativeTextLabel: NSTextField!
    
    /// The stack view for the actions of the notification
    @IBOutlet var actionsStackView: NSStackView!
    
    /// The notification this notification view represents
    var notification : MUNotification = MUNotification();
    
    /// Should the close action be called?(Should only be set to false when clearing notifications and similar actions)
    var performCloseAction : Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Style the window
        styleWindow();
        
        // Set the notification close speed
        window.closeSpeed = MUNotificationCenter().defaultCenter().notificationCloseSpeed;
    }
    
    /// Shows the given notification
    func showNotification(notification : MUNotification) {
        print("Showing notification with title \"\(notification.title)\" and informative text \"\(notification.informativeText)\"");
        
        // Set the notification this item represents
        self.notification = notification;
        
        // For every item in the image size notification view holder...
        for(currentIndex, currentSubview) in imageSizeNotificationView.subviews.enumerate() {
            // If the current subview isnt the image view...
            if(currentSubview != imageView) {
                // Remove the current subview
                imageSizeNotificationView.subviews.removeAtIndex(currentIndex);
            }
        }
        
        // If the notification window is open...
        if(window.open) {
            // Hide the current notification
            window.hide();
        }
        
        // Set the background effect
        switch(notification.style) {
            case .Dark:
                backgroundVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
                backgroundVisualEffectView.material = .Dark;
                topBarVisualEffectView.material = .Dark;
                bottomBarVisualEffectView.material = .Dark;
                break;
            case .Light:
                backgroundVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
                backgroundVisualEffectView.material = .MediumLight;
                topBarVisualEffectView.material = .MediumLight;
                bottomBarVisualEffectView.material = .MediumLight;
                break;
        }
        
        // Clear the stack view
        actionsStackView.subviews = [];
        
        // If the actions arent blank...
        if(!notification.actions.isEmpty) {
            // For every view in the actions...
            for(_, currentAction) in notification.actions.enumerate() {
                // Add the current action view to the stack view
                actionsStackView.addView(currentAction, inGravity: NSStackViewGravity.Center);
                
                // I dont know what this does, but it works
                currentAction.translatesAutoresizingMaskIntoConstraints = false;
                
                // If this action is a MUNotificationTextField...
                if((currentAction as? MUNotificationTextField) != nil) {
                    
                }
                // If this action is a MUNotificationButton...
                else if((currentAction as? MUNotificationButton) != nil) {
                    // If the button should dismiss the notification on click...
                    if((currentAction as! MUNotificationButton).dismissOnClick) {
                        // Set the dismiss target of the button
                        (currentAction as! MUNotificationButton).dismissTarget = self;
                        
                        // Set the dismiss action to dismiss this notification
                        (currentAction as! MUNotificationButton).dismissAction = Selector("dismiss");
                    }
                }
                
                /// The constraint for the bottom edge
                let bottomConstraint = NSLayoutConstraint(item: currentAction, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: actionsStackView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0);
                
                // Add the constraint
                actionsStackView.addConstraint(bottomConstraint);
                
                /// The constraint for the top edge
                let topConstraint = NSLayoutConstraint(item: currentAction, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: actionsStackView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0);
                
                // Add the constraint
                actionsStackView.addConstraint(topConstraint);
                
                // Add the divider
                /// The divider for the actions of the notification
                let divider : NSView = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: MUNotificationCenter().defaultCenter().bottomBarHeight));
                
                // Set the divider to have a layer
                divider.wantsLayer = true;
                
                // Set the divider color
                switch(notification.style) {
                    case .Dark:
                        divider.layer?.backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.2).CGColor;
                        break;
                    case .Light:
                        divider.layer?.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.2).CGColor;
                        break;
                }
                
                // Add the divider to the stack view
                actionsStackView.addView(divider, inGravity: .Center);
                
                // Again, no idea
                divider.translatesAutoresizingMaskIntoConstraints = false;
                
                /// The constraint for the width of the divider
                let widthConstraint = NSLayoutConstraint(item: divider, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 1);
                
                // Add the constraint
                actionsStackView.addConstraint(widthConstraint);
                
                /// The constraint for the height of the divider
                let heightConstraint = NSLayoutConstraint(item: divider, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 39);
                
                // Add the constraint
                actionsStackView.addConstraint(heightConstraint);
            }
            
            // Remove the last view(It will be a divider) from the stack view
            actionsStackView.subviews.removeLast();
            
            // Show the bottom bar
            bottomBarVisualEffectView.hidden = false;
        }
        // If the actions are blank...
        else {
            // Hide the bottom bar
            bottomBarVisualEffectView.hidden = true;
        }
        
        // If we said to have the image size notification view be full size...
        if(notification.imageSizeViewFullSize) {
            // Restore the constraints for the image size view container
            imageSizeNotificationViewTopConstraint.constant = 0;
            imageSizeNotificationViewBottomConstraint.constant = 0;
            
            // Set the top bar to be vibrant within the window
            topBarVisualEffectView.blendingMode = .WithinWindow;
            
            // Set the bottom bar to be vibrant within the window
            bottomBarVisualEffectView.blendingMode = .WithinWindow;
        }
            // If we said to have the image size view not full size...
        else {
            // Set the constraints for the image size view container
            imageSizeNotificationViewTopConstraint.constant = 63;
            
            // If there are any actions...
            if(!notification.actions.isEmpty) {
                imageSizeNotificationViewBottomConstraint.constant = MUNotificationCenter().defaultCenter().bottomBarHeight;
            }
            else {
                imageSizeNotificationViewBottomConstraint.constant = 0;
            }
            
            // Set the top bar to be vibrant behind the window
            topBarVisualEffectView.blendingMode = .BehindWindow;
            
            // Set the bottom bar to be vibrant behind the window
            bottomBarVisualEffectView.blendingMode = .BehindWindow;
        }
        
        // If the notification size is Image...
        if(notification.size == .Image) {
            // Set the height to the image notification height
            window.originalHeight = MUNotificationCenter().defaultCenter().imageHeight;
            
            // If we wanted a custom view...
            if(notification.imageSizeView != nil) {
                // Hide the image view
                imageView.hidden = true;
                
                // Add the custom view to the image size view container
                imageSizeNotificationView.addSubview(notification.imageSizeView!);
                
                // Once more, still no
                notification.imageSizeView!.translatesAutoresizingMaskIntoConstraints = false;
                
                /// The constraint for the bottom edge
                let bottomConstraint = NSLayoutConstraint(item: notification.imageSizeView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: imageSizeNotificationView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0);
                
                // Add the constraint
                imageSizeNotificationView.addConstraint(bottomConstraint);
                
                /// The constraint for the top edge
                let topConstraint = NSLayoutConstraint(item: notification.imageSizeView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: imageSizeNotificationView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0);
                
                // Add the constraint
                imageSizeNotificationView.addConstraint(topConstraint);
                
                /// The constraint for the trailing edge
                let trailingConstraint = NSLayoutConstraint(item: notification.imageSizeView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: imageSizeNotificationView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0);
                
                // Add the constraint
                imageSizeNotificationView.addConstraint(trailingConstraint);
                
                /// The constraint for the leading edge
                let leadingConstraint = NSLayoutConstraint(item: notification.imageSizeView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: imageSizeNotificationView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0);
                
                // Add the constraint
                imageSizeNotificationView.addConstraint(leadingConstraint);
            }
            // If we didnt want a custom view...
            else {
                // Show the image view
                imageView.hidden = false;
                
                // Set the image
                imageView.image = notification.image;
            }
            
            // Hide the top bar bottom divider
            topBarBottomDivider.hidden = true;
            
            // Set the resize time
            window.resizeTime = MUNotificationCenter().defaultCenter().imageAnimateSpeed;
        }
        // If the notification size is Banner...
        else if(notification.size == .Banner) {
            // Set the height to the banner height
            window.originalHeight = MUNotificationCenter().defaultCenter().bannerHeight;
            
            // If there are any actions...
            if(!notification.actions.isEmpty) {
                // Set the height to the banner height + the bottom bar height
                window.originalHeight = MUNotificationCenter().defaultCenter().bannerHeight + MUNotificationCenter().defaultCenter().bottomBarHeight;
                
                // Show the top bar bottom divider
                topBarBottomDivider.hidden = false;
                
                // Set the top bar bottom divider color
                switch(notification.style) {
                    case .Dark:
                        topBarBottomDivider.layer?.backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.2).CGColor;
                        break;
                    case .Light:
                        topBarBottomDivider.layer?.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.2).CGColor;
                        break;
                }
            }
            // If there arent actions...
            else {
                // Hide the top bar bottom divider
                topBarBottomDivider.hidden = true;
            }
            
            // Hide the image view
            imageView.hidden = true;
            
            // Set the top bar to be vibrant behind the window
            topBarVisualEffectView.blendingMode = .BehindWindow;
            
            // Set the bottom bar to be vibrant behind the window
            bottomBarVisualEffectView.blendingMode = .BehindWindow;
            
            // Set the resize time
            window.resizeTime = MUNotificationCenter().defaultCenter().bannerAnimateSpeed;
        }
        
        // Set the title labe;
        titleLabel.stringValue = notification.title;
        
        // Set the informative text label
        informativeTextLabel.stringValue = notification.informativeText;
        
        // Set the icon
        iconImageView.image = notification.icon;
        
        // Show the window
        window.show();
        
        // If the stay time for the notification is not -1...
        if(notification.stayTime != -1) {
            // Set the timer for auto dismiss
            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(notification.stayTime), target: self, selector: Selector("dismiss"), userInfo: nil, repeats: false);
        }
    }
    
    /// Dismisses the current notification, if there is one
    func dismiss() {
        // Post the notification saying that a notification is closing, with this notification
        NSNotificationCenter.defaultCenter().postNotificationName("MUNotificationViewController.Dismissed", object: self);
        
        // If we said the close action should be called...
        if(performCloseAction) {
            // If the close action and target are set...
            if(notification.closeAction != nil && notification.closeActionTarget != nil) {
                // Perform the close action
                notification.closeActionTarget!.performSelector(notification.closeAction!);
            }
        }
        
        // Hide the notification window
        window.hide();
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the window
        window = NSApplication.sharedApplication().windows.last! as! MUNotificationWindow;
        
        // Hide the titlebar
        window.styleMask |= NSFullSizeContentViewWindowMask;
        window.standardWindowButton(.CloseButton)?.superview?.superview?.removeFromSuperview();
        
        // Set the top bar's notification controller(So it can dismiss notifications from mouse down)
        topBarCloseNotificationView.notificationViewController = self;
        
        // Set the original width
        window.originalWidth = MUNotificationCenter().defaultCenter().notificationWidth;
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}