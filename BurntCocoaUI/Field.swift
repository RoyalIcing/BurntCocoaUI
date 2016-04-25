//
//  Field.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 25/04/2016.
//  Copyright © 2016 Burnt Caramel. All rights reserved.
//

import Cocoa


public enum FieldKind : String {
	case popUp = "popUp"
	case text = "text"
	case checkbox = "checkbox"
}

public protocol FieldProtocol {
	var fieldKind: FieldKind { get }
	var label: String? { get }
}

public protocol FieldsProducer {
	associatedtype Field : FieldProtocol
	
	mutating func control(forField field: Field) -> NSView
	
	mutating func cellView(forField field: Field) -> NSView
	mutating func updateStackView(stackView: NSStackView, forFields fields: [Field]) -> [NSView]
}

extension FieldsProducer {
	public mutating func cellView(forField field: Field) -> NSView {
		let control = self.control(forField: field)
		let label: NSTextField? = field.label.map{ text in
			let label = NSTextField()
			label.stringValue = text
			label.selectable = false
			return label
		}
		
		let cellView = NSView(frame: NSRect(origin: .zero, size: NSSize(width: 100.0, height: 36.0)))
		
		cellView.addSubview(control)
		NSLayoutConstraint.activateConstraints([
			NSLayoutConstraint(item: control, attribute: .Leading, relatedBy: .Equal, toItem: cellView, attribute: .Leading, multiplier: 1.0, constant: 8.0),
			NSLayoutConstraint(item: control, attribute: .Trailing, relatedBy: .Equal, toItem: cellView, attribute: .CenterX, multiplier: 1.0, constant: -4.0),
			NSLayoutConstraint(item: control, attribute: .CenterY, relatedBy: .Equal, toItem: cellView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
		])
		
		if let label = label {
			cellView.addSubview(label)
			NSLayoutConstraint.activateConstraints([
				NSLayoutConstraint(item: control, attribute: .Leading, relatedBy: .Equal, toItem: cellView, attribute: .CenterX, multiplier: 1.0, constant: 4.0),
				NSLayoutConstraint(item: control, attribute: .Trailing, relatedBy: .Equal, toItem: cellView, attribute: .Trailing, multiplier: 1.0, constant: 8.0),
				NSLayoutConstraint(item: control, attribute: .Baseline, relatedBy: .Equal, toItem: control, attribute: .Baseline, multiplier: 1.0, constant: 0.0)
			])
		}
		
		return cellView
	}
	
	public mutating func updateStackView(stackView: NSStackView, forFields fields: [Field?], gapSpacing: CGFloat, gravity: NSStackViewGravity) {
		let viewsWithGaps = fields.map{ $0.map{ cellView(forField: $0) } }
		
		let views = viewsWithGaps.flatMap{ $0 }
		stackView.setViews(views, inGravity: gravity)
		
		for (isGap, view) in zip(viewsWithGaps.map{ $0 == nil }.dropFirst(), viewsWithGaps) {
			if let view = view where isGap {
				stackView.setCustomSpacing(gapSpacing, afterView: view)
			}
		}
	}
}
