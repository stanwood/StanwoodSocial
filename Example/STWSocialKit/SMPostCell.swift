//
//  SMPostCell.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 31/08/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import UIKit
import YouTubePlayer
import FontAwesome_swift
import FBSDKLoginKit
import FBSDKCoreKit
import STWSocialKit

enum SocialAction: Int {
    case like
    case comment
    case share
}

enum SocialImage: String {
    case like = "sot_social_liked"
    case unlike = "sot_social_like"
}

class SMPostCell: UICollectionViewCell {
    
    @IBOutlet weak var postImageHeightLayoutConstraints: NSLayoutConstraint!
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var authorThumbnail: UIImageView! {
        didSet {
            authorThumbnail.alpha = 1
        }
    }
    
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet var actionUIButtons: [UIButton]!
    @IBOutlet weak var playerView: YouTubePlayerView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var postedAtLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    private var postType:PostType!
    var post:SMPost?
    private var commentObject: STComment?
    private var likeObject: STLike?
    
    weak var target:UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func socialAction(_ sender: UIButton) {
        guard let action = SocialAction(rawValue: sender.tag) else { return }
        guard post != nil else { return }
        
        switch action {
        case .like:
            guard let hasLiked = likeObject?.hasLiked else { return }
            hasLiked ? unlike(sender: sender) : like(sender: sender)
        case .comment:
            guard let type = STSocialType(rawValue: postType.rawValue) else { return }
            guard let canComment = commentObject?.canComment else { return }
            if canComment {
                STSocialManager.shared.postComment(forObjectId: post!.id, type: type, withLocalizedStrings: nil)
            }
        case .share:
            guard let type = STSocialType(rawValue: postType.rawValue) else { return }
            
            do {
                try STSocialManager.shared.share(postLink: likeObject?.shareLink ?? "", forType: type, localizedStrings: nil, withPostTitle: post!.author.name, postText: post!.text, postImageURL: post!.image, image: postImage.image)
            } catch STSocialError.shareError(let message) {
                AppController.sharedController.logResponse(message)
            } catch {
                AppController.sharedController.logResponse(error.localizedDescription)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImage.hnk_cancelSetImage()
        authorThumbnail.hnk_cancelSetImage()
        authorThumbnail.image = nil
        postImage.image = nil
        playerView.stop()
        playerView.clear()
        playerView.isHidden = true
        isPlayer(hidden: true)
        post = nil
        likesLabel.text = ""
        likeObject = nil
        actionUIButtons[0].setImage(UIImage(named: SocialImage.unlike.rawValue), for: .normal)
    }
    
    func fill(withPost post: SMPost, target: UIViewController? = nil) {
        self.target = target
        postType = post.type
        self.post = post
        
        getCommentObject()
        getLikeObject()
        
        playerView.isHidden = true
        setLayout(forPost: post)
        authorLabel.text = post.author.name
        textLabel.text = post.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        postedAtLabel.text = post.postedAt
        
        //Setting author image
        if let url = URL(string: post.author.imageUrl) {
            authorThumbnail.hnk_setImageFromURL(url)
            authorThumbnail.clipsToBounds = true
        }
        
        //Setting the icon
        setIcon(forType: post.type)
        
        if let url = URL(string: post.image) {
            postImage.hnk_setImageFromURL(url)
            postImage.clipsToBounds = true
        }
        
        if post.type! == .youtube {
            isPlayer(hidden: true)
            if let videoId = post.video, getVideoIDFromUrl(videoId) != nil {
                self.loadVideoWithID(getVideoIDFromUrl(videoId)!)
            }
        } else {
            isPlayer(hidden: true)
        }
    }
    
    private func getCommentObject() {
        guard let type = STSocialType(rawValue: postType.rawValue) else { return }
        
        STSocialManager.shared.getComment(bjectID: post?.id ?? "", forType: type, handler: {
            [weak self] (commentObject, error) in
            if error == nil, commentObject != nil {
                self?.commentObject = commentObject
            } else {
                if error != nil {
                    AppController.sharedController.recordError(error!)
                }
            }
        })
    }
    
    private func getLikeObject() {
        guard let type = STSocialType(rawValue: postType.rawValue) else { return }

        STSocialManager.shared.getLike(objectID: post?.id ?? "", forType: type, handler: {
            [weak self] (likeObject, error) in
            DispatchQueue.main.async(execute: {
                if error == nil, let _likeObject = likeObject {
                    self?.likeObject = _likeObject
                    //Setting like button
                    if let _hasLiked = _likeObject.hasLiked {
                        if _hasLiked {
                            self?.actionUIButtons[0].setImage(UIImage(named: SocialImage.like.rawValue), for: .normal)
                        } else {
                            self?.actionUIButtons[0].setImage(UIImage(named: SocialImage.unlike.rawValue), for: .normal)
                        }
                    }
                    self?.likesLabel.text = _likeObject.countString
                } else {
                    if error != nil {
                        AppController.sharedController.recordError(error!)
                    }
                }
            })
        })
    }
    
    fileprivate func setIcon(forType type: PostType) {
        iconLabel.font = UIFont.fontAwesome(ofSize: 28)
        
        switch type {
        case .facebook:
            iconLabel.text = String.fontAwesomeIcon(name: .facebookOfficial)
        case .instagram:
            iconLabel.text = String.fontAwesomeIcon(name: .instagram)
        case .youtube:
            iconLabel.text = String.fontAwesomeIcon(name: .youTubeSquare)
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let attributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
        let height = contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var newFrame = attributes.frame
        newFrame.size.height = height
        attributes.frame = newFrame
        return attributes
    }
    
    fileprivate func setLayout(forPost post:SMPost) {
        
        var height:CGFloat
        
        if post.type == .youtube {
            let ratio:CGFloat = 9 / 16
            height = frame.width * ratio
        } else if post.image == "" {
            height = 50
        } else {
            height = frame.width
        }
        
        postImageHeightLayoutConstraints.constant = height
        needsUpdateConstraints()
        UIView.animate(withDuration: 0, animations: {
            self.layoutIfNeeded()
        })
    }
    
    fileprivate func like(sender: UIButton){
        guard let type = STSocialType(rawValue: postType.rawValue),
            (likeObject?.canLike)! else { return }
        
        STSocialManager.shared.like(postID: post!.id, forSocialType: type, handler: {
            [weak self, id = post!.id] (success: Bool) in
            DispatchQueue.main.async(execute: {
                if success {
                    self?.likeObject?.hasLiked = true
                    sender.setImage(UIImage(named: SocialImage.like.rawValue), for: .normal)
                } else {
                    AppController.sharedController.logResponse("Failed do liek post id\(id)")
                }
            })
        })
    }
    
    fileprivate func unlike(sender: UIButton){
        guard let type = STSocialType(rawValue: postType.rawValue) else { return }
        
        STSocialManager.shared.unlike(postID: post!.id, forSocialType: type, handler: {
            [weak self, id = post!.id] (success: Bool) in
            DispatchQueue.main.async {
                if success {
                    self?.likeObject?.hasLiked = false
                    sender.setImage(UIImage(named: SocialImage.unlike.rawValue), for: .normal)
                } else {
                    AppController.sharedController.logResponse("Failed do liek post id\(id)")
                }
            }
        })
    }
    
    
    
    /**
     Loading the video with ID
     */
    fileprivate func loadVideoWithID(_ videoID:String){
        self.playerView.delegate = self
        self.playerView.playerVars = [
            "playsinline": "0",
            "controls": "0",
            "showinfo": "0"
        ]
        self.playerView.loadVideoID(videoID)
    }
    
    
    
    /**
     The function return the video ID
     */
    fileprivate func getVideoIDFromUrl(_ url:String)->String?{
        if url.contains("=") {
            if let videoID = url.components(separatedBy: "=").last {
                return videoID
            }
        } else if url.contains("embed"){
            if let videoID = url.components(separatedBy: "embed/").last {
                return videoID
            }
        }
        return nil
    }
    
    fileprivate func isPlayer(hidden:Bool) {
        if hidden {
            playerView.isHidden = true
            playerView.alpha = 0
        } else {
            playerView.isHidden = false
            playerView.alpha = 1
        }
    }
}

extension SMPostCell: YouTubePlayerDelegate {
    
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        isPlayer(hidden: false)
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        
    }
}

