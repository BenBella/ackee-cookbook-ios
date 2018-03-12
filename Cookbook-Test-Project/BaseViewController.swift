//
//  BaseViewController.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showErrorAlert(error: Error, completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController (title: "global.error".localized, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "global.continue".localized, style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            completion?()
        }
        alert.addAction(okButton)
        self.present(alert, animated:true, completion:nil)
    }
    
    func showInfoAlert(time: Double, info: String, completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController (title: "", message: info, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated:true, completion: nil)
        let when = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: when){
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
        }) { (_) in
            snapshot.removeFromSuperview()
        }
    }
    
    func createViewBorder(for view: UIView, flag: Bool, color: UIColor) {
        view.layer.borderColor = flag ? UIColor.theme.clear.cgColor : color.cgColor
        view.layer.borderWidth = flag ? 0 : 2
        view.layer.cornerRadius = 5
    }

}
