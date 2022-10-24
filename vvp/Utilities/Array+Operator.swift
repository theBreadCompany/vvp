//
//  Array+Operator.swift
//  vvp
//
//  Created by Fabio Mauersberger on 24.10.22.
//

import Foundation

extension Array {
    static func +(lhs: [Element], rhs: Element) -> [Element] {
        var lhs = lhs
        lhs.append(rhs)
        return lhs
    }
    static func +(lhs: Element, rhs: [Element]) -> [Element] {
        return rhs + lhs
    }
}
