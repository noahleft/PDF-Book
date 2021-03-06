//
//  SettingViewController.swift
//  SongBook
//
//  Created by 林世豐 on 27/12/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import SwiftyDropbox


class SettingViewController: UIViewController {
    
    @IBOutlet weak var checkDateLabel: UILabel!
    
    @IBAction func pressClearFileButton(_ sender: Any) {
        downloader.removeFile()
        database.clearFile()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func pressLinkToDropbox(_ sender: Any) {
        linkToDropbox()
    }
    
    @IBAction func pressFetchDropbox(_ sender: Any) {
        downloader.fetchDropboxFileList()
    }
    
    @IBAction func pressContactUsButton(_ sender: Any) {
        if let url = URL(string: "https://noahleft.github.io/PDF-Book/") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func pressDumpButton(_ sender: Any) {
        database.dump()
    }
    
    @IBAction func pressOpenSafari(_ sender: Any) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: NSURL(string: "https://www.google.com") as! URL)
            svc.delegate = self
            self.present(svc, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func pressExample(_ sender: Any) {
        downloadProcess(plistURL: "https://noahleft.github.io/PDF-Book/example/index.plist")
    }
    
    @IBAction func pressPullPlist(_ sender: Any) {
        if checkUpdateDate() {
            downloader.checkUpdatableFile()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func downloadProcess(plistURL: String?) {
        if let urlString = plistURL {
            print("handle \(urlString)")
            downloader.downloadFile(urlString: urlString)
        }
    }
    
    func linkToDropbox() {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
        })
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var linkTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if UserDefaults.standard.bool(forKey: "login") {
            linkButton.isHidden = true
            linkTextLabel.isHidden = true
        }
        
        if isKeyPresentInUserDefaults(key: "UpdatableFileDate") {
            let ti = UserDefaults.standard.double(forKey: "UpdatableFileDate")
            let updateDate = Date(timeIntervalSince1970: ti)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            
            checkDateLabel.text = dateFormatter.string(from: updateDate)
        }
        
    }
    
    func checkUpdateDate() -> Bool {
        if isKeyPresentInUserDefaults(key: "UpdatableFileDate") {
            let ti = UserDefaults.standard.double(forKey: "UpdatableFileDate")
            let updateDate = Date(timeIntervalSince1970: ti)
            
            let currentDate = Date()
            
            let difTI = currentDate.timeIntervalSince(updateDate)
            
            if difTI.isLess(than: 600) {
                print("check file in less than 10 min before")
            }
            else {
                return true
            }
        }
        else {
            return true
        }
        return false
    }
    
}


extension SettingViewController: SFSafariViewControllerDelegate {
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

