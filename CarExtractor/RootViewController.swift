//
//  RootViewController.swift
//  CarExtractor
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
    
    fileprivate func generateDir(_ d: String = "") -> String{
        let formatter = DateFormatter();
        formatter.dateFormat = "YYYY-MM-dd HH-mm-ss"
        let dateStr = formatter.string(from: Date())
        let dir = outDir.appendingFormat("%@/%@", dateStr,d)
        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        return dir
    }
    
    fileprivate func exportCarFile(_ carPath: String, _ d: String) {
        
        tripLabel.isHidden = true;
        
        let dir = generateDir(d)
        currentDir = dir
        let sum = exportCarFileAtPath(carPath, dir)
        if sum > 0 {
            showInfo("成功提取\(sum)张图片，快去Finder查看吧")
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
                guard let carPath = url?.path else { return }
                exportCarFile(carPath, "")
            }
        }
    }
    
    fileprivate func showError(_ err: String) {
        tripLabel.isHidden = false;
        tripLabel.stringValue = err;
        tripLabel.textColor = NSColor(red: 246.0/255.0, green: 44.0/255.0, blue: 57.0/255.0, alpha: 1);
    }
    
    fileprivate func showInfo(_ msg: String) {
        tripLabel.isHidden = false;
        tripLabel.stringValue = msg;
        tripLabel.textColor = NSColor(red: 39.0/255.0, green: 161.0/255.0, blue: 82.0/255.0, alpha: 1);
    }
    
    @IBAction func aboutMe(_ sender: NSToolbarItem) {
        let url:URL = URL(string:"http://debugly.cn/apps/CarExporter/")!;
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
    
    func didDragFile(_ path: String, _ dir: String) {
        exportCarFile(path, dir)
    }
    
    func didDragNotCarFile(_ err: String) {
        showError(err)
    }
}
