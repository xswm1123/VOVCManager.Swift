//
//  VORecentsMainController.swift
//  VOVCManger.Swift
//
//  Created by Valo on 15/7/9.
//  Copyright (c) 2015年 Valo. All rights reserved.
//

import UIKit

class VORecentsMainController: UIViewController {
    var test:String? = nil{
        didSet{
            println("didSet: test = \(test!)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("test = \(self.test)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
