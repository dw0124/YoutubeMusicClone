import UIKit
import SnapKit

class MusicPlayerPageViewController: UIViewController {

    // MARK: - Properties
    
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var selectedTabIndex: Int = 0 // Selected index of the tab bar
    let underLineView = UIView()
    
    // PageController
    let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let viewControllers: [UIViewController] = [
        {
            let viewController = MusicListViewController()
            return viewController
        }(),
        SavedViewController(), SavedViewController()
    ]
    
    
    let cellTitles = ["다음 트랙", "가사", "관련 항목"]
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupPageController()
        
        let scrollView = pageController.view.subviews
            .compactMap { $0 as? UIScrollView }
            .first

        scrollView?.delegate = self
        
    }
    
    
    // MARK: - Layout
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TabBarCollectionViewCell.self, forCellWithReuseIdentifier: TabBarCollectionViewCell.reuseIdentifier)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: view.frame.width / 3, height: 30)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(83)
        }
        
        underLineView.backgroundColor = .white
        view.addSubview(underLineView)
        
        underLineView.snp.makeConstraints { make in
            make.height.equalTo(3)
            make.width.equalTo(view.frame.width / 3.0)
            make.leading.equalTo(collectionView.snp.leading)
            make.bottom.equalTo(collectionView.snp.bottom)
        }
    }
    
    func setupPageController() {
        
        pageController.delegate = self
        pageController.dataSource = self
        addChild(pageController)
        view.addSubview(pageController.view)
        
        pageController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom)
        }
        pageController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
        
        // Find the scrollView inside the UIPageViewController's view hierarchy
        if let scrollView = findScrollViewInView(view: pageController.view) {
            scrollView.bounces = false
        }
    }

    // Helper function to find the scrollView in the view hierarchy
    private func findScrollViewInView(view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }

        for subview in view.subviews {
            if let scrollView = findScrollViewInView(view: subview) {
                return scrollView
            }
        }

        return nil
    }
}

// MARK: - UICollectionViewDataSource

extension MusicPlayerPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabBarCollectionViewCell.reuseIdentifier, for: indexPath) as! TabBarCollectionViewCell
        
        let title = cellTitles[indexPath.item]
        cell.setTitle(title: title)
        
        if indexPath.item == 0 {
            cell.isSelected = true
            cell.titleLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
        } else {
            cell.titleLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MusicPlayerPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTabIndex = indexPath.item // Selected index of the tab bar
        
        // Reset all cell colors
        collectionView.visibleCells.forEach { cell in
            if let tabBarCell = cell as? TabBarCollectionViewCell {
                tabBarCell.titleLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
            }
        }

        // Set the selected cell's text color to pure white
        if let selectedItem = collectionView.cellForItem(at: indexPath) as? TabBarCollectionViewCell {
            selectedItem.titleLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
            updateUnderLineViewLayout(selectedItem: selectedItem)
        }
        pageController.setViewControllers([viewControllers[selectedTabIndex]], direction: .reverse, animated: true, completion: nil)
    }
    
    func updateUnderLineViewLayout(selectedItem: UICollectionViewCell) {
        UIView.animate(withDuration: 0.2) {
            self.underLineView.snp.remakeConstraints { make in
                make.height.equalTo(3)
                make.width.equalTo(self.view.frame.width / 3.0)
                make.leading.equalTo(selectedItem.snp.leading)
                make.bottom.equalTo(self.collectionView.snp.bottom)
            }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate

extension MusicPlayerPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        //return viewControllers[index - 1]
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index < viewControllers.count - 1 else {
            return nil
        }
        //return viewControllers[index + 1]
        return nil
    }

}
