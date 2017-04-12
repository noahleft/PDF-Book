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
import SwiftyDropbox

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
    
    func downloadFile(urlStringArray : [String]) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        let request : DownloadRequest
        
        if let urlString = urlStringArray.first {
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
                    var newUrlStringArray = urlStringArray
                    newUrlStringArray.removeFirst()
                    self.downloadFile(urlStringArray: newUrlStringArray)
                }
            }
        }
        else {
            print("no links to download")
            willChangeValue(forKey: "failureCounter")
            failureCounter += 1
            didChangeValue(forKey: "failureCounter")
        }
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
                                var stringArray = Array(array)
                                stringArray.removeFirst()
//                                self.downloadFile(urlString: array[1] as! String)
                                self.downloadFile(urlStringArray: stringArray as! [String])
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
    
    func checkUpdatableFile() {
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: dir)
                let plistFileList = contents.filter{ (n) -> Bool in
                    return n.range(of: ".plist") != nil }
                
                print(plistFileList)
            }
            catch {
                print("!@#")
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
    
    func fetchDropboxFileList() {
        // Reference after programmatic auth flow
        if let client = DropboxClientsManager.authorizedClient {
            _ = client.files.listFolder(path: "").response { response, error in
                if let result = response {
                    print("Folder contents:")
                    for entry in result.entries {
                        print(entry.name)
                        self.downloadFileFromDropbox(filePath: entry.pathLower!, fileName: entry.name)
                    }
                } else {
                    print("Error: \(error!)")
                }
            }
        }
    }
    
    func downloadFileFromDropbox(filePath : String, fileName: String) {
        if let client = DropboxClientsManager.authorizedClient {
            let fileManager = FileManager.default
            let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destURL = directoryURL.appendingPathComponent(fileName)
            let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                return destURL
            }
            
            _ = client.files.download(path: filePath, destination: destination).response { response, error in
                if let result = response {
                    print(result)
                    self.willChangeValue(forKey: "counter")
                    self.counter += 1
                    self.didChangeValue(forKey: "counter")
                } else {
                    print("Error: \(error!)")
                }
            }.progress { progressData in
                    print(progressData)
            }
        }
    }
    
    func uploadFileToDropbox(url : URL) {
        if let client = DropboxClientsManager.authorizedClient {
            let fileName = url.lastPathComponent
            _ = client.files.upload(path: "/"+fileName, input: url).response { response, error in
                if let response = response {
                    print(response)
                    self.turnOnDropboxShare(filePath: response.pathLower!, fileName: response.name, fileURL: url)
                } else if let error = error {
                    print(error)
                }
                }
                .progress { progressData in
                    print(progressData)
            }
        }
    }
    
    func turnOnDropboxShare(filePath : String, fileName : String, fileURL: URL) {
        if let client = DropboxClientsManager.authorizedClient {
            print("dropbox client is auth.")
            
            _ = client.sharing.createSharedLinkWithSettings(path: filePath).response { response, error in
                if let result = response {
                    print("get share link")
                    print("id: \(result.id) \t name: \(result.name)")
                    print("url: \(result.url)")
                    let qrfileURL = self.generateQRCode(fileURL: result.url, fileName: fileName)
                    print("download file: \(fileName)  from \(result.url) to \(fileURL)")
                    database.appendingFile(file: IMPORTED_FILE(name: fileName, sour: result.url, dest: fileURL, qrcode: qrfileURL))
                    database.save()
                } else {
                    print("Error: \(error!)")
                }
            }
        }
    }
    
    
    
}

let downloader : Downloader = Downloader()
