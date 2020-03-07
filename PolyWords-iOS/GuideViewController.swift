
import UIKit

class GuideViewController : UITableViewController {

	let initWithWords:Int = 100// s;
	let ROW_HEIGHT:CGFloat = 60
	let GUIDE_TAG = 1
	let LEVEL_TAG = 2
	let IMAGE_TAG = 3
	let LEFT_COLUMN_OFFSET:CGFloat = 5.0
	let LEFT_COLUMN_WIDTH:CGFloat = 55.0
	
	let MIDDLE_COLUMN_OFFSET:CGFloat = 60.0
	let MIDDLE_COLUMN_WIDTH:CGFloat = 200.0
	
	let MAIN_FONT_SIZE:CGFloat = 18.0
	let LABEL_HEIGHT:CGFloat = 26.0
	
	let IMAGE_SIDE:CGFloat = 50.0


	let viewTitle = "Polywords Guide"
	var myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
	let lightColor = UIColor(red: 0.905, green: 0.835, blue: 0.690, alpha: 1.0)
	let appController = AppController()
	
	var mainView:UIView!
//	var tableView:UITableView!
		
	required init?(coder: NSCoder) {
		super.init(coder: coder)
//		tableView.rowHeight = ROW_HEIGHT
//		tableView.separatorStyle = .none
	}
	
	override func viewWillAppear(_ animated: Bool) {
		mainView = UIView(frame: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: appController.screenRect.width, height: appController.screenRect.height))
		mainView.backgroundColor = appController.darkColor
		self.view = mainView
		
		myTableView = UITableView(frame: CGRect(x: 0.0, y: 40.0, width: appController.screenRect.width, height: appController.screenRect.height), style: .plain)
		myTableView.rowHeight = ROW_HEIGHT
		myTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		myTableView.delegate = self
		myTableView.dataSource = self
		myTableView.sectionIndexMinimumDisplayRowCount = 10
		myTableView.backgroundColor = appController.darkColor
		myTableView.separatorColor = appController.darkColor
		
		let backgroundView = UILabel(frame: CGRect(x: 0.0, y: -80.0, width: appController.screenRect.width, height: 40.0))
		backgroundView.text = "No peeking"
		backgroundView.textColor = lightColor
		backgroundView.font = UIFont(name: "Helvetica-Bold", size: 30)//[UIFont fontWithName:@"Helvetica-Bold" size:30];
		backgroundView.textAlignment = .center
		backgroundView.backgroundColor = appController.darkColor
		
		myTableView.addSubview(backgroundView)
		
		mainView.addSubview(myTableView)
		
		super.viewDidAppear(animated)

	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 9
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "GuideCell")
		configureCell(cell: cell, forIndex: indexPath)
		cell.accessoryType = .detailDisclosureButton
		
		return cell
	}
	
	func configureCell(cell: UITableViewCell, forIndex index:IndexPath) {
		let guideArray = ["Rotating Polyhedra","Selecting Letters","Deselecting Letters","Making Words","Submitting Words", "Replacing Letters", "Scoring", "Game Modes", "Unlocking Levels"]
//		let imagesArray = ["Tetrahedron.png","Cube.png","Octahedron.png","Dodecahedron.png","Icosahedron.png", "Cuboctahedron.png"]
		
		let label:UILabel = cell.viewWithTag(GUIDE_TAG) as! UILabel
		label.text = guideArray[index.row]
//		let imageView:UIImageView = cell.viewWithTag(IMAGE_TAG) as! UIImageView
//		let imageCount = imagesArray.count
//		imageView.image = UIImage(named: imagesArray[index.row % imageCount])
		
	}
	
//  I think this isn't correct.  Need to figure out how the table view gets a reusable cell
	func tableViewCellWithReuseIdentifier(_ identifer: String) -> UITableViewCell {
		var rect = CGRect(x: 0, y: 0, width: 320, height: ROW_HEIGHT)
		let cell:UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: identifer)
		cell.selectionStyle = .gray
		
		rect = CGRect(x: 0.0, y: 0.0, width: appController.screenRect.width, height: ROW_HEIGHT)
		let blockView = UIView(frame: rect)
		cell.contentView.addSubview(blockView)
		blockView.backgroundColor = lightColor
		
		rect = CGRect(x: MIDDLE_COLUMN_OFFSET, y: (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, width: MIDDLE_COLUMN_WIDTH, height: LABEL_HEIGHT)
		let label = UILabel(frame: rect)
		label.tag = GUIDE_TAG
		label.font = UIFont(name: "Helvetica-Bold", size: 20)
		label.adjustsFontSizeToFitWidth = true
		cell.contentView.addSubview(label)
		label.backgroundColor = lightColor
		label.textColor = appController.darkColor
		
		rect = CGRect(x: LEFT_COLUMN_OFFSET, y: (ROW_HEIGHT - IMAGE_SIDE) / 2.0, width: IMAGE_SIDE, height: IMAGE_SIDE)
		let blockView2 = UIImageView(frame: rect)//[[UIImageView alloc] initWithFrame:rect];
		blockView2.tag = IMAGE_TAG
		blockView2.backgroundColor = appController.darkColor
		cell.contentView.addSubview(blockView2)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, willSelectRowAt index:IndexPath) -> IndexPath? {
		tableView.deselectRow(at: index, animated: true)
		
		
		let guideScrollerController = GuideScrollerController(coder: coder)
		
		init2(withGuide: index.row)
		return index
	}

		
/*

- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier {
//	NSLog(@"start tableviewCellWithReuseIdentifier");

	/*
	 Create an instance of UITableViewCell and add tagged subviews for the name, local time, and quarter image of the time zone.
	 */
	CGRect rect;
	
	rect = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:rect reuseIdentifier:identifier] autorelease];
	
#define LEFT_COLUMN_OFFSET 5.0
#define LEFT_COLUMN_WIDTH 55.0
	
#define MIDDLE_COLUMN_OFFSET 60.0
#define MIDDLE_COLUMN_WIDTH 200.0

#define MAIN_FONT_SIZE 18.0
#define LABEL_HEIGHT 26.0
	
#define IMAGE_SIDE 50.0
	
	UILabel *label;
	
	rect = CGRectMake(LEFT_COLUMN_OFFSET, (ROW_HEIGHT - IMAGE_SIDE) / 2.0, IMAGE_SIDE, IMAGE_SIDE);
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
	imageView.tag = IMAGE_TAG;
	[cell.contentView addSubview:imageView];
	[imageView release];
	
	rect = CGRectMake(MIDDLE_COLUMN_OFFSET, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, MIDDLE_COLUMN_WIDTH, LABEL_HEIGHT);
	label = [[UILabel alloc] initWithFrame:rect];
	label.tag = GUIDE_TAG;
	label.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
	label.adjustsFontSizeToFitWidth = YES;
	[cell.contentView addSubview:label];
	label.highlightedTextColor = [UIColor whiteColor];
	[label release];
	
//	NSLog(@"end tableviewCellWithReuseIdentifier");
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
//	NSLog(@"start tableView:willSelectRowAtIndexPath");
	[tableView deselectRowAtIndexPath:newIndexPath animated:YES];
	
	GuideScrollerController *guideScrollerController = [[GuideScrollerController alloc] initWithGuide:newIndexPath.row];
	
	// push the element view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:guideScrollerController animated:YES];
	[guideScrollerController release];
//	NSLog(@"end tableView:willSelectRowAtIndexPath");
	return newIndexPath;
}

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	return nil;
//}

@end
*/
}
