//
//  VariableObject.swift
//  SongBook
//
//  Created by 林世豐 on 07/01/2017.
//  Copyright © 2017 林世豐. All rights reserved.
//

import Foundation

class IMPORTED_FILE : NSObject, NSCoding {
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(fileName, forKey: "fileName")
        aCoder.encode(fileSoureURL, forKey: "fileSourceURL")
        aCoder.encode(fileDestination, forKey: "fileDestinationURL")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fileName = aDecoder.decodeObject(forKey: "fileName") as! String
        fileSoureURL = aDecoder.decodeObject(forKey: "fileSourceURL") as! String
        fileDestination = aDecoder.decodeObject(forKey: "fileDestinationURL") as! URL
    }
    
    var fileName         : String
    var fileSoureURL     : String
    var fileDestination  : URL
    
    init(name : String, sour : String, dest : URL) {
        fileName = name
        fileSoureURL = sour
        fileDestination = dest
    }
    
    func dump() {
        print("\(fileName) url:\(fileSoureURL)")
    }
    
}

class DATABASE : NSObject {
    
    var fileList : [IMPORTED_FILE] = []
    
    func appendingFile(file : IMPORTED_FILE) {
        fileList.append(file)
    }
    
    func clearFile() {
        fileList.removeAll()
    }
    
    func save() {
        let defaults = UserDefaults.standard
        let fileData = NSKeyedArchiver.archivedData(withRootObject: fileList)
        defaults.set(fileData, forKey: "database")
        
        defaults.synchronize()
    }
    
    func restore() {
        let defaults = UserDefaults.standard
        let optionalData = defaults.object(forKey: "database") as? Data
        
        if let fileData = optionalData {
            let optionalDataList = NSKeyedUnarchiver.unarchiveObject(with: fileData) as? [IMPORTED_FILE]
            if let dataList = optionalDataList {
                fileList = dataList
            }
        }
    }
    
    func dump() {
        for element in fileList {
            element.dump()
        }
    }
}

var database : DATABASE = DATABASE()
