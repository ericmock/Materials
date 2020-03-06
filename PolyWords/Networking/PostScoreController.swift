import Foundation

class PostScoreController {
	
	var responseData:NSMutableData!
	var connection:NSURLConnection!
	
	init() {
		
	}
	
	func startSend(_ informationArray:NSArray) {
		var success:Bool
		var url:URL
		var request:NSMutableURLRequest
		
		// I want to use a URLSessionConfiguration = .background
		
//		if var urlComponents = URLComponents(string: "https://itunes.apple.com/search") {
//			urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
//			// 3
//			guard let url = urlComponents.url else {
//				return
//			}
//			// 4
//			dataTask =
//				defaultSession.dataTask(with: url) { [weak self] data, response, error in
//				defer {
//					self?.dataTask = nil
//				}
//				// 5
//				if let error = error {
//					self?.errorMessage += "DataTask error: " +
//																	error.localizedDescription + "\n"
//				} else if
//					let data = data,
//					let response = response as? HTTPURLResponse,
//					response.statusCode == 200 {
//					self?.updateSearchResults(data)
//					// 6
//					DispatchQueue.main.async {
//						completion(self?.tracks, self?.errorMessage ?? "")
//					}
//				}
//			}
//			// 7
//			dataTask?.resume()
//		}
//		
		
		responseData = NSMutableData()
		
//		url = URL(string: "http://www.smallfeats.com/polywords/scores.php")
	}
}
