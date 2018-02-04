//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Sebastian Prokesch on 14.01.18.
//  Copyright © 2018 Sebastian Prokesch. All rights reserved.
//

import Foundation
import CoreLocation

class FlickrClient {
    static let urlScheme = "https"
    static let apiHost = "api.flickr.com"
    static let apiPath = "/services/rest"
    
    static let APIKey = "149a077a41ffcdc3080c9a6546ee1696"
    
    enum PossibleSorts: String {
        case DatePostedAsc = "date-posted-asc"
        case DatePostedDesc = "date-posted-desc"
        case DateTakenAsc = "date-taken-asc"
        case DateTakenDesc = "date-taken-desc"
        case InterestingnesDesc = "interestingness-desc"
        case InterestingnesAsc = "interestingness-asc"
        case Relevance = "relevance"
        
        static func randomSort() -> PossibleSorts {
            let rand = Int(arc4random_uniform(7))
            return PossibleSorts.fromHashValue(hashValue: rand)
        }
        
        static func fromHashValue(hashValue: Int) -> PossibleSorts {
            switch hashValue {
            case 0:
                return .DatePostedAsc
            case 1:
                return .DatePostedDesc
            case 2:
                return .DateTakenAsc
            case 3:
                return .DateTakenDesc
            case 4:
                return .InterestingnesDesc
            case 5:
                return .InterestingnesAsc
            default:
                return .Relevance
            }
        }
    }
    
    var methodParameters = ["extras": "url_m",
                            "method": "flickr.photos.search",
                            "api_key": FlickrClient.APIKey,
                            "format": "json",
                            "nojsoncallback": "1"
                            ]
    
    
    func getPhotosList(location: CLLocationCoordinate2D, handler: @escaping (_ success: Bool, _ errorString: NSError?, _ result: [String: AnyObject]?) -> Void) {
        // network code to get photos list
        
        methodParameters["lat"] = String(location.latitude)
        methodParameters["lon"] = String(location.longitude)
        methodParameters["radios"] = "2"
//        methodParameters["per_page"] = "250"
        methodParameters["sort"] = PossibleSorts.randomSort().rawValue
        
        
        var urlString = FlickrClient.urlScheme + "://" + FlickrClient.apiHost + FlickrClient.apiPath + escapedParameters(methodParameters as [String: AnyObject])
//        var components = URLComponents()
//        components.scheme = FlickrClient.urlScheme
//        components.host = FlickrClient.apiHost
//
//        let path =  FlickrClient.apiPath + escapedParameters(methodParameters as [String: AnyObject])
//        components.path = path
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                handler(false, NSError(domain: "execRequest", code: 1, userInfo: userInfo), nil)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
                sendError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            // return back to calling (block) with list/dict of pictures
            handler(true, nil, parsedResult)
        
        }
        
//            {
//                farm = 8;
//                "height_m" = 333;
//                id = 7276658202;
//                isfamily = 0;
//                isfriend = 0;
//                ispublic = 1;
//                owner = "79468477@N08";
//                secret = 83373a90ed;
//                server = 7215;
//                title = "IMG_0248 Werntalbahn";
//                "url_m" = "https://farm8.staticflickr.com/7215/7276658202_83373a90ed.jpg";
//                "width_m" = 500;
//        }
        
        task.resume()
    }
    
    func loadPhotos(imageURLs: [URL]) {
        // load all photos
    }
    
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
//    private func apiURLFromParameters(baseURL_ parameters: [String:String], withPathExtension: String? = nil) -> URL {
//
//        var components = URLComponents()
//        components.scheme = FlickrClient.urlScheme
//        components.host = FlickrClient.apiHost
//        components.path = FlickrClient.apiPath + (withPathExtension ?? "")
//        components.queryItems = [URLQueryItem]()
//
//        for (key, value) in parameters {
//            let queryItem = URLQueryItem(name: key, value: "\(value)")
//            components.queryItems!.append(queryItem)
//        }
//
//        return components.url!
//    }
    
    // MARK: Helper for Escaping Parameters in URL
    
    private func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
}
