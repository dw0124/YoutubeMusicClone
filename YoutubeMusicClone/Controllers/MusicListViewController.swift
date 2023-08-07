//
//  MusicListTableViewController.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/19.
//

import UIKit
import Foundation
import SnapKit

class MusicListViewController: UIViewController {
    
    var musicListTableView = UITableView()
    var musicEntityList = [MusicEntity]()
    var checkEvent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicListTableView.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        musicListTableView.register(MusicListTableViewCell.self, forCellReuseIdentifier: MusicListTableViewCell.identifier)
        
        musicListTableView.delegate = self
        musicListTableView.dataSource = self
        musicListTableView.dragInteractionEnabled = true
        musicListTableView.dragDelegate = self
        musicListTableView.dropDelegate = self
        
        view.addSubview(musicListTableView)
        
        musicListTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        MusicPlayerSingleton.shared.music.bind { music in
            DispatchQueue.main.async {
                self.musicListTableView.reloadData()
                
                if self.checkEvent == false {
                    self.fetchAndSaveMusicList()
                }
            }
        }
        
        //fetchAndSaveMusicList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNextMusicPlayed), name: .nextMusicPlayed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePrevMusicPlayed), name: .prevMusicPlayed, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func fetchAndSaveMusicList() {
        DataManager.shared.deleteAll()
        
        guard let musicResult = MusicPlayerSingleton.shared.music.value?.results else {
            return
        }
        
        DataManager.shared.createMusicListList(musicList: musicResult) {
            self.musicEntityList = DataManager.shared.fetchMusicList()
        }
    }
    
    @objc func handleNextMusicPlayed() {
        print(#function)
        
        musicListTableView.selectRow(at: IndexPath(row: MusicPlayerSingleton.shared.currentIndex, section: 0), animated: true, scrollPosition: .top)
        
        musicListTableView.cellForRow(at: IndexPath(row: MusicPlayerSingleton.shared.currentIndex - 1, section: 0))?.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        
        musicListTableView.cellForRow(at: IndexPath(row: MusicPlayerSingleton.shared.currentIndex, section: 0))?.backgroundColor = .darkGray
    }
    
    @objc func handlePrevMusicPlayed() {
        print(#function)
        
        musicListTableView.selectRow(at: IndexPath(row: MusicPlayerSingleton.shared.currentIndex, section: 0), animated: true, scrollPosition: .top)
        
        musicListTableView.cellForRow(at: IndexPath(row: MusicPlayerSingleton.shared.currentIndex + 1, section: 0))?.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        
        musicListTableView.cellForRow(at: IndexPath(row: MusicPlayerSingleton.shared.currentIndex, section: 0))?.backgroundColor = .darkGray
    }
}

extension MusicListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicPlayerSingleton.shared.music.value?.results.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = musicListTableView.dequeueReusableCell(withIdentifier: MusicListTableViewCell.identifier) as? MusicListTableViewCell else {
            return UITableViewCell()
        }
        
        guard let value = MusicPlayerSingleton.shared.music.value else {
            return UITableViewCell()
        }
        
        cell.singerLabel.text = value.results[indexPath.row].artistName
        cell.titleLabel.text = value.results[indexPath.row].trackName
        cell.titleLabel.textColor = .white
        cell.imageView?.image = nil
        
        if let url = URL(string: value.results[indexPath.row].artworkUrl100) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.musicImageView.image = image
                    }
                }
            }
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

extension MusicListViewController: UITableViewDelegate {
    
    // didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        musicListTableView.cellForRow(at: IndexPath(row: MusicPlayerSingleton.shared.currentIndex, section: 0))?.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        
        MusicPlayerSingleton.shared.didSelectedMusicAt(indexPath: indexPath.row)
        musicListTableView.cellForRow(at: IndexPath(row: MusicPlayerSingleton.shared.currentIndex, section: 0))?.backgroundColor = .darkGray
        
        MusicPlayerSingleton.shared.isPlaying.value = true
        
        musicListTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    // trailingSwipeActionsConfigurationForRowAt
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { action, view, completion in
            completion(true)
            MusicPlayerSingleton.shared.removeMusicAt(indexPath: indexPath.row)
            
            let willDeleteMusic = self.musicEntityList.remove(at: indexPath.row)
            DataManager.shared.delete(entity: willDeleteMusic)
            
            self.musicListTableView.reloadData()
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print(MusicPlayerSingleton.shared.currentIndex)
        
        // 셀 위치 변경 후 다음곡을 재생할때 다음곡이 아닌 노래가 재생되는 현상 수정
        if var music = MusicPlayerSingleton.shared.music.value {
            let movedMusic = music.results.remove(at: sourceIndexPath.row)
            music.results.insert(movedMusic, at: destinationIndexPath.row)
            MusicPlayerSingleton.shared.music.value = music
            
            if MusicPlayerSingleton.shared.currentIndex == sourceIndexPath.row {
                MusicPlayerSingleton.shared.currentIndex = destinationIndexPath.row
            }
        }

        let firstEntity = self.musicEntityList[sourceIndexPath.row]
        let secondEntity = self.musicEntityList[destinationIndexPath.row]
        DataManager.shared.swapMusicEntity(firstEntity: firstEntity, secondEntity: secondEntity, soureIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
        let movedMusicEntity = self.musicEntityList.remove(at: sourceIndexPath.row)
        self.musicEntityList.insert(movedMusicEntity, at: destinationIndexPath.row)
        
        
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
}

extension MusicListViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        //dragItem.localObject = list[indexPath.row]
        //print(dragItem.localObject)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        print(coordinator.items)
    }
}
