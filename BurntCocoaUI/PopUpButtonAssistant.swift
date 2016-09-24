//
//  PopUpButtonAssistant.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 2/05/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa


public class PopUpButtonAssistant<T : UIChoiceRepresentative> {
	public typealias Item = T
	public typealias Value = Item.UniqueIdentifier
	public typealias ItemUniqueIdentifier = Item.UniqueIdentifier
	
	public let popUpButton: NSPopUpButton
	public let menuAssistant: MenuAssistant<Item>
	
	public init(popUpButton: NSPopUpButton) {
		self.popUpButton = popUpButton
		menuAssistant = MenuAssistant<Item>(menu: popUpButton.menu!)
		
		if let defaultMenuItemRepresentatives = self.defaultMenuItemRepresentatives {
			menuItemRepresentatives = defaultMenuItemRepresentatives
		}
	}
	
	public convenience init() {
		let popUpButton = NSPopUpButton()
		self.init(popUpButton: popUpButton)
	}
	
	/**
		The default item representatives to populate with.
	*/
	public var defaultMenuItemRepresentatives: [Item?]? {
		return nil
	}
	
	/**
		Pass an array of item representatives for each menu item. Use nil for separators.
	*/
	public var menuItemRepresentatives: [Item?]! {
		get {
			return menuAssistant.menuItemRepresentatives
		}
		set {
			menuAssistant.menuItemRepresentatives = newValue
		}
	}
	
	/**
		Populates the menu of the pop-up button with menu items created for each member of `menuItemRepresentatives`. The selected item will remain selected if its menu item is still present after updating.
	*/
	public func update() {
		// Get current selected item
		let selectedItem = popUpButton.selectedItem
		
		menuAssistant.update()
		
		// Restore selected item
		if let selectedItem = selectedItem {
			let selectedItemIndex = popUpButton.index(of: selectedItem)
			if selectedItemIndex != -1 {
				popUpButton.selectItem(at: selectedItemIndex)
			}
		}
	}
	
	/**
		The item representative for the selected menu item, or nil if no menu item is selected.
	*/
	public var selectedItemRepresentative: Item? {
		get {
			guard menuItemRepresentatives != nil else {
				return nil
			}
			
			let index = popUpButton.indexOfSelectedItem
			guard index != -1 else {
				return nil
			}
			
      return menuAssistant.itemRepresentative(at: index)
		}
	}
	
	/**
		The unique identifier for the selected menu item, or nil if no menu item is selected.
	*/
	public var selectedUniqueIdentifier: ItemUniqueIdentifier? {
		get {
			return selectedItemRepresentative?.uniqueIdentifier
		}
		set(newIdentifier) {
			if let newIdentifier = newIdentifier {
				for (index, itemRepresentative) in menuItemRepresentatives.enumerated() {
					if itemRepresentative?.uniqueIdentifier == newIdentifier {
						popUpButton.selectItem(at: index)
						return
					}
				}
			}
			
			popUpButton.select(nil)
		}
	}
}

extension PopUpButtonAssistant : UIControlAssistant {
	typealias Control = NSPopUpButton
	
	var control: Control { return popUpButton }
	
	var controlRenderer: (Value?) -> Control {
		return { newValue in
			self.selectedUniqueIdentifier = newValue
			return self.control
		}
	}
}


extension PopUpButtonAssistant where T : UIChoiceEnumerable {
	public var defaultMenuItemRepresentatives: [Item?]? {
		return Item.allChoices.map{ $0 }
	}
}
