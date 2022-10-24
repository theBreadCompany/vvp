//
//  Cells.swift
//  vvp
//
//  Created by Fabio Mauersberger on 24.10.22.
//

import Foundation
import UIKit

@IBDesignable
class CategoryCell: UICollectionViewCell {
    @IBInspectable
    @IBOutlet weak var button: UIButton!
}

@IBDesignable
class NewsEntry: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var author: UIButton!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var views: UILabel!
    weak var vc: UIViewController?
}
