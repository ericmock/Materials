import MetalKit

class ViewController: LocalViewController {
  
  var renderer: Renderer?
	var gameScene:GameScene?
	var titleScene:TitleScene?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let metalView = view as? MTKView else {
      fatalError("metal view not set up in storyboard")
    }
		renderer = Renderer(view: metalView)
    addGestureRecognizers(to: metalView)
		
		metalView.device = Renderer.device
		metalView.delegate = renderer
		metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
		titleScene = TitleScene(screenSize: metalView.bounds.size, sceneName:"Title")
		gameScene = GameScene(screenSize: metalView.bounds.size, sceneName:"Game")
		renderer?.scene = titleScene

  }
}
