//
//  DragView.swift
//  CarExtractor
//
//  Created by Matt Reach on 2019/10/22.
//  Copyright © 2019 Matt Reach. All rights reserved.
//

import Cocoa

@objc
protocol DragViewDelegate: NSObjectProtocol {
    
    func didDragFile(_ path:String,_ dir:String)->Void
    func didDragNotCarFile(_ err:String)->Void
}

class DragView: NSView {
    
    var delegate:DragViewDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.wantsLayer = true
        let color = NSColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1)
        self.layer?.borderColor = color.cgColor
        let draggedType = NSPasteboard.PasteboardType(kUTTypeDirectory as String)
         registerForDraggedTypes([draggedType,NSPasteboard.PasteboardType.init(rawValue: "NSFilenamesPboardType")])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.layer?.borderWidth = 2
        let dragMask = sender.draggingSourceOperationMask
        if (dragMask.rawValue & NSDragOperation.link.rawValue != 0){
            return NSDragOperation.link
        } else {
            return dragMask
        }
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.borderWidth = 0
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.borderWidth = 0
    }
    
    fileprivate func didDragFile(_ path:String,_ dir:String){
        if (delegate != nil) && delegate!.responds(to: #selector(DragViewDelegate.didDragFile(_:_:))) {
                        delegate!.didDragFile(path,dir)
        }
    }
    
    fileprivate func didDragFolder(_ res_dir:String){
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: res_dir)
            let bundle = NSString(string: res_dir).lastPathComponent
            
            if files.count > 0 {
                let carFiles = NSArray(array:files).pathsMatchingExtensions(["car"])
                if carFiles.count == 1 {
                    let car = carFiles.first!
                    didDragFile("\(res_dir)/\(car)",bundle)
                } else if carFiles.count > 1 {
                    for car in carFiles {
                        let carName = (NSURL(string: car)?.lastPathComponent)!
                        didDragFile(carFiles.first!,"\(bundle)/\(carName)")
                    }
                } else {
                    didDragNotCarFile("\(bundle)文件夹内没有发现Assets哦")
                }
            } else {
               didDragNotCarFile("\(bundle)文件夹内没有发现Assets哦")
            }
        } catch {
            print(error)
        }
    }
    
    fileprivate func didDragNotCarFile(_ err:String){
        if (delegate != nil) && delegate!.responds(to: #selector(DragViewDelegate.didDragNotCarFile(_:))) {
                        delegate!.didDragNotCarFile(err)
        }
    }
    
    fileprivate func didDragAppBundle(_ bundle:String){
        let res_dir = bundle.appending("/Contents/Resources")
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: res_dir)
            if files.count > 0 {
                let carFiles = NSArray(array:files).pathsMatchingExtensions(["car"])
                let bundleName = NSString(string: bundle).lastPathComponent
                let bundle = NSString(string: bundleName).deletingPathExtension
                
                if carFiles.count == 1 {
                    let car = carFiles.first!
                    didDragFile("\(res_dir)/\(car)",bundle)
                } else if carFiles.count > 1 {
                    for car in carFiles {
                        let carName = (NSURL(string: car)?.lastPathComponent)!
                        didDragFile(carFiles.first!,"\(bundle)/\(carName)")
                    }
                } else {
                    didDragNotCarFile("App内没有发现Assets哦")
                }
            } else {
               didDragNotCarFile("App内没有发现Assets哦")
            }
        } catch {
            print(error)
        }
    }
    
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly:true]) ?? []
        
        for url in urls {
            let src = url as! URL
            
            if src.pathExtension.count > 0 {
                if "app".elementsEqual(src.pathExtension) {
                    didDragAppBundle(src.path)
                } else if "car".elementsEqual(src.pathExtension) {
                    didDragFile(src.path,"")
                } else {
                    didDragNotCarFile("不支持的文件类型\(src.pathExtension)")
                }
            } else {
                didDragFolder(src.path)
            }
        }
        return true
    }
    
    
}
