import UIKit

class GuideScrollerController : UIViewController {
	var scrollView:UIScrollView!
	var pageControl:UIPageControl!
//	let polyhedronNamesArray:[String]
	var guide:Int = 0
	var guidePages:[Int] = []
	let MAIN_FONT_SIZE:CGFloat = 18.0

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 435.0))
		pageControl = UIPageControl(frame: CGRect(x: 0.0, y: 400.0, width: 320.0, height: 30.0) )
	}

	func init2(withGuide guide:Int) {
		self.guide = guide
		guidePages = [1,6,2,3,3,3,5,3,4,1,4]
	}
		
	override func loadView() {
		let mainView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 435.0))
		mainView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
		self.view = mainView
		scrollView.backgroundColor = .clear
		scrollView.canCancelContentTouches = false
		scrollView.indicatorStyle = .white
		scrollView.clipsToBounds = false
		scrollView.isScrollEnabled = true
		scrollView.isPagingEnabled = true
		scrollView.delegate = (self as! UIScrollViewDelegate)
		mainView.addSubview(scrollView)
		
//		let guideView = UILabel()
		var textArray:[String] = []
		
		switch guide {
		case 0:
			textArray  = ["To rotate the polyhedron simply drag your finger across it.\nThe polyhedron will rotate as if you are rotating a suspended sphere."]
			break
		case 1:
			textArray  = ["You select letters simply by tapping on the polygon containing the letter.",
										"When a letter is selected the background will change to yellow if fewer than three letters are selected, red if the selected letters do not form a valid word, or green if the selected letters form a valid word.",
										"When the polygons are small you can use 'select mode' to choose a polygon.  Select mode is activated by pressing and holding (do not drag) your finger on the screen.",
										"When select mode becomes active you will see the polygon currently selected turn white and appear in with any other letters in the word.",
										"Once select mode is active, dragging does not rotate the polyhedron but instead allows you to choose different polygons.",
										"Once you remove your finger from the screen the currently highlighted polygon is selected and select mode is deactivated."]
			break
		case 2:
			textArray  = ["You deselect polygons by tapping on a selected polygon or tapping off the polyhedron to deselect all polygons.",
										"When you deselect a polygon by tapping it, that polygon and all the following polygons in the chain are deselected."]
			break
		case 3:
			textArray  = ["Words are made by making chains of selected polygons.",
										"Each polygon in the chain must share a side with the prior and/or following polygon in the chain.",
										"Polygons that simply share a vertex (touch at a point) do not form a chain.\n\nWords must be at least three letters in length."]
			break
		case 4:
			textArray  = ["If the letters in the polygon chain form a word, the polygons will turn green and the bottom button will say \"Submit Word.\"",
										"The left 'Score' background will also turn green and the word score will show a positive value.",
										"Submitting the word will add the word score to your total score and the polygons forming the word will be replaced with new ones.",
			]
			break
		case 5:
			textArray  = [
				"You can replace unwanted letters for a penalty (see Scoring).",
				"If less than three letters are selected or the letters do not form a word in the dictionary, the bottom button will say \"Replace Letter(s)\" and tapping it will cause the selected polygons to be replaced.",
				"The selected letters and the left 'Score' background will either be yellow (if less than three letters are selected) or red (if the letters do not form a word).  The word score will indicate a negative value.",
			]
			break
		case 6:
			textArray  = [
				"The score for a word is calculated by summing the value of each letter in the word and multiplying the total by the number of letters in the word.",
				"Thus, longer words have disproportion-ately larger values.  Letter values range from one to four depending on how frequently the letter appears in the dictionary.",
				"For example 'kin' would have a value of \n15 = 3 x (3 + 1 + 1) while 'king' would have a value of \n28 = 4 x (3 + 1 + 1 + 2).",
				"If the polygon chain does not form a three-plus letter word, replacing the letters will penalize you by the value of the letters replaced.",
				"For example, replacing 'xhw' would deduct 7 (= 4 + 1 + 2) points from your total score.",
			]
			break
		case 7:
			textArray  = [
				"Alphahedra has two modes of play – explore (free play) mode and adventure mode.",
				"In explore mode you can play using any unlocked polyhedron.  In adventure mode you are given five minutes to score as many points in each unlocked level as you can.",
				"Your score accumulates so as you unlock more levels, higher and higher scores are possible.",
			]
			break
		case 8:
			textArray = [
				"The trend graph shows your progress and indicates how you are doing.",
				"In explore mode there is a trend line that either sets a pace to unlock the next level or beat your previous fastest time to 300 points.",
				"In adventure mode the graph is split to show progress in the current level and overall progress through the unlocked levels.",
				"The background color changes to indicate your progress.  It becomes more red as you fall behind pace and more green the farther ahead of pace you are.",
			]
			break
		case 9:
			textArray  = [
				"Levels are unlocked by scoring 300 points within 300 seconds (five minutes) on the previous level in either explore or adventure mode.",
			]
			break
		case 10:
			textArray  = [
				"Shuffles allow you to rearrange the letters on the polyhedron.  The letters are not replaced, they are simply shuffled.",
				"Thus, if there are many vowels grouped together a shuffle will likely help distribute them for use in words.",
				"In explore mode you have three shuffles for to use to beat each level.",
				"In adventure mode you start with three shuffles and for each level you complete with a score of 300 or more points you are rewarded with three additional shuffles.",
			]
			break
		default:
			break
		}
		
		for ii in 0..<textArray.count {
			let guideView = UILabel(frame: CGRect(x: 320.0 * CGFloat(ii) + 40.0, y: 0.0, width: 280.0, height: 435.0))
			guideView.text = textArray[ii]
			guideView.textColor = UIColor(red:0.800, green:1.000, blue:0.400, alpha:1.000)
			guideView.backgroundColor = .clear
			guideView.font = UIFont.systemFont(ofSize: MAIN_FONT_SIZE, weight: .bold)   //[UIFont boldSystemFontOfSize:26.0];
			guideView.lineBreakMode = .byWordWrapping
			guideView.numberOfLines = 20
			guideView.shadowColor = .black
		}
		
		scrollView.contentSize = CGSize(width: CGFloat(guidePages[guide]) * 320.0, height: scrollView.bounds.size.height)
		pageControl.numberOfPages = guidePages[guide]
		pageControl.currentPage = 0
		pageControl.defersCurrentPageDisplay = false
		
		mainView.addSubview(pageControl)
		
		let edgeView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 435.0))
		edgeView.backgroundColor = .black
		mainView.addSubview(edgeView)

	}
	
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)sender {
//	if (pageControlUsed) {
// do nothing - the scroll was initiated from the page control, not the user dragging
//		return;
//	}

// Switch the indicator
CGFloat pageWidth = scrollView.frame.size.width;
int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//	NSLog("page = %i",page);
pageControl.currentPage = page;
[pageControl setNeedsDisplay];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
[super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
// Return YES for supported orientations
return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
// Releases the view if it doesn't have a superview.
[super didReceiveMemoryWarning];

// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
// Release any retained subviews of the main view.
// e.g. self.myOutlet = nil;
}


- (void)dealloc {
[super dealloc];
}


end
*/
