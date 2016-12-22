//
//  CodeReader.swift
//  SongBook
//
//  Created by 林世豐 on 22/12/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//
import Foundation
import QRCodeReader
import AVFoundation


extension ViewController: QRCodeReaderViewControllerDelegate {
    /**
     Tells the delegate that the user wants to stop scanning codes.
     
     - parameter reader: A code reader object informing the delegate about the cancellation.
     */
    public func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }

    /**
     Tells the delegate that the reader did scan a code.
     
     - parameter reader: A code reader object informing the delegate about the scan result.
     - parameter result: The result of the scan
     */
    // MARK: - QRCodeReaderViewController Delegate Methods
    public func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }

    //This is an optional delegate method, that allows you to be notified when the user switches the cameraName
    //By pressing on the switch camera button
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        if let cameraName = newCaptureDevice.device.localizedName {
            print("Switching capturing to: \(cameraName)")
        }
    }
    
}

