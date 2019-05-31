//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Obai Alnajjar on 5/26/19.
//  Copyright © 2019 Obai Alnajjar. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let dataController = DataController.init(modelName: "Virtual_Tourist")
    
    
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

