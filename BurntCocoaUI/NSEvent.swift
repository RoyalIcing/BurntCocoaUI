//
//  NSEvent.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 6/09/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa


extension NSEvent {
	public var burnt_firstCharacter: Character? {
		if let charactersIgnoringModifiers = charactersIgnoringModifiers {
			return charactersIgnoringModifiers[charactersIgnoringModifiers.startIndex]
		}
		
		return nil
	}
	
	public var burnt_isSpaceKey: Bool {
		return burnt_firstCharacter == " "
	}
}
