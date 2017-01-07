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
    var failureCounter : Int = 0
    
    override init() {
        super.init()
    }
    
    func downloadFile(urlString : String) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        let request : DownloadRequest
        request = Alamofire.download(urlString, to: destination)
        
        request.responseData { response in
            switch response.result {
            case .success:
                print("success")
                let fileURL = response.destinationURL
                let fileName = fileURL?.lastPathComponent
                if let fileType = fileName?.components(separatedBy: ".").last {
                    if fileType == "plist" {
                        print("trigger download event")
                        if let plistArray = NSArray(contentsOf: fileURL!) {
                            for element in plistArray {
                                let array = element as! NSArray
                                self.downloadFile(urlString: array[1] as! String)
                            }
                        }
                    }
                }
                self.willChangeValue(forKey: "counter")
                self.counter += 1
                self.didChangeValue(forKey: "counter")
            case .failure:
                print("failure")
                self.willChangeValue(forKey: "failureCounter")
                self.failureCounter += 1
                self.didChangeValue(forKey: "failureCounter")
            }
        }
    }
    
    func getDestination() -> DownloadRequest.DownloadFileDestination {
        return DownloadRequest.suggestedDownloadDestination(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    }
    
    
    func removeFile() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        var directoryContents: [String]
        do {
            try directoryContents = FileManager.default.contentsOfDirectory(atPath: dirPath)
            print(directoryContents)
            
            for path in directoryContents {
                let fullPath = (dirPath as NSString).appendingPathComponent(path) as String
                try FileManager.default.removeItem(atPath: fullPath)
            }
        }
        catch {
            print("listing directory contents fails")
        }
        willChangeValue(forKey: "counter")
        counter += 1
        didChangeValue(forKey: "counter")
    }
    
}

let downloader : Downloader = Downloader()
