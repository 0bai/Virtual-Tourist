import Foundation
import CoreData
import MapKit
class PinAnnotation: NSObject, MKAnnotation {
    
    var pin: Pin
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2DMake(pin.latitude, pin.longitude) }
    
    init(pin: Pin) {
        self.pin = pin
        super.init()
    }
}
