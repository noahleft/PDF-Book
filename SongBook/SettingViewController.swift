//
//  SettingViewController.swift
//  SongBook
//
//  Created by 林世豐 on 27/12/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//

import Foundation
import UIKit

class SettingViewController: UIViewController {
    
    
    @IBAction func pressClearFileButton(_ sender: Any) {
        downloader.removeFile()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pressContactUsButton(_ sender: Any) {
        if let url = URL(string: "https://noahleft.github.io/PDF-Book/") {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    
    
}
