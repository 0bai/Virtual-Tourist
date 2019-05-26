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
    var latitude: Float = -1
    var longitude: Float = -1
    var queries: [String:String] {
        return [
            "api_key":"cff5b90024cb048187170551d75411e7",
            "method":"flickr.photos.search",
            "bbox":"-180,-90,180,90",
            "lat":"\(latitude)",
            "lon":"\(longitude)",
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
