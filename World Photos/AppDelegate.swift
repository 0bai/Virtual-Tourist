import UIKit
import CoreData

@UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let dataController = DataController.init(modelName: "World-Photos")
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load()
        
        let travelLocationMapViewController = window?.rootViewController as! TravelLocationsMapViewController
        travelLocationMapViewController.dataController = dataController
        
        ConnectionManager.dataController = dataController
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }
    
    func saveContext(){
        try? dataController.viewContext.save()
    }
}

