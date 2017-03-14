//
//  PhotoDownlaoder.swift
//  Virtual Tourist
//
//  Created by Ricardo Barbosa on 14/03/17.
//  Copyright © 2017 STI-UFPB. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoDownlaoder: NSObject {
  
  func download(pin: Pin) {
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    for photo in pin.photos?.array as! [Photo] {
      managedContext.delete(photo)
    }
    
    let baseURL = "https://api.flickr.com/services/rest/?&method=flickr.photos.search"
    let apiString = "&api_key=e86a1f8a8d13068a4341545a51bea638"
    let searchString = "&lat=\(pin.latitude)&lon=\(pin.longitude)"
    let format = "&format=json"
    let page = "&page=\(pin.page)"
    
    let session = URLSession.shared
    let url = URL(string: baseURL + apiString + searchString + format + page)
    
    let task = session.dataTask(with: url!) { (data, response, error) in
      
      guard (error == nil) else {
        print("There was an error with your request: \(error)")
        return
      }
      
      /* GUARD: Was there any data returned? */
      guard let data = data else {
        print("No data was returned by the request!")
        return
      }
      
      
      var stringJson = String(data: data, encoding: .utf8)!
      stringJson = (stringJson as NSString).replacingOccurrences(of: "jsonFlickrApi(", with: "")
      stringJson = (stringJson as NSString).replacingOccurrences(of: "})", with: "}")
      
      let parsedResult : Dictionary<String, Any>
      do {
        let any = try JSONSerialization.jsonObject(with: stringJson.data(using: .utf8)!, options: .allowFragments)
        parsedResult = any as! Dictionary<String, Any>
        
        let root  = parsedResult["photos"] as! Dictionary<String, Any>
        let photosJson = root["photo"] as! [Dictionary<String, Any>]
        let page = (root["page"] as? Int16) ?? 1
        let pages = (root["pages"] as? Int16) ?? 1
        
        for photoJson in photosJson {
          let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: managedContext) as! Photo
          
          //https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
          let farm_id = photoJson["farm"] as! Int
          let server_id = photoJson["server"] as! String
          let id = photoJson["id"] as! String
          let secret = photoJson["secret"] as! String
          
          let stringUrlPhoto = "https://farm\(farm_id).staticflickr.com/\(server_id)/\(id)_\(secret).jpg"
          
          photo.url = stringUrlPhoto
          photo.startDownloadPhoto() { o in
            if o.image != nil {
              let managedContext = appDelegate.persistentContainer.viewContext
              do {
                try managedContext.save()
              } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
              }
              
            }
          }
          photo.pin = pin
          pin.addToPhotos(photo)
        }
        
        pin.page = (page+1 > pages) ? 1 : page+1
        pin.pages = pages
        
        do {
          try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
        
        
        
      } catch let ex {
        print(ex)
        let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
      }
      
    }
    
    task.resume()
    

  }
}
