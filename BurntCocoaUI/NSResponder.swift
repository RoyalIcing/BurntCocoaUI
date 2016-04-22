//
//  NSResponder.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 22/04/2016.
//  Copyright © 2016 Burnt Caramel. All rights reserved.
//

import Cocoa


extension NSResponder {
	public var nextResponderChain: AnySequence<NSResponder> {
		var currentNextResponder = nextResponder
		return AnySequence(AnyGenerator<NSResponder> {
			defer {
				currentNextResponder = currentNextResponder?.nextResponder
			}
			
			return currentNextResponder
		})
	}
}
