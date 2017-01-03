//
//  ViewController.swift
//  SongBook
//
//  Created by 林世豐 on 12/11/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation

class ViewController: UIViewController {
    
    //Custom QR Code Reader
    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
    lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
    })
    //
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    
    
    var songList : [String] = []
    var songNumberList : [String] = []
    let reuseIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        buildSongList()
        downloader.addObserver(self, forKeyPath: "downloadFraction", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        downloader.addObserver(self, forKeyPath: "counter", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }
    
    func buildSongList() {
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: dir)
                let songNames = contents.filter{ (n) -> Bool in
                    return n.range(of: ".pdf") != nil
                    }.map{ (n) -> String in
                        return n.components(separatedBy: ".")[0]
                    }.sorted(by: songNameSortFunction)
                songList.append(contentsOf: songNames)
            }
            catch {
                print("!@#")
            }
        }
        
        songNumberList = songList.map{ (n) -> String in
            return n.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
        }
        
        if songList.count > 0 {
            imageView.isHidden = true
            textLabel.isHidden = true
        }
        else {
            imageView.isHidden = false
            textLabel.isHidden = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("catch fraction changes")
        reload()
    }
    
    
    func songNameSortFunction(aStr: String, bStr: String) -> Bool {
        let aDig : String = aStr.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
        let bDig : String = bStr.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
        return Int(aDig)! < Int(bDig)!
    }
    
    func reload() {
        songList = []
        songNumberList = []
        buildSongList()
        collectionView.reloadData()
    }
    
    @IBAction func pressDownloadButton(_ sender: Any) {
        downloader.pullAllFile()
        reload()
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
    
    
    @IBAction func scanAction(_ sender: AnyObject) {
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
            downloader.pullFileList(fileURLString: urlString)
            reload()
        }
    }
}

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
}

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return songList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return songList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = songList[row]
    }
    
}

extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
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
        let selectedPDF = songList[indexPath.item]
        if let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first {
            let selectedPDFComp = selectedPDF.appending(".pdf")
            let path = dir.appendingPathComponent(selectedPDFComp)
            presentPDFDocumentInteraction(fileURL: path)
        }
    }
    
    
}

