//
//  MUDismissOnClickView.swift
//  Mutsu
//
//  Created by Seth on 2016-03-27.
//

import Cocoa

class MUDismissOnClickView: NSView {

    /// The notification view controller to dismiss notifications from
    var notificationViewController : MUNotificationViewController?;
    
    override func mouseDown(theEvent: NSEvent) {
        // Dismiss the notifications
        notificationViewController!.dismiss();
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
}
