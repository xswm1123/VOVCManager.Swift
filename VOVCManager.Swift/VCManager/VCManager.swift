//
//  VCManager.swift
//  VOVCManagerDemo
//
//  Created by Valo on 15/6/29.
//  Copyright (c) 2015年 Valo. All rights reserved.
//

import UIKit
//MARK:调试开关
let VO_DEBUG = true
//MARK:注册信息Key
let VCName:String = "name"
let VCController:String = "controller"
let VCStoryBoard:String = "storyboard"
let VCISPresent:String = "present"

//MARK:全局方法
/**
设置指定对象的参数

:param: params 参数
:param: obj    指定对象
*/
private func setParams(params:Dictionary<String,AnyObject>, forObject obj:AnyObject){
    for (key,val) in params{
        let sel:Selector? = Selector(key)
        if(sel != nil && obj.respondsToSelector(sel!)){
            obj.setValue(val, forKey: key)
        }
    }
}

func swiftClassFromString(className: String) -> AnyClass! {
    if  var appName: String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String? {
        appName = appName?.stringByReplacingOccurrencesOfString(".", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let classStringName = "\(appName!).\(className)"
        var  cls: AnyClass?  = NSClassFromString(classStringName)
        assert(cls != nil, "class notfound,please check className")
        return cls
    }
    return nil;
}


class VCRegistration: NSObject{
    var name:String?
    var controller:String?
    var storyboard:String?
    var isPresent:Bool = false

    convenience init?(spec:Dictionary<String,AnyObject>?){
        self.init()
        if(spec != nil){
            setParams(spec!, forObject: self)
        }
    }
}

class VCManager: NSObject{
    //MARK:私有属性
    private var viewControllers = [UIViewController]()
    private var naviControllers = [UINavigationController]()
    private var registerList:Set<VCRegistration> = []
    //MARK:公共属性
    var curViewController:UIViewController?{
        get{
            return self.viewControllers.last
        }
    }
    var curNaviController:UINavigationController?{
        get {
            var navi = self.viewControllers.last?.navigationController
            if(navi == nil){
                navi = self.naviControllers.last
            }
            return navi
        }
    }
    //MARK:单例对象
    /// 生成单例对象
    class func sharedManager()->VCManager{
        struct Singleton{
            static var predicate:dispatch_once_t = 0
            static var instance:VCManager? = nil
        }
        dispatch_once(&Singleton.predicate,{
            Singleton.instance = VCManager()
            Singleton.instance?.commonInit()
            }
        )
        return Singleton.instance!
    }
    
    //MARK:viewController管理
    /**
    将viewController添加到缓存列表
    
    :param: viewController 要添加的viewController
    */
    func addViewController(viewController:UIViewController){
        if(viewController.isKindOfClass(UIViewController.classForCoder()) && NSStringFromClass(viewController.classForCoder) != "UIInputWindowController"){
                self.viewControllers.append(viewController)
                self.printWithTag("Appear")
        }
        if(viewController.isKindOfClass(UINavigationController.classForCoder())){
            self.naviControllers.append(viewController as! UINavigationController)
        }
    }
    
    /**
    从保存的viewController列表中删除指定的viewController
    
    :param: viewController 要删除的viewController
    */
    func removeViewController(viewController:UIViewController){
        var index:Int = -1
        for i in 0..<self.viewControllers.count{
            let tmpVc = self.viewControllers[i]
            if(tmpVc == viewController){
                index = i
                break
            }
        }
        if(index >= 0){
            self.viewControllers.removeAtIndex(index)
            self.printWithTag("DisAppear")
        }
        index = -1
        if(viewController.isKindOfClass(UINavigationController.classForCoder())){
            for i in 0..<self.naviControllers.count{
                let tmpVc = self.naviControllers[i]
                if(tmpVc == viewController){
                    index = i
                    break
                }
            }
            if(index >= 0){
                self.naviControllers.removeAtIndex(index)
            }
        }
    }
    
    //MARK: viewController生成
    /**
    根据ViewController名称和Storyboard名称生成ViewController,无参数
    
    :param: aController 页面名称
    :param: aStoryboard 故事版名称
    
    :returns: viewController or nil
    */
    func viewController(aController:String, storyboard aStoryboard:String?)->UIViewController?{
        return self.viewController(aController, storyboard: aStoryboard, params: nil)
    }

    /**
    根据ViewController名称和Storyboard名称生成ViewController
    
    :param: aController 页面名称
    :param: aStoryboard 故事版名称
    :param: params      页面参数
    
    :returns: viewController or nil
    */
    func viewController(aController:String, storyboard aStoryboard:String?, params:Dictionary<String,AnyObject>?)->UIViewController?{
        let aClass:AnyClass? = swiftClassFromString(aController)
        if(aClass == nil){
            return nil
        }
        
        var viewController:AnyObject? = nil
        if(aStoryboard?.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) > 0){
            let storyboard:UIStoryboard? = UIStoryboard(name: aStoryboard!, bundle: nil)
            if(storyboard != nil){
                viewController = storyboard?.instantiateViewControllerWithIdentifier(aController)
            }
        }
        if(viewController == nil){
            let aControllerClass = aClass as! UIViewController.Type
            viewController = aControllerClass(nibName: aController, bundle: nil)
            if(viewController == nil){
                viewController = aControllerClass()
            }
        }
        if(viewController != nil && params != nil){
            setParams(params!, forObject: viewController!)
        }
        return viewController as? UIViewController
    }
    
    //MARK: 页面跳转
    /**
    页面跳转,push
    
    :param: aController 页面名称
    :param: aStoryboard 故事版名称
    */
    func pushViewController(aController:String, storyboard aStoryboard:String?){
        self.pushViewController(aController, storyboard: aStoryboard, params: nil, animated: true)
    }
    
    /**
    页面跳转,push,指定是否有动画效果
    
    :param: aController 页面名称
    :param: aStoryboard 故事版名称
    :param: animated    是否有动画效果
    */
    func pushViewController(aController:String, storyboard aStoryboard:String?, animated:Bool){
        self.pushViewController(aController, storyboard: aStoryboard, params: nil, animated: animated)
    }
    
    /**
    页面跳转,push,设置参数
    
    :param: aController 页面名称
    :param: aStoryboard 故事版名称
    :param: params      页面参数
    */
    func pushViewController(aController:String, storyboard aStoryboard:String?, params:Dictionary<String,AnyObject>?){
        self.pushViewController(aController, storyboard: aStoryboard, params: params, animated: true)
    }
    
    /**
    页面跳转,push,设置参数,并指定是否有动画效果
    
    :param: aController 页面名称
    :param: aStoryboard 故事版名称
    :param: params      页面参数
    :param: animated    是否有动画效果
    */
    func pushViewController(aController:String, storyboard aStoryboard:String?, params:Dictionary<String,AnyObject>?, animated:Bool){
        let viewController = self.viewController(aController, storyboard: aStoryboard, params: params)
        if(viewController == nil){
            return
        }
        self.curNaviController?.pushViewController(viewController!, animated: animated)
    }
    
    /**
    页面跳转,push,跳转至指定页面,并移除中间页面
    
    :param: aController       页面名称
    :param: aStoryboard       故事版名称
    :param: params            页面参数
    :param: animated          是否有动画效果
    :param: removeControllers 要移除的页面
    */
    func pushViewController(aController:String, storyboard aStoryboard:String?, params:Dictionary<String,AnyObject>?, animated:Bool, removeControllers:[String]?){
        self.pushViewController(aController, storyboard: aStoryboard, params: params, animated:animated)
        if(removeControllers == nil || self.curNaviController == nil){
            return
        }
        for removeController in removeControllers!{
            if(removeController != aController){
                var removeIndex:Int = -1
                for i in 0..<self.curNaviController!.viewControllers.count{
                    let viewController:AnyObject = self.curNaviController!.viewControllers[i]
                    if(viewController.type == removeController){
                        removeIndex = i
                    }
                }
                if(removeIndex >= 0){
                    self.curNaviController!.viewControllers .removeAtIndex(removeIndex)
                }
            }
        }
    }
    
    //MARK: 页面出栈
    /**
    页面出栈,指定是否有动画效果
    
    :param: animated 是否有动画效果
    
    :returns: 出栈的页面
    */
    func popViewControllerAnimated(animated:Bool)->UIViewController?{
        return self.curNaviController?.popViewControllerAnimated(animated)
    }
    
    /**
    页面出栈,至根页面,指定是否有动画效果
    
    :param: animated 指定是否有动画效果
    
    :returns: 出栈的页面数组
    */
    func popToRootViewControllerAnimated(animated:Bool)->[AnyObject]?{
        return self.curNaviController?.popToRootViewControllerAnimated(animated)
    }
    
    /**
    页面出栈,至指定页面,设置参数,指定是否有动画效果
    
    :param: aController 要显示的页面
    :param: params      要显示页面的参数
    :param: animated    是否有动画效果
    
    :returns: 出栈的页面数组
    */
    func popToViewController(aController:String, params:Dictionary<String,AnyObject>?, animated:Bool)->[AnyObject]?{
        if(self.curNaviController == nil){
            return nil
        }
        var targetVC:UIViewController? = nil
        for viewController in self.curNaviController!.viewControllers{
            if(viewController.type == aController){
                targetVC = viewController as? UIViewController
                break;
            }
        }
        
        if(targetVC != nil){
            if(params != nil){
                setParams(params!, forObject: targetVC!)
            }
            return self.curNaviController?.popToViewController(targetVC!, animated: animated)
        }
        
        return nil;
    }
    
    //MARK:页面显示
    /**
    页面显示,present方式,设置参数,指定动画等
    
    :param: aController 页面名称
    :param: aStoryboard 故事版名称
    :param: params      页面参数
    :param: animated    是否有动画效果
    :param: completion  显示完成后的操作
    */
    func presentViewController(aController:String, storyboard aStoryboard:String?, params:Dictionary<String,AnyObject>?, animated:Bool, completion:(()->Void)?){
        self.presentViewController(aController, storyboard: aStoryboard, params: params, animated: animated, isInNavi: false, completion: completion)
    }
    
    /**
    页面显示,present方式,设置参数,指定动画,是否包含在导航页中
    
    :param: aController 页面名称
    :param: aStoryboard 故事版名称
    :param: params      页面参数
    :param: animated    是否有动画效果
    :param: inNavi      是否包含在导航页中
    :param: completion  显示完成后的操作
    */
    func presentViewController(aController:String, storyboard aStoryboard:String?, params:Dictionary<String,AnyObject>?, animated:Bool,isInNavi inNavi:Bool, completion:(()->Void)?){
        let viewController = self.viewController(aController, storyboard: aStoryboard, params: params)
        if(viewController == nil||self.curViewController == nil){
            return
        }
        if(inNavi){
            if(self.curNaviController == nil){
                let navi = UINavigationController(rootViewController: viewController!)
                self.curViewController?.presentViewController(navi, animated: animated, completion: completion)
            }
            else{
                self.curNaviController!.presentViewController(viewController!, animated: animated, completion: completion)
            }
        }
        else{
            self.curViewController!.presentViewController(viewController!, animated: animated, completion: completion)
        }
    }
    
    /**
    页面销毁
    
    :param: animated   是否有动画效果
    :param: completion 页面销毁后的操作
    */
    func dismissViewControllerAnimated(animated:Bool, completion:(()->Void)?){
        if(self.curViewController == nil){
            return
        }
        self.curViewController!.dismissViewControllerAnimated(animated, completion: completion)
    }
    
    //MARK:页面URL管理
    /**
    注册页面
    
    :param: spec 页面特征参数
    */
    func registerWithSpec(spec:Dictionary<String,AnyObject>){
        let vcReg:VCRegistration? = VCRegistration(spec: spec)
        if(vcReg != nil){
            self.addRegistration(vcReg!)
        }
    }
    
    /**
    注册页面
    
    :param: name        页面注册名
    :param: aController 页面名称
    :param: aStoryboard 故事版名称
    :param: isPresent   是否present方式显示,是-present,否-push
    */
    func registerName(name:String,forViewController aController:String, storyboard aStoryboard:String?, isPresent:Bool){
        let vcReg = VCRegistration()
        vcReg.name = name
        vcReg.controller = aController
        vcReg.storyboard = aStoryboard
        vcReg.isPresent = isPresent
        self.addRegistration(vcReg)
    }
    
    /**
    取消注册页面
    
    :param: name 页面注册名
    */
    func cancelRegisterName(name:String){
        var removeVcReg:VCRegistration? = nil
        for vcReg in self.registerList{
            vcReg.name == name
            removeVcReg  = vcReg
            break
        }
        if(removeVcReg != nil){
            self.registerList.remove(removeVcReg!)
        }
    }
    
    /**
    处理URL
    
    :param: url 以AppScheme开始的URL
    
    :returns: 是否成功处理
    */
    func handleURL(url:NSURL)->Bool{
        /** 1.检查scheme是否匹配 */
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
        let urlTypes:[Dictionary<String, AnyObject>]? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleURLTypes") as? [Dictionary<String, AnyObject>]
        var schemes = [String]()
        if(urlTypes == nil){
            return false
        }
        for dic in urlTypes!{
            let tmpArray:[String]? = dic["CFBundleURLSchemes"] as? [String]
            if(tmpArray != nil){
                schemes += tmpArray!
            }
        }
        var match:Bool = false
        for scheme in schemes{
            if(scheme == components?.scheme){
                match = true
            }
        }
        if(!match){
            return false
        }
        /** 2.获取页面名 */
        let name = (components?.path?.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) == 0) ? components?.host : components?.path?.lastPathComponent
        /** 3.获取页面参数 */
        var params:Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        let tmpArray = components?.query?.componentsSeparatedByString("&")
        if(tmpArray == nil){
            return false
        }
        for paramStr in tmpArray!{
            let range = paramStr.rangeOfString("=", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil)
            if(range != nil){
                let key = paramStr.substringToIndex(range!.startIndex)
                let val = paramStr.substringFromIndex(range!.endIndex)
                params[key] = val
            }
        }
        /** 4.打开对应页面 */
        self.showViewControllerWithRegisterName(name!, params: params)
        
        return true
    }
    
    /**
    显示指定页面
    
    :param: name   页面注册名
    :param: params 页面参数
    */
    func showViewControllerWithRegisterName(name:String, params:Dictionary<String, AnyObject>){
        /** 1.检查是否注册,若注册,则获取相应的参数 */
        var registration:VCRegistration? = nil
        for tmpReg in self.registerList{
            if(tmpReg.name == name){
                registration = tmpReg
                break
            }
        }
        if(registration == nil || registration?.controller == nil){
            return
        }
        
        /** 2.打开指定页面 */
        if(registration!.isPresent){
            self.presentViewController(registration!.controller!, storyboard: registration!.storyboard, params: params, animated: true, completion: nil)
        }
        else{
            self.pushViewController(registration!.controller!, storyboard: registration!.storyboard, params: params)
        }
    }
    //MARK:私有函数
    private func commonInit(){
        UIViewController.record()
    }
    
    /**
    打印viewController层级信息
    
    :param: tag 打印标签
    */
    private func printWithTag(tag:String){
        if(VO_DEBUG){
            var paddingItems:String = ""
            for tmpVc in self.viewControllers{
                paddingItems = paddingItems + "--"
            }
            println("\(tag):\(paddingItems)>\(self.viewControllers.last?.description)")
        }
    }
    
    /**
    添加注册信息
    
    :param: registration 注册信息
    
    :returns: 是否添加成功
    */
    private func addRegistration(registration:VCRegistration)->Bool{
        for vcReg in self.registerList{
            if(vcReg.name == registration.name){
                return false
            }
        }
        self.registerList.insert(registration)
        return true
    }

}