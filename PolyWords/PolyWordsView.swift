import Foundation
import Cocoa
import simd

// this should all get rolled into GameScene and TitleScene
class PolyWordsView {
	var gameState:Int = 0
	var appController:AppController!
	var paused = true
	var num_words_found:Int = 0
	var polyhedron:Polyhedron!
	let commonLettersArray = NSArray(array:["A", "E", "I", "O", "T", "N"])
	let uncommonLettersArray = NSArray(array:["J", "Q", "X", "Z"])
	var lookingUpWordsQ = false
	var availableWords:NSMutableArray!
	var availableWordScores:NSMutableArray!
	var animationInterval:TimeInterval = 0
	var dragging = false

	
	func selectPolyhedron(withInfo polyInfo:NSDictionary) {
		
	}
	
	
//	required init?(coder:NSCoder) {
//		super.init(coder:coder)
//	}
	init() {
//		super.init()
	}
	convenience init?(withFrame frame:CGRect, withAppController d:AppController, aCoder:NSCoder) {
//		self.init(coder: aCoder)
		self.init()
		appController = d
		//		self.initializeIvars(withFrame: frame)
//Move to new NSView class		self.addSubview(touchedLetterView)
		var yPos:CGFloat
		if !appController.unlocked {
			yPos = -48.0
		} else {
			yPos = 0.0
		}
		var thickness:CGFloat = 95.0
		let polygonsCheckedView = NSTextField(string: "\nPolygons Checked")
		polygonsCheckedView.frame = CGRect(x: CGFloat(0.0), y: yPos, width: appController.screenRect.width, height: CGFloat(thickness))
		//		polygonsCheckedView.adjustsFontSizeToWidth = true
		polygonsCheckedView.backgroundColor = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
		polygonsCheckedView.font = NSFont(name: "Helvetica", size: 36)
		polygonsCheckedView.textColor = .white
		polygonsCheckedView.alignment = .center
		polygonsCheckedView.isHidden = (appController.checking != 2)
		//		polygonsCheckedView.numberOfLines = 2
		//		polygonsCheckedView.shadowColor = .black
		//		polygonsCheckedView.shadowOffset = CGSizeMake(2.0,2.0)
		polygonsCheckedView.tag = 100
//Move to new NSView class		self.addSubview(polygonsCheckedView)
		
		yPos += thickness
		thickness = 65.0
		let indicatorView = NSTextField(frame: CGRect(x: 0.0, y: yPos, width: appController.screenRect.width, height: thickness))
		indicatorView.backgroundColor = NSColor(red:1.0, green: 0.0, blue: 0.0, alpha:0.1)
		
		indicatorView.isHidden = (appController.checking != 2)
		indicatorView.tag = 101
//Move to new NSView class		self.addSubview(indicatorView)
		
		yPos += thickness
		thickness = 95.0
		let availableWordsView = NSTextField(string: "Words Found")
		availableWordsView.frame = CGRect(x: 0.0, y: yPos, width: appController.screenRect.width, height: thickness)
		//				availableWordsView.adjustsFontSizeToFitWidth = YES
		availableWordsView.backgroundColor = .red//[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
		availableWordsView.font = NSFont(name: "Helvetica", size: 36)
		availableWordsView.textColor = .white
		availableWordsView.alignment = .center
		availableWordsView.isHidden = (appController.checking != 2)
		//				availableWordsView.numberOfLines = 3
		//				availableWordsView.shadowColor = [UIColor blackColor]
		//				availableWordsView.shadowOffset = CGSizeMake(2.0,2.0)
		availableWordsView.tag = 102
//Move to new NSView class		self.addSubview(availableWordsView)
		
		yPos += thickness
		thickness = 65.0
		let indicatorView2 = NSTextField.init(frame:CGRect(x: 0.0, y: yPos, width: appController.screenRect.size.width, height: thickness))
		indicatorView2.backgroundColor = NSColor(red:1.0, green:0.0, blue:0.0, alpha:0.1)
		indicatorView2.isHidden = (appController.checking != 2)
		indicatorView2.tag = 103
//Move to new NSView class		self.addSubview(indicatorView2)
		
		yPos += thickness
		thickness = 95.0
		let availablePointsView = NSTextField(string: "nPoints Found")
		
		availablePointsView.frame = CGRect(x: 0.0, y: yPos, width: appController.screenRect.size.width, height: thickness)
		//				availablePointsView.adjustsFontSizeToFitWidth = YES
		availablePointsView.backgroundColor = .red
		availablePointsView.font = NSFont(name: "Helvetica", size: 36)
		availablePointsView.textColor = .white
		availablePointsView.alignment = .center
		availablePointsView.isHidden = (appController.checking != 2)
		//				availablePointsView.numberOfLines = 3
		//				availablePointsView.shadowColor = [UIColor blackColor]
		//				availablePointsView.shadowOffset = CGSizeMake(2.0,2.0)
		availablePointsView.tag = 104
//Move to new NSView class		self.addSubview(availablePointsView)
		
		yPos += thickness
		thickness = 65.0
		let indicatorView3 = NSTextField.init(frame:CGRect(x: 0.0, y: yPos, width: appController.screenRect.size.width, height: thickness))
		indicatorView3.backgroundColor = NSColor(red:1.0, green:0.0, blue:0.0, alpha:0.1)
		indicatorView3.isHidden = (appController.checking != 2)
		indicatorView3.tag = 105
//Move to new NSView class		self.addSubview(indicatorView3)
		
//		timeHistory = NSMutableArray()
	}
	
	
	
	
	
	@objc func drawView() {
		
	}
	

}
