//
//  ConnectionManager.swift
//  Virtual Tourist
//
//  Created by Obai Alnajjar on 5/26/19.
//  Copyright © 2019 Obai Alnajjar. All rights reserved.
//


import Foundation

@objc protocol ConnectionDelegate{
    
    func photosRetrieved()
    func serverError(error:String, details: String)
    
}

class ConnectionManager {
    
    static var delegate:ConnectionDelegate!
    static var sessionURL = URLComponents()
    static var userURL = URLComponents()
    
    
    static func fireRequest(url:URLComponents, headers:[String:String]?, body:Data?, responseHandler:@escaping (_ data:Data, _ response:URLResponse?, _ error:Error?)->()) {
        
        var request = URLRequest(url: url.url!)
        
        headers?.forEach{(key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = body
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                self.delegate?.serverError(error: "Connection Error", details: "Please check your internet connection!")
                return
            }
            
            switch statusCode {
            case 200 ... 299 :
                responseHandler(data!, response, error)
            default :
                self.delegate?.serverError(error: "Server Error", details: "Something went wrong!")
                
            }
        }
        
        task.resume()
    }
    
    static func encode<T:Codable>(object:T) -> Data{
        
        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(object)
            return json
        } catch {
            self.delegate?.serverError(error: "Internal Error", details: "something went wrong while wrapping the data!")
            return "{\"error\": \"something went wrong while encoding\"}".data(using: .utf8)!
        }
    }
    
    static func decode<T: Codable>(data:Data, type:T.Type) -> Codable{
        do {
            let decoder = JSONDecoder()
            let genericObject =  try decoder.decode(type.self, from: data)
            return genericObject
        } catch  {
            print("error while decoding \(type)")
            delegate?.serverError(error: "Internal Error", details: "Error while unwrapping the data!")
            return error as! Codable
        }
    }
}






