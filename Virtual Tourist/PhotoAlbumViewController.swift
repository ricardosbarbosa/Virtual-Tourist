//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by STI-UFPB on 13/03/17.
//  Copyright © 2017 STI-UFPB. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Foundation

extension PhotoAlbumViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin?.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        
        // Configure the cell
        cell.photo = pin?.photos?.object(at: indexPath.row) as? Photo
        
        return cell
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        collectionView.reloadData()
    }
}
class PhotoAlbumViewController: UIViewController {

    var pin : Pin?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelNoImages: UILabel!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    //MARK: Core Data
    lazy var fetchedResultsController : NSFetchedResultsController<Photo> = {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1 set the location on map as a pin
        setThePinOnMap()
        
        loadThePhotos()
    }
    
    func setThePinOnMap() {
        if let pin = pin {
            mapView.addAnnotation(pin)
            mapView.setCenter(pin.coordinate, animated: true)
        }
    }
    
    func loadThePhotos() {
        do {
            try fetchedResultsController.performFetch()
            verifyIfThereArePhotosSaved()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func verifyIfThereArePhotosSaved() {
        collectionView.isHidden = (fetchedResultsController.fetchedObjects?.count ?? 0) == 0
        labelNoImages.isHidden = (fetchedResultsController.fetchedObjects?.count ?? 0) > 0
    }
    
    

    @IBAction func newCollectionAction(_ sender: Any) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        for photo in fetchedResultsController.fetchedObjects! as [Photo] {
            managedContext.delete(photo)
        }

        let baseURL = "https://api.flickr.com/services/rest/?&method=flickr.photos.search"
        let apiString = "&api_key=e86a1f8a8d13068a4341545a51bea638"
        let searchString = "&lat=\(pin!.latitude)&lon=\(pin!.longitude)"
        let format = "&format=json"
        
        let session = URLSession.shared
            let url = URL(string: baseURL + apiString + searchString + format)
            
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
                
                let max = (photosJson.count > 10) ? 10 : photosJson.count
                for i in 0..<max {
                    let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: managedContext) as! Photo
                    
                    //https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
                    let farm_id = photosJson[i]["farm"] as! Int
                    let server_id = photosJson[i]["server"] as! String
                    let id = photosJson[i]["id"] as! String
                    let secret = photosJson[i]["secret"] as! String
                    
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
                    photo.pin = self.pin
                    self.pin?.addToPhotos(photo)
                }
                
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
