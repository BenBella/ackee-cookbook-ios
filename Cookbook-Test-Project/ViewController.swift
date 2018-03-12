//
//  ViewController.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 11/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

extension UIViewController {
    func appIsActive() -> SignalProducer<Bool, NoError> {
        
        // Track whether app is in foreground
        
        let notificationCenter = NotificationCenter.default
        let didBecomeActive = notificationCenter.reactive.notifications(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil).producer
        let willBecomeInactive = notificationCenter.reactive.notifications(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil).producer
        
        let appIsActive: SignalProducer<Bool, NoError> = SignalProducer.init([
            didBecomeActive.map { _ in true },
            willBecomeInactive.map { _ in false }
            ]).flatten(FlattenStrategy.merge)
        
        return appIsActive
    }
    
    func isActive() -> SignalProducer<Bool, NoError> {
        
        // Track whether view is visible
        
        let viewWillAppear = self.reactive.signal(for: #selector(UIViewController.viewWillAppear(_:))).producer
        let viewWillDisappear = self.reactive.signal(for: #selector(UIViewController.viewWillDisappear(_:))).producer
        
        let viewIsVisible: SignalProducer<Bool, NoError> = SignalProducer.init([
            viewWillAppear.map { _ in true },
            viewWillDisappear.map { _ in false }
            ]).flatten(FlattenStrategy.merge)
        
        return viewIsVisible
    }
}
