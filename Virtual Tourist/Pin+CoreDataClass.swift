//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by STI-UFPB on 13/03/17.
//  Copyright © 2017 STI-UFPB. All rights reserved.
//

import Foundation
import CoreData
import MapKit

protocol PinProtocol {
  func downloadFinished(pin: Pin)
}
public class Pin: NSManagedObject , MKAnnotation {
  
    var pinProtocol : PinProtocol?
  
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(latitude , longitude)
        }
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }

}
