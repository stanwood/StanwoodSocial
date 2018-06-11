//
//  SocialMediaDelegate.swift
//  StanwoodSocial
//
//  Copyright (c) 2018 stanwood GmbH
//  Distributed under MIT licence.
//

import Foundation
import UIKit
import StanwoodSocial

protocol SocialMediaLoadDelegate {
    
}

class SocialMediaDelegate: CollectionDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SMPostCell else { return }
        guard let post = cell.post else { return }
        
        // Canceling the operation task
        STSocialManager.shared.cancelOperation(forPostID: post.id ?? "", operation: .like)
        STSocialManager.shared.cancelOperation(forPostID: post.id ?? "", operation: .comment)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        guard let viewController = currentViewController as? SocialMediaViewController else { return CGSize.zero }
        
        var ratio:CGFloat
        let labelWidth:CGFloat = 28
        
        let width = viewController.view.frame.width
        let height = viewController.view.frame.height
        let font = UIFont(name: "AvenirNext-Regular", size: 14)!
        
        guard (dataObject as! SMPosts).items.count > 0 else {
            ratio = 0.753
            let height = width / ratio
            return CGSize(width: width, height: height)

        }
        
        let post = (dataObject as! SMPosts).items[indexPath.row]
    
        if post.type! == .youtube {
            ratio = 0.912
        } else if post.image == "" {
            ratio = 1.63
        } else {
            ratio = 0.66
        }
        
        let labelHeight = post.text.getHeight(font, width: width - labelWidth, readingOption: .usesLineFragmentOrigin)
        
        let numberOfLines = post.text.getNumberOfLines(width - labelWidth, labelHeight: CGFloat(labelHeight), font: font)
        var labelPadding:CGFloat = 0
        
        if numberOfLines > 1 {
            labelPadding = 20
        } else if post.text == "" {
            labelPadding = -20
        }
        
        let cellHeight:CGFloat = width / ratio + CGFloat(labelHeight) + labelPadding
        
        return CGSize(width: viewController.view.frame.width, height: cellHeight)

    }
}
