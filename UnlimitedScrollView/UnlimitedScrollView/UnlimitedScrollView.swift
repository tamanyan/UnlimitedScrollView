//
//  UnlimitedScrollView.swift
//  UnlimitedScrollView
//
//  Created by tamanyan on 2015/10/23.
//  Copyright © 2015年 tamanyan. All rights reserved.
//

private final class UnlimitedPageIndex {
    var numberOfPages: Int = 0
    var cursor: Int = 0

    private var firstPageIndex: Int {
        return 0
    }

    private var lastPageIndex: Int {
        return max(self.firstPageIndex, self.numberOfPages - 1)
    }

    init(cursor: Int, numberOfPages: Int) {
        self.cursor = cursor
        self.numberOfPages = numberOfPages
    }

    func next() -> UnlimitedPageIndex {
        self.cursor = self.nextIndex(self.cursor)
        return self
    }

    func prev() -> UnlimitedPageIndex {
        self.cursor = self.prevIndex(self.cursor)
        return self
    }

    private func nextIndex(index: Int) -> Int {
        return index == self.lastPageIndex ? self.firstPageIndex : index + 1
    }

    private func prevIndex(index: Int) -> Int {
        return index == self.firstPageIndex ? self.lastPageIndex : index - 1
    }
}

public protocol UnlimitedScrollViewDataSource {
    /**
    Return number of pages.

    - parameter unlimitedScrollView: unlimitedScrollView view object

    - returns: number of pages
    */
    func numberOfPagesInUnlimitedScrollView(unlimitedScrollView: UnlimitedScrollView) -> Int
    /**
    Return number of visible pages. This return value only accepts odd.

    - parameter unlimitedScrollView: unlimitedScrollView view object

    - returns: number of visible pages
    */
    func numberOfVisiblePagesInUnlimitedScrollView(unlimitedScrollView: UnlimitedScrollView) -> Int
    /**
    Called when need to create page.

    - parameter unlimitedScrollView: unlimitedScrollView view object
    - parameter index:               page index

    - returns: UnlimitedScrollViewPage view object
    */
    func unlimitedScrollView(unlimitedScrollView: UnlimitedScrollView, pageForItemAtIndex index: Int) -> UnlimitedScrollViewPage
}

@objc public protocol UnlimitedScrollViewDelegate {
    /**
    Called when arrived to page.

    - parameter unlimitedScrollView: unlimitedScrollView view object
    - parameter page:                arrived page
    */
    optional func unlimitedScrollViewArrivePage(unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage)
    /**
    Called when leaved to page.

    - parameter unlimitedScrollView: unlimitedScrollView view object
    - parameter page:                leaved page
    */
    optional func unlimitedScrollViewLeavePage(unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage)
    /**
    Called when removed to page.

    - parameter unlimitedScrollView: unlimitedScrollView view object
    - parameter page:                removed page
    */
    optional func unlimitedScrollViewRemovePage(unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage)
    /**
    Called when added to page.

    - parameter unlimitedScrollView: unlimitedScrollView view object
    - parameter page:                added page
    */
    optional func unlimitedScrollViewAddPage(unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage)
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
    /**
    current page index
    */
    public var currentPageIndex: Int {
        return currentUnlimitedPageIndex.cursor
    }
    /**
    first visible page index
    */
    public var firstVisiblePageIndex: Int = 0
    /**
    if this value is true, page relocation event will happen.
    */
    public var isPageRelocation = true
    private var currentUnlimitedPageIndex = UnlimitedPageIndex(cursor: 0, numberOfPages: 1)
    private var reusablePages = [UnlimitedScrollViewPage]()
    private var visiblePages = [UnlimitedScrollViewPage]()
    private var scrollViewPanGestureRecognizer: UIPanGestureRecognizer?

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

    private var centerContentOffsetX: CGFloat {
        return CGFloat(self.numberOfVisiblePages / 2) * self.pageSize.width
    }

    private var nextPageThresholdX: CGFloat {
        return (self.contentSize.width / 2) + self.pageSize.width * 1.5
    }

    private var prevPageThresholdX: CGFloat {
        return (self.contentSize.width / 2) - self.pageSize.width * 1.5
    }

    private var currentVisiblePageIndex: Int {
        return self.numberOfVisiblePages / 2
    }

    private var currentVisiblePage: UnlimitedScrollViewPage? {
        return self.visiblePages.count > currentVisiblePageIndex
            ? self.visiblePages[currentVisiblePageIndex] : nil
    }

    private var lastVisiblePage: UnlimitedScrollViewPage? {
        return self.visiblePages.last
    }

    private var firstVisiblePage: UnlimitedScrollViewPage? {
        return self.visiblePages.first
    }

    private var firstPageIndex: Int {
        return currentUnlimitedPageIndex.firstPageIndex
    }

    private var lastPageIndex: Int {
        return currentUnlimitedPageIndex.lastPageIndex
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
        if isPageRelocation {
            let visibleBounds = self.bounds
            let minimumVisibleX = CGRectGetMinX(visibleBounds)
            let maximumVisibleX = CGRectGetMaxX(visibleBounds)
            if self.nextPageThresholdX <= maximumVisibleX {
                self.emitLeavePageEvent()
                self.moveNextPage()
                self.emitArrivePageEvent()
            }
            if self.prevPageThresholdX >= minimumVisibleX {
                self.emitLeavePageEvent()
                self.movePrevPage()
                self.emitArrivePageEvent()
            }
            self.layoutIfNeeded()
        }
    }

    /**
    Reload all pages data source.
    */
    public func reloadData() {
        assert(self.firstVisiblePageIndex < self.numberOfPages, "firstVisiblePageIndex is less than numberOfPages")
        assert(self.numberOfVisiblePages % 2 == 1, "numberOfVisiblePages only accepts odd.")
        self.updateData()
        self.emitArrivePageEvent()
    }

    /**
    Get a reusable page.

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

    /**
    Move page.

    - parameter pageIndex: page index

    - returns: eturn moving size
    */
    public func moveTo(pageIndex: Int) -> Int {
        let currentPageIndex = self.currentPageIndex
        if currentPageIndex == pageIndex {
            return 0
        }

        self.emitLeavePageEvent()
        if let targetVisibleIndex = self.visiblePages.indexOf({ $0.index == pageIndex }),
            currentVisibleIndex = self.visiblePages.indexOf({ $0.index == currentPageIndex }) {
            let moveSize = targetVisibleIndex - currentVisibleIndex
            if moveSize > 0 {
                for _ in 0..<moveSize {
                    self.moveNextPage()
                }
            } else if moveSize < 0 {
                for _ in 0..<abs(moveSize) {
                    self.movePrevPage()
                }
            }
            self.emitArrivePageEvent()
            return moveSize
        } else {
            let moveSize = pageIndex - currentPageIndex
            self.firstVisiblePageIndex = pageIndex
            self.updateData()
            self.emitArrivePageEvent()
            return moveSize
        }
    }

    private func setUp() {
        self.backgroundColor = UIColor.clearColor()
        self.bounces = false
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.userInteractionEnabled = true
    }

    private func moveNextPage() {
        self.removeFirstVisiblePage()
        self.addLastVisiblePage()
        self.relocateVisiblePage()
        self.setCenterContentOffset()
        self.currentUnlimitedPageIndex.next()
    }

    private func movePrevPage() {
        self.removeLastVisiblePage()
        self.addFirstVisiblePage()
        self.relocateVisiblePage()
        self.setCenterContentOffset()
        self.currentUnlimitedPageIndex.prev()
    }

    private func emitArrivePageEvent() {
        if let page = self.currentVisiblePage, arrivePageMethod = self.unlimitedScrollViewDelegate?.unlimitedScrollViewArrivePage {
            arrivePageMethod(self, page: page)
        }
    }

    private func emitLeavePageEvent() {
        if let page = self.currentVisiblePage, leavePageMethod = self.unlimitedScrollViewDelegate?.unlimitedScrollViewLeavePage {
            leavePageMethod(self, page: page)
        }
    }

    private func emitAddPageEvent(page: UnlimitedScrollViewPage) {
        if let addPageMethod = self.unlimitedScrollViewDelegate?.unlimitedScrollViewAddPage {
            addPageMethod(self, page: page)
        }
    }

    private func emitRemovePageEvent(page: UnlimitedScrollViewPage) {
        if let removePageMethod = self.unlimitedScrollViewDelegate?.unlimitedScrollViewRemovePage {
            removePageMethod(self, page: page)
        }
    }

    private func updateData() {
        for i in self.visiblePages {
            self.emitRemovePageEvent(i)
            self.reusablePages.append(i)
            i.removeFromSuperview()
        }
        self.currentUnlimitedPageIndex = self.createInitialPageIndex()
        self.visiblePages.removeAll()
        self.updateContentSize()
        self.updateLayout()
    }

    private func updateContentSize() {
        self.contentSize = CGSizeMake(CGFloat(self.numberOfVisiblePages) * pageSize.width, pageSize.height)
    }

    private func setCenterContentOffset() {
        self.contentOffset = CGPoint(x: self.centerContentOffsetX, y: self.contentOffset.y)
        self.setContentOffset(CGPoint(x: self.centerContentOffsetX, y: self.contentOffset.y), animated: false)
    }

    private func updateLayout() {
        self.setCenterContentOffset()
        var indexList = [Int]()
        let pageIndex = self.createCurrentPageIndex()
        for _ in 0..<(self.numberOfVisiblePages / 2 + 1) {
            pageIndex.prev()
        }
        for _ in 0..<self.numberOfVisiblePages {
            indexList.append(pageIndex.next().cursor)
        }
        var i = 0
        for index in indexList {
            if let page = self.pageAtIndex(index) {
                page.frame = CGRect(
                    origin: CGPoint(x: CGFloat(i++) * self.pageSize.width, y: 0),
                    size: self.pageSize)
                self.addSubview(page)
                page.index = index
                self.visiblePages.append(page)
                self.emitAddPageEvent(page)
            }
        }
    }

    private func relocateVisiblePage() {
        for i in 0..<self.visiblePages.count {
            let page = self.visiblePages[i]
            page.frame.origin = CGPoint(x: CGFloat(i) * self.pageSize.width, y: 0)
        }
    }

    private func addFirstVisiblePage() {
        guard let firstPage = self.firstVisiblePage else {
            return
        }
        let pageIndex = createPageIndex(firstPage.index).prev()
        if let page = self.pageAtIndex(pageIndex.cursor) {
            page.index = pageIndex.cursor
            self.visiblePages.insert(page, atIndex: 0)
            self.addSubview(page)
            self.emitAddPageEvent(page)
        }
    }

    private func addLastVisiblePage() {
        guard let lastPage = self.lastVisiblePage else {
            return
        }
        let pageIndex = createPageIndex(lastPage.index).next()
        if let page = self.pageAtIndex(pageIndex.cursor) {
            page.index = pageIndex.cursor
            self.visiblePages.append(page)
            self.addSubview(page)
            self.emitAddPageEvent(page)
        }
    }

    private func removeFirstVisiblePage() {
        if let firstPage = self.firstVisiblePage {
            firstPage.removeFromSuperview()
            self.reusablePages.append(firstPage)
            self.visiblePages.removeFirst()
            self.emitRemovePageEvent(firstPage)
        }
    }

    private func removeLastVisiblePage() {
        if let lastPage = self.lastVisiblePage {
            lastPage.removeFromSuperview()
            self.reusablePages.append(lastPage)
            self.visiblePages.removeLast()
            self.emitRemovePageEvent(lastPage)
        }
    }

    private func pageAtIndex(index: Int) -> UnlimitedScrollViewPage? {
        guard let page = self.unlimitedScrollViewDataSource?.unlimitedScrollView(self, pageForItemAtIndex: index) else {
            return nil
        }
        if let view = page.customView {
            page.addSubview(view)
        }
        return page
    }

    private func createPageIndex(index: Int) -> UnlimitedPageIndex {
        return UnlimitedPageIndex(cursor: index, numberOfPages: self.numberOfPages)
    }

    private func createCurrentPageIndex() -> UnlimitedPageIndex {
        return UnlimitedPageIndex(cursor: self.currentPageIndex, numberOfPages: self.numberOfPages)
    }

    private func createInitialPageIndex() -> UnlimitedPageIndex {
        return UnlimitedPageIndex(cursor: self.firstVisiblePageIndex, numberOfPages: self.numberOfPages)
    }
}
