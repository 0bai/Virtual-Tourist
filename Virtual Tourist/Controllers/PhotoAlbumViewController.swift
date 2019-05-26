//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Obai Alnajjar on 5/26/19.
//  Copyright © 2019 Obai Alnajjar. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func newCollection(_ sender: Any) {
    }
    

}
