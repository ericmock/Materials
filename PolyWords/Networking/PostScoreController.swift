import Foundation

class PostScoreController {
	
	var responseData:NSMutableData!
	var connection:NSURLConnection!
	
	init() {
		
	}
	
	func startSend(_ information:[Any]) {
//		var success:Bool
//		var url:URL
//		var request:NSMutableURLRequest
		
		// I want to use a URLSessionConfiguration = .background
		
		let url = URL(string: "http://www.smallfeats.com/polywords/scores.php")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		
//		application/x-www-form-urlencoded

//		let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
//				if let error = error {
//						print ("error: \(error)")
//						return
//				}
//				guard let response = response as? HTTPURLResponse,
//						(200...299).contains(response.statusCode) else {
//						print ("server error")
//						return
//				}
//				if let mimeType = response.mimeType,
//						mimeType == "application/json",
//						let data = data,
//						let dataString = String(data: data, encoding: .utf8) {
//						print ("got data: \(dataString)")
//				}
//		}
//		task.resume()

//		url = URL(string: "http://www.smallfeats.com/polywords/scores.php")
	}
}
