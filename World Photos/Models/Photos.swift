import Foundation

struct PhotosJSON: Codable {
    var photos: Photos
}
struct Photos: Codable{
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
    var title: String
}
