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

    fileprivate var firstPageIndex: Int {
        return 0
    }

    fileprivate var lastPageIndex: Int {
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

    fileprivate func nextIndex(_ index: Int) -> Int {
        return index == self.lastPageIndex ? self.firstPageIndex : index + 1
    }

    fileprivate func prevIndex(_ index: Int) -> Int {
        return index == self.firstPageIndex ? self.lastPageIndex : index - 1
    }
}

public protocol UnlimitedScrollViewDataSource {
    /**
    Return number of pages.

    - parameter unlimitedScrollView: unlimitedScrollView view object

    - returns: number of pages
    */
    func numberOfPagesInUnlimitedScrollView(_ unlimitedScrollView: UnlimitedScrollView) -> Int
    /**
    Return number of visible pages. This return value only accepts odd.

    - parameter unlimitedScrollView: unlimitedScrollView view object

    - returns: number of visible pages
    */
    func numberOfVisiblePagesInUnlimitedScrollView(_ unlimitedScrollView: UnlimitedScrollView) -> Int
    /**
    Called when need to create page.

    - parameter unlimitedScrollView: unlimitedScrollView view object
    - parameter index:               page index

    - returns: UnlimitedScrollViewPage view object
    */
    func unlimitedScrollView(_ unlimitedScrollView: UnlimitedScrollView, pageForItemAtIndex index: Int) -> UnlimitedScrollViewPage
}

@objc public protocol UnlimitedScrollViewDelegate {
    /**
    Called when arrived to page.

    - parameter unlimitedScrollView: unlimitedScrollView view object
    - parameter page:                arrived page
    */
    @objc optional func unlimitedScrollViewArrivePage(_ unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage)
    /**
    Called when leaved to page.

    - parameter unlimitedScrollView: unlimitedScrollView view object
    - parameter page:                leaved page
    */
    @objc optional func unlimitedScrollViewLeavePage(_ unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage)
    /**
    Called when removed to page.

    - parameter unlimitedScrollView: unlimitedScrollView view object
    - parameter page:                removed page
    */
    @objc optional func unlimitedScrollViewRemovePage(_ unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage)
    /**
    Called when added to page.

    - parameter unlimitedScrollView: unlimitedScrollView view object
    - parameter page:                added page
    */
    @objc optional func unlimitedScrollViewAddPage(_ unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage)
}

open class UnlimitedScrollView: UIScrollView {
    /**
    This protocol allows the adopting delegate to respond to scrolling operations.
    */
    open var unlimitedScrollViewDelegate: UnlimitedScrollViewDelegate?
    /**
    This protocol represents the data model object.
    */
    open var unlimitedScrollViewDataSource: UnlimitedScrollViewDataSource?
    /**
    current page index
    */
    open var currentPageIndex: Int {
        return currentUnlimitedPageIndex.cursor
    }
    /**
    first visible page index
    */
    open var firstVisiblePageIndex: Int = 0
    /**
    if this value is true, page relocation event will happen.
    */
    open var isPageRelocation = true
    fileprivate var currentUnlimitedPageIndex = UnlimitedPageIndex(cursor: 0, numberOfPages: 1)
    fileprivate var reusablePages = [UnlimitedScrollViewPage]()
    fileprivate var visiblePages = [UnlimitedScrollViewPage]()
    fileprivate var scrollViewPanGestureRecognizer: UIPanGestureRecognizer?

    /**
    number of page
    */
    open var numberOfPages: Int {
        guard let number = self.unlimitedScrollViewDataSource?.numberOfPagesInUnlimitedScrollView(self) else {
            return 0
        }
        return number
    }

    /**
    number of valid page
    */
    open var numberOfVisiblePages: Int {
        guard let number = self.unlimitedScrollViewDataSource?.numberOfVisiblePagesInUnlimitedScrollView(self) else {
            return 0
        }
        return number
    }

    /**
    unit page size
    */
    open var pageSize: CGSize {
        return self.frame.size
    }

    /**
    Get current visible page.
    */
    open var currentVisiblePage: UnlimitedScrollViewPage? {
        return self.visiblePages.count > currentVisiblePageIndex
            ? self.visiblePages[currentVisiblePageIndex] : nil
    }

    /**
    Get all visible pages.
    */
    open var allVisiblePage: [UnlimitedScrollViewPage] {
        return self.visiblePages
    }

    fileprivate var centerContentOffsetX: CGFloat {
        return CGFloat(self.numberOfVisiblePages / 2) * self.pageSize.width
    }

    fileprivate var nextPageThresholdX: CGFloat {
        return (self.contentSize.width / 2) + self.pageSize.width * 1.5
    }

    fileprivate var prevPageThresholdX: CGFloat {
        return (self.contentSize.width / 2) - self.pageSize.width * 1.5
    }

    fileprivate var currentVisiblePageIndex: Int {
        return self.numberOfVisiblePages / 2
    }

    fileprivate var lastVisiblePage: UnlimitedScrollViewPage? {
        return self.visiblePages.last
    }

    fileprivate var firstVisiblePage: UnlimitedScrollViewPage? {
        return self.visiblePages.first
    }

    fileprivate var firstPageIndex: Int {
        return currentUnlimitedPageIndex.firstPageIndex
    }

    fileprivate var lastPageIndex: Int {
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

    override open func layoutSubviews() {
        super.layoutSubviews()
        if isPageRelocation {
            let visibleBounds = self.bounds
            let minimumVisibleX = visibleBounds.minX
            let maximumVisibleX = visibleBounds.maxX
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
    open func reloadData() {
        assert(self.firstVisiblePageIndex < self.numberOfPages, "firstVisiblePageIndex is less than numberOfPages")
        assert(self.numberOfVisiblePages % 2 == 1, "numberOfVisiblePages only accepts odd.")
        self.updateData()
        self.emitArrivePageEvent()
    }

    /**
    Get a reusable page.

    - returns: A reusable UnlimitedScrollViewPage
    */
    open func dequeueReusablePage() -> UnlimitedScrollViewPage? {
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
    open func moveTo(_ pageIndex: Int) -> Int {
        let currentPageIndex = self.currentPageIndex
        if currentPageIndex == pageIndex {
            return 0
        }

        self.emitLeavePageEvent()
        if let targetVisibleIndex = self.visiblePages.index(where: { $0.index == pageIndex }),
            let currentVisibleIndex = self.visiblePages.index(where: { $0.index == currentPageIndex }) {
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

    fileprivate func setUp() {
        self.backgroundColor = UIColor.clear
        self.bounces = false
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.isUserInteractionEnabled = true
    }

    fileprivate func moveNextPage() {
        self.removeFirstVisiblePage()
        self.addLastVisiblePage()
        self.relocateVisiblePage()
        self.setCenterContentOffset()
        _ = self.currentUnlimitedPageIndex.next()
    }

    fileprivate func movePrevPage() {
        self.removeLastVisiblePage()
        self.addFirstVisiblePage()
        self.relocateVisiblePage()
        self.setCenterContentOffset()
        _ = self.currentUnlimitedPageIndex.prev()
    }

    fileprivate func emitArrivePageEvent() {
        if let page = self.currentVisiblePage, let arrivePageMethod = self.unlimitedScrollViewDelegate?.unlimitedScrollViewArrivePage {
            arrivePageMethod(self, page)
        }
    }

    fileprivate func emitLeavePageEvent() {
        if let page = self.currentVisiblePage, let leavePageMethod = self.unlimitedScrollViewDelegate?.unlimitedScrollViewLeavePage {
            leavePageMethod(self, page)
        }
    }

    fileprivate func emitAddPageEvent(_ page: UnlimitedScrollViewPage) {
        if let addPageMethod = self.unlimitedScrollViewDelegate?.unlimitedScrollViewAddPage {
            addPageMethod(self, page)
        }
    }

    fileprivate func emitRemovePageEvent(_ page: UnlimitedScrollViewPage) {
        if let removePageMethod = self.unlimitedScrollViewDelegate?.unlimitedScrollViewRemovePage {
            removePageMethod(self, page)
        }
    }

    fileprivate func updateData() {
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

    fileprivate func updateContentSize() {
        self.contentSize = CGSize(width: CGFloat(self.numberOfVisiblePages) * pageSize.width, height: pageSize.height)
    }

    fileprivate func setCenterContentOffset() {
        self.contentOffset = CGPoint(x: self.centerContentOffsetX, y: self.contentOffset.y)
        self.setContentOffset(CGPoint(x: self.centerContentOffsetX, y: self.contentOffset.y), animated: false)
    }

    fileprivate func updateLayout() {
        self.setCenterContentOffset()
        var indexList = [Int]()
        let pageIndex = self.createCurrentPageIndex()
        for _ in 0..<(self.numberOfVisiblePages / 2 + 1) {
            _ = pageIndex.prev()
        }
        for _ in 0..<self.numberOfVisiblePages {
            indexList.append(pageIndex.next().cursor)
        }
        var i = 0
        for index in indexList {
            if let page = self.pageAtIndex(index) {
                page.frame = CGRect(
                    origin: CGPoint(x: CGFloat(i) * self.pageSize.width, y: 0),
                    size: self.pageSize)
                i += 1
                self.addSubview(page)
                page.index = index
                self.visiblePages.append(page)
                self.emitAddPageEvent(page)
            }
        }
    }

    fileprivate func relocateVisiblePage() {
        for i in 0..<self.visiblePages.count {
            let page = self.visiblePages[i]
            page.frame.origin = CGPoint(x: CGFloat(i) * self.pageSize.width, y: 0)
        }
    }

    fileprivate func addFirstVisiblePage() {
        guard let firstPage = self.firstVisiblePage else {
            return
        }
        let pageIndex = createPageIndex(firstPage.index).prev()
        if let page = self.pageAtIndex(pageIndex.cursor) {
            page.index = pageIndex.cursor
            self.visiblePages.insert(page, at: 0)
            self.addSubview(page)
            self.emitAddPageEvent(page)
        }
    }

    fileprivate func addLastVisiblePage() {
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

    fileprivate func removeFirstVisiblePage() {
        if let firstPage = self.firstVisiblePage {
            firstPage.removeFromSuperview()
            self.reusablePages.append(firstPage)
            self.visiblePages.removeFirst()
            self.emitRemovePageEvent(firstPage)
        }
    }

    fileprivate func removeLastVisiblePage() {
        if let lastPage = self.lastVisiblePage {
            lastPage.removeFromSuperview()
            self.reusablePages.append(lastPage)
            self.visiblePages.removeLast()
            self.emitRemovePageEvent(lastPage)
        }
    }

    fileprivate func pageAtIndex(_ index: Int) -> UnlimitedScrollViewPage? {
        guard let page = self.unlimitedScrollViewDataSource?.unlimitedScrollView(self, pageForItemAtIndex: index) else {
            return nil
        }
        if let view = page.customView {
            page.addSubview(view)
        }
        return page
    }

    fileprivate func createPageIndex(_ index: Int) -> UnlimitedPageIndex {
        return UnlimitedPageIndex(cursor: index, numberOfPages: self.numberOfPages)
    }

    fileprivate func createCurrentPageIndex() -> UnlimitedPageIndex {
        return UnlimitedPageIndex(cursor: self.currentPageIndex, numberOfPages: self.numberOfPages)
    }

    fileprivate func createInitialPageIndex() -> UnlimitedPageIndex {
        return UnlimitedPageIndex(cursor: self.firstVisiblePageIndex, numberOfPages: self.numberOfPages)
    }
}
