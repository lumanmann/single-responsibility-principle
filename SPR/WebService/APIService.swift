//
//  APIService.swift
//  SPR
//
//  Created by WY NG on 12/10/2019.
//  Copyright © 2019 natalie. All rights reserved.
//

import Foundation

final class APIService {
    
    func doLogin(account: String, password: String, completion: @escaping (Bool?, Error?) -> Void) {
        let urlString = "https://localhost:3000/login"
        
        request(urlString: urlString, parameters: ["account": account, "password": password]) {(data, error) in
            
            guard error == nil else {
                completion(nil, error!)
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            guard let result = try? JSONDecoder().decode(LoginResponseModel.self, from: data) else {
                completion(nil, nil)
                return
            }
            
            completion(result.result, nil)
            
        }
    }
    
    private func request(urlString: String, parameters: [String: Any], completion: @escaping (Data?, Error?) -> Void){
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        var request = URLRequest(url: url)
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        }catch let error{
            completion(nil, error)
        }
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        fetch(request: request, completion: completion)
    }
    
    private func fetch(request: URLRequest, completion: @escaping (Data?, Error?) -> Void){
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil, error!)
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            completion(data, nil)
        }
        task.resume()
    }
    
    
    
}
