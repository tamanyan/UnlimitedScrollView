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
    var scrollView: UnlimitedScrollView!
    var button: UIButton!
    var pageSlider: UISlider!
    var pages = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        (0...9).forEach { [unowned self] (value) in
            self.pages.append(value)
        }
        self.scrollView = UnlimitedScrollView(frame: UIScreen.mainScreen().applicationFrame)
        self.view.addSubview(self.scrollView)
        self.scrollView.unlimitedScrollViewDataSource = self
        self.scrollView.unlimitedScrollViewDelegate = self
        self.scrollView.firstVisiblePageIndex = 5
        self.scrollView.reloadData()

        self.button = UIButton(type: .System)
        self.button.frame = CGRectMake(10, 60, 100, 30)
        self.button.setTitle("ページ追加", forState: UIControlState.Normal)
        self.button.layer.masksToBounds = true
        self.view.addSubview(self.button)
        self.button.addTarget(self, action: "addPage:", forControlEvents: .TouchUpInside)

        let insetFrame = CGRectInset(self.view.frame, 10, 10)
        self.pageSlider = UISlider(frame:
            CGRectMake(
                CGRectGetMinX(insetFrame),
                CGRectGetMaxY(insetFrame) - 50,
                insetFrame.width, 30
            )
        )
        self.pageSlider.minimumValue = 0
        self.pageSlider.maximumValue = Float(pages.count - 1)
        self.pageSlider.continuous = false
        self.pageSlider.addTarget(self, action: "movePage:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.pageSlider)
    }

    func addPage(button: UIButton) {
        self.pages.append(self.pages.maxElement()! + 1)
        self.pageSlider.maximumValue = Float(pages.count - 1)
        self.scrollView.firstVisiblePageIndex = self.scrollView.currentPageIndex
        self.scrollView.reloadData()
    }

    func movePage(slider: UISlider) {
        let moveSize = self.scrollView.moveTo(Int(slider.value))
        print("move size \(moveSize)")
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