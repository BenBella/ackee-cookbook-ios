//
//  StubNetwork.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 20/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift

class StubNetwork: Networking {

    init() {

    }
    
    func request(_ url: String, method: Alamofire.HTTPMethod = .get, parameters: [String: Any]?, encoding: ParameterEncoding = URLEncoding.default, headers: [String: String]?, useDisposables: Bool) -> SignalProducer<Any?, NetworkError> {
        
        return SignalProducer { sink, disposable in
            
            let testBundle = Bundle(for: type(of: self))
            var path: String?
            // TODO: This should be done in more conceptual fashion
            let endPoint = url.replacingOccurrences(of: "https://cookbook.ack.ee/api/v1/", with: "")
            switch (endPoint, method) {
            case ("recipes", .get):
                path = testBundle.path(forResource: "recipes", ofType: "json")
            default:
                path = testBundle.path(forResource: "recipes", ofType: "json")
            }
            let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                sink.send(value: json)
                sink.sendCompleted()
            } catch {
                sink.send(error: NetworkError(error: (error as NSError), request: nil, response: nil))
                return
            }
        }
    }
}
