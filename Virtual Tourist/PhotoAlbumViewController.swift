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

extension PhotoAlbumViewController : PinProtocol {
  func downloadFinished(pin: Pin) {
    let arrayPhoto = pin.photos?.array as! [Photo]
    
    let map = arrayPhoto.map() { p in
      p.image != nil
    }
    
    let completed = map.reduce(true) {$0 && $1}
    newCollectionButton.isEnabled = completed
  }
}

extension PhotoAlbumViewController : UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return pin?.photos?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
    
    // Configure the cell
    let photo = pin?.photos?.object(at: indexPath.row) as? Photo
    photo?.photoProtocol = cell
    cell.photo = photo
    
    return cell
  }
  
}

extension PhotoAlbumViewController : UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("selecionou imagem")
    
    let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
      (alert: UIAlertAction!) -> Void in
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let managedContext = appDelegate.persistentContainer.viewContext
      if let photo = self.pin?.photos?.array[indexPath.row] as? Photo{
        managedContext.delete(photo)
        try! managedContext.save()
      }
      
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
      (alert: UIAlertAction!) -> Void in
      
    })
    optionMenu.addAction(deleteAction)
    optionMenu.addAction(cancelAction)
    self.present(optionMenu, animated: true, completion: nil)
  }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    updateUI()
  }
}
class PhotoAlbumViewController: UIViewController {
  
  @IBOutlet var photoDownloader: PhotoDownlaoder!
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
    pin?.pinProtocol = self
    if (pin?.photos?.count ?? 0) == 0 {
      newCollectionAction(newCollectionButton)
    }
    setThePinOnMap()
    updateUI()
  }
  
  func updateUI() {
    collectionView.reloadData()
    labelNoImages.isHidden = (fetchedResultsController.fetchedObjects?.count ?? 0) > 0
    do {
      try fetchedResultsController.performFetch()
    } catch let error as NSError {
      print(error)
    }
  }
  
  func setThePinOnMap() {
    if let pin = pin {
      mapView.addAnnotation(pin)
      mapView.setCenter(pin.coordinate, animated: true)
    }
  }
  
  
  @IBAction func newCollectionAction(_ sender: Any) {
    newCollectionButton.isEnabled = false
    if let pin = pin {
      photoDownloader.download(pin: pin)
    }
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
