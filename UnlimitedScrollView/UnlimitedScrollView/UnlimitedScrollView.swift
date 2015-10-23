//
//  UnlimitedScrollView.swift
//  UnlimitedScrollView
//
//  Created by svpcadmin on 2015/10/23.
//  Copyright © 2015年 tamanyan. All rights reserved.
//

public protocol UnlimitedScrollViewDataSource {
    func numberOfPagesInUnlimitedScrollView(unlimitedScrollView: UnlimitedScrollView) -> Int
    func numberOfVisiblePagesInUnlimitedScrollView(unlimitedScrollView: UnlimitedScrollView) -> Int
    func unlimitedScrollView(unlimitedScrollView: UnlimitedScrollView, pageForItemAtIndex index: Int) -> UnlimitedScrollViewPage
}

public protocol UnlimitedScrollViewDelegate {
}

public class UnlimitedScrollView: UIScrollView {
    /**
    This protocol allows the adopting delegate to respond to scrolling operations.
    */
    public var unlimitedScrollViewDelegate: UnlimitedScrollViewDelegate?
    /**
    This protocol represents the data model object.
    */
    public var unlimitedScrollViewDataSource: UnlimitedScrollViewDataSource?
    public var currentPageIndex: Int = 0
    public var firstPageIndex: Int = 0
    private var reusablePages = [UnlimitedScrollViewPage]()
    private var visiblePages = [UnlimitedScrollViewPage]()

    /**
    number of page
    */
    public var numberOfPages: Int {
        guard let number = self.unlimitedScrollViewDataSource?.numberOfPagesInUnlimitedScrollView(self) else {
            return 0
        }
        return number
    }

    /**
    number of valid page
    */
    public var numberOfVisiblePages: Int {
        guard let number = self.unlimitedScrollViewDataSource?.numberOfVisiblePagesInUnlimitedScrollView(self) else {
            return 0
        }
        return number
    }

    /**
    unit page size
    */
    public var pageSize: CGSize {
        return self.frame.size
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
    }

    /**
    Reload all pages data source
    */
    public func reloadData() {
        self.updateData()
    }

    /**
    Gets a reusable page.

    - returns: A reusable UnlimitedScrollViewPage
    */
    public func dequeueReusablePage() -> UnlimitedScrollViewPage? {
        guard let page = reusablePages.last else {
            return UnlimitedScrollViewPage(frame: CGRect(origin: CGPoint.zero, size: self.pageSize))
        }
        reusablePages.removeLast()
        page.prepareForReuse()
        return page
    }

    private func setUp() {
        self.backgroundColor = UIColor.clearColor()
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.userInteractionEnabled = true
    }

    private func updateData() {
        for i in self.visiblePages {
            self.reusablePages.append(i)
            i.removeFromSuperview()
        }
        self.visiblePages.removeAll()
        self.updateContentSize()
        self.updateLayout()
    }

    private func updateContentSize() {
        self.contentSize = CGSizeMake(CGFloat(self.numberOfVisiblePages) * pageSize.width, pageSize.height)
    }

    private func updateLayout() {
        for i in (firstPageIndex..<self.numberOfVisiblePages) {
            if let page = self.pageAtIndex(i) {
                self.placePage(page, index: i)
            }
        }
    }

    private func placePage(page: UnlimitedScrollViewPage, index: Int) {
        page.frame = CGRect(origin: CGPoint(x: CGFloat(index) * self.pageSize.width, y: 0), size: self.pageSize)
        self.addSubview(page)
    }

    private func pageAtIndex(index: Int) -> UnlimitedScrollViewPage? {
        return self.unlimitedScrollViewDataSource?.unlimitedScrollView(self, pageForItemAtIndex: index)
    }
}

extension UnlimitedScrollView: UIScrollViewDelegate {
}