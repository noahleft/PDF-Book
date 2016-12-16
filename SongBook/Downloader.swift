//
//  Downloader.swift
//  SongBook
//
//  Created by 林世豐 on 16/12/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//

import Foundation
import Alamofire

class Downloader {
    
    var plistArray : NSArray = []
    
    init() {
        let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print("\(documentPath)")
    }
    
    func pullFileList() {
        let plistURL = "https://noahleft.github.io/PDF-Book/index.plist"
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(plistURL, to: destination)
    }
    
    func loadPlist() {
        pullFileList()
        if let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first {
            let path = dir.appendingPathComponent("index.plist")
            
            if let array = NSArray(contentsOf: path) {
                plistArray = array
            }
        }
    }
    
    func pullAllFile() {
        loadPlist()
        for element in plistArray {
            let array = element as! NSArray
            pullFile(urlString: array[1] as! String)
        }
        
    }
    
    func pullFile(urlString : String) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(urlString, to: destination)
    }
    
}

let downloader : Downloader = Downloader()
