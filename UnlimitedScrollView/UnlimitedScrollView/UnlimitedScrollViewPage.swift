//
//  UnlimitedScrollViewPage.swift
//  UnlimitedScrollView
//
//  Created by tamanyan on 2015/10/23.
//  Copyright © 2015年 tamanyan. All rights reserved.
//

open class UnlimitedScrollViewPage: UIView {
    open var customView: UIView?
    open var index: Int = 0

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func prepareForReuse() {
        self.customView?.removeFromSuperview()
        self.customView = nil
    }
}
