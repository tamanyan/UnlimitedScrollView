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
    var pageSlider: UISlider?
    var pages = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        (0...9).forEach { [unowned self] (value) in
            self.pages.append(value)
        }
        self.scrollView = UnlimitedScrollView(frame: UIScreen.main.applicationFrame)
        self.view.addSubview(self.scrollView)
        self.scrollView.unlimitedScrollViewDataSource = self
        self.scrollView.unlimitedScrollViewDelegate = self
        self.scrollView.firstVisiblePageIndex = 5

        self.button = UIButton(type: .system)
        self.button.frame = CGRect(x: 10, y: 60, width: 100, height: 30)
        self.button.setTitle("Add Page", for: UIControlState())
        self.button.layer.masksToBounds = true
        self.view.addSubview(self.button)
        self.button.addTarget(self, action: #selector(ViewController.addPage(_:)), for: .touchUpInside)

        let insetFrame = self.view.frame.insetBy(dx: 10, dy: 10)
        self.pageSlider = UISlider(frame:
            CGRect(
                x: insetFrame.minX,
                y: insetFrame.maxY - 50,
                width: insetFrame.width, height: 30
            )
        )
        self.pageSlider?.minimumValue = 0
        self.pageSlider?.maximumValue = Float(pages.count - 1)
        self.pageSlider?.isContinuous = false
        self.pageSlider?.addTarget(self, action: #selector(ViewController.movePage(_:)), for: .touchUpInside)
        self.view.addSubview(self.pageSlider!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scrollView.reloadData()
    }

    func addPage(_ button: UIButton) {
        self.pages.append(self.pages.max()! + 1)
        self.pageSlider?.maximumValue = Float(pages.count - 1)
        self.scrollView.firstVisiblePageIndex = self.scrollView.currentPageIndex
        self.scrollView.reloadData()
    }

    func movePage(_ slider: UISlider) {
        let moveSize = Int(slider.value) - self.scrollView.currentPageIndex
        if self.scrollView.moveTo(Int(slider.value)) != 0 {
            self.scrollView.isPageRelocation = false
            let originalOffsetX = self.scrollView.contentOffset.x
            if moveSize < 0 {
                self.scrollView.contentOffset.x += self.scrollView.pageSize.width / 2
            } else {
                self.scrollView.contentOffset.x -= self.scrollView.pageSize.width / 2
            }
            self.scrollView.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2, animations: { [unowned self] in
                self.scrollView.contentOffset.x = originalOffsetX
            }, completion: { [unowned self] (finished) -> Void in
                self.scrollView.isPageRelocation = true
                self.scrollView.isUserInteractionEnabled = true
            })
        }
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
    func numberOfPagesInUnlimitedScrollView(_ unlimitedScrollView: UnlimitedScrollView) -> Int {
        return pages.count
    }

    func numberOfVisiblePagesInUnlimitedScrollView(_ unlimitedScrollView: UnlimitedScrollView) -> Int {
        return 3
    }

    func unlimitedScrollView(_ unlimitedScrollView: UnlimitedScrollView, pageForItemAtIndex index: Int) -> UnlimitedScrollViewPage {
        let page = unlimitedScrollView.dequeueReusablePage()
        let textView = TextScrollView(frame: CGRect(origin: CGPoint.zero, size: unlimitedScrollView.pageSize))
        textView.textLabel?.text = "\(index)"
        page?.customView = textView
        return page!
    }
}

extension ViewController: UnlimitedScrollViewDelegate {
    func unlimitedScrollViewArrivePage(_ unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage) {
        print("arrive page \(page.index)")
        self.pageSlider?.value = Float(page.index)
    }

    func unlimitedScrollViewLeavePage(_ unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage) {
        if let view = page.customView as? TextScrollView {
            view.zoomScale = 1
        }
        print("leave page \(page.index)")
    }

    func unlimitedScrollViewRemovePage(_ unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage) {
        print("remove page \(page.index)")
    }

    func unlimitedScrollViewAddPage(_ unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage) {
        print("add page \(page.index)")
    }
}
