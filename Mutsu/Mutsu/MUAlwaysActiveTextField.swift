//
//  MUAlwaysActiveTextField.swift
//  Mutsu
//
//  Created by Seth on 2016-03-27.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class MUAlwaysActiveTextField: NSTextField {

    // Always let the text field be the first responder
    override var acceptsFirstResponder : Bool {
        return true;
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
