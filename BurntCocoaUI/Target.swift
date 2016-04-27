//
//  Target.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 27/04/2016.
//  Copyright © 2016 Burnt Caramel. All rights reserved.
//

import Cocoa

public class Target : NSObject {
	private var onPerform: (sender: AnyObject?) -> ()
	
	public init(onPerform: (sender: AnyObject?) -> ()) {
		self.onPerform = onPerform
	}
	
	public func performed(sender: AnyObject?) {
		onPerform(sender: sender)
	}
	
	public var action: Selector = #selector(Target.performed(_:))
}


extension NSControl {
	public func setActionHandler(onPerform: (sender: AnyObject?) -> ()) -> Target {
		let target = Target(onPerform: onPerform)
		self.target = target
		self.action = target.action
		
		return target
	}
}
