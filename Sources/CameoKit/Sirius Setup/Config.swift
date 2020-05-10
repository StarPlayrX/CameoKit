import Foundation

public func Config()  {
    
   let endpoint = http + root +  "/get/configuration?result-template=html5&app-region=US"
    
   let config = GetSync(endpoint: endpoint, method: "config")
    
    /* get patterns and encrpytion keys */
    if let s = config.value( forKeyPath: "ModuleListResponse.moduleList.modules" ), let p = s as? NSArray, let x = p[0] as? NSDictionary,
       let customAudioInfos = x.value( forKeyPath: "moduleResponse.configuration.components" ) as? NSArray {
        let str = "relativeUrls"
        for i in customAudioInfos {
            if let a = i as? NSDictionary, let name = a["name"] as? String, name == str, let streamUrls = a.value( forKeyPath: "settings.relativeUrls" ) as? NSArray, let streamRoots = (streamUrls[0]) as? NSArray {
                
                for j in streamRoots {
                    if let b = j as? NSDictionary, let streamName = b["name"] as? String, let streamUrl = b["url"] as? String {
                        hls_sources[streamName] = streamUrl
                        UserDefaults.standard.set(hls_sources, forKey: "hls_sources")
                    } else {
                        
                        if let hls = UserDefaults.standard.dictionary(forKey: "hls_sources") as? Dictionary<String, String> {
                            hls_sources = hls
                        }
                    }
                }
            } else {
                
                if let hls = UserDefaults.standard.dictionary(forKey: "hls_sources") as? Dictionary<String, String> {
                    hls_sources = hls
                }
                
            }
        }
    }


}
