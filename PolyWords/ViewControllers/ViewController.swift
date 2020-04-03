import MetalKit

class ViewController: LocalViewController {
  
  var renderer: Renderer?
	var gameScene:GameScene?
	var titleScene:TitleScene?
	var levelSelectionScene:LevelSelectionScene?
	var item:NSMenu?
  
	@IBOutlet weak var touchedLetterView: NSTextField!
	@IBOutlet weak var polyhedronPicker: NSPopUpButton!
	@IBAction func handleSelection(_ sender: NSPopUpButton) {
		let item = selectedPolyhedra(sender.titleOfSelectedItem ?? "None")
			print("importanceIndex: \(item)")
	}
	override func viewDidLoad() {
    super.viewDidLoad()
    guard let metalView = view as? MTKView else {
      fatalError("metal view not set up in storyboard")
    }
		renderer = Renderer(view: metalView)
    addGestureRecognizers(to: metalView)

		polyhedronPicker.removeAllItems()
		polyhedronPicker.addItem(withTitle: "Select a Polyhedron")
		//		let namesArray = appController.polyhedronNamesArray as! [String]
		polyhedronPicker.addItems(withTitles: AppConstants.kPolyhedronNames)
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(polyhedronPickerOpened),
																					 name: NSPopUpButton.willPopUpNotification,
																					 object: nil)

		metalView.device = Renderer.device
		metalView.delegate = renderer
		metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
//		titleScene = TitleScene(screenSize: metalView.bounds.size, sceneName:"Title")
//		levelSelectionScene = LevelSelectionScene(screenSize: metalView.bounds.size, sceneName:"Title")
		gameScene = GameScene(screenSize: metalView.bounds.size, sceneName:"Game")
		renderer?.scene = gameScene
		renderer?.scene?.viewController = self

  }
	
	@objc func polyhedronPickerOpened() {
		print("Picked: \(polyhedronPicker.selectedTag())")
	}
	
	func selectedPolyhedra(_ polyhedraName:String) -> String {
		return polyhedraName
	}
}
