import Foundation

class PullDataController {
	let connection:URLSession!
	
	init(withRequest request:URLRequest) {
		connection = URLSession(configuration: .default)
	}
	
	func startSend(arrayWithObjects array:NSArray) {
		
	}
	
	func cancel() {
		
	}
}
