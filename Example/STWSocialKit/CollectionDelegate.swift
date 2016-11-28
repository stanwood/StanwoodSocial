//
//  CollectionDelegate.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 02/05/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation
import UIKit

protocol CollectionDelegateType {
    
    var dataObject:DataType? {get set}
    weak var currentViewController:UIViewController! {get set}
    
    init(currentViewController: UIViewController, dataObject:DataType?)
    //func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}

class CollectionDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CollectionDelegateType {
    
    weak var currentViewController: UIViewController!
    var dataObject: DataType?
    
    required init(currentViewController: UIViewController, dataObject: DataType? = nil) {
        self.currentViewController = currentViewController
        self.dataObject = dataObject
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fatalError("didSelectItemAtIndexPath Must be overriden")
    }
    
    /*
     // TODO: Let's switch to auto sizing cells.
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        fatalError("sizeForItemAtIndexPath Must be overriden")
    }
     */
}
