//
//  VariableObject.swift
//  SongBook
//
//  Created by 林世豐 on 07/01/2017.
//  Copyright © 2017 林世豐. All rights reserved.
//

import Foundation

class IMPORTED_FILE {
    
    var fileName : String
    var fileURL  : URL
    
    init(name : String, url : URL) {
        fileName = name
        fileURL  = url
    }
    
}

class DATABASE {
    
    var fileList : [IMPORTED_FILE] = []
    
    func appendingFile(file : IMPORTED_FILE) {
        fileList.append(file)
    }
    
    func clearFile() {
        fileList.removeAll()
    }
    
}

