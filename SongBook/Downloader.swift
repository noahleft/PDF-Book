//
//  Downloader.swift
//  SongBook
//
//  Created by 林世豐 on 16/12/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//

import Foundation
import Alamofire

class Downloader : NSObject {
    
    var plistArray : NSArray = []
    var counter : Int = 0
    var downloadFraction : Double = 0
    
    override init() {
        super.init()
        
        let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print("\(documentPath)")
    }
    
    func pullFileList(fileURLString : String) {
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        
        let request: DownloadRequest
        
        request = Alamofire.download(fileURLString, to: destination)
        
        request.responseData { response in
            switch response.result {
            case .success:
                print("success")
                if let target = fileURLString.components(separatedBy: "/").last {
                    if let fileType = target.components(separatedBy: ".").last {
                        if fileType == "plist" {
                            print("pull all file list")
                            self.pullAllFile()
                        }
                    }
                }
            case .failure:
                print("failure")
            }
        }
        
    }
    
    func loadPlist() {
        if let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first {
            let path = dir.appendingPathComponent("index.plist")
            
            if let array = NSArray(contentsOf: path) {
                plistArray = array
            }
        }
    }
    
    func pullAllFile() {
        loadPlist()
        downloadFraction = 0
        for element in plistArray {
            let array = element as! NSArray
            pullFile(urlString: array[1] as! String, fraction: Double(plistArray.count))
        }
    }
    
    func pullFile(urlString : String, fraction : Double) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        let request: DownloadRequest
        
        request = Alamofire.download(urlString, to: destination).downloadProgress{ progress in
            print("Download progress \(progress.fractionCompleted)")
            }
        
        request.responseData { response in
            switch response.result {
            case .success:
                print("success")
                self.willChangeValue(forKey: "downloadFraction")
                self.downloadFraction+=fraction
                self.didChangeValue(forKey: "downloadFraction")
            case .failure:
                print("failure")
            }
        }
        
    }
    
    func getDestination() -> DownloadRequest.DownloadFileDestination {
        return DownloadRequest.suggestedDownloadDestination(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    }
}

let downloader : Downloader = Downloader()
