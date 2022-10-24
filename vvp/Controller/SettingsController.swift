//
//  SettingsController.swift
//  vvp
//
//  Created by Fabio Mauersberger on 30.08.22.
//
//  I wonder how I can prevent boilerplating, especially as there has been a time when xibs where the standard

import Foundation
import UIKit

@IBDesignable
class SettingsController: UIViewController {
    
    @IBOutlet weak var impressumView: ImpressumView!
    @IBOutlet weak var archiveStatisticsView: ArchiveStatisticsView!
    @IBOutlet weak var creatorCreditView: CreatorCreditsView!
    @IBOutlet weak var fontSizeView: FontSizeView!
    
    override func viewDidLoad() {
        fontSizeView.fontSizeSlider.value = Float(Settings.shared.fontSize)
        
        archiveStatisticsView.archiveActivationSwitch.isOn = Settings.shared.archiveActive
        archiveStatisticsView.postDBStateLabel.text = PersistenceManager.shared.getpostDB().count.description
        
        #if DEBUG
        let debugNote = NSLocalizedString("This is a debugging build! You may watch the logs.", comment: "debug note")
        #else
        let debugNote = NSLocalizedString("This is a release build!", comment: "debug note")
        #endif
        
        
        impressumView.impressumLabel.text = NSLocalizedString(
            "Welcome to vvp - the inofficial app for volksverpetzer.de!\n\nThis version contains\n- showing an entry for an entry, being a thumbnail and a title (excerpt wip)\n- reading the full article\n- perisistently storing articles and their media\n- some settings that do nothing for now", comment: "the impressum") + "\n\n" + debugNote
        
        creatorCreditView.creditLabel.text = NSLocalizedString(
        """
        created by theBreadCompany
        this is an educational project, feedback is appreciated ^^
        """
        , comment: "credit to the creator of the app")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        archiveStatisticsView.postDBStateLabel.text = PersistenceManager.shared.getpostDB().count.description
    }
}


@IBDesignable
class FontSizeView: UIView {
    
    @IBOutlet var fontSizeSlider: UISlider!
    @IBAction func roundValue(_ sender: Any) {
        fontSizeSlider.value = roundf(fontSizeSlider.value)
        Settings.shared.fontSize = Int(fontSizeSlider.value)
    }
}

@IBDesignable
class ArchiveStatisticsView: UIView {
    
    @IBOutlet weak var archiveActivationSwitch: UISwitch!
    @IBAction func archiveActivationSwitchToggled(_ sender: Any) {
        if let sender = sender as? UISwitch, sender.isOn {
            PersistenceManager.shared.archiveActivationSwitchToggled()
        } else if let sender = sender as? UISwitch, !sender.isOn {
            PersistenceManager.shared.stopArchiving()
        }
    }
    @IBOutlet weak var postDBStateLabel: UILabel!
}

@IBDesignable
class ImpressumView: UIView {
    
    @IBOutlet weak var impressumLabel: UILabel!
}

@IBDesignable
class CreatorCreditsView: UIView {

    @IBOutlet weak var creditLabel: UILabel!
}
