//
//  SegmentedControlAssistant.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 29/04/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa


public struct SegmentedItemCustomization<T: UIChoiceRepresentative> {
	public typealias Item = T
	
	/**
	Customize the title dynamically, called for each segmented item representative.
	*/
	public var title: ((_ segmentedItemRepresentative: Item) -> String)?
	/**
	Customize the integer tag, called for each segemented item representative.
	*/
	public var tag: ((_ segmentedItemRepresentative: T) -> Int?)?
}


public class SegmentedControlAssistant<T: UIChoiceRepresentative> {
	public typealias Item = T
	public typealias Value = Item.UniqueIdentifier
	public typealias ItemUniqueIdentifier = Item.UniqueIdentifier
	
	public let segmentedControl: NSSegmentedControl
	public var segmentedCell: NSSegmentedCell {
		return segmentedControl.cell as! NSSegmentedCell
	}
	
	public init(segmentedControl: NSSegmentedControl) {
		self.segmentedControl = segmentedControl
		
		if let defaultSegmentedItemRepresentatives = self.defaultSegmentedItemRepresentatives {
			segmentedItemRepresentatives = defaultSegmentedItemRepresentatives
		}
	}
	
	public convenience init() {
		let segmentedControl = NSSegmentedControl()
		self.init(segmentedControl: segmentedControl)
	}
	
	/**
	The default item representatives to populate with.
	*/
	public var defaultSegmentedItemRepresentatives: [Item]? {
		return nil
	}
	
	/**
		Pass an array of item representatives for each segmented item.
	*/
	public var segmentedItemRepresentatives: [Item]! {
		willSet {
			if hasUpdatedBefore {
				previouslySelectedUniqueIdentifier = selectedUniqueIdentifier
			}
		}
	}
	
	/**
		Customize the segmented item’s title, tag with this.
	*/
	public var customization = SegmentedItemCustomization<Item>()
	
	fileprivate var hasUpdatedBefore: Bool = false
	fileprivate var previouslySelectedUniqueIdentifier: ItemUniqueIdentifier?
	
	/**
		Populates the segemented control with items created for each member of `segmentedItemRepresentatives`
	*/
	public func update() {
		let segmentedCell = self.segmentedCell
		let trackingMode = segmentedCell.trackingMode
		
		let segmentedItemRepresentatives = self.segmentedItemRepresentatives!
		
		// Update number of segments
		segmentedCell.segmentCount = segmentedItemRepresentatives.count
		
		let customization = self.customization
		
		// Update each segment from its corresponding representative
		var segmentIndex: Int = 0
		for segmentedItemRepresentative in segmentedItemRepresentatives {
			let title = customization.title?(segmentedItemRepresentative) ?? segmentedItemRepresentative.title
			let tag = customization.tag?(segmentedItemRepresentative) ?? 0
			
			segmentedCell.setLabel(title, forSegment: segmentIndex)
			segmentedCell.setTag(tag, forSegment: segmentIndex)
			
			segmentIndex += 1
		}
		
		if trackingMode == .selectOne {
			self.selectedUniqueIdentifier = previouslySelectedUniqueIdentifier
		}
		
		hasUpdatedBefore = true
		previouslySelectedUniqueIdentifier = nil
	}
	
	/**
		Find the item representative for the passed segmented item index.
		
		- parameter segmentIndex: The index of the segmented item to find.
		
		- returns: The item representative that matched.
	*/
	public func itemRepresentative(at segmentIndex: Int) -> Item {
		return segmentedItemRepresentatives[segmentIndex]
	}
	
	/**
		Find the unique identifier for the passed segmented item index.
		
		- parameter segmentIndex: The index of the segmented item to find.
		
		- returns: The item representative that matched.
	*/
	public func uniqueIdentifier(at segmentIndex: Int) -> ItemUniqueIdentifier {
    return itemRepresentative(at: segmentIndex).uniqueIdentifier
	}
	
	/**
		The item representative for the selected segment, or nil if no segment is selected.
	*/
	public var selectedItemRepresentative: Item? {
		get {
			let index = segmentedCell.selectedSegment
			guard index != -1 else {
				return nil
			}
			
      return itemRepresentative(at: index)
		}
		set {
			selectedUniqueIdentifier = newValue?.uniqueIdentifier
		}
	}
	
	/**
		The unique identifier for the selected segment, or nil if no segment is selected.
	*/
	public var selectedUniqueIdentifier: ItemUniqueIdentifier? {
		get {
			return selectedItemRepresentative?.uniqueIdentifier
		}
		set(newIdentifier) {
			guard let newIdentifier = newIdentifier else {
				segmentedControl.selectedSegment = -1
				return
			}
			
			for (index, itemRepresentative) in segmentedItemRepresentatives.enumerated() {
				if itemRepresentative.uniqueIdentifier == newIdentifier {
					segmentedControl.selectedSegment = index
					return
				}
			}
			
			segmentedControl.selectedSegment = -1
		}
	}
}

extension SegmentedControlAssistant : UIControlAssistant {
	typealias Control = NSSegmentedControl
	
	var control: Control { return segmentedControl }
	
	var controlRenderer: (Value?) -> Control {
		return { newValue in
			self.selectedUniqueIdentifier = newValue
			return self.control
		}
	}
}


extension SegmentedControlAssistant where T : UIChoiceEnumerable {
	public var defaultSegmentedItemRepresentatives: [Item]? {
		return Item.allChoices.map{ $0 }
	}
}
