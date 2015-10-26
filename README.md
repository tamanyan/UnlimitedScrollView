# UnlimitedScrollView
UnlimitedScrollView provides an endlessly UIScrollView

![Demo](https://github.com/tamanyan/UnlimitedScrollView/raw/master/images/demo.gif)


# Usage

initialize a UnlimitedScrollView new instance.

```swift
let scrollView = UnlimitedScrollView(frame: UIScreen.mainScreen().applicationFrame)
scrollView.unlimitedScrollViewDataSource = self
scrollView.unlimitedScrollViewDelegate = self
scrollView.firstVisiblePageIndex = 0
self.view.addSubview(self.scrollView)
scrollView.reloadData()
```

Finally, implement the UnlimitedScrollViewDataSource and UnlimitedScrollViewDelegate protocols methods.

```swift
extension ViewController: UnlimitedScrollViewDataSource {
    func numberOfPagesInUnlimitedScrollView(unlimitedScrollView: UnlimitedScrollView) -> Int {
        return 10
    }

    func numberOfVisiblePagesInUnlimitedScrollView(unlimitedScrollView: UnlimitedScrollView) -> Int {
        return 3
    }

    func unlimitedScrollView(unlimitedScrollView: UnlimitedScrollView, pageForItemAtIndex index: Int) -> UnlimitedScrollViewPage {
        let page = unlimitedScrollView.dequeueReusablePage()
        let textLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: unlimitedScrollView.pageSize))
        textLabel.text = "\(index)"
        textLabel.textColor = UIColor.blackColor()
        textLabel.font = UIFont.boldSystemFontOfSize(30)
        textLabel.textAlignment = .Center
        page?.customView = textView
        return page!
    }
}
```

```swift
extension ViewController: UnlimitedScrollViewDelegate {
    func unlimitedScrollViewArrivePage(unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage) {
        print("arrive page \(page.index)")
    }

    func unlimitedScrollViewLeavePage(unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage) {
        print("leave page \(page.index)")
    }

    func unlimitedScrollViewRemovePage(unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage) {
        print("remove page \(page.index)")
    }

    func unlimitedScrollViewAddPage(unlimitedScrollView: UnlimitedScrollView, page: UnlimitedScrollViewPage) {
        print("add page \(page.index)")
    }
}
```
