//
//  TextViewDelegate.swift
//  vvp
//
//  Created by Fabio Mauersberger on 17.10.22.
//

import Foundation
import UIKit

class TextViewDelegate: NSObject, UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        return false
    }
}
