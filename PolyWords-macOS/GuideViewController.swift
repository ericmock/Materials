import Cocoa

class GuideViewController: NSViewController {

  @IBOutlet weak var statusLabel: NSTextField!

  let sizeFormatter = ByteCountFormatter()
//  var directory: Directory?
//  var directoryItems: [Metadata]?
//  var sortOrder = Directory.FileOrder.Name
  var sortAscending = true

	let guideArray = ["Rotating Polyhedra","Selecting Letters","Deselecting Letters","Making Words","Submitting Words", "Replacing Letters", "Scoring", "Game Modes", "Unlocking Levels"]

	@IBOutlet weak var tableView: NSTableView!
	override func viewDidLoad() {
    super.viewDidLoad()
    statusLabel.stringValue = ""
  }

  override var representedObject: Any? {
    didSet {
      if let url = representedObject as? URL {
        print("Represented object: \(url)")

      }
    }
  }
}

extension GuideViewController: NSTableViewDataSource {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
		return guideArray.count
  }
}

extension GuideViewController: NSTableViewDelegate {

  fileprivate enum CellIdentifiers {
    static let NameCell = "TopicTitle"
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

//    var image: NSImage?
    var text: String = ""
    var cellIdentifier: String = ""

//    let dateFormatter = DateFormatter()
//    dateFormatter.dateStyle = .long
//    dateFormatter.timeStyle = .long
    
    // 1
		let item = guideArray[row]
    // 2
    if tableColumn == tableView.tableColumns[0] {
      text = item
      cellIdentifier = CellIdentifiers.NameCell
    }

    // 3
		if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
//      cell.imageView?.image = image ?? nil
      return cell
    }
    return nil
  }

}
