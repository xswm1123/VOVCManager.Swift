//
//  NSObject+Runtime.swift
//  VOVCManagerDemo
//
//  Created by Valo on 15/6/29.
//  Copyright (c) 2015年 Valo. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

func method_swizzle(aClass:AnyClass?, origSelector:Selector, altSelector:Selector)->Bool{
    if aClass == nil {
        return false
    }
    
    var origMethod:Method?
    var altMethod:Method?
    
    func find_methods(){
        var methodCount:UInt32 = 0
        let methodList:UnsafeMutablePointer<Method> = class_copyMethodList(aClass, &methodCount)
        origMethod = nil
        altMethod = nil
        
        if methodList != nil {
            for index in 0...methodCount{
                let method:Method = methodList[Int(index)]
                let sel:Selector = method_getName(method)
                if origSelector == sel{
                    origMethod = method
                }
                
                if altSelector == sel{
                    altMethod = method
                }
            }
        }
        free(methodList)
    }
    
    find_methods()
    
    if origMethod == nil{
        origMethod = class_getInstanceMethod(aClass, origSelector)
        if origMethod == nil{
            return false
        }
        if class_addMethod(aClass, method_getName(origMethod!), method_getImplementation(origMethod!), method_getTypeEncoding(origMethod!)) == false{
            return false
        }
    }
    
    if altMethod == nil{
        altMethod = class_getInstanceMethod(aClass, altSelector)
        if altMethod == nil{
            return false
        }
        if class_addMethod(aClass, method_getName(altMethod!), method_getImplementation(altMethod!), method_getTypeEncoding(altMethod!)) == false{
            return false
        }
    }
    
    find_methods()
    
    if origMethod == nil || altMethod == nil{
        return false
    }
    
    method_exchangeImplementations(origMethod!, altMethod!)
    return true;
}

func method_append(toClass:AnyClass?, fromClass:AnyClass?, aSelector:Selector?){
    if toClass == nil || fromClass == nil || aSelector == nil  {
        return
    }
    
    let method:Method = class_getInstanceMethod(fromClass, aSelector!)
    
    if method == nil {
        return
    }
    class_addMethod(toClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method))
}

func method_replace(toClass:AnyClass?, fromClass:AnyClass?, selector:Selector?){
    if toClass == nil || fromClass == nil || selector == nil  {
        return
    }
    
    let method:Method = class_getInstanceMethod(fromClass, selector!)
    
    if method == nil {
        return
    }
    class_replaceMethod(toClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method))
}

func loop_check(aClass:AnyClass?, aSelector:Selector?, stopClass:AnyClass?)->Bool{
    if aClass == nil || aClass === stopClass{
        return false
    }
    var methodCount:UInt32 = 0
    let methodList:UnsafeMutablePointer<Method> = class_copyMethodList(aClass!, &methodCount)
    if methodList != nil{
        for i in 0...methodCount{
            if method_getName(methodList[Int(i)]) == aSelector!{
                return true
            }
        }
    }
    return loop_check(aClass,  aSelector, stopClass)
}

extension NSObject{
    class func swizzleMethod(origSelector:Selector, newSelector:Selector){
        method_swizzle(self, origSelector, newSelector)
    }
    
    class func appendMethod(newSelector:Selector, fromClass aClass:AnyClass){
        method_append(self, aClass, newSelector)
    }
    
    class func replaceMethod(aSelector:Selector, fromClass aClass:AnyClass){
        method_replace(self, aClass, aSelector)
    }
    
    class func instancesRespondToSelector(aSelector:Selector, untilClass stopClass:AnyClass)->Bool {
        return loop_check(self.classForCoder(), aSelector, stopClass)
    }
    
    func respondsToSelector(aSelector:Selector, untilClass stopClass:AnyClass)->Bool{
        return self.classForCoder.instancesRespondToSelector(aSelector, untilClass: stopClass)
    }
    
    func superRespondsToSelector(aSelector:Selector)->Bool{
        return self.superclass!.instancesRespondToSelector(aSelector)
    }
    func superRespondsToSelector(aSelector:Selector, untilClass stopClass:AnyClass)->Bool{
        return self.superclass!.instancesRespondToSelector(aSelector, untilClass: stopClass)
    }
}



























