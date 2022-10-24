//
//  LaunchingController.swift
//  vvp
//
//  Created by Fabio Mauersberger on 05.10.22.
//

import Foundation
import UIKit
import WPKit

class LaunchingController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        activityIndicator.startAnimating()
        PersistenceManager.shared.fetchPosts(limit: 10) { newPostCount in
            
            self.launchingDone()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func launchingDone() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "LaunchSegue", sender: self)
        }
    }
}
