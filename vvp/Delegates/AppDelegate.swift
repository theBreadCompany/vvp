//
//  AppDelegate.swift
//  vvp
//
//  Created by Fabio Mauersberger on 27.08.22.
//

import UIKit
import WPKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func applicationWillTerminate(_ application: UIApplication) {
        wplog("Application will terminate! Saving the PersistenceManager...")
        do {
            try PersistenceManager.shared.save()
        } catch {
            wplog("Couldnt save persistent manager! Will try to recover on next init.")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}

