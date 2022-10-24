//
//  CollectionViewDelegate.swift
//  vvp
//
//  Created by Fabio Mauersberger on 16.10.22.
//

import Foundation
import UIKit

class CategoryDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCell // dumb workaround for padding
        cell.button.setTitle("  " + categories[indexPath.row] + "  ", for: .normal)
        cell.button.titleLabel?.numberOfLines = 1
        cell.button.layer.backgroundColor = UIColor.systemBlue.cgColor.copy(alpha: 0.2)
        //cell.button.clipsToBounds = true
        cell.button.layer.cornerRadius = 10
        return cell
    }
    
    
    var categories: [String] = []
    var filterType: FilterType = .category
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        false
    }
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    
}

enum FilterType {
    case category, author
}
