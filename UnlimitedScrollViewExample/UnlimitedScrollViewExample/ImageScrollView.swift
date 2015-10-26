//
//  TextScrollView.swift
//  UnlimitedScrollViewExample
//
//  Created by tamanyan on 2015/10/26.
//  Copyright © 2015年 tamanyan. All rights reserved.
//

import UIKit

class TextScrollView: UIScrollView, UIScrollViewDelegate {
    var textLabel: UILabel?
    var parantView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.parantView = UIView(frame: frame)
        self.textLabel = UILabel(frame: CGRectInset(frame, 20, 40))
        self.textLabel?.textColor = UIColor.blackColor()
        self.textLabel?.font = UIFont.boldSystemFontOfSize(30)
        self.textLabel?.textAlignment = .Center
        self.textLabel?.layer.borderColor = UIColor.blackColor().CGColor
        self.textLabel?.layer.borderWidth = 2.0
        self.addSubview(self.parantView!)
        self.parantView?.addSubview(self.textLabel!)
        self.clipsToBounds = false
        self.minimumZoomScale = 1
        self.maximumZoomScale = 4.0
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.contentSize = self.frame.size
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.parantView
    }
}
