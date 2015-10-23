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
    var pages = (0...10)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let scrollView = UnlimitedScrollView(frame: UIScreen.mainScreen().applicationFrame)
        self.view.addSubview(scrollView)
        scrollView.unlimitedScrollViewDataSource = self
        scrollView.unlimitedScrollViewDelegate = self
        scrollView.reloadData()
        self.scrollView = scrollView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UnlimitedScrollViewDataSource {
    func numberOfPagesInUnlimitedScrollView(unlimitedScrollView: UnlimitedScrollView) -> Int {
        return pages.count
    }

    func numberOfVisiblePagesInUnlimitedScrollView(unlimitedScrollView: UnlimitedScrollView) -> Int {
        return 3
    }

    func unlimitedScrollView(unlimitedScrollView: UnlimitedScrollView, pageForItemAtIndex index: Int) -> UnlimitedScrollViewPage {
        let page = unlimitedScrollView.dequeueReusablePage()
        page!.textLabel?.text = "\(index)"
        page?.layer.borderColor = UIColor.blackColor().CGColor
        page?.layer.borderWidth = 2.0
        return page!
    }
}

extension ViewController: UnlimitedScrollViewDelegate {
}