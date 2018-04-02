//
//  Target.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 27/04/2016.
//  Copyright © 2016 Burnt Caramel. All rights reserved.
//

import Cocoa

public class Target : NSObject {
	fileprivate var onPerform: (_ sender: AnyObject?) -> ()
	
	public init(onPerform: @escaping (_ sender: AnyObject?) -> ()) {
		self.onPerform = onPerform
	}
	
	@objc public func performed(_ sender: AnyObject?) {
		onPerform(sender)
	}
	
	public var action: Selector = #selector(Target.performed(_:))
}


extension NSControl {
	public func setActionHandler(_ onPerform: @escaping (_ sender: AnyObject?) -> ()) -> Target {
		let target = Target(onPerform: onPerform)
		self.target = target
		self.action = target.action
		
		return target
	}
}
