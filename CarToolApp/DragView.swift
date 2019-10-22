//
//  DragView.swift
//  CarToolApp
//
//  Created by Matt Reach on 2019/10/22.
//  Copyright © 2019 Matt Reach. All rights reserved.
//

import Cocoa

@objc
protocol DragViewDelegate: NSObjectProtocol {
    
    func didDragFile(_ path:String)->Void
}

class DragView: NSView {
    
    var delegate:DragViewDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.wantsLayer = true
        let color = NSColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1)
        self.layer?.borderColor = color.cgColor
        registerForDraggedTypes([NSPasteboard.PasteboardType.init(rawValue: "NSFilenamesPboardType")])
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
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly:true]) ?? []
        
        for url in urls {
            let src = url as! URL
            if (delegate != nil) && delegate!.responds(to: #selector(DragViewDelegate.didDragFile(_:))) {
                delegate!.didDragFile(src.path)
            }
                
        }
        return true
    }
    
    
}
