import Foundation

//Get Sync
internal func GetSync(endpoint: String, method: String ) -> NSDictionary {
    
    //MARK: - for Sync
    let semaphore = DispatchSemaphore(value: 0)

    var syncData : NSDictionary? = NSDictionary()
    
    let http_method = "GET"
    let time_out = 30
    
    
    func getURLRequest() -> URLRequest? {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpMethod = http_method
            urlReq.timeoutInterval = TimeInterval(time_out)
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
            } else if let result = response as! HTTPURLResponse?, result.statusCode == 200  {
                syncData = ["status": result.statusCode] as NSDictionary
            }
            
            
            //MARK: - for Sync
            semaphore.signal()
        }
        
        task.resume()
    }

    //MARK: - for Sync
    _ = semaphore.wait(timeout: .distantFuture)

    return syncData!
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
    let string = String(data: bytes, encoding: .utf8)
        
    let str = string!.data(using: .utf8)!.prettyPrintedJSONString
    
    if str!.contains(".jpg") || str!.contains(".png") {
        debugPrint(str!)

    }
}

//GetPDTX
internal func GetPDTX(endpoint: String, method: String ) -> NewPDT? {
    
    //MARK: for Sync
    let semaphore = DispatchSemaphore(value: 0)
    
    var syncData : NewPDT? = nil
    
    let http_method = "GET"
    let time_out = 30
    let decoder = JSONDecoder()

    func getURLRequest() -> URLRequest! {
        if let url = URL(string: endpoint) {
            var urlReq = URLRequest(url: url)
            urlReq.httpMethod = http_method
            urlReq.timeoutInterval = TimeInterval(time_out)
            return urlReq
        }
        
        return .none
    }
    
    let task = URLSession.shared.dataTask(with: getURLRequest() ) { ( rdata, response, error ) in
        
        var status : Int? = 400
        if response != nil {
            let result = response as! HTTPURLResponse
            status = result.statusCode
        }
        
        if status == 200, let data = rdata {

            do { syncData = try decoder.decode(NewPDT.self, from: data)
            } catch {
                print(error)
            }
            
        }
        
        status = nil
        
        //MARK - for Sync
        semaphore.signal()
    }
    
    task.resume()
    
    //MARK: - for Sync
    _ = semaphore.wait(timeout: .distantFuture)
    
    return syncData
    
}

