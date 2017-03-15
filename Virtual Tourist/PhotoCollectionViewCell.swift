//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by STI-UFPB on 13/03/17.
//  Copyright © 2017 STI-UFPB. All rights reserved.
//

import UIKit
import CoreData

extension PhotoCollectionViewCell : PhotoProtocol {
   func downloadFinished(photo: Photo) {
     updateUI()
  }
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var photo : Photo? {
        didSet {
            updateUI()
        }
    }
  
  
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    func updateUI() {
        if let imageData = photo?.image {
          indicator.stopAnimating()
          let image = UIImage(data: imageData)
          imageView.image = image
          imageView.isHidden = false
        }
        else {
          imageView.image = nil
          imageView.isHidden = true
          indicator.startAnimating()
        }
    }
    
}
