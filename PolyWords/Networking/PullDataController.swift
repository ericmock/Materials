import Foundation

//  See:  Fetching Website Data into Memory in Developer Documentation
//  See:  Uploading Data to a Website in Developer Documentation

class PullDataController {
	let session = URLSession(configuration: .default)
	var dataTask:URLSessionDataTask?
	var errorMessage = ""
	var results:[ServerResponse] = []
	
	typealias JSONDictionary = [String: Any]
	typealias QueryResults = (Data?, String) -> Void
	
	struct ParseConfig: Decodable {
			private enum CodingKeys: String, CodingKey {
					case data, response, error
			}

			let data: String
			let response: Int
			let error: Bool
	}

	func parseConfig(fromData data: Data, withError error:String) -> ParseConfig {
			let decoder = PropertyListDecoder()
			return try! decoder.decode(ParseConfig.self, from: data)
	}
	
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
				defer {
					self?.dataTask = nil
				}
				
				if let error = error {
					self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
				} else if let data = data,
					let response = response as? HTTPURLResponse,
					response.statusCode == 200 {
					
					completion(data, self?.errorMessage ?? "")
					
					DispatchQueue.main.async {
						self?.parseConfig(fromData: data, withError: self?.errorMessage ?? "")
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
