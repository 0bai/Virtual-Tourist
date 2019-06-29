//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Obai Alnajjar on 5/26/19.
//  Copyright © 2019 Obai Alnajjar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate, NSFetchedResultsControllerDelegate, ConnectionDelegate {
    @IBOutlet weak var noImagesLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var new: UIButton!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var location: PinAnnotation!
    var numberOfPhotos: Int?
    var saveObserverToken: Any?
    var cached : Double!
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var movedIndexPaths: [[IndexPath:IndexPath]]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ConnectionManager.delegate = self
        setupFetchedResultsController()
        addSaveNotificationObserver()
        setupLongPress()
        cached = fetchedResultsController.fetchedObjects?.count ?? 0 > 0 ? 0.0 : 0.5
        if fetchedResultsController.fetchedObjects?.count ?? 0 == 0 {
            newCollection(self)
        }
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    deinit {
        removeSaveNotificationObserver()
    }
    
    func setupFetchedResultsController(){
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", location.pin)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(location.pin)-photos")
        
        fetchedResultsController.delegate = self
        
        new.isEnabled = true
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        do {
            fetchedResultsController.fetchedObjects?.forEach{ photo in
                dataController.viewContext.delete(photo)
            }
            try dataController.viewContext.save()
            collectionView.reloadData()
            cached = 0.5
            ConnectionManager.getPhotoAlbum(pinID: location.pin.objectID, coordinates: location.coordinate)
        } catch{
            print(error.localizedDescription)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(sharePhoto(gestureRecognizer:)))
        longPress.minimumPressDuration = 1.0
        collectionView.addGestureRecognizer(longPress)
    }
    
    @objc func sharePhoto(gestureRecognizer: UIGestureRecognizer){
        guard gestureRecognizer.state == UIGestureRecognizer.State.began else {
            return
        }

        let photoIndex = gestureRecognizer.location(in: self.collectionView)
        
        if let indexPath = self.collectionView.indexPathForItem(at: photoIndex) {
            let activityController = UIActivityViewController(activityItems: [UIImage(data:fetchedResultsController.object(at: indexPath).image!)!], applicationActivities: nil)
            
//            activityController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
//                if completed{
//                    self.save()
//                }
//            }
            
            present(activityController, animated: true, completion: nil)
            
            if let popover = activityController.popoverPresentationController {
                popover.sourceView = self.view
            }
        } else {
            print("couldn't find index path")
        }
    }
}

//MARK:- ConnectionManager Delegate
extension PhotoAlbumViewController{
    
    func listRetrieved(size: Int) {
        
        guard size > 0 else {
            DispatchQueue.main.sync {
                self.collectionView.isHidden = true
                self.noImagesLabel.isHidden = false
            }
            return
        }
        
        numberOfPhotos = size
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func serverError(error: String, details: String) {
        Alert.show(title: error, message: details, sender: self, completion: {return})
    }
}

//MARK:- CollectionView Delegate
extension PhotoAlbumViewController{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        
        
        if indexPath.row < fetchedResultsController.sections?[0].numberOfObjects ?? -1 {
            cell.addImage(data: fetchedResultsController.object(at: indexPath).image, delay: cached)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 130.0, height: 130.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            let objectToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(objectToDelete)
            try dataController.viewContext.save()
            collectionView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }
}

//MARK:- MapView Delegate
extension PhotoAlbumViewController {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        mapView.addAnnotation(location)
        mapView.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
    
}

//MARK:- Notification Functions
extension PhotoAlbumViewController {
    
    func addSaveNotificationObserver() {
        removeSaveNotificationObserver()
        saveObserverToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: dataController?.viewContext, queue: nil, using: handleSaveNotification(notification:))
    }
    
    func removeSaveNotificationObserver() {
        if let token = saveObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func handleSaveNotification(notification:Notification) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

//MARK:- NSFetchedResultsController Delegate
extension PhotoAlbumViewController {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: insertedIndexPaths)
            collectionView.deleteItems(at: deletedIndexPaths)
            collectionView.reloadItems(at: updatedIndexPaths)
            movedIndexPaths.forEach({ (item) in
                collectionView.moveItem(at: item.keys.first!, to: item.values.first!)
            })
        }, completion: {finished in
            self.insertedIndexPaths = nil
            self.deletedIndexPaths = nil
            self.updatedIndexPaths = nil
            self.movedIndexPaths = nil
        })
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        movedIndexPaths = [[IndexPath:IndexPath]]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
        case .move:
            movedIndexPaths.append([indexPath!:newIndexPath!])
            break
        @unknown default:
            fatalError()
        }
    }
}
