//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Obai Alnajjar on 5/27/19.
//  Copyright © 2019 Obai Alnajjar. All rights reserved.
//

import Foundation
struct PhotosJSON: Codable{
    var page: Int
    var pages: Int
    var perpage: Int
    var total: String
    var photo: [PhotoJSON]
}

struct PhotoJSON: Codable {
    var id: String
    var owner: String
    var secret: String
    var server: String
    var farm: Int
}
