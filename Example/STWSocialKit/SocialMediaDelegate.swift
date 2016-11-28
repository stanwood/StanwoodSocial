//
//  SocialMediaDelegate.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 31/08/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation

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
            if viewController.isLogin {
                return CGSize(width: width, height: height * 0.95)
            } else {
                ratio = 0.753
                let height = width / ratio
                return CGSize(width: width, height: height)
            }

        }
        
        let post = (dataObject as! SMPosts).items[indexPath.row]
        
        if indexPath.section == 0 {
            if viewController.isLogin {
                return CGSize(width: width, height: height * 0.724)
            } else {
                ratio = 0.753
                let height = width / ratio
                return CGSize(width: width, height: height)
            }
        } else {
            
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
            
            let height:CGFloat = width / ratio + CGFloat(labelHeight) + labelPadding
            
            return CGSize(width: viewController.view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        guard let viewController = currentViewController as? SocialMediaViewController else { return UIEdgeInsets.zero }
            
        if section == 0 {
            if viewController.isLogin {
                return UIEdgeInsetsMake(-20, 0, 10, 0)
            } else {
                return UIEdgeInsetsMake(-20, 0, 10, 0)
            }
        } else {
            return UIEdgeInsetsMake(10, 0, 10, 0)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            guard let viewController = currentViewController as? SocialMediaViewController else { return }
            viewController.loadRefresh()
        }
    }
}
