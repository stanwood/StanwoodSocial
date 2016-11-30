//
//  ViewController.swift
//  STWSocialKit
//
//  Created by Tal Zion on 29/11/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

// Sophia URL : https://social-media-wall-sartorius.firebaseio.com/iho6nlj79jdd/Sophia/posts.json

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var socialTextField: UITextField!
    
    @IBAction func presentFeed(_ sender: Any) {
        guard let url = URL(string: socialTextField.text ?? "") else { presentError(); return }
        
        let socialViewController = storyboard?.instantiateViewController(withIdentifier: "SocialMediaViewController") as? SocialMediaViewController
        socialViewController?.socialUrl = url
        
        navigationController?.pushViewController(socialViewController!, animated: true)
    }
    
    func presentError() {
        let alert = UIAlertController(title: "Error", message: "Please enter a valid URL!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
