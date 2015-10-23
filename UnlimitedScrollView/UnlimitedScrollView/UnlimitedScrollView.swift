//
//  UnlimitedScrollView.swift
//  UnlimitedScrollView
//
//  Created by svpcadmin on 2015/10/23.
//  Copyright © 2015年 tamanyan. All rights reserved.
//

public protocol UnlimitedScrollViewDataSource {
}

public protocol UnlimitedScrollViewDelegate {
}

public class UnlimitedScrollView: UIScrollView {
    public var unlimitedScrollViewDelegate: UnlimitedScrollViewDelegate?
    public var unlimitedScrollViewDataSource: UnlimitedScrollViewDelegate?

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setUp() {
        self.backgroundColor = UIColor.clearColor()
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.userInteractionEnabled = true
    }
}