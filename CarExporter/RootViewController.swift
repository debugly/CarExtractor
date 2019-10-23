//
//  RootViewController.swift
//  CarToolApp
//
//  Created by Matt Reach on 2019/10/22.
//  Copyright © 2019 Matt Reach. All rights reserved.
//

import Cocoa

class RootViewController: NSViewController,DragViewDelegate {
    
    @IBOutlet weak var dragView: DragView!
    
    @IBOutlet weak var tripLabel: NSTextField!
    lazy var outDir = { () -> String in
        var dir  = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.desktopDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        dir = dir.appending("/CarTool/")
        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        return dir
    }()
    
    var currentDir: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        dragView.delegate = self
    }
    
    fileprivate func generateDir() -> String{
        let formatter = DateFormatter();
        formatter.dateFormat = "YYYY-MM-dd HH-MM-SS"
        let dateStr = formatter.string(from: Date())
        let dir = outDir.appendingFormat("%@", dateStr)
        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        return dir
    }
    
    fileprivate func exportCarFile(_ carPath: String?) {
        
        tripLabel.isHidden = true;
        
        if carPath != nil {
            
            let dir = generateDir()
            currentDir = dir
            let sum = exportCarFileAtPath(carPath, dir)
            if sum > 0 {
                tripLabel.isHidden = false;
                tripLabel.stringValue = "成功提取\(sum)张图片，快去Finder查看吧";
            }
        }
    }
    
    @IBAction func openFile(_ sender: NSToolbarItem) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.downloadsDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        
        if(dir != nil){
            openPanel.directoryURL = URL(string: dir!)
        }
        
        openPanel.allowedFileTypes = ["car","app"];
        
        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            let url = openPanel.url;
            if url != nil {
                let carPath = url?.path
                exportCarFile(carPath)
            }
        }
    }
    
    @IBAction func aboutMe(_ sender: NSToolbarItem) {
        let url:URL = URL(string:"http://debugly.cn/apps")!;
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func showInFinder(_ sender: NSToolbarItem) {
        tripLabel.isHidden = true;
        var dir = currentDir
        if dir == nil {
            dir = outDir
        }
        let url = URL(fileURLWithPath: dir!)
        NSWorkspace.shared.open(url)
    }
    
    func didDragFile(_ path: String) {
        exportCarFile(path)
    }
}
