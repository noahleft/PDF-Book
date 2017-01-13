//
//  AddFileViewController.swift
//  SongBook
//
//  Created by 林世豐 on 11/01/2017.
//  Copyright © 2017 林世豐. All rights reserved.
//

import Foundation
import UIKit

class AddFileViewController: UIViewController {
    
    @IBOutlet weak var webLinkTextField: UITextField!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBAction func PressPreviewButton(_ sender: Any) {
        if let weblink = webLinkTextField.text {
            if let weburl = URL(string: weblink) {
                let request = URLRequest(url: weburl)
                webView.loadRequest(request)
            }
        }
        
    }
    
    @IBAction func PressDownloadItButton(_ sender: Any) {
        
        downloader.downloadFile(urlString: webLinkTextField.text!)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
}
