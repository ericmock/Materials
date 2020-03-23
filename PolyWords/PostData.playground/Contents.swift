import Cocoa

let information:[Any] = ["1000", "1.34", "4", "2", ["test1", "test2", "test3", "test4"], ["30", "45", "14", "25"]]
let url = URL(string: "http://unstablefocus.com/polywords/scores.php")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

let postString = "Score=\(information[0])&Time=\(information[1])&Level=\(information[2])&Mode=\(information[3])&Words=\((information[4] as! Array).joined(separator: "_"))&Wordscores=\((information[5] as! Array).joined(separator: "_"))"

let encodedString = postString.data(using: .ascii)
let encryptedString = "data=\(encodedString!.base64EncodedString())"
let encryptedEncodedString = encryptedString.data(using: .ascii)

request.httpMethod = "POST"
request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
request.httpBody = encryptedEncodedString
request.setValue("\(String(describing: encodedString!.count))", forHTTPHeaderField: "Content-Length")
let task = URLSession.shared.dataTask(with: request) { data, response, error in
		if let error = error {
				print ("error: \(error)")
				return
		}
		guard let response = response as? HTTPURLResponse,
				(0...500).contains(response.statusCode) else {
					print ("server error:")
				return
		}
	print(response.statusCode)
		if let mimeType = response.mimeType,
				mimeType == "application/json",
				let data = data,
				let dataString = String(data: data, encoding: .utf8) {
				print ("got data: \(dataString)")
		}
}
task.resume()
