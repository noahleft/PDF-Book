//
//  ViewController.swift
//  SongBook
//
//  Created by 林世豐 on 12/11/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var pickerTextField: UITextField!
    
    var songList : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let songNames = ["song#07", "song#12", "song#17", "song#18", "song#22", "song#27", "song#29", "song#30", "song#43", "song#48", "song#49", "song#50", "song#54", "song#61", "song#63", "song#66", "song#80", "song#81", "song#86", "song#88", "song#97", "song#102", "song#105", "song#106", "song#108", "song#123", "song#125",  "song#131", "song#133", "song#136", "song#137", "song#138", "song#139", "song#140", "song#141", "song#142", "song#143", "song#144", "song#146", "song#147", "song#148", "song#149", "song#152"]
        
        songList.append(contentsOf: songNames)
        
        let picker = UIPickerView()
        picker.delegate = self
        pickerTextField.inputView = picker
        pickerTextField.text = songList[0]
        
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(ViewController.dismissPicker))
        pickerTextField.inputAccessoryView = toolBar
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        print("memory warning")
    }
    
    @IBAction func pressPresentPDFButton(_ sender: AnyObject) {
        let selectedPDF = pickerTextField.text!
         if let pdfURL = Bundle.main.url(forResource: selectedPDF, withExtension: "pdf", subdirectory: nil, localization: nil) {
            presentPDFDocumentInteraction(fileURL: pdfURL)
        }
    }

    @IBAction func pressLoadButton(_ sender: AnyObject) {
        
        let selectedPDF = pickerTextField.text!
        
        if let pdfURL = Bundle.main.url(forResource: selectedPDF, withExtension: "pdf", subdirectory: nil, localization: nil) {
            print("Phy ya")
            let url = URLRequest(url: pdfURL)
            webView.loadRequest(url)
        }
    }
    
    func presentPDFDocumentInteraction(fileURL : URL) {
        let docuController : UIDocumentInteractionController = UIDocumentInteractionController.init(url: fileURL)
        docuController.delegate = self
        docuController.presentPreview(animated: true)
    }
    
    func dismissPicker() {
        view.endEditing(true)
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

