//
//  ECWeather.swift
//  Weather
//
//  Created by Brian Advent on 23/03/2017.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import Foundation
import CoreLocation

extension String {
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string,
                                         with: replacement,
                                         options: NSString.CompareOptions.literal,
                                         range: nil)
    }
    
    func replaceWhitespace() -> String {
        return self.replace(" ", replacement: "+")
    }
}




fileprivate struct Const {
    static let basePath = "http://explorecalifornia.org/api/weather"
}

open class ECWeather {
    public enum TemperatureFormat: String {
        case Celsius = "metric"
        case Fahrenheit = "imperial"
    }
    
    public enum Result {
        case success(URLResponse?, NSDictionary?)
        case Error(URLResponse?, NSError?)
        
        public func data() -> NSDictionary? {
            switch self {
            case .success(_, let dictionary):
                return dictionary
            case .Error(_, _):
                return nil
            }
        }
        
        public func response() -> URLResponse? {
            switch self {
            case .success(let response, _):
                return response
            case .Error(let response, _):
                return response
            }
        }
        
        public func error() -> NSError? {
            switch self {
            case .success(_, _):
                return nil
            case .Error(_, let error):
                return error
            }
        }
    }

    
    open func dailyForecast(_ coordinate: CLLocationCoordinate2D, callback: @escaping (Result) -> ()) {
        call("/lat/\(coordinate.latitude)/lng/\(coordinate.longitude)/qty/1", callback: callback)
        
    }
    
    
    fileprivate func call(_ method: String, callback: @escaping (Result) -> ()) {
        let url = Const.basePath  + method 
        let request = URLRequest(url: URL(string: url)!)
        let currentQueue = OperationQueue.current
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            var error: NSError? = error as NSError?
            var resultsArray = [NSDictionary]()
            
            if let data = data {
                do {
                    
                    resultsArray = try JSONSerialization.jsonObject(with: data, options: []) as! [NSDictionary]
    
                } catch let e as NSError {
                    error = e
                    print(error?.localizedDescription ?? "Error parsing JSON")
                }
            }
            currentQueue?.addOperation {
                var result = Result.success(response, resultsArray.first)
                if error != nil {
                    result = Result.Error(response, error)
                }
                callback(result)
            }
        })
        task.resume()
    }
    
      
    

}


