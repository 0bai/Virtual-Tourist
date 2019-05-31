//
//  Alert.swift
//  Virtual Tourist
//
//  Created by Obai Alnajjar on 5/31/19.
//  Copyright © 2019 Obai Alnajjar. All rights reserved.
//

import Foundation
import UIKit

class Alert{
    
    public static func show(title:String, message: String, sender: UIViewController, completion: @escaping ()->()){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {
            action in completion()
        }))
        sender.present(alert, animated: true, completion: nil)
    }
}

