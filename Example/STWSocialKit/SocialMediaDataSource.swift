//
//  SocialMediaDataSource.swift
//  StanwoodSocial
//
//  Copyright (c) 2018 stanwood GmbH
//  Distributed under MIT licence.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class SocialMediaDataSource: CollectionDataSource {
    
    required init<A : DataType>(dataObject: A?, currentViewController: UIViewController?) {
        super.init(dataObject: dataObject, currentViewController: currentViewController)
        reloadData()
    }
    
    required init(type: Type, currentViewController: UIViewController?) {
        fatalError("init(type:currentViewController:) has not been implemented")
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewController = currentViewController as? SocialMediaViewController else { fatalError() }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SMPostCell", for: indexPath) as! SMPostCell
        let post = (dataObject as! SMPosts).items[indexPath.row]
        cell.delegate = viewController
        cell.fill(withPost: post, target: viewController)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: IndexPath) {
        guard let cell = cell as? SMPostCell else { return }
        cell.playerView.clear()
    }
}

