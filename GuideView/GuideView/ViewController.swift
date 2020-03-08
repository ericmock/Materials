/*
* Copyright (c) 2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Cocoa

class ViewController: NSViewController {
	
	@IBOutlet weak var statusLabel: NSTextField!
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet var topicDetailView: NSTextView!
	
	let sizeFormatter = ByteCountFormatter()
//	var directory: Directory?
//	var directoryItems: [Metadata]?
//	var sortOrder = Directory.FileOrder.Name
//	var sortAscending = true
	let guideTopics = ["Rotating Polyhedra","Selecting Letters","Deselecting Letters","Making Words","Submitting Words", "Replacing Letters", "Scoring", "Game Modes", "Unlocking Levels"]

	override func viewDidLoad() {
		super.viewDidLoad()
		statusLabel.stringValue = ""
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.target = self
//		tableView.doubleAction = #selector(tableViewDoubleClick(_:))
		
		// 1
//		let descriptorName = NSSortDescriptor(key: Directory.FileOrder.Name.rawValue, ascending: true)
//		let descriptorDate = NSSortDescriptor(key: Directory.FileOrder.Date.rawValue, ascending: true)
//		let descriptorSize = NSSortDescriptor(key: Directory.FileOrder.Size.rawValue, ascending: true)

		// 2
//		tableView.tableColumns[0].sortDescriptorPrototype = descriptorName
//		tableView.tableColumns[1].sortDescriptorPrototype = descriptorDate
//		tableView.tableColumns[2].sortDescriptorPrototype = descriptorSize
	}
	
//	@objc func tableViewDoubleClick(_ sender:AnyObject) {
//
		// 1
//		guard tableView.selectedRow >= 0,
//				let item = directoryItems?[tableView.selectedRow] else {
//			return
//		}
		
//		if item.isFolder {
//			// 2
//			self.representedObject = item.url as Any
//		}
//		else {
//			// 3
//			NSWorkspace.shared.open(item.url as URL)
//		}
//	}
	
//	override var representedObject: Any? {
//		didSet {
//			if let url = representedObject as? URL {
//				directory = Directory(folderURL: url)
//				reloadFileList()
//			}
//		}
//	}
	
//	func reloadFileList() {
//		directoryItems = directory?.contentsOrderedBy(sortOrder, ascending: sortAscending)
//		tableView.reloadData()
//	}
	
	func updateStatus() {
		
		let text: String
		
//		let itemSelected = tableView.selectedRowIndexes
//		if (directoryItems == nil) {
//			text = "No Items"
//		}
//		if(itemSelected.count == 0) {
//			text = ""
//		}
//		else {
		switch (tableView.selectedRow) {
		case 0:
			text = "To rotate the polyhedron simply drag your finger across it.\nThe polyhedron will rotate as if you are rotating a suspended sphere."
			break
		case 1:
			text = "You select letters simply by tapping on the polygon containing the letter.\nSelected letters will move to the top of the screen and become translucent in polyhedron.\nWhen the polygons are small you can use 'select mode' to choose a polygon.  Select mode is activated by pressing and holding (do not drag for a second) your finger on the screen."
			break
		default:
			text = ""
			break
		}
//		}

		topicDetailView.string = text
	}
}

extension ViewController: NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return guideTopics.count
	}
	
	func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
		// 1
//		guard let sortDescriptor = tableView.sortDescriptors.first else {
//			return
//		}
//		if let order = Directory.FileOrder(rawValue: sortDescriptor.key!) {
//			// 2
//			sortOrder = order
//			sortAscending = sortDescriptor.ascending
//			reloadFileList()
//		}
	}
}

extension ViewController: NSTableViewDelegate {
	
	fileprivate enum CellIdentifiers {
		static let TopicCell = "TopicTitleCellID"
//		static let DateCell = "DateCellID"
//		static let SizeCell = "SizeCellID"
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		updateStatus()
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
//		var image: NSImage?
		var text: String = ""
		var cellIdentifier: String = ""
		
//		let dateFormatter = DateFormatter()
//		dateFormatter.dateStyle = .long
//		dateFormatter.timeStyle = .long
//
		let item = guideTopics[row]
		
		if tableColumn == tableView.tableColumns[0] {
//			image = item.icon
			text = item
			cellIdentifier = CellIdentifiers.TopicCell
//		} else if tableColumn == tableView.tableColumns[1] {
//			text = item
//			cellIdentifier = CellIdentifiers.DateCell
//		} else if tableColumn == tableView.tableColumns[2] {
//			text = item
//			cellIdentifier = CellIdentifiers.SizeCell
		}
		
		// 3
		if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
			cell.textField?.stringValue = text
//			cell.imageView?.image = image ?? nil
			return cell
		}
		return nil
	}
	
}

