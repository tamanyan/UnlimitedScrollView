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
        self.textLabel = UILabel(frame: frame.insetBy(dx: 20, dy: 100))
        self.textLabel?.textColor = UIColor.black
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        self.textLabel?.textAlignment = .center
        self.textLabel?.layer.borderColor = UIColor.black.cgColor
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

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.parantView
    }
}
