//
//  Scene.swift
//  MetalRenderer
//
//  Created by Eric Mockensturm on 2/12/20.
//  Copyright © 2020 Eric Mockensturm. All rights reserved.
//
import Cocoa
import Foundation

enum inputMode {
    case rotate
    case select
}


class Scene {
    var rootNode = Node2()
    var renderables: [Renderable] = []
    
    var screenSize: CGSize
    
    let camera = ArcballCamera2()
    let trackball = Trackball()
    var gTrackBallRotation:SIMD4<Float> = [0, 0, 0, 0]
    var rotationAngles:SIMD4<Float> = [0, 0, 0, 0]
    var worldRotationAngles:SIMD4<Float> = [0, 0, 0, 0]
    var worldRotation:SIMD4<Float> = [0, 0, 0, 0]
    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    
    private var startPoint:CGPoint = .zero
    private var lastPoint:CGPoint = .zero
    private var startTime:Float = 0
    var checked = false
    var dragging = false
    var mode = inputMode.select
    var initialTouchPosition:CGPoint = .zero
    var currentTouchPosition:CGPoint = .zero
    var previousTouchPosition:CGPoint = .zero
    var previousTouchNumber:Int = 0
    var touchedPolygon:Int = 0
    
    var dragTimer:Timer = Timer()
    var touchedLetters:String = ""
    var oldText:String = ""
    //    var viewController: ViewController!
    var thePolyhedron:Polyhedron!
    
    //    var renderer: Renderer!
    var alphabetArray:[String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var commonLettersArray:[String] = ["A", "E", "I", "O", "T", "N"]
    var uncommonLettersArray:[String] = ["J", "Q", "X", "Z"];
    
    var previouslyTouchedNumber: Int = 0
    var touchedNumber: Int = 0
    
    var words:[NSString] = [""]
    @objc var lookingUpWordsQ:Bool = false
    
    var accelz:Float = 0.0
    var accely:Float = 0.0
    
     
    init(screenSize: CGSize, sceneName: String) {
        self.screenSize = screenSize
        setupScene()
    }
    
    func updateScene(deltaTime: Float) {
        if camera.speed != 0.0 {
            camera.rotate(delta: SIMD2<Float>(Float(camera.velocity.x) * deltaTime, Float(camera.velocity.y) * deltaTime))
            camera.velocity = CGPoint(x:0.99 * camera.velocity.x, y:0.99 * camera.velocity.y)
        }
    }
    
    func update(deltaTime: Float) {
        updateScene(deltaTime: deltaTime)
        uniforms.viewMatrix = camera.viewMatrix
        uniforms.projectionMatrix = camera.projectionMatrix
        
        fragmentUniforms.cameraPosition = camera.position
    }
    
    final func add(node: Node2, parent: Node2? = nil, renderQ: Bool = true) {
        if node.name == "TestPolyhedron" {
            thePolyhedron = (node as! Polyhedron);
        } else if node.name == "TitleQuad" {
            
        }
        if let parent = parent {
            parent.add(childNode: node)
        } else {
            rootNode.add(childNode: node)
        }
        if renderQ, let renderable = node as? Renderable {
            renderables.append(renderable)
        }
    }
    
    final func remove(node: Node2) {
        if let parent = node.parent {
            parent.remove(childNode: node)
        } else {
            for child in node.children {
                child.parent = nil
            }
            node.children = []
        }
        
        if node is Renderable,
            let index = renderables.firstIndex(where: { $0 as? Node === node }) {
            renderables.remove(at: index)
        }
    }
    
    func setupScene() {
        //override
    }
    
    func sceneSizeWillChange(to size: CGSize) {
        camera.aspect = Float(size.width / size.height)
        screenSize = size
    }
    
    @objc func checkDrag(timer: Timer) {
        //Override if needed
    }
    
    func findTouchedPolygon(atPoint touchPos: CGPoint) -> Int {
        //Override if needed
        return 0
    }
    
    func interactionsBegan(with event: NSEvent, inView view: NSViewController) {//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        
        //NSArray *touchArray = [touches allObjects];
        //UITouch *t = [touchArray objectAtIndex:0];
        var touchPosition = event.locationInWindow//CGPoint touchPos = [t locationInView:t.view];
        initialTouchPosition = touchPosition
        
        dragging = false
        
        checked = false
        dragTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(checkDrag), userInfo: nil, repeats: false) //dragTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkDrag:) userInfo:nil repeats:NO] retain];
        
        mode = .rotate
        // Do we need this still?
        touchPosition.y = screenSize.height - touchPosition.y
        trackball.startTrackball(withX: Float(touchPosition.x), withY: Float(touchPosition.y), withOriginX: 0, withOriginY: 0, withWidth: Float(screenSize.width), withHeight: Float(screenSize.height));
    }
    
    func touchesMoved(with event: NSEvent, inView view: NSViewController) {
        
        dragging = true
        
        //NSArray *touchArray = [touches allObjects];
        var touchPosition: CGPoint = CGPoint(x:0.0, y:0.0)
        
        //UITouch *t = [touchArray objectAtIndex:0];
        touchPosition = event.locationInWindow//[t locationInView:t.view];
        currentTouchPosition = touchPosition
        
        if (mode == .rotate) {
            touchPosition.y = screenSize.height - touchPosition.y
            gTrackBallRotation = trackball.rollToTrackball(withX: Float(touchPosition.x), withY: Float(touchPosition.y));
            //[self setRotationAngle:gTrackBallRotation[0] X:gTrackBallRotation[1] Y:gTrackBallRotation[2] Z:gTrackBallRotation[3]];
        } else if (mode == .select) {
//            int touched_num = [self findTouchedPolygonAtPoint:touchPos];
//            if (prev_touched_num >= 0 && prev_touched_num < [polyhedron.polygons count]) {
//                Polygons *poly = [polyhedron.polygons objectAtIndex:prev_touched_num];
//                poly.touched = FALSE;
//            }
//            if (touched_num >= 0) {
//                Polygons *poly = [polyhedron.polygons objectAtIndex:touched_num];
//                poly.touched = TRUE;
//                delegate.touchedLetterView.text = [oldText stringByAppendingString:[[alphabetArray objectAtIndex:(poly.texture)%26] lowercaseString]];
//                prev_touched_num = touched_num;
//            }
        }
    }

    func interactionsEnded(withEvent event:NSEvent) {
        
        var touchPosition: CGPoint = CGPoint(x:0.0, y:0.0)
        dragTimer.invalidate()
            
        if (dragging && mode == .rotate) {
            //addToRotationTrackball (gTrackBallRotation, worldRotation);
            gTrackBallRotation[0] = 0.0
            gTrackBallRotation[1] = 0.0
            gTrackBallRotation[2] = 0.0
            gTrackBallRotation[3] = 0.0
            
            rotationAngles = gTrackBallRotation
            worldRotationAngles = worldRotation
        } else if (!dragging || mode == .select) {
            touchPosition = event.locationInWindow//[t locationInView:t.view];
            
            if (previousTouchNumber >= 0 && previousTouchNumber < thePolyhedron.polygons.count) {
                // need to make sure from level to level that index is within bounds
                //((Polygons *)[polyhedron.polygons objectAtIndex:prev_touched_num]).touched = FALSE;
                thePolyhedron.polygons[previousTouchNumber].touched = false
            }

            let touchedNumber = findTouchedPolygon(atPoint: touchPosition)//[self findTouchedPolygonAtPoint:touchPos];

            if (touchedNumber >= 0) {
                touchedPolygon = touchedNumber//][delegate setTouchedPolygon:[polyhedron.polygons objectAtIndex:touched_num]];
            } else {
                touchedPolygon = 0//[delegate setTouchedPolygon:nil]
            }
            
        }
        dragging = false
    }
}
