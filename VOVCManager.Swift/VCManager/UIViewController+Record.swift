//
//  UIViewController+Record.swift
//  VOVCManagerDemo
//
//  Created by Valo on 15/6/29.
//  Copyright (c) 2015年 Valo. All rights reserved.
//

import UIKit

extension UIViewController{
    static var isRecord:Bool? = false
    
    func recordViewDidAppear(animated:Bool){
        VCManager.sharedManager().addViewController(self)
        self.recordViewDidAppear(animated)
    }
    func recordViewDidDisappear(animated:Bool){
        VCManager.sharedManager().removeViewController(self)
        self.recordViewDidDisappear(animated)
    }
    
    class func record(){
        if(isRecord!){
            return
        }
        
        self.swizzleMethod(Selector("viewDidAppear:"), newSelector: Selector("recordViewDidAppear:"))
        self.swizzleMethod(Selector("viewDidDisappear:"), newSelector: Selector("recordViewDidDisappear:"))
        
        isRecord = true
    }
    
    class func unRecord(){
        if(!isRecord!){
            return
        }
        
        self.swizzleMethod(Selector("recordViewDidAppear:"), newSelector: Selector("viewDidAppear:"))
        self.swizzleMethod(Selector("recordViewDidDisappear:"), newSelector: Selector("viewDidDisappear:"))
        
        isRecord = false
    }
}

