//
//  HanakeFix.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 09/11/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation
import Kingfisher

extension UIImageView {
    
    public func hnk_setImageFromURL(_ url: URL?) {
        self.kf.setImage(with: url)
    }
    
    public func hnk_setImageFromURL(_ url: URL?, complitionHandler: @escaping CompletionHandler) {
        self.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: {
            (_ image: Image?, _ error: NSError?, _ cacheType: CacheType, _ imageURL: URL?) in
            complitionHandler(image, error, cacheType, imageURL)
        })
    }
    
    public func hnk_cancelSetImage() {
        self.kf.cancelDownloadTask()
    }
    
    public func hnk_setImage(_ image: UIImage, key: String) {
        self.image = image
    }
}
