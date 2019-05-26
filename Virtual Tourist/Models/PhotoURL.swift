//
//  PhotoURL.swift
//  Virtual Tourist
//
//  Created by Obai Alnajjar on 5/26/19.
//  Copyright © 2019 Obai Alnajjar. All rights reserved.
//

import Foundation

struct PhotoURL {
    var farmID: Int = -1
    var serverID: Int = -1
    var photoID: Int = -1
    var secret: Int = -1
    let scheme = "https"
    var host: String {
        return "farm\(farmID).staticflickr.com"
    }
    var path: String {
        return "/\(serverID)/\(photoID)_\(secret)_q.jpg"
    }
    
    func getURL() -> URL{
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        return urlComponents.url!
    }
}
