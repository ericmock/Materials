import Foundation

class PushDataController {
	let connection:URLSession!
	
	init(withRequest request:URLRequest) {
		connection = URLSession(configuration: .default)
	}
	func startSend(with data:NSArray) {
		
	}
	
	func cancel() {
		
	}
}
