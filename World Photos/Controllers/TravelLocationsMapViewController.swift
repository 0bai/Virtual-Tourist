import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, ConnectionDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var location: PinAnnotation!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ConnectionManager.delegate = self
        setupFetchedResultsController()
        setupLongPress()
        mapView.selectedAnnotations.forEach{ annotation in
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
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
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func addPin(gestureRecognizer: UIGestureRecognizer){
        guard gestureRecognizer.state == UIGestureRecognizer.State.began else {
            return
        }
        let point = gestureRecognizer.location(in: mapView)
        let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        
        do {
            try dataController.viewContext.save()
            ConnectionManager.getPhotoAlbum(pinID: pin.objectID, coordinates: CLLocationCoordinate2DMake(pin.latitude, pin.longitude))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "showAlbum"{
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.topViewController as! PhotoAlbumViewController
            vc.dataController = dataController
            vc.location = location
        }
    }
}

//MARK:- ConnectionManager Delegate
extension TravelLocationsMapViewController {
    
    func listRetrieved(size: Int) {
        print(size)
    }
    
    func serverError(error: String, details: String) {
        Alert.show(title: error, message: details, sender: self, completion: {return})
    }
}

//MARK:- MapView Delegate
extension TravelLocationsMapViewController {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        var annotations = [PinAnnotation]()
        
        fetchedResultsController.fetchedObjects?.forEach{ pin in
            let annotation = PinAnnotation(pin: pin)
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        location = view.annotation as? PinAnnotation
        self.performSegue(withIdentifier: "showAlbum", sender: self)
    }
}

//MARK:- NSFetchedResultsController Delegate
extension TravelLocationsMapViewController {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            mapView.addAnnotation(PinAnnotation(pin: anObject as! Pin))
            break
        case .delete:
            mapView.removeAnnotation(PinAnnotation(pin: anObject as! Pin))
            break
        case .move:
            mapView.addAnnotation(PinAnnotation(pin: anObject as! Pin))
            break
        case .update:
            mapView.addAnnotation(PinAnnotation(pin: anObject as! Pin))
            break
        @unknown default:
            fatalError()
        }
    }
}

