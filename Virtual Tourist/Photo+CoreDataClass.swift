//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by STI-UFPB on 13/03/17.
//  Copyright © 2017 STI-UFPB. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol PhotoProtocol {
  func downloadFinished(photo: Photo)
}

public class Photo: NSManagedObject {
  
    var photoProtocol : PhotoProtocol?
  
    func startDownloadPhoto(completionHandler: @escaping (_ photo: Photo) -> Void) {
        
        let session = URLSession.shared
        let urlPhoto = URL(string: self.url!)
        
        let task = session.dataTask(with: urlPhoto!) { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            self.image = UIImage(data: data)
            self.photoProtocol?.downloadFinished(photo: self)
            self.pin?.pinProtocol?.downloadFinished(pin: self.pin!)
            completionHandler(self)
        }
        
        task.resume()
    }
}
