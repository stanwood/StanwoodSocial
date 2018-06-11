//
//  ViewController.swift
//  StanwoodSocial
//
//  Copyright (c) 2018 stanwood GmbH
//  Distributed under MIT licence.
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

// Sophia URL : https://social-media-wall-sartorius.firebaseio.com/iho6nlj79jdd/Sophia/posts.json

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var socialTextField: UITextField!
    
    @IBAction func presentFeed(_ sender: Any) {
        guard let url = URL(string: socialTextField.text ?? "") else { presentError(); return }
        
        let socialViewController = storyboard?.instantiateViewController(withIdentifier: "SocialMediaViewController") as? SocialMediaViewController
        socialViewController?.socialUrl = url
        
        navigationController?.pushViewController(socialViewController!, animated: true)
    }
    
    @IBAction func setDefault(_ sender: Any) {
        socialTextField.text = "https://social-media-wall-sartorius.firebaseio.com/iho6nlj79jdd/Sophia/posts.json"
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
