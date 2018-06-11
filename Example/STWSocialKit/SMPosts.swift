//
//  SMPosts.swift
//  StanwoodSocial
//
//  Copyright (c) 2018 stanwood GmbH
//  Distributed under MIT licence.
//

import Foundation

struct SMPosts: DataType {
    var items = [SMPost]()
    
    var numberOfItems:Int {
        return items.count
    }
    
    var numberOfCompletedItems:Int {
        return items.count
    }
    
    init(items: [SMPost] = []) {
        self.items = items.sorted(by: { (post1, post2) -> Bool in
            return post1.createdAt.timeIntervalSince(post2.createdAt as Date) > 0
        })
    }
    
    subscript(index: Int) -> Type {
        return items[index]
    }
    
    subscript(index: Int) -> Type? {
        return items.count == 0 ? nil : items[index]
    }
    
    subscript(item: Type) -> Int {
        return 0
    }
    
    func setItemsFrom(_ parser: Type) -> SMPosts {
        let items:[SMPost] = []
        return SMPosts(items: items)
    }
    
    func insertItemAtIndex(insertItem item: Type, toIndex: Int) -> SMPosts {
        var items = self.items
        items[toIndex] = item as! SMPost
        return SMPosts(items: self.items)
    }
    
    func insterItem(_ item: Type) -> SMPosts {
        var items = self.items
        items.append(item as! SMPost)
        return SMPosts(items: items)
    }
    
    func updateItem(_ type: Type) -> SMPosts {
        return self
    }
    
    func appendItems(_ items: [SMPost]) -> SMPosts {
        var posts = self.items
        var trimmedPosts = items.sorted(by: { (post1, post2) -> Bool in
            return post1.createdAt.timeIntervalSince(post2.createdAt as Date) > 0
        })
        
        //Removing the first post as duplicate from the previuse call
        trimmedPosts.removeFirst()
        posts.append(contentsOf: trimmedPosts)
        
        return SMPosts(items: posts)
    }
}
