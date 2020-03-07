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

public struct Metadata: CustomDebugStringConvertible, Equatable {

  let word: String
  let score: Int

  init(word: String, score: Int) {
    self.word = word
    self.score = score
  }

  public var debugDescription: String {
    return "Word: \(word), Score: \(score)"
  }

}

class WordListViewController: NSViewController {
	
	@IBOutlet weak var topicDetails: NSTextField!
	@IBOutlet weak var tableView: NSTableView!
	
	let sizeFormatter = ByteCountFormatter()
//	var directory: Directory?
//	var directoryItems: [Metadata]?
//	var sortOrder = Directory.FileOrder.Name
//	var sortAscending = true
	let fakeWords = ["Rotating Polyhedra","Selecting Letters","Deselecting Letters","Making Words","Submitting Words", "Replacing Letters", "Scoring", "Game Modes", "Unlocking Levels"]
	
	let fakeWordScores = [5,8,10,22,18, 6, 4, 12, 15]
	var sortAscending = true
	var sortOrder = WordOrder.Word
	var wordItems: [Metadata]?
	fileprivate var wordScores:[Metadata] = []
	
	public enum WordOrder: String {
		case Word
		case Score
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		topicDetails.stringValue = ""
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.target = self
//		tableView.doubleAction = #selector(tableViewDoubleClick(_:))
		
		for (word, score) in zip(fakeWords,fakeWordScores) {
			wordScores.append(Metadata(word: word, score: score))
		}
		reloadWordList()

		let descriptorWord = NSSortDescriptor(key: "Word", ascending: true)
		let descriptorWordScore = NSSortDescriptor(key: "Score", ascending: true)

		tableView.tableColumns[0].sortDescriptorPrototype = descriptorWord
		tableView.tableColumns[1].sortDescriptorPrototype = descriptorWordScore
//		tableView.tableColumns[2].sortDescriptorPrototype = descriptorSize
	}
	
	override var representedObject: Any? {
		didSet {
			for (word, score) in zip(fakeWords,fakeWordScores) {
				wordScores.append(Metadata(word: word, score: score))
			}
			reloadWordList()
		}
	}
	
//	@objc func tableViewDoubleClick(_ sender:AnyObject) {
//	}
	
	func reloadWordList() {
		wordItems = contentsOrderedBy(sortOrder, ascending: sortAscending)
		tableView.reloadData()
	}
	
	func contentsOrderedBy(_ orderedBy: WordOrder, ascending: Bool) -> [Metadata] {
		let sortedWords:[Metadata]
    switch orderedBy {
		case .Word:
      sortedWords = wordScores.sorted {
        return itemComparator(lhs:$0.word, rhs: $1.word, ascending: ascending)
      }
		case .Score:
      sortedWords = wordScores.sorted {
        return itemComparator(lhs:$0.score, rhs: $1.score, ascending: ascending)
      }
			
		}
		return sortedWords
	}
	
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

		topicDetails.stringValue = text
	}
}

extension WordListViewController: NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return fakeWords.count
	}
	
	func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
		guard let sortDescriptor = tableView.sortDescriptors.first else {
			return
		}
		if let order = WordOrder(rawValue: sortDescriptor.key!) {
			sortOrder = order
			sortAscending = sortDescriptor.ascending
			reloadWordList()
		}
	}
}

extension WordListViewController: NSTableViewDelegate {
	
	fileprivate enum CellIdentifiers {
		static let WordCell = "WordsCellID"
		static let ScoreCell = "ScoresCellID"
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
		guard let item = wordItems?[row] else {
			return nil
		}
		
		if tableColumn == tableView.tableColumns[0] {
//			image = item.icon
			text = item.word
			cellIdentifier = CellIdentifiers.WordCell
		} else if tableColumn == tableView.tableColumns[1] {
			text = String(item.score)
			cellIdentifier = CellIdentifiers.ScoreCell
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

func itemComparator<T:Comparable>(lhs: T, rhs: T, ascending: Bool) -> Bool {
  return ascending ? (lhs < rhs) : (lhs > rhs)
}
