
import UIKit

class WordsViewController2 : UIViewController, UITableViewDataSource {
	
	let initWithWords:Int = 100// s;
	let ROW_HEIGHT:CGFloat = 60
	let titleName:String? = "AlphaHedra Statistics"
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
	
	
	let wordsArray: [String] = ["Word1", "Words"]
	
	
	//	init(with style:UITableView.Style) {
	//		super.init()
	//		self.tableView.rowHeight = ROW_HEIGHT
	//		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone
	//	}
	
	func numberOfSections(in tableView:UITableView) -> Int {
		return 2
	}
	
	override func viewDidLoad() {
		
	}
	
	func sectionIndexTitles(for tableView:UITableView) -> [String]? {
		return ["3","4"]
	}
	
	func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
		if section == 1 {
			return 3
		} else {
			return 4
		}
	}
	
	func tableView(_ tableView:UITableView, titleForHeaderIn section:NSInteger) -> String {
		if section == 0 {
			return "Three Letter Words"
		} else {
			return "Four Letter Words"
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = "WordsCell"
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier)// as! CustomTableViewCell
		
		//		let cell:UITableViewCell = tableViewCellWithReuseIdentifier(identifier)//[self tableviewCellWithReuseIdentifier:identifier]
		configure(withCell:cell!, forIndexPath:indexPath)
		cell!.accessoryType = .disclosureIndicator
		return cell!
	}
	
	func configure(withCell cell:UITableViewCell, forIndexPath path:IndexPath) {
		let wordsArray:[[String]] = [["Best words", "Longest words", "Average word scores", "Average word lengths"],
																 ["Word score", "Word length", "Average level score"]]
		
		let imagesArray = ["Tetrahedron.png", "Cube.png", "Octahedron.png", "Dodecahedron", "Icosahedron", "Cuboctahedron"]
		
		let label:UILabel = UILabel()
		label.text = wordsArray[path.section][path.row]
		let imageView = UIImageView()
		imageView.tag = IMAGE_TAG
		let imageCount = imagesArray.count
		imageView.image = UIImage(named: imagesArray[(path.row)%imageCount])
		
	}
	
	func tableViewCellWithReuseIdentifier(_ identifer:String) -> UITableViewCell {
		var rect = CGRect(x: 0, y: 0, width: 320, height: ROW_HEIGHT)
		let cell:UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: identifer)
		
		var label = UILabel()
		rect = CGRect(x: LEFT_COLUMN_OFFSET, y: (ROW_HEIGHT - IMAGE_SIDE)/2.0, width: IMAGE_SIDE, height: IMAGE_SIDE)
		let imageView = UIImageView(frame: rect)
		imageView.tag = IMAGE_TAG
		cell.contentView.addSubview(imageView)
		
		rect = CGRect(x: MIDDLE_COLUMN_OFFSET, y: (ROW_HEIGHT - LABEL_HEIGHT)/2.0, width: MIDDLE_COLUMN_WIDTH, height: LABEL_HEIGHT)
		label = UILabel(frame: rect)
		label.tag = GUIDE_TAG
		label.font = UIFont.systemFont(ofSize: MAIN_FONT_SIZE, weight: .bold)
		label.adjustsFontSizeToFitWidth = true
		cell.contentView.addSubview(label)
		label.highlightedTextColor = UIColor(white: 1.0, alpha: 1.0)
		
		return cell
	}
	
	func tableView(_ tableView:UITableView, willSelectRowAt newPath:IndexPath) -> IndexPath {
		tableView.deselectRow(at: newPath, animated: true)
		
		return newPath
	}
}
