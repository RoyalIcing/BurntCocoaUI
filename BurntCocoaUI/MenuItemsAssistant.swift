//
//  MenuItemsAssistant.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 14/05/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa


public struct MenuItemCustomization<T : UIChoiceRepresentative> {
	/**
		Customize the title dynamically, called for each menu item representative.
	*/
	public var title: ((_ menuItemRepresentative: T) -> String)?
	/**
		Customize the action & target dynamically, called for each menu item representative.
	*/
	public var actionAndTarget: ((_ menuItemRepresentative: T) -> (action: Selector?, target: AnyObject?))?
	/**
		Customize the represented object, called for each menu item representative.
	*/
	public var representedObject: ((_ menuItemRepresentative: T) -> AnyObject?)?
	/**
		Customize the integer tag, called for each menu item representative.
	*/
	public var tag: ((_ menuItemRepresentative: T) -> Int?)?
	/**
		Customize the state (NSOnState / NSOffState / NSMixedState), called for each menu item representative.
	*/
	public var state: ((_ menuItemRepresentative: T) -> Int)?
	/**
		Customize whether the menu item is enabled, called for each menu item representative.
	*/
	public var enabled: ((_ menuItemRepresentative: T) -> Bool)?
	/**
	Customize the image, called for each menu item representative.
	*/
	public var image: ((_ menuItemRepresentative: T) -> NSImage?)?
	/**
	Customize the submenu, called for each menu item representative.
	*/
	public var additionalSetUp: ((_ menuItemRepresentative: T, _ menuItem: NSMenuItem) -> ())?
}


public class MenuItemsAssistantCache<T : UIChoiceRepresentative> {
	typealias ItemUniqueIdentifier = T.UniqueIdentifier
	
	/// Menu items are cached so they are not thrown away and recreated every time.
	var uniqueIdentifierToMenuItems = [ItemUniqueIdentifier: NSMenuItem]()
}


/**
MenuItemsAssistant
*/
public class MenuItemsAssistant<T : UIChoiceRepresentative> {
	public typealias Item = T
	public typealias ItemUniqueIdentifier = Item.UniqueIdentifier
	
	/**
		Pass your implementation of UIChoiceRepresentative. Use nil for separator menu items.
	*/
	public var menuItemRepresentatives: [Item?]!
	
	/**
		Customize the menu item’s title, action, etc with this.
	*/
	public var customization = MenuItemCustomization<Item>()
	
	/**
	Creates menu items based on the array of `menuItemRepresentatives`
	
	- parameter cache: Pass this multiple times to createItems() to reuse menu items.
	*/
	public func createItems(cache: MenuItemsAssistantCache<Item>?) -> [NSMenuItem] {
		if menuItemRepresentatives == nil {
			fatalError("Must set .menuItemRepresentatives before calling createItems()")
		}
		
		var previousCachedIdentifiers = Set<ItemUniqueIdentifier>()
		if let cache = cache {
			previousCachedIdentifiers.formUnion(cache.uniqueIdentifierToMenuItems.keys)
		}
		
		let customization = self.customization
		
		let items = menuItemRepresentatives.map { menuItemRepresentative -> NSMenuItem in
			if let menuItemRepresentative = menuItemRepresentative {
				let title = customization.title?(menuItemRepresentative) ?? menuItemRepresentative.title
				let representedObject = customization.representedObject?(menuItemRepresentative)
				let tag = customization.tag?(menuItemRepresentative) ?? 0
				let state = customization.state?(menuItemRepresentative) ?? NSOffState
				let enabled = customization.enabled?(menuItemRepresentative) ?? true
				let image = customization.image?(menuItemRepresentative)
				let (action, target) = customization.actionAndTarget?(menuItemRepresentative) ?? (nil, nil)
				
				let uniqueIdentifier = menuItemRepresentative.uniqueIdentifier
				previousCachedIdentifiers.remove(uniqueIdentifier)
				
				let item: NSMenuItem
				if let cachedItem = cache?.uniqueIdentifierToMenuItems[uniqueIdentifier] {
					item = cachedItem
				}
				else {
					item = NSMenuItem()
					cache?.uniqueIdentifierToMenuItems[uniqueIdentifier] = item
				}
				
				item.title = title
				item.representedObject = representedObject
				item.action = action
				item.target = target
				item.tag = tag
				item.state = state
				item.isEnabled = enabled
				item.image = image
				
				customization.additionalSetUp?(menuItemRepresentative, item)
				
				return item
			}
			else {
				// Separator for nil
				return NSMenuItem.separator()
			}
		}
		
		if let cache = cache {
			for uniqueIdentifier in previousCachedIdentifiers {
				// Clear cache of any items that were not reused.
				cache.uniqueIdentifierToMenuItems.removeValue(forKey: uniqueIdentifier)
			}
		}
		
		return items
	}
	
	/**
	Find the item representative for the passed NSMenuItem.
	
	- parameter menuItem: The menu item to find.
	- parameter menuItem: The menu items to search within.
	
	- returns: The item representative that matched the menu item.
	*/
	public func itemRepresentative(for menuItemToFind: NSMenuItem, in menuItems: [NSMenuItem]) -> T? {
		for (index, menuItem) in menuItems.enumerated() {
			if menuItem === menuItemToFind {
				return menuItemRepresentatives[index]
			}
		}
		
		return nil
	}
}
