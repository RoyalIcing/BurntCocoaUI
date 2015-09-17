//
//  UIChoiceRepresentative.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 15/05/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa


/**
What each UI item (menu item, segmented item) is represented with. Recommended to be used on an enum. This can either be a model enum directly using an extension, or you can use an independent enum with the model value inside.
*/
public protocol UIChoiceRepresentative {
	var title: String { get }
	
	typealias UniqueIdentifier: Hashable
	var uniqueIdentifier: UniqueIdentifier { get }
}

extension UIChoiceRepresentative where UniqueIdentifier == Self {
	var uniqueIdentifier: UniqueIdentifier {
		return self
	}
}
