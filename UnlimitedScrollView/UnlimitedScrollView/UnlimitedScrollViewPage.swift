//
//  UnlimitedScrollViewPage.swift
//  UnlimitedScrollView
//
//  Created by svpcadmin on 2015/10/23.
//  Copyright © 2015年 tamanyan. All rights reserved.
//

public class UnlimitedScrollViewPage: UIView {
    public var customView: UIView?
    public var textLabel: UILabel?

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupTextLabel() {
        self.textLabel = UILabel(frame: self.bounds)
        self.addSubview(self.textLabel!)
    }

    func prepareForReuse() {
        self.customView = nil
    }
}
