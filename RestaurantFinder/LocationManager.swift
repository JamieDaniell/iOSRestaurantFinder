//
//  LocationManager.swift
//  RestaurantFinder
//
//  Created by James Daniell on 13/09/2016.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation
import CoreLocation


extension Coordinate
{
    init(location : CLLocation)
    {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }
}

final class LocationManager: NSObject, CLLocationManagerDelegate
{
    let manager = CLLocationManager()
    var onLocationFix: (Coordinate -> Void)?
    
    func getPremission()
    {
        if CLLocationManager.authorizationStatus() == .NotDetermined
        {
            manager.requestWhenInUseAuthorization()
        }
    }
    override init()
    {
        super.init()
        manager.delegate = self
        manager.requestLocation()
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedWhenInUse
        {
            manager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        // need alert here
        print(error.description)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let location  = locations.first else { return }
        
        let coordinate = Coordinate(location: location)
        if let onLocationFix = onLocationFix
        {
                onLocationFix(coordinate)
        }
        
    }
}





