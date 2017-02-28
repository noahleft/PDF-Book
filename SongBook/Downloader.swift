//
//  Downloader.swift
//  SongBook
//
//  Created by 林世豐 on 16/12/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//

import Foundation
import Alamofire
import QRCode

class Downloader : NSObject {
    
    var counter : Int = 0
    var downloadFraction : Double = 0
    var failureCounter : Int = 0
    
    override init() {
        super.init()
    }
    
    func triggerReload() {
        willChangeValue(forKey: "counter")
        counter += 1
        didChangeValue(forKey: "counter")
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
                let qrfileURL = self.generateQRCode(fileURL: urlString, fileName: fileName!)
                print("download file: \(fileName)  from \(urlString) to \(fileURL)")
                database.appendingFile(file: IMPORTED_FILE(name: fileName!, sour: urlString, dest: fileURL!, qrcode: qrfileURL))
                database.save()
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
                if path == "Inbox" {
                    continue
                }
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
    
    func generateQRCode(fileURL : String, fileName : String) -> String {
        checkQRCodeDirectory()
        let qrCode = QRCode(fileURL)
        if let data = UIImagePNGRepresentation((qrCode?.image)!) {
            let qrcodeFileName = fileName.components(separatedBy: ".")[0]+".png"
            let filePath = getQRCodeDirectoryPath()+"/"+qrcodeFileName
            print("Try to store QR Code image to \(filePath)")
            let destFileURL = URL(fileURLWithPath: filePath)
            
            do {
                try data.write(to: destFileURL)
            } catch {
                print("QRCode write to disk fail")
                return ""
            }
            return qrcodeFileName
        }
        return ""
    }
    
    func getQRCodeDirectoryPath() -> String {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let qrcodeDirPath = dirPath.appending("/QRCode")
        return qrcodeDirPath
    }
    
    func checkQRCodeDirectory() {
        let filemgr = FileManager.default
        let isDir = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        isDir[0] = true
        if filemgr.fileExists(atPath: getQRCodeDirectoryPath(), isDirectory: isDir) {
            print("check QR code directory success")
        }
        else {
            do {
            try filemgr.createDirectory(atPath: getQRCodeDirectoryPath(), withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("QR Code directory create fail")
            }
        }
    }
    
}

let downloader : Downloader = Downloader()
