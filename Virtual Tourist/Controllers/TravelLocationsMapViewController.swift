//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Obai Alnajjar on 5/26/19.
//  Copyright © 2019 Obai Alnajjar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        context = persistentContainer.viewContext
        setupFetchedResultsController()
        setupLongPress()
        
    }
    
    func setupLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
    }
    
    func setupFetchedResultsController(){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func addPin(gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.location(in: mapView)
        let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates

        let pin = Pin(context: context)
        pin.latitude = Float(coordinates.latitude)
        pin.longitude = Float(coordinates.longitude)
        
        do {
            try context.save()
            mapView.addAnnotation(annotation)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        var annotations = [MKAnnotation]()
        
        fetchedResultsController.fetchedObjects?.forEach{ pin in
            let lat = CLLocationDegrees(pin.latitude)
            let lon = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
}
