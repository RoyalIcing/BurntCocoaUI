//
//  MenuItemsAssistant.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 14/05/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa


public struct MenuItemCustomization<T: UIChoiceRepresentative> {
	/**
		Customize the title dynamically, called for each menu item representative.
	*/
	public var title: ((menuItemRepresentative: T) -> String)?
	/**
		Customize the action & target dynamically, called for each menu item representative.
	*/
	public var actionAndTarget: ((menuItemRepresentative: T) -> (action: Selector, target: AnyObject?))?
	/**
		Customize the represented object, called for each menu item representative.
	*/
	public var representedObject: ((menuItemRepresentative: T) -> AnyObject?)?
	/**
		Customize the integer tag, called for each menu item representative.
	*/
	public var tag: ((menuItemRepresentative: T) -> Int?)?
	/**
		Customize the state (NSOnState / NSOffState / NSMixedState), called for each menu item representative.
	*/
	public var state: ((menuItemRepresentative: T) -> Int)?
	/**
		Customize whether the menu item is enabled, called for each menu item representative.
	*/
	public var enabled: ((menuItemRepresentative: T) -> Bool)?
	/**
	Customize the image, called for each menu item representative.
	*/
	public var image: ((menuItemRepresentative: T) -> NSImage?)?
	/**
	Customize the submenu, called for each menu item representative.
	*/
	public var additionalSetUp: ((menuItemRepresentative: T, menuItem: NSMenuItem) -> ())?
}


public class MenuItemsAssistantCache<T: UIChoiceRepresentative> {
	typealias ItemUniqueIdentifier = T.UniqueIdentifier
	
	/// Menu items are cached so they are not thrown away and recreated every time.
	var uniqueIdentifierToMenuItems = [ItemUniqueIdentifier: NSMenuItem]()
}


/**
MenuItemsAssistant
*/
public class MenuItemsAssistant<T: UIChoiceRepresentative> {
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
	public func createItems(cache cache: MenuItemsAssistantCache<Item>?) -> [NSMenuItem] {
		if menuItemRepresentatives == nil {
			fatalError("Must set .menuItemRepresentatives before calling createItems()")
		}
		
		var previousCachedIdentifiers = Set<ItemUniqueIdentifier>()
		if let cache = cache {
			previousCachedIdentifiers.unionInPlace(cache.uniqueIdentifierToMenuItems.keys)
		}
		
		let customization = self.customization
		
		let items = menuItemRepresentatives.map { menuItemRepresentative -> NSMenuItem in
			if let menuItemRepresentative = menuItemRepresentative {
				let title = customization.title?(menuItemRepresentative: menuItemRepresentative) ?? menuItemRepresentative.title
				let representedObject = customization.representedObject?(menuItemRepresentative: menuItemRepresentative)
				let tag = customization.tag?(menuItemRepresentative: menuItemRepresentative) ?? 0
				let state = customization.state?(menuItemRepresentative: menuItemRepresentative) ?? NSOffState
				let enabled = customization.enabled?(menuItemRepresentative: menuItemRepresentative) ?? true
				let image = customization.image?(menuItemRepresentative: menuItemRepresentative)
				let (action, target) = customization.actionAndTarget?(menuItemRepresentative: menuItemRepresentative) ?? (nil, nil)
				
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
				item.enabled = enabled
				item.image = image
				
				customization.additionalSetUp?(menuItemRepresentative: menuItemRepresentative, menuItem: item)
				
				return item
			}
			else {
				// Separator for nil
				return NSMenuItem.separatorItem()
			}
		}
		
		if let cache = cache {
			for uniqueIdentifier in previousCachedIdentifiers {
				// Clear cache of any items that were not reused.
				cache.uniqueIdentifierToMenuItems.removeValueForKey(uniqueIdentifier)
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
	public func itemRepresentativeForMenuItem(menuItemToFind: NSMenuItem, inMenuItems menuItems: [NSMenuItem]) -> T? {
		for (index, menuItem) in menuItems.enumerate() {
			if menuItem === menuItemToFind {
				return menuItemRepresentatives[index]
			}
		}
		
		return nil
	}
}
