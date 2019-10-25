//
//  AppDelegate.swift
//  CarExtractor
//
//  Created by Matt Reach on 2019/10/22.
//  Copyright © 2019 Matt Reach. All rights reserved.
//

import Cocoa

let ReLaunchKey = "from workspace"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var isMoveToApplicationFolder = false
    var bundlePath:String?
    var bundleName:String?
    
    fileprivate func checkMoveToApplicationFolder(callback: () -> Void) {
        
        let lunchPath = ProcessInfo.processInfo.arguments.first
        
        if lunchPath != nil {
            // .../CarExtractor.app/Contents/MacOS/CarExtractor
            var lunchUrl = NSURL(string: lunchPath!)
            guard (lunchUrl != nil) else { return }
            
            if lunchUrl != nil {
                lunchUrl = lunchUrl!.deletingLastPathComponent as NSURL?
            }
            if lunchUrl != nil {
                lunchUrl = lunchUrl!.deletingLastPathComponent as NSURL?
            }
            if lunchUrl != nil {
                lunchUrl = lunchUrl!.deletingLastPathComponent as NSURL?
            }
            
            if lunchUrl != nil {
                bundlePath = lunchUrl!.absoluteString
                bundleName = lunchUrl!.lastPathComponent
                lunchUrl = lunchUrl!.deletingLastPathComponent as NSURL?
            }
            
            if lunchUrl != nil {
                
                guard let lunchDir = lunchUrl!.absoluteString else { return }
                if !lunchDir.elementsEqual("/Applications/") {
                    
                    let alert = NSAlert()
                    alert.messageText = "Move to Applications folder?"
                    alert.informativeText = "I can move myself to the Applications folder if you'd like."
                    alert.addButton(withTitle: "Move Now")
                    alert.addButton(withTitle: "No,Thanks")
                    
                    if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
                        isMoveToApplicationFolder = true
                        NSApp.terminate(self);
                    } else {
                        print("lunch from \(lunchDir).")
                        callback()
                        return
                    }
                } else {
                    print("lunch from Applications Folder.")
                    callback()
                    return
                }
            }
        }
        
        callback()
    }
    
    fileprivate func moveToApplicationFolder(){
        guard (bundlePath != nil) else {
            return
        }
        
        do {
            let toPath = "/Applications/\(bundleName!)"
            if FileManager.default.fileExists(atPath: toPath) {
               try FileManager.default.removeItem(atPath: toPath)
            }
            try FileManager.default.copyItem(atPath: bundlePath!, toPath: toPath)
            
            let url:URL? = URL(fileURLWithPath: toPath)
            guard (url != nil) else { return }
            
            try NSWorkspace.shared.launchApplication(at: url!, options: [NSWorkspace.LaunchOptions.async,  NSWorkspace.LaunchOptions.newInstance], configuration: [NSWorkspace.LaunchConfigurationKey.arguments:[]])
        
            try FileManager.default.removeItem(atPath: bundlePath!)
        } catch {
            print(error)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if ProcessInfo.processInfo.environment["__XCODE_BUILT_PRODUCTS_DIR_PATHS"] == nil {
            checkMoveToApplicationFolder {
                window.makeKeyAndOrderFront(nil)
                
                if ProcessInfo.processInfo.arguments.contains(ReLaunchKey) {
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        } else {
            window.makeKeyAndOrderFront(nil)
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        if isMoveToApplicationFolder {
            moveToApplicationFolder()
            isMoveToApplicationFolder = false
            print("move to Applications folder.")
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        window.makeKeyAndOrderFront(nil)
        return true
    }
}
