//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Obai Alnajjar on 5/26/19.
//  Copyright © 2019 Obai Alnajjar. All rights reserved.
//

import Foundation

struct FlickrAPI {
    let scheme = "https"
    let host = "flickr.com"
    let path = "/services/rest"
    var latitude: Double = -1
    var longitude: Double = -1
    var bbox: String {
        let lowerLonBound = "\(max(longitude - 0.2, -180.0))"
        let lowerLatBound = "\(max(latitude  - 0.2, -90.0))"
        let upperLonBound = "\(min(longitude + 0.2, 180.0))"
        let upperLatBound = "\(min(latitude  + 0.2, 90.0))"
        return "\(lowerLonBound),\(lowerLatBound),\(upperLonBound),\(upperLatBound)"
    }
    var queries: [String:String] {
        return [
            "api_key":"cff5b90024cb048187170551d75411e7",
            "method":"flickr.photos.search",
            "bbox":"\(bbox)",
            "lat":"\(latitude)",
            "lon":"\(longitude)",
            "page": "\(Int.random(in: 1..<10))",
            "per_page": "30",
            "format":"json",
            "nojsoncallback":"1"]
    }
    
    func getURL() -> URL{
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = []
        
        queries.forEach{ key, val in
            urlComponents.queryItems?.append(URLQueryItem(name: key, value: val))
        }
        
        return urlComponents.url!
    }
}
