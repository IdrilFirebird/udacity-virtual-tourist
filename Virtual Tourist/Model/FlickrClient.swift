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
    
    
    func getPhotosList(pin: MapPin, handler: @escaping (_ success: Bool, _ error: NSError?, _ result: AnyObject?) -> Void) {
        // network code to get photos list
        
        methodParameters["lat"] = String(pin.coordinate.latitude)
        methodParameters["lon"] = String(pin.coordinate.longitude)
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
     
        taskForGetRequest(request: request) { (success, error, result) in
            if !success {
                handler(success, error, nil)
            } else {
                
                
                // parse the data
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: result as! Data, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    self.sendError("Could not parse the data as JSON: '\(result)'", handler: handler)
                    return
                }
                /* GUARD: Did Flickr return an error (stat != ok)? */
                guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
                    self.sendError("Flickr API returned an error. See error code and message in \(parsedResult)", handler: handler)
                    return
                }
                
                if let photosDict = parsedResult?["photos"] as? [String: AnyObject], let photos = photosDict["photo"] as? [[String: AnyObject]] {
                    
                    DispatchQueue.main.async {
                        let photoRange =  photos.count < 21 ? 0...photos.count : 0...21
                        
                        for _ in photoRange {
                            let index: Int = Int(arc4random_uniform(UInt32(photos.count)))
                            let photoURLString = photos[index]["url_m"] as! String
                            let photo = FlickrPhoto(flickrPhotoUrl: photoURLString, pin: pin, context: CoreDataStack.sharedInstance().managedObjectContext)
                            
                            self.loadPhoto(photo: photo) { (success, error, result) in
                                if !success {
                                    handler(false, error, nil)
                                } else {
                                    CoreDataStack.sharedInstance().saveContext()
                                    handler(true, nil, nil)
                                }
                            }
                        }
                    }
                }
                
            }
            
            
        }
        
    }
    

    
    func loadPhoto(photo: FlickrPhoto, handler: @escaping (_ success: Bool, _ error: NSError?, _ result: AnyObject?) -> Void ) {
        
        let url = URL(string: photo.flickrURL!)!
        let request = URLRequest(url: url)
        
        taskForGetRequest(request: request) { (success, error, data) in
            if !success {
                photo.imagePath = nil
                handler(success, error, nil)
            } else {
                if let result = data {
                    DispatchQueue.main.async {
                        let fileName = (photo.flickrURL! as NSString).lastPathComponent
                        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let imagePath = path + "/Images/" + fileName
                        
//                        do {
//                            try FileManager.default.createDirectory(atPath: path + "/Images", withIntermediateDirectories: false, attributes: nil)
//                        } catch let error as NSError {
//                            print(error)
//                        }
                        
                        FileManager.default.createFile(atPath: imagePath, contents: result as? Data, attributes: nil)
                        
                        photo.imagePath = imagePath
                        handler(true,nil,nil)
                    }
                } else {
                    self.sendError("Couldn't save file", handler: handler)
                }
            }
        }
        
        
        
    }
    
    func taskForGetRequest(request: URLRequest, handler: @escaping (_ success: Bool, _ error: NSError?, _ result: AnyObject?) -> Void) {
    
    
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
    
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.sendError("There was an error with your request: \(error!.localizedDescription)", handler: handler)
                return
            }
    
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                self.sendError("Your request returned a status code other than 2xx!", handler: handler)
                return
            }
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.sendError("No data was returned by the request!", handler: handler)
                return
            }
            
            // return back to calling (block) with list/dict of pictures
            handler(true, nil, data as AnyObject)
    
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
  
    // MARK: Helper functions
    
    private func sendError(_ error: String, handler: (_ success: Bool, _ error: NSError?, _ result: AnyObject?) -> Void) {
        print(error)
        let userInfo = [NSLocalizedDescriptionKey : error]
        handler(false, NSError(domain: "execRequest", code: 1, userInfo: userInfo), nil)
    }
    
//    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
//
//        var parsedResult: AnyObject! = nil
//        do {
//            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
//        } catch {
//            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
//            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
//        }
//
//        completionHandlerForConvertData(parsedResult, nil)
//    }
    
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
