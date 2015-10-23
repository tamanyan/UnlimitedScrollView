//
//  ViewController.swift
//  UnlimitedScrollViewExample
//
//  Created by svpcadmin on 2015/10/23.
//  Copyright © 2015年 tamanyan. All rights reserved.
//

import UIKit
import UnlimitedScrollView

class ViewController: UIViewController {
    var scrollView: UnlimitedScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let scrollView = UnlimitedScrollView(frame: UIScreen.mainScreen().applicationFrame)
        scrollView.backgroundColor = UIColor.redColor()
        self.view.addSubview(scrollView)
        self.scrollView = scrollView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

