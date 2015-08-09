# BurntCocoaUI
Declarative assistants to make NSMenu, NSPopUpButton, NSSegmentedControl easier. Use Swift enums instead of creating and removing NSMenuItems and fiddling with indexes and tags.

## Example

### NSPopUpMenu with PopUpButtonAssistant

#### The choices you want to show in the menu, as an enum.

```swift
enum BaseContentTypeChoice: Int {
	case LocalHTMLPages = 1
	case Images
	case Feeds
}
```

#### Add an extension to the enum to make it conform to the UIChoiceRepresentative protocol.

```swift
extension BaseContentTypeChoice: UIChoiceRepresentative {
	var title: String {
		switch self {
		case .LocalHTMLPages:
			return "Local Pages"
		case .Images:
			return "Images"
		case .Feeds:
			return "Feeds"
		}
	}
	
	typealias UniqueIdentifier = BaseContentTypeChoice
	var uniqueIdentifier: UniqueIdentifier { return self }
}
```

#### Use PopUpButtonAssistant in View Controller, with customized menu item titles.

```swift
class ExampleViewController: NSViewController {
  
	@IBOutlet var baseContentTypeChoicePopUpButton: NSPopUpButton! // Hooked up in storyboard/nib
	var baseContentTypeChoicePopUpButtonAssistant: PopUpButtonAssistant<BaseContentTypeChoice>!

	var chosenBaseContentChoice: BaseContentTypeChoice = .LocalHTMLPages
	

	var baseContentTypeChoiceMenuItemRepresentatives: [BaseContentTypeChoice?] {
		return [
			.LocalHTMLPages,
			.Images,
			.Feeds
		]
	}
	
	func updateBaseContentTypeChoiceUI() {
		let popUpButtonAssistant = baseContentTypeChoicePopUpButtonAssistant ?? {
			let popUpButtonAssistant = PopUpButtonAssistant<BaseContentTypeChoice>(popUpButton: baseContentTypeChoicePopUpButton)
			
			let menuAssistant = popUpButtonAssistant.menuAssistant
			// Customize the title by appending a total count
			menuAssistant.customization.title = { choice in
				let baseContentType = choice.baseContentType
				let loadedURLCount = self.pageMapper?.numberOfLoadedURLsWithBaseContentType(baseContentType) ?? 0
				return "\(choice.title) (\(loadedURLCount))"
			}
			
			self.baseContentTypeChoicePopUpButtonAssistant = popUpButtonAssistant
			return popUpButtonAssistant
		}()
		
		popUpButtonAssistant.menuItemRepresentatives = baseContentTypeChoiceMenuItemRepresentatives
		popUpButtonAssistant.update()
	}
	
	@IBAction func changeBaseContentTypeFilter(sender: NSPopUpButton) {
		if let contentChoice = baseContentTypeChoicePopUpButtonAssistant.selectedItemRepresentative {
			chosenBaseContentChoice = contentChoice
			
			reloadData()
		}
	}
	
	func reloadData() {
		// Example ...
	}
}
```

## Installation

To integrate into your Xcode project using Carthage, specify it in your Cartfile:

```
github "BurntCaramel/BurntCocoaUI" >= 0.2
```

## Origin
My Mac app Lantern: http://www.burntcaramel.com/lantern/
