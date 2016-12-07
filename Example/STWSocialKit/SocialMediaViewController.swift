//
//  SocialMediaViewController.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 31/08/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import UIKit
import STWSocialKit

class SocialMediaViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var dataSource:SocialMediaDataSource!
    fileprivate var delegate:SocialMediaDelegate!
    fileprivate var items:SMPosts?
    fileprivate var activityIndictor:UIActivityIndicatorView!
    
    var socialUrl:URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Setting OAuth handler
        STSocialManager.shared.set(target: self)
        STSocialManager.shared.delegate = self
        
        collectionView.allowsSelection = false
 
        loadData(withUrl: socialUrl.absoluteString)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        STSocialManager.shared.cancelAllOperations()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndictor = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndictor.hidesWhenStopped = true
        activityIndictor.tintColor = UIColor.black
        
        activityIndictor.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height * 0.95)
        view.addSubview(activityIndictor)
    }
    
    fileprivate func loadData(withUrl url: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        NetworkManager.sharedManager.getPosts(withUrl: url)  {
            [unowned self] (posts, response) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if posts != nil {
                if self.items == nil {
                    self.items = SMPosts(items: posts!)
                } else {
                    
                    self.items = self.items!.appendItems(posts!)
                }
                
                DispatchQueue.main.async(execute: {
                    self.configureDataSource()
                })
            } else {
                print(response ?? "")
            }
        }
    }
    
    fileprivate func configureDataSource(){
        let nib = UINib(nibName: "SMPostCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "SMPostCell")
        
        self.dataSource = SocialMediaDataSource(dataObject: self.items, currentViewController: self)
        self.delegate = SocialMediaDelegate(currentViewController: self, dataObject: self.items)
        
        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self.delegate
    }
}

extension SocialMediaViewController: STSocialManagerDelegate {
    
    func didLogout(type: STSocialType?) {
        collectionView.reloadData()
    }
    
    func didLogin(type: STSocialType, withError error: Error?) {
        collectionView.reloadData()
    }
}
