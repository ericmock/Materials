import UIKit

var high_score: Int!
var score: Int!
var longest_word: Int!
var max_occurences: Int!
var best_word: Int!
var mode: UInt!
var time: Float!
var filePath: String!
//var appController: AppController!
var decodedScoreDataArray: [Float] = []
var encodedScoreDataArray: [String:Any]!
var wordArray: [String]!

	mode = 0
	score = 0
	time = 0
	self.filePath = path
	let rawData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
	encodedScoreDataArray = try! PropertyListSerialization.propertyList(from: rawData, format: nil) as! [String:Any]
