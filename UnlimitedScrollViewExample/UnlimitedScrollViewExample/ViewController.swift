//
//  ViewController.swift
//  UnlimitedScrollViewExample
//
//  Created by tamanyan on 2015/10/23.
//  Copyright © 2015年 tamanyan. All rights reserved.
//

import UIKit
import UnlimitedScrollView

class ViewController: UIViewController {
    var scrollView: UnlimitedScrollView?
    var pages = (0...9)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view, typically from a nib.
        let scrollView = UnlimitedScrollView(frame: UIScreen.mainScreen().applicationFrame)
        self.view.addSubview(scrollView)
        scrollView.unlimitedScrollViewDataSource = self
        scrollView.unlimitedScrollViewDelegate = self
        scrollView.firstVisiblePageIndex = 9
        scrollView.reloadData()
        self.scrollView = scrollView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.view.setNeedsDisplay()
        self.view.setNeedsLayout()
    }
}

extension ViewController: UnlimitedScrollViewDataSource {
    func numberOfPagesInUnlimitedScrollView(unlimitedScrollView: UnlimitedScrollView) -> Int {
        return pages.count
    }

    func numberOfVisiblePagesInUnlimitedScrollView(unlimitedScrollView: UnlimitedScrollView) -> Int {
        return 5
    }

    func unlimitedScrollView(unlimitedScrollView: UnlimitedScrollView, pageForItemAtIndex index: Int) -> UnlimitedScrollViewPage {
        let page = unlimitedScrollView.dequeueReusablePage()
        let textView = TextScrollView(frame: CGRect(origin: CGPoint.zero, size: unlimitedScrollView.pageSize))
        textView.textLabel?.text = "\(index)"
        page?.customView = textView
        return page!
    }
}

extension ViewController: UnlimitedScrollViewDelegate {
}