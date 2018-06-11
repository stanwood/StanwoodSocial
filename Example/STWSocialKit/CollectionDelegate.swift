//
//  CollectionDelegate.swift
//  StanwoodSocial
//
//  Copyright (c) 2018 stanwood GmbH
//  Distributed under MIT licence.
//

import Foundation
import UIKit

/**
 DataSourceDelegate informs the UIViewController when it need to execute some tasks
 */
protocol DataSourceDelegate: class {
    func reloadData()
}

protocol DataType {
    var numberOfItems:Int { get }
    func setItemsFrom(_ parser: Type) -> Self
    func insertItemAtIndex(insertItem item: Type, toIndex:Int) -> Self
    subscript(index: Int) -> Type { get }
    subscript(item: Type) -> Int { get }
    func insterItem(_ item: Type) -> Self
    func updateItem(_ type: Type) -> Self
}

/**
 Type protocol must be implelemented to any object passed to objects thta conform with DataType
 */
protocol Type {
}

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
