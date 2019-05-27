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
    var serverID: String = ""
    var photoID: String = ""
    var secret: String = ""
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
        urlComponents.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")]
        return urlComponents.url!
    }
}
