import Foundation

//Get Sync
internal func GetSync(endpoint: String, method: String ) -> NSDictionary {
    
    //MARK: - for Sync
    let semaphore = DispatchSemaphore(value: 0)

    var syncData = NSDictionary()
    
    func getURLRequest() -> URLRequest? {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpMethod = "GET"
            urlReq.timeoutInterval = TimeInterval(30)
            return urlReq
        }
        
        return nil
    }
    
    if let request = getURLRequest() {
        let task = URLSession.shared.dataTask(with: request ) { ( data, response, error ) in
            
            if let result = response as! HTTPURLResponse?, let data = data, result.statusCode == 200 {
                
                do { let result =
                    try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    if let result = result {
                        syncData = result as NSDictionary
                    }
                } catch {
                    print(error)
                }
            }
            
            
            //MARK: - for Sync
            semaphore.signal()
        }
        
        task.resume()
    }

    //MARK: - for Sync
    _ = semaphore.wait(timeout: .distantFuture)

    return syncData
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

//GetPDTX
internal func GetPDT(endpoint: String, method: String ) -> NewPDT? {
    guard let url = URL(string: endpoint) else { return nil }

    //MARK: for Sync
    let semaphore = DispatchSemaphore(value: 0)
    
    var syncData : NewPDT? = nil
    
    let decoder = JSONDecoder()
    var urlReq = URLRequest(url: url)
    urlReq.httpMethod = "GET"
    urlReq.timeoutInterval = TimeInterval(10)
    
    let task = URLSession.shared.dataTask(with: urlReq ) { ( data, response, error ) in
        
        if let data = data {
            do { syncData = try decoder.decode(NewPDT.self, from: data)
            } catch {
                print(error)
            }
        }
                
        //MARK - for Sync
        semaphore.signal()
    }
    
    task.resume()
    
    //MARK: - for Sync
    _ = semaphore.wait(timeout: .distantFuture)
    
    return syncData
    
}

