import Foundation

// Define a model to hold both temperature and a Date object for time.
struct WeatherData {
    let temperature: String
    let time: Date
}

class WeatherXMLFetcher: NSObject, URLSessionDelegate, XMLParserDelegate {
    private var currentElement: String = ""
    private var temperature: String = ""
    private var timeValue: String = ""
    
    // Fetch and parse the XML, returning a WeatherData object via a completion handler.
    func fetchXML(completion: @escaping (WeatherData?) -> Void) {
        guard let url = URL(string: "https://xmlweather.vedur.is/?op_w=xml&type=obs&lang=en&view=xml&ids=1;422") else {
            completion(nil)
            return
        }
        
        // Create a URLSession that bypasses certificate validation (for development/testing only)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching XML: \(error)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self
            if parser.parse() {
                // Convert the time string to a Date object.
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let timeDate = dateFormatter.date(from: self.timeValue) {
                    let weatherData = WeatherData(temperature: self.temperature, time: timeDate)
                    DispatchQueue.main.async { completion(weatherData) }
                } else {
                    print("Error parsing date from string: \(self.timeValue)")
                    DispatchQueue.main.async { completion(nil) }
                }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
        task.resume()
    }
    
    // URLSessionDelegate method to bypass certificate validation (development only)
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    // MARK: - XMLParserDelegate methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if currentElement == "T" {
            temperature += trimmed
        } else if currentElement == "time" {
            timeValue += trimmed
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = ""
    }
}
