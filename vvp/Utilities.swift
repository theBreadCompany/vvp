//
//  Utilities.swift
//  vvp
//
//  Created by Fabio Mauersberger on 01.09.22.
//

import Foundation

internal func log(_ message: CVarArg ...) {
    #if DEBUG
    NSLog(String(repeating: "%@", count: message.count), message)
    #endif
}

