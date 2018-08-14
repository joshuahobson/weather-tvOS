//
//  WeatherManager.swift
//  Weather
//
//  Created by Brian Advent on 02/02/2017.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import Foundation
import CoreLocation

struct WeatherManager {

    static var exploreCaliforniaClient = ECWeather()
    
    public static func weatherForLocation (location:CLLocation, completion: @escaping (_ forecastArray: [WeatherData]?) -> Void){
        
               
        WeatherManager.exploreCaliforniaClient.dailyForecast(location.coordinate) { result in
            if result.error() == nil {
                if let forecastDataList = result.data()!["forecast"] as? [Dictionary<String,Any>] {
                    var forecastData = [WeatherData]()
                    
                    for dataPoint in forecastDataList {
                        let temperature = dataPoint["temp_max"] as! NSNumber
                        let summary = dataPoint["condition_desc"] as! String
                        let icon = Icon(rawValue: dataPoint["condition_name"] as! String)
                        
                        let weatherData = WeatherData(temperature: temperature as? Float, icon: icon, summary: summary)
                        forecastData.append(weatherData)
                        
                    }
                    
                    completion(forecastData)
                    
                }
            }
            
           
        }
        
    }
    
    
    
    
}
