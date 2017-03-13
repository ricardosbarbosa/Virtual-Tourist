//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by STI-UFPB on 13/03/17.
//  Copyright © 2017 STI-UFPB. All rights reserved.
//

import UIKit
import CoreData

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var photo : Photo? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    func updateUI() {
        if let image = photo?.image {
            imageView.image = image
        }
        else {
            indicator.startAnimating()
        }
    }
    
}
