//
//  ViewController.swift
//  SongBook
//
//  Created by 林世豐 on 12/11/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var webView2: UIWebView!
    var songList : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let songNames = ["song#07", "song#17", "song#18", "song#22", "song#27", "song#29", "song#30", "song#43", "song#48", "song#49", "song#50", "song#54", "song#61", "song#63", "song#66", "song#80", "song#81", "song#86", "song#88", "song#97", "song#102", "song#105", "song#106", "song#108", "song#12", "song#123", "song#125",  "song#131", "song#133"]
        
        songList.append(contentsOf: songNames)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressLoadButton(_ sender: AnyObject) {
        
        let selectedIndex = pickerView.selectedRow(inComponent: 0)
        let selectedPDF = songList[selectedIndex]
        print("\(selectedIndex)   \(selectedPDF)")
        
        if let pdfURL = Bundle.main.url(forResource: selectedPDF, withExtension: "pdf", subdirectory: nil, localization: nil) {
            print("Phy ya")
            let url = URLRequest(url: pdfURL)
            webView.loadRequest(url)
            if let pdfURL2 = Bundle.main.url(forResource: selectedPDF+"_2", withExtension: "pdf", subdirectory: nil, localization: nil) {
                let url2 = URLRequest(url: pdfURL2)
                webView2.loadRequest(url2)
            }
            else {
                webView2.loadRequest(url)
            }
        }
        
        
    }

    @IBAction func pressToggleButton(_ sender: AnyObject) {
        
        if webView.isHidden {
            webView.isHidden = false
            webView2.isHidden = true
        }
        else {
            webView.isHidden = true
            webView2.isHidden = false
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
    
    
}
