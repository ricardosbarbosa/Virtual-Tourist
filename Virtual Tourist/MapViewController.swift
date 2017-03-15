//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by STI-UFPB on 13/03/17.
//  Copyright © 2017 STI-UFPB. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
  
  var pins : [Pin] = []
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    
    /* The center of the map and the zoom level should be persistent */
    loadTheCenterMapAndLocation()
    
    loadAllThePinsSaved()
  }
  
  func loadTheCenterMapAndLocation() {
    
    guard
      let latitude = UserDefaults.standard.object(forKey: "latitude") as? Double,
      let longitude = UserDefaults.standard.object(forKey: "longitude") as? Double,
      let latitudeDelta = UserDefaults.standard.object(forKey: "latitudeDelta") as? Double,
      let longitudeDelta = UserDefaults.standard.object(forKey: "longitudeDelta") as? Double
      
      else {
        
        return
    }
    let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    let region = MKCoordinateRegion(center: center, span: span)
    mapView.setRegion(region, animated: true)
  }
  
  func loadAllThePinsSaved() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    do {
      pins = try managedContext.fetch(Pin.fetchRequest())
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    for pin in pins {
      mapView.addAnnotation(pin)
    }
  }
  
  @IBAction func addPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == .began {
      print("add a pin")
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
          return
      }
      
      let managedContext = appDelegate.persistentContainer.viewContext
      let pin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: managedContext) as! Pin
      
      let touchPoint = gestureRecognizer.location(in: mapView)
      let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
      
      pin.coordinate = newCoordinates
      mapView.addAnnotation(pin)
      
      /*When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved. */
      pin.latitude = pin.coordinate.latitude
      pin.longitude = pin.coordinate.longitude
      
      do {
        try managedContext.save()
        pins.append(pin)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
  
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? PhotoAlbumViewController {
      if let pin = mapView.selectedAnnotations[0] as? Pin {
        vc.pin = pin
      }
      
    }
  }
}

extension MapViewController : MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    print("pin tapped")
    
    //When a pin is tapped, the app transitions to the photo album associated with the pin location.
    performSegue(withIdentifier: "PhotoAlbumViewController", sender: nil)
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    saveTheZoomAndCenter()
  }
  
  func saveTheZoomAndCenter() {
    let center = mapView.centerCoordinate
    UserDefaults.standard.set(center.latitude, forKey: "latitude")
    UserDefaults.standard.set(center.longitude, forKey: "longitude")
    let zoom = mapView.region
    UserDefaults.standard.set(zoom.span.latitudeDelta, forKey: "latitudeDelta")
    UserDefaults.standard.set(zoom.span.longitudeDelta, forKey: "longitudeDelta")
  }
}
