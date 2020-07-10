//
//  ApiService.swift
//  Movie Browser
//
//  Created by Mohseen Shaikh on 04/05/20.
//  Copyright © 2020 XYZ. All rights reserved.
//

import Foundation

/// An abstraction for all the api service in the app.
protocol APIServiceProtocol {
    
    func fetchPopularMoviesData(pageNumber: Int, completion: @escaping (Result<ServiceResponseVO, Error>) -> Void)
}


class APIService: APIServiceProtocol {
    
    func fetchPopularMoviesData(pageNumber: Int, completion: @escaping (Result<ServiceResponseVO, Error>) -> Void) {
        
        var param = WebserviceParameter.init(httpMethod: .GET)
        param.url = WebserviceManager.sharedInstance.getMostPopularUrl()
        param.body = ["api_key":"8c5eb7947a0c3c7d81216fe562c7cc6d",
                      "language":"en-US",
                      "page":"\(pageNumber)"]
        
        WebserviceManager.sharedInstance.fetchDataFromServer(parameter: param) { (data, error) in
            if let error = error
            {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(HTTPError.HTTPErrorInvalidResponse))
                return
            }
            
            let decoder = JSONDecoder.init()
            do
            {
                let responseObject = try decoder.decode(ServiceResponseVO.self, from: data)
                completion(.success(responseObject))
            }
            catch(let exception)
            {
                completion(.failure(exception))
            }
        }
    }
}

