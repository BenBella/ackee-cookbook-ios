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
    
    func showErrorAlert(error: Error, completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController (title: "global.error".localized, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "global.continue".localized, style: UIAlertActionStyle.default) { _ in
            completion?()
        }
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showInfoAlert(time: Double, info: String, completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController (title: "", message: info, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: completion)
        }
    }
    
    func changeRoot(viewController: UIViewController) {
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let snapshot = window.snapshotView(afterScreenUpdates: true) else { return }
        viewController.view.addSubview(snapshot)
        window.rootViewController = viewController
        UIView.animate(withDuration: 0.35, animations: {
            snapshot.layer.opacity = 0
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: { (_) in
            snapshot.removeFromSuperview()
        })
    }
    
    func createViewBorder(for view: UIView, flag: Bool, color: UIColor) {
        view.layer.borderColor = flag ? UIColor.theme.clear.cgColor : color.cgColor
        view.layer.borderWidth = flag ? 0 : 2
        view.layer.cornerRadius = 5
    }
}
