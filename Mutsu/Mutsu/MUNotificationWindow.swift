//
//  MUNotificationWindow.swift
//  Mutsu
//
//  Created by Seth on 2016-03-27.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class MUNotificationWindow: NSWindow, NSWindowDelegate {
    
    /// The original height of the window
    var originalHeight : CGFloat = 0.0;
    
    /// The original width of the window
    var originalWidth : CGFloat = 0.0;
    
    /// The duration for the resize animation
    var resizeTime : CGFloat = 0.75;
    
    // Dont allow the window to become key
    override var canBecomeKeyWindow : Bool {
        return false;
    }
    
    override func awakeFromNib() {
        // Set the delegate to this
        self.delegate = self;
        
        // Set the level to float above everything else
        self.level = 20;
        
        // Allow the window to show without logging in
        self.canBecomeVisibleWithoutLogin = true;
        
        // Disable dragging
        self.movable = false;
        
        // Store the window's height
        originalHeight = frame.height;
        
        // Store the window's width
        originalWidth = MUNotificationCenter().defaultCenter().notificationWidth;
        
        // Set the window to be its original size, with 0 height
        self.setFrame(NSRect(x: NSScreen.mainScreen()!.frame.width - originalWidth - 24, y: frame.origin.y + originalHeight, width: originalWidth, height: 0), display: false);
    }
    
    // Set the resize animation time
    override func animationResizeTime(newFrame: NSRect) -> NSTimeInterval {
        return NSTimeInterval(resizeTime);
    }
    
    /// Is the window open?
    var open : Bool = false;
    
    /// The speed that the close animation happens
    var closeSpeed : CGFloat = 0.25;
    
    /// Animates in the window
    func show() {
        // Say the window is open
        open = true;
        
        // Show the window
        self.orderFrontRegardless();
        
        // Size in the window vertically so it drops down
        self.animateToFrame(NSRect(x: frame.origin.x, y: frame.origin.y - originalHeight, width: originalWidth, height: originalHeight));
    }
    
    /// Animates out the window, and then closes it
    func hide() {
        // Say the window is closed
        open = false;
        
        // Set the resize time
        resizeTime = closeSpeed;
        
        // Size out the window vertically so it drops up
        self.animateToFrame(NSRect(x: frame.origin.x, y: frame.origin.y + originalHeight, width: originalWidth, height: 0));
    }
    
    /// Animates to the given frame
    func animateToFrame(frame : NSRect) {
        /// The animation for the frame with the Ease in and Out curve
        let frameAnimation : CABasicAnimation = CABasicAnimation(keyPath: "frame");
        
        // Set the timing to be Ease in and Out
        frameAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        
        // Set the duration to the resize time
        frameAnimation.duration = NSTimeInterval(resizeTime);
        
        // Add the animation to the window
        self.animations = ["frame":frameAnimation];
        
        // Animate the window
        self.animator().setFrame(frame, display: false);
    }
}
