//
//  YourLocationViewController.swift
//  weather-tvOS
//
//  Created by Joshua Hobson on 8/14/18.
//  Copyright © 2018 Joshua Hobson. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class YourLocationViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var nextDayButton: UIButton!
    
    // MARK: - Video Background
    var avPlayer:AVPlayer!
    var avPlayerLayer:AVPlayerLayer!
    
    // MARK: - Location Properties
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    //MARK: - Weather Properties
    var weatherArray = [WeatherData]()
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initVideoBackground()
        setupLocationServices()
        getDate()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.pause()
    }
    
    // MARK: - Functions
    
    func getDate(){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let result = formatter.string(from: date)
        datelabel.text = result
        
    }
    
    
    
    func initVideoBackground(){
        avPlayer = AVPlayer(playerItem:preparePlayerItem(withIcon: Icon.cloudy))
        avPlayerLayer = AVPlayerLayer(player:avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
    }
    
    @objc func playerItemDidReachEnd(notification:Notification){
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seek(to: kCMTimeZero, completionHandler: nil)
        
    }
    
    
    func preparePlayerItem(withIcon icon:Icon) -> AVPlayerItem {
        return AVPlayerItem(url: Bundle.main.url(forResource: icon.rawValue, withExtension: "mp4")!)
    }
    
    // MARK: - Location Services
    
    // Get Location
    func setupLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager.delegate = self
            
            if CLLocationManager.authorizationStatus() == .notDetermined{
                locationManager.requestWhenInUseAuthorization()
            }
                else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
            {
                locationManager.requestLocation()
            }
            
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // Handle authorization changes
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            manager.requestLocation()
        }
    }
    
    
    // Handle location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    manager.stopUpdatingLocation()
        if let locationObject = locations.first{
            currentLocation = locationObject
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks:[CLPlacemark]?, error:Error?) in
                if error == nil {
                    guard let cityName = placemarks?.first?.locality else{return}
                    
                    DispatchQueue.main.async {
                        self.locationLabel.text = cityName
                    }
                }
            })
            getWeatherForLocation(location: locationObject, andForecastIndex: 0)

        }
        
        
    }
        
    
    //MARK: - Weather
    
    func getWeatherForLocation (location:CLLocation, andForecastIndex index:Int){
        
        WeatherManager.weatherForLocation(location: location) {
            
            (dataArray:[WeatherData]?) in
            
            if let weatherData = dataArray {
                self.weatherArray = weatherData
                print(self.weatherArray)
            }
            
        }
        
    }
    
    
    
    
    // MARK: - UI Interactions
    @IBAction func nextDay(_ sender: UIButton) {
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
