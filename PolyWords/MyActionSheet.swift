import Foundation
import Cocoa

class MyActionSheet : NSPopover, NSPopoverDelegate {
	var appController:AppController!// = AppController()
	var reason:Int = 0
	var title:String = ""
	
	required init(coder aCoder:NSCoder) {
		super.init()
	}
	
//	static func initialize(withController d:AppController, withInformation info:NSArray, withCallingObject callingMechod:Any) {
////		self.init(coder: NSCoder())
//		appController = d
//		reason = info.object(at:0) as! Int
//		title = info.object(at: 1) as! String
//		appController.currentAlertView = self
//		//		NSArray *buttonArray = [info objectAtIndex:2];
//		for string in info.object(at:2) as! [String] {
//			//			self.addButton(withTitle:string)
//		}
//		//			self.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//		self.delegate = self
//		
//		if (!(reason == 2 || reason == 4 || reason == 5 || reason == 7)) {
//			//				appController.upgradeDelegate.anchor = Anchor_Top | Anchor_Left;
//			if info.object(at: 1) as! String == "" {
//				appController.upgradeDelegate.position = .zero
//			} else {
//				appController.upgradeDelegate.position = CGPoint(x:0.0, y:50.0);
//			}
//			
//			//			appController.adManager.delegate = appController.upgradeDelegate;
//			//			appController.adManager.view.hidden = NO;
//			//			[self addSubview:appController.adManager.view];
//			//			[appController.adManager requestRefreshAd];
//			//			[appController.adManager updateView];
//		}
//
//	}
	
	func addButton(withTitle title:String) {
		
	}
}
