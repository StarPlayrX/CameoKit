import Foundation


//MARK: GetAsync
internal func GetAsync(endpoint: String, DictionaryHandler: @escaping DictionaryHandler)  {
    guard let url = URL(string: endpoint) else { DictionaryHandler(.none); return}
    
    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = "GET"
    urlReq.timeoutInterval = TimeInterval(15)
    urlReq.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( returndata, response, _ ) in
        if let r = returndata {
            let dict = try? JSONSerialization.jsonObject(with: r, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            DictionaryHandler(dict)
        } else {
            DictionaryHandler(nil)
        }
    }
    
    task.resume()
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString
    }
}

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

//maybe shorten this down sometime
func generateJSON(data: Data) {
    
    let bytes: Data = data

    if  let string = String(data: bytes, encoding: .utf8),
        let str = string.data(using: .utf8)?.prettyPrintedJSONString {
        debugPrint(str)
    }
}




//MARK: - GetPdtAsyc
internal func GetPdtAsyc(endpoint: String, method: String, PdtHandler: @escaping PdtHandler) {
    guard let url = URL(string: endpoint) else { PdtHandler(nil); return }

    let decoder = JSONDecoder()
    
    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = "GET"
    urlReq.timeoutInterval = TimeInterval(10)
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( data, response, error ) in
        
        if let data = data {
            do { let pdtData = try decoder.decode(NewPDT.self, from: data)
                PdtHandler(pdtData)
            } catch {
                PdtHandler(nil)
                print(error)
            }
        }
    }
    
    task.resume()
}

