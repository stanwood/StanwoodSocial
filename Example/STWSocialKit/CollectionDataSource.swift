//
//  DataSource.swift
//  StanwoodSocial
//
//  Copyright (c) 2018 stanwood GmbH
//  Distributed under MIT licence.
//

import UIKit

protocol CollectionSourceType: class {
    
    weak var delegate:DataSourceDelegate! {get set}
    weak var currentViewController:UIViewController? {get set}
    
    init<A: DataType>(dataObject: A?, currentViewController: UIViewController?)
    init(type:Type, currentViewController: UIViewController?)
    
    func updateData(_ dataObject: DataType)
    func cancelAllOperations()
    func reloadData()
    func numberOfSections(in collectionView: UICollectionView) -> Int
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

class CollectionDataSource: NSObject, UICollectionViewDataSource, CollectionSourceType {
    
    var dataObject:DataType!
    var dataType: Type!
    
    weak var delegate:DataSourceDelegate!
    weak var currentViewController: UIViewController?
    
    required init<A : DataType>(dataObject: A?, currentViewController: UIViewController? = nil) {
        self.currentViewController = currentViewController
        if dataObject != nil {
            self.dataObject = dataObject!
        }
    }
    
    required init(type: Type, currentViewController: UIViewController? = nil) {
        self.currentViewController = currentViewController
        self.dataType = type
    }
    
    func updateData(_ dataObject: DataType) {
        self.dataObject = dataObject
    }
    
    func cancelAllOperations() {
        fatalError("Cancel all operations mustt be overriden")
    }
    
    func reloadData() {
        switch self.delegate {
        case .some:
            delegate.reloadData()
        case .none: break
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataObject.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: IndexPath) {
       fatalError("Must override DataSource didEndDisplayingCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Must overide DataSource cellForItemAtIndexPath")
    }
}

