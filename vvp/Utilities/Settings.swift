//
//  Settings.swift
//  vvp
//
//  Created by Fabio Mauersberger on 01.10.22.
//

import Foundation
import WPKit

class Settings: NSObject {
    
    static var shared = Settings()
    
    var fontSize: Int {
        get {
            UserDefaults.standard.integer(forKey: "FontSize")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "FontSize")
            wplog("Font size set to ", newValue)
        }
    }
    
    var archiveActive: Bool {
        get {
            UserDefaults.standard.bool(forKey: "ArchiveIsActive")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ArchiveIsActive")
            wplog("Archiving set to ", newValue)
        }
    }
    
    
}
