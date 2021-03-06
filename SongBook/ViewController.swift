//
//  ViewController.swift
//  SongBook
//
//  Created by 林世豐 on 12/11/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//

import UIKit
import QRCodeReader
import QRCode
import AVFoundation
import QuickLook
import SwiftyDropbox

let quickLookController = QLPreviewController()

class ViewController: UIViewController {
    
    //Custom QR Code Reader
    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
    lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
    })
    //
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var failureLabel: UILabel!
    @IBOutlet weak var linkDropboxButton: UIButton!
    @IBOutlet weak var linkDropboxTextLabel: UILabel!
    
    var songList : [String] = []
    var fileList : [String] = []
    var songNumberList : [String] = []
    let reuseIdentifier = "Cell"
    
    var selectedNum : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        database.restore()
        database.dump()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        buildSongList()
        downloader.addObserver(self, forKeyPath: "downloadFraction", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        downloader.addObserver(self, forKeyPath: "counter", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        downloader.addObserver(self, forKeyPath: "failureCounter", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        
        notificationLabel.alpha = 0
        notificationLabel.layer.cornerRadius = 10
        notificationLabel.clipsToBounds = true
        failureLabel.alpha = 0
        failureLabel.layer.cornerRadius = 10
        failureLabel.clipsToBounds = true
        
        quickLookController.dataSource = self
        
    }
    
    func buildSongList() {
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: dir)
                let fileNames = contents.filter{ (n) -> Bool in
                    return n.range(of: ".pdf") != nil || n.range(of: ".jpg") != nil || n.range(of: ".png") != nil
                    }.sorted(by: songNameSortFunction)
                let songNames = fileNames.map{ (n) -> String in
                    return n.components(separatedBy: ".")[0]
                }
                songList.append(contentsOf: songNames)
                fileList.append(contentsOf: fileNames)
                
            }
            catch {
                print("!@#")
            }
        }
        
//        songNumberList = songList.map{ (n) -> String in
//            return n.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
//        }
        songNumberList = songList.map{ (n) -> String in
            return trim(aString: n)
        }
        
        if songList.count > 0 {
            textLabel.isHidden = true
            moreInfoButton.isHidden = true
            linkDropboxButton.isHidden = true
            linkDropboxTextLabel.isHidden = true
        }
        else {
            textLabel.isHidden = false
            moreInfoButton.isHidden = false
        }
        
        if UserDefaults.standard.bool(forKey: "login") {
            linkDropboxButton.isHidden = true
            linkDropboxTextLabel.isHidden = true
        }
    }
    
    func trim(aString : String) -> String {
        let digits = aString.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
        if digits != "" {
            return digits
        }
        else {
            return aString.substring(to: aString.index(aString.startIndex, offsetBy: 1))
        }
    }
    
    func trim2(aString : String) -> String {
        let digits = aString.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
        if digits != "" {
            return digits
        }
        else {
            return "0"
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("catch fraction changes")
        reload()
        if keyPath == "failureCounter" {
            print("observe failure")
            fadeViewInThenOut(popupString: "Download Fail.\n  Please check link availability", view: failureLabel, delay: 2)
            
        }
    }
    
    
    func songNameSortFunction(aStr: String, bStr: String) -> Bool {
//        let aDig : String = aStr.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
//        let bDig : String = bStr.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
        let aDig : String = trim2(aString: aStr)
        let bDig : String = trim2(aString: bStr)
        if (Int(aDig) != nil) && (Int(bDig) != nil) {
            return Int(aDig)! < Int(bDig)!
        }
        return true
    }
    
    func reload() {
        songList = []
        fileList = []
        songNumberList = []
        buildSongList()
        collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        print("memory warning")
    }
    
    func presentPDFDocumentInteraction(fileURL : URL) {
        let docuController : UIDocumentInteractionController = UIDocumentInteractionController.init(url: fileURL)
        docuController.delegate = self
        docuController.presentPreview(animated: true)
    }
    
    
    
    func dismissPicker() {
        view.endEditing(true)
    }
    
    @IBAction func pressLinkDropbox(_ sender: Any) {
        linkToDropbox()
    }
    
    func linkToDropbox() {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
        })
    }
    
    @IBAction func scanAction(_ sender: AnyObject) {
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized {
            presentScanAction()
            print("present scan action")
        }
        else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == true
                {
                    // User granted
                    self.presentScanAction()
                    print("first time access")
                }
                else
                {
                    // User Rejected
                    print("user reject")
                }
            });
        }
        
    }
    
    func presentScanAction() {
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            self.downloadProcess(plistURL: result?.value)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    func downloadProcess(plistURL: String?) {
        if let urlString = plistURL {
            print("handle \(urlString)")
            fadeViewInThenOut(popupString: getPopupString(inputString: urlString), view: notificationLabel, delay: 2)
            downloader.downloadFile(urlString: urlString)
            reload()
        }
    }
    
    func getPopupString(inputString: String) -> String{
        let element = inputString.components(separatedBy: "/")
        let fileName = element.last!
        let website = element[2]
        let fileType = fileName.components(separatedBy: ".").last
        var popupString : String
        
        if fileType == "plist" {
            popupString = "Try to Download files from " + website
        }
        else {
            popupString = "Try to Download " + fileName + " from " + website
        }
        return popupString
    }
    
    func fadeViewInThenOut(popupString: String,view : UILabel, delay: TimeInterval) {
        
        view.text = popupString
        
        let animationDuration = 2.5
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 1
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
                view.alpha = 0
            },
                                       completion: nil)
        }
    }
    
    
    @IBAction func ClickWebsiteButton(_ sender: Any) {
        if let url = URL(string: "https://noahleft.github.io/PDF-Book/") {
            UIApplication.shared.openURL(url)
        }
    }
    
}

extension ViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
        cell.titleLabel.text = songNumberList[indexPath.item]
        
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select \(indexPath.item)")
        quickLookController.currentPreviewItemIndex = 0
        selectedNum = indexPath.item
        quickLookController.reloadData()
////        navigationController?.pushViewController(quickLookController, animated: true)
        present(quickLookController, animated: true, completion: nil)
        
        
//        let selectedFile = fileList[indexPath.item]
//        if let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first {
////            let selectedPDFComp = selectedFile.appending(".pdf")
//            let path = dir.appendingPathComponent(selectedFile)
//            presentPDFDocumentInteraction(fileURL: path)
//        }
    }
    
    
}

extension ViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        
        if fileList.count>0 {
            let selectedFile = fileList[selectedNum]
            if let fileName = database.getFile(aFileName: selectedFile)?.qrcodeName {
                let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
                let qrcodeDocu = dir?.appendingPathComponent("QRCode", isDirectory: true)
                let path = qrcodeDocu?.appendingPathComponent(fileName)
                if FileManager.default.fileExists(atPath: (path?.path)!) {
                    return 2
                }
                else {
                    return 1
                }
            }
        }
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        if fileList.count > 0 {
            let selectedFile = fileList[selectedNum]
            if index == 1 {
                let fileName = database.getFile(aFileName: selectedFile)?.qrcodeName
                let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
                let qrcodeDocu = dir?.appendingPathComponent("QRCode", isDirectory: true)
                let path = qrcodeDocu?.appendingPathComponent(fileName!)
                return path as! QLPreviewItem
            }
            else {
                let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
                let path = dir?.appendingPathComponent(selectedFile)
                return path as! QLPreviewItem
            }
        }
        else {
            let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
            return dir as! QLPreviewItem
        }
    }
}


