//
//  AppDelegate.swift
//  SongBook
//
//  Created by 林世豐 on 12/11/2016.
//  Copyright © 2016 林世豐. All rights reserved.
//

import UIKit
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DropboxClientsManager.setupWithAppKey("9aji0wsn1xpj392")
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
        }
        else {
            do {
                var destURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                destURL.appendPathComponent(url.lastPathComponent)
                try FileManager.default.copyItem(at: url, to: destURL)
                try FileManager.default.removeItem(at: url)
                downloader.triggerReload()
            }
            catch {
                print("open in event (UTI) failure.")
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        do {
            // File Manager
            let filemgr = FileManager.default
            
            // Document Directory
            let docsDirURL = try filemgr.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
            
            let recipesURL = docsDirURL.appendingPathComponent("Books")
            if !filemgr.fileExists(atPath: recipesURL.absoluteString) {
                do {
                    try filemgr.createDirectory(at: recipesURL, withIntermediateDirectories: false, attributes: nil)
                    print("Directory created at: \(recipesURL)")
                } catch let error as NSError {
                    NSLog("Unable to create directory \(error.debugDescription)")
                    return false
                }
            }
            
            let incomingFileName = url.lastPathComponent
            
            let startingURL = url
            let endingURL = recipesURL.appendingPathComponent(incomingFileName)
            
            if !filemgr.fileExists(atPath: endingURL.absoluteString) {
                do {
                    try filemgr.moveItem(at: startingURL, to: endingURL)
                } catch let error as NSError {
                    NSLog("Unable to move file \(error.debugDescription)")
                }
            }
        }
        catch {
            return false
        }
        return true
    }
    
}

