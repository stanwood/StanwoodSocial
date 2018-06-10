//
//  SocialMediaViewController.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 31/08/2016.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2018 Stanwood GmbH (www.stanwood.io)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import StanwoodSocial

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
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(SocialMediaViewController.logout))
    }
    
    func logout(){
        STSocialManager.shared.logout()
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

extension SocialMediaViewController: SMPostCellDelegate {
    func auth(type: PostType) {
        guard let serviceType = STSocialType(rawValue: type.rawValue) else { return }
        STSocialManager.shared.auth(forType: serviceType)
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
