import Foundation

class PullDataController {
	let session = URLSession(configuration: .default)
	var dataTask:URLSessionDataTask?
	var errorMessage = ""
	var results:[ServerResponse] = []
	
	typealias JSONDictionary = [String: Any]
	typealias QueryResults = ([ServerResponse]?, String) -> Void
	
	
	func startSend(arrayWithObjects array:NSArray) {
	}
	
	func getResults(forQuery: String, withInfo array:NSArray, completion: @escaping QueryResults) {
		dataTask?.cancel()
		
		if var urlComponents = URLComponents(string: "https://www.unstablefocus.com/polywords/pullgamedata.php") {
			urlComponents.query = "GameID=\(array.object(at:0))&Mode=\(array.object(at:1))"
			guard let url = urlComponents.url else {
				return
			}
			
			dataTask = session.dataTask(with: url) { [weak self] data, response, error in
				defer{
					self?.dataTask = nil
				}
				
				if let error = error {
					self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
				} else if let data = data,
					let response = response as? HTTPURLResponse,
					response.statusCode == 200 {
					self?.updateResults(data)
					
					DispatchQueue.main.async {
						completion(self?.results, self?.errorMessage ?? "")
					}
				}
			}
			
			dataTask?.resume()
		}
		
	}
	
	private func updateResults(_ data: Data) {
		
	}
	
	func cancel() {
		
	}
}
