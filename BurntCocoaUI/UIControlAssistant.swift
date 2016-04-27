//
//  UIControlAssistant.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 25/04/2016.
//  Copyright © 2016 Burnt Caramel. All rights reserved.
//

import Cocoa


protocol UIControlAssistant {
	associatedtype Value : Hashable
	associatedtype Control : NSView
	
	var control: Control { get }
	
	var controlRenderer: (Value?) -> Control { get }
}
