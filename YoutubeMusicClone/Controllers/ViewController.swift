//
//  ViewController.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/06/16.
//

import UIKit
import SnapKit
import SwiftUI
import FloatingPanel

class ViewController: UIViewController {
    
    let playerfpc = FloatingPanelController()
    var fpcCheck = false
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: getLayout())
        collectionView.register(SongsCollectionViewCell.self, forCellWithReuseIdentifier:  SongsCollectionViewCell.identifier)
        collectionView.register(MyMusicStationCell.self, forCellWithReuseIdentifier: MyMusicStationCell.identifier)
        collectionView.register(MyHeaderFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MyHeaderView")
        collectionView.register(MyHeaderFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "MyFooterView")
        
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false

        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        //DataManager.shared.deleteAll()
        
        let musicList = DataManager.shared.fetchMusicList()
        
        print(musicList.count)
        for musicEntity in musicList {
            if let trackName = musicEntity.trackName,
               let artistName = musicEntity.artistName,
               let previewUrl = musicEntity.previewUrl,
               let artworkUrl30 = musicEntity.artworkUrl30,
               let artworkUrl60 = musicEntity.artworkUrl60,
               let artworkUrl100 = musicEntity.artworkUrl100 {
//                MusicPlayerSingleton.shared.music.value?.results.append(
                   let result = Result(
                        trackId: Int(musicEntity.trackId),
                        trackName: trackName,
                        artistName: artistName,
                        previewUrl: previewUrl,
                        artworkUrl30: artworkUrl30,
                        artworkUrl60: artworkUrl60,
                        artworkUrl100: artworkUrl100
                    )
                MusicPlayerSingleton.shared.music.value?.results.append(result)
            }
        }
        
        if musicList.count > 0 {
            openFloatingPanelWithCoreData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MusicPlayerSingleton.shared.music.bind { music in
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        collectionView.backgroundColor = .black
        
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(view.layoutMarginsGuide)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Songs.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return Songs.list[section].count
        case 1: return Songs.list[section].count
        case 2: return Songs.list[section].count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {
        case 0, 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  SongsCollectionViewCell.identifier, for: indexPath) as! SongsCollectionViewCell

            cell.configure(with: Songs.list[indexPath.section][indexPath.item])
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyMusicStationCell.identifier, for: indexPath) as! MyMusicStationCell

            cell.configure(with: Songs.list[indexPath.section][indexPath.item])
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongsCollectionViewCell", for: indexPath) as! SongsCollectionViewCell

            cell.configure(with: Songs.list[indexPath.section][indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyHeaderView", for: indexPath) as! MyHeaderFooterView
            
            switch indexPath.section {
            case 0:
                headerView.label.text = "Songs"
            case 1:
                headerView.label.text = "Album"
            default:
                headerView.label.text = "Other Section"
            }
            
            return headerView
            
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyFooterView", for: indexPath) as! MyHeaderFooterView
            
            switch indexPath.section {
            case 0:
                footerView.label.text = "Songs"
            case 1:
                footerView.label.text = "Album"
            default:
                footerView.label.text = "Other Section"
            }
            
            return footerView
        } else {
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if playerfpc.state == .hidden {
            openFloatingPanel(indexPath: indexPath)
        } else {
            playerfpc.willMove(toParent: nil)
            // Remove the floating panel view from your controller's view.
            self.playerfpc.view.removeFromSuperview()
            // Remove the floating panel controller from the controller hierarchy.
            self.playerfpc.removeFromParent()
            
            openFloatingPanel(indexPath: indexPath)
        }
    }
    
}

// MARK: - Extension ViewController
extension ViewController {
    
    private func openFloatingPanel(indexPath: IndexPath) {
        let contentVC = MusicPlayerViewController()
        
        contentVC.artist = "\(Songs.list[indexPath.section][indexPath.row].title)"
        print(contentVC.artist)
        
        playerfpc.set(contentViewController: contentVC)
        
        playerfpc.layout = MusicFloatingPanelLayout()
        playerfpc.invalidateLayout() // if needed
        
        playerfpc.delegate = contentVC
        
        playerfpc.isRemovalInteractionEnabled = false
        playerfpc.surfaceView.grabberHandle.isHidden = true
        
        playerfpc.surfaceView.backgroundColor = .black
        
        playerfpc.addPanel(toParent: self, animated: true)
    }
    
    private func openFloatingPanelWithCoreData() {
        
        let contentVC = MusicPlayerViewController()
        
        playerfpc.set(contentViewController: contentVC)
        
        playerfpc.layout = MusicWithCoreDataFloatingPanelLayout()
        playerfpc.invalidateLayout() // if needed
        
        playerfpc.delegate = contentVC
        
        playerfpc.isRemovalInteractionEnabled = false
        playerfpc.surfaceView.grabberHandle.isHidden = true
        
        playerfpc.surfaceView.backgroundColor = .black
        
        playerfpc.addPanel(toParent: self, animated: true)
    }
    
    // layout
    private static func getLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            
            switch section {
            case 0:
                
                // item
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(0.5)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 6, bottom: 0, trailing: 6)
                
                // group
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.31),
                    heightDimension: .fractionalHeight(0.45)
                )
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 2)
                
                // section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                section.orthogonalScrollingBehavior = .continuous
                
                // header / footer
                let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100.0))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerFooterSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                return section
            case 1:
                // item
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 6, bottom: 12, trailing: 6)
                
                // group
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.465),
                    heightDimension: .fractionalWidth(0.55)
                )
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                // section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                section.orthogonalScrollingBehavior = .continuous
                
                // header / footer
                let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100.0))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerFooterSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                return section
            case 2:
                // item
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 6, bottom: 12, trailing: 6)
                
                // group
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1/4)
                )
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                // section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                section.orthogonalScrollingBehavior = .none
                
                
                // header / footer
                let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100.0))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerFooterSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                return section
            default:
                // item
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .fractionalHeight(1/3)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
                
                // group
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(0.6)
                )
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 3)
                
                // section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                section.orthogonalScrollingBehavior = .continuous
                
                // header / footer
                let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100.0))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerFooterSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerFooterSize,
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )
                section.boundarySupplementaryItems = [header, footer]
                
                return section
            }
        }
        return layout
    }
}

extension ViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        if fpc.state == .tip {
            fpc.isRemovalInteractionEnabled = true
        } else {
            fpc.isRemovalInteractionEnabled = false
        }
    }
    
    func floatingPanelWillRemove(_ fpc: FloatingPanelController) {
        // Inform the panel controller that it will be removed from the hierarchy.
        fpc.willMove(toParent: nil)
            
        // Hide the floating panel.
        fpc.hide(animated: true) {
            // Remove the floating panel view from your controller's view.
            fpc.view.removeFromSuperview()
            // Remove the floating panel controller from the controller hierarchy.
            fpc.removeFromParent()
        }
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        Container().edgesIgnoringSafeArea(.all)
//    }
//    struct Container: UIViewControllerRepresentable {
//        func makeUIViewController(context: Context) -> UIViewController {
//            return     UINavigationController(rootViewController: ViewController())
//        }
//        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        }
//        typealias  UIViewControllerType = UIViewController
//    }
//}
