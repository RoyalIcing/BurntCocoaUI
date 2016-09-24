//
//  MainTests.swift
//  BurntCocoaUI
//
//  Created by Patrick Smith on 15/05/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa
import XCTest
import BurntCocoaUI


enum FruitChoice: Int {
	case apple
	case pear
	case banana
	case mango
	
	var name: String {
		switch self {
		case .apple:
			return "Apple"
		case .pear:
			return "Pear"
		case .banana:
			return "Banana"
		case .mango:
			return "Mango"
		}
	}
}

extension FruitChoice: UIChoiceRepresentative {
	var title: String {
		return name
	}
	
	typealias UniqueIdentifier = FruitChoice
	var uniqueIdentifier: UniqueIdentifier { return self }
}


class MenuTests: XCTestCase {
	var fruitChoiceRepresentatives: [FruitChoice] {
		return [
			.apple,
			.pear,
			.banana,
			.mango
		]
	}
	
	override func setUp() {
		super.setUp()
		
	}
	
	override func tearDown() {
		
		super.tearDown()
	}
	
	func testCreateMenu() {
		let menu = NSMenu()
		let menuAssistant = MenuAssistant<FruitChoice>(menu: menu)
		
		// Convert into array of optional types for menuAssistant
		let fruitChoiceRepresentatives:[FruitChoice?] = self.fruitChoiceRepresentatives.map { $0 }
		
		
		menuAssistant.menuItemRepresentatives = fruitChoiceRepresentatives
		menuAssistant.update()
		
		XCTAssert(menu.numberOfItems == fruitChoiceRepresentatives.count, "Correct count")
		XCTAssert(menu.item(at: 1)?.title == "Pear", "Second menu item has title 'Pear'")
    XCTAssert(menuAssistant.itemRepresentative(for: menu.item(withTitle: "Mango")!) == .mango, "Representative for menu item with title 'Mango' is .Mango")
    XCTAssert(menuAssistant.itemRepresentative(for: NSMenuItem()) == nil, "Representative for newly created menu item is nil")
		
		
		menuAssistant.menuItemRepresentatives = [nil]
		menuAssistant.update()
		
		XCTAssert(menu.numberOfItems == 1, "Correct count of one")
		XCTAssert(menu.item(at: 0)?.isSeparatorItem == true, "First menu item is separator")
		
		
		menuAssistant.menuItemRepresentatives = []
		menuAssistant.update()
		
		XCTAssert(menu.numberOfItems == 0, "Correct count of zero")
	}
	
	func testCreateSegmentedControl() {
		let segmentedControl = NSSegmentedControl()
		let segmentedControlAssistant = SegmentedControlAssistant<FruitChoice>(segmentedControl: segmentedControl)
		
		let fruitChoiceRepresentatives = self.fruitChoiceRepresentatives
		
		
		segmentedControlAssistant.segmentedItemRepresentatives = fruitChoiceRepresentatives
		segmentedControlAssistant.update()
		
		XCTAssert(segmentedControl.segmentCount == fruitChoiceRepresentatives.count, "Correct count")
		XCTAssert(segmentedControl.label(forSegment: 1) == "Pear", "Second segmented item has label 'Pear'")
    XCTAssert(segmentedControlAssistant.itemRepresentative(at: 3) == .mango, "Representative for fourth segment is .Mango")
		
		
		segmentedControl.selectedSegment = 2
		XCTAssert(segmentedControlAssistant.selectedItemRepresentative == .banana, "Selected item representative is .Banana, the third item")
		
		
		segmentedControlAssistant.selectedItemRepresentative = .mango
		XCTAssert(segmentedControl.selectedSegment == 3, "Selected segment is fourth item")
		
		
		segmentedControlAssistant.segmentedItemRepresentatives = []
		segmentedControlAssistant.update()
		
		XCTAssert(segmentedControl.segmentCount == 0, "Correct count of zero")
	}
}
