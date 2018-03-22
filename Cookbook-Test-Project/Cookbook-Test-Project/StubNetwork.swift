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
            switch (url, method) {
            case ("recipes", .get):
                let path = testBundle.path(forResource: "recipes", ofType: "json")
                let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    sink.send(value: json)
                    sink.sendCompleted()
                } catch {
                    sink.send(error: NetworkError(error: (error as NSError), request: nil, response: nil))
                    return
                }
            case ("recipe", .get):
                let path = testBundle.path(forResource: "recipes", ofType: "json")
                let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    sink.send(value: json)
                    sink.sendCompleted()
                } catch {
                    sink.send(error: NetworkError(error: (error as NSError), request: nil, response: nil))
                    return
                }
            case ("recipe", .post):
                sink.send(value: true)
                sink.sendCompleted()
            case ("recipe", .delete):
                sink.send(value: true)
                sink.sendCompleted()
            case ("recipe/ratings", .post):
                sink.send(value: true)
                sink.sendCompleted()
            default:
                sink.send(error: NetworkError(error: NSError(domain: "cookbook.stubnetwork.error", code: 0, userInfo: nil), request: nil, response: nil))
            }
        }
    }
    
}
